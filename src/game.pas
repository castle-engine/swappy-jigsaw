{ Copyright (C) 2018-2026 Yevhen Loza, Michalis Kamburelis

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>. }

{ --------------------------------------------------------------------------- }

(* Main unit of the game, all the gameplay happens "here"
   Handles mouse clicks, shuffling, swapping tiles,
   determines victory conditions, loads images, etc. *)

unit Game;
{$INCLUDE compilerconfig.inc}

interface

uses
  SysUtils, Classes,
  CastleWindow, CastleKeysMouse,
  CastleVectors, CastleGLUtils, CastleColors, CastleMessages, CastleUiControls,
  CastleRectangles, CastleImages, CastleGLImages, CastleRenderContext,
  {$IFDEF AndroidVibrate}CastleOpenDocument,{$ENDIF}
  Global, GUI,
  StarFallUnit, DrawBatched3x3,
  ImageList, WindowUnit, SelectImage, Settings, SoundMusic,
  DecoLog;

type
  TViewGame = class(TCastleView)
  private
    type
      TMyFloatRectangleArray = packed array of TFloatRectangle;
    var
      { Image, currently being solved }
      Image: TDrawableImage;
      { Selected tile ID }
      Selected: Integer;
      { Is the Hint image currently being shown? }
      ShowHint: Boolean;
      { Has the game been started? Is it over with victory? }
      GameStarted, Victory: Boolean;
      { Rectangles of shuffled and unshuffled images }
      JigCount: Integer;
      JigsawRects, ScreenRects: TMyFloatRectangleArray; //TFloatRectangleArray;
      { Rectangles of wronly placed image tiles }
      WrongRects: TMyFloatRectangleArray;
      { Victory effect - stars falling down }
      StarFall: TStarFallEffect;
      { Last image (i.e. current image) loaded. }
      CurrentImage: Integer;

    function GetLinearCoord(const A: TVector2Integer): Integer;
    function IsTileWrong(const ScreenLinearCoordinates: Integer): Boolean;
    function IsTileWrong(const ScreenCoordinates: TVector2Integer): Boolean;
    procedure SwapTiles(const A, B: TVector2Integer);
    procedure SwapTiles(const A, B: Integer);
    procedure StartVictory;
    procedure EndVictory;
    procedure DoVictory;
    function WrongTilesCount: Integer;
    function IsGameOver: Boolean;
    procedure Shuffle;
    procedure ClickForwardButton;
    procedure ClickHintButton;
    procedure ReleaseHintButton;
    procedure ClickExit;
    function GetScreenTile(X, Y: Single): Integer;
    procedure NewGame;
  public
    { Start a new game with a specified ImageID. -1 for random image.
      Set this before Start.
      Pay attention, ImageID meaning is changed every time image list is sorted. }
    AImageID: Integer;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Start; override;
    procedure Render; override;
    function Press(const Event: TInputPressRelease): Boolean; override;
    function Release(const Event: TInputPressRelease): Boolean; override;
  end;

var
  ViewGame: TViewGame;

implementation

{----------------------------------------------------------------------------}

function TViewGame.GetLinearCoord(const A: TVector2Integer): Integer;
begin
  Result := A[0] + A[1] * SlicesX;
end;

{----------------------------------------------------------------------------}

function TViewGame.IsTileWrong(const ScreenLinearCoordinates: Integer): Boolean;
begin
  Result := (Abs(JigsawRects[ScreenLinearCoordinates].Bottom - ScreenRects[ScreenLinearCoordinates].Bottom + ImageStartBottom) > ScaleY / 2) or
            (Abs(JigsawRects[ScreenLinearCoordinates].Left - ScreenRects[ScreenLinearCoordinates].Left + ImageStartLeft) > ScaleX / 2);
end;

function TViewGame.IsTileWrong(const ScreenCoordinates: TVector2Integer): Boolean;
begin
  Result := IsTileWrong(GetLinearCoord(ScreenCoordinates));
end;

{----------------------------------------------------------------------------}

procedure TViewGame.SwapTiles(const A, B: TVector2Integer);
var
  R: TFloatRectangle;
begin
  R := ScreenRects[GetLinearCoord(A)];
  ScreenRects[GetLinearCoord(A)] := ScreenRects[GetLinearCoord(B)];
  ScreenRects[GetLinearCoord(B)] := R;
  {$IFDEF AndroidVibrate}
  if GameStarted and not Victory and DoVibrate and
    ((not IsTileWrong(A)) or (not IsTileWrong(B))) then
    Vibrate(100);
  {$ENDIF}
end;

procedure TViewGame.SwapTiles(const A, B: Integer);
var
  R: TFloatRectangle;
begin
  R := ScreenRects[A];
  ScreenRects[A] := ScreenRects[B];
  ScreenRects[B] := R;
  {$IFDEF AndroidVibrate}
  if GameStarted and not Victory and DoVibrate and
    ((not IsTileWrong(A)) or (not IsTileWrong(B))) then
    Vibrate(100);
  {$ENDIF}
end;

{----------------------------------------------------------------------------}

procedure TViewGame.StartVictory;
begin
  //increase image score
  Inc(ImageDataList[CurrentImage].Hits);
  SaveConfig;
  //prepare Window for rendering victory effect
  Window.AutoRedisplay := true;
  StarFall.Start;
  {$IFDEF Android}
  if DoVibrate then
    Vibrate(500);
  {$ENDIF}
end;

procedure TViewGame.EndVictory;
begin
  StarFall.Stop;
  //return window in low-resources mode
  Window.AutoRedisplay := false;
  Window.Invalidate;
end;

{----------------------------------------------------------------------------}

{this procedure happens inside Render event, so rendering can be done here
 Moreover, it renders the last, i.e. on top of all other elements.}
procedure TViewGame.DoVictory;
var
  h: Boolean;
begin
  h := false;
  StarFall.Update(0, h);
  StarFall.Render;

  //if the victory animation is finished, stop victory effect
  if not StarFall.Active then
    EndVictory;
end;

{----------------------------------------------------------------------------}

function TViewGame.WrongTilesCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Pred(JigCount) do
    if IsTileWrong(I) then
      Inc(Result);
end;

function TViewGame.IsGameOver: Boolean;
var
  I: Integer;
begin
  Result := true;
  for I := 0 to Pred(JigCount) do
    Result := Result and (not IsTileWrong(I));

  if (not Victory) and Result then
  begin
    Victory := true;
    StartVictory;
  end;
end;

{----------------------------------------------------------------------------}

procedure TViewGame.Render;
var
  I, Ix, Iy: Integer;

  Count: Integer;
begin
  inherited;

  CheckMusic; //check if the music has finished and load a new one

  RenderContext.Clear([cbColor], Black);

  if ShowHint then
    Image.Draw(ImageStartLeft, ImageStartBottom, ImageWidth, ImageHeight)
  else begin

    Image.Draw(@ScreenRects[0], @JigsawRects[0], JigCount);

    I := 0;

    Count := 0;
    for Ix := 0 to Pred(SlicesX) do
      for Iy := 0 to Pred(SlicesY) do
      begin
        if IsTileWrong(I) then
        begin
          WrongRects[Count] := ScreenRects[I];
          Inc(Count);
        end;
        Inc(I);
      end;
    BlackBorder.Draw3x3Batched(@WrongRects[0], Count, 5, 5, 5, 5);

    if Selected >= 0 then
      WhiteBorder.Draw3x3(ScreenRects[Selected], Vector4Integer(5, 5, 5, 5));
  end;

  {DRAW UI}

  GameScreenLeft.Draw3x3(WindowLeft, WindowBottom, GameWidth, WindowHeight, 19, 19, 19, 19);
  GameScreenRight.Draw3x3(MenuBarLeft, WindowBottom, MenuBarWidth, WindowHeight, 19, 9, 19, 0);

  Buttons.Draw(FloatRectangle(MenuBarLeft, WindowBottom + ButtonSpacer * 3.5 - ButtonSize / 2, ButtonSize, ButtonSize),
    ButtonForward);
  Buttons.Draw(FloatRectangle(MenuBarLeft, WindowBottom + ButtonSpacer * 2.5 - ButtonSize / 2, ButtonSize, ButtonSize),
    ButtonHint);
  if PlaySound then
    Buttons.Draw(FloatRectangle(MenuBarLeft, WindowBottom + ButtonSpacer * 1.5 - ButtonSize / 2, ButtonSize, ButtonSize),
      ButtonSoundOn)
  else
    Buttons.Draw(FloatRectangle(MenuBarLeft, WindowBottom + ButtonSpacer * 1.5 - ButtonSize / 2, ButtonSize, ButtonSize),
      ButtonSoundOff);
  Buttons.Draw(FloatRectangle(MenuBarLeft, WindowBottom + ButtonSpacer * 0.5 - ButtonSize / 2, ButtonSize, ButtonSize),
    ButtonMenu);

  if Victory then
    DoVictory;
end;

{----------------------------------------------------------------------------}

function TViewGame.GetScreenTile(X, Y: Single): Integer;
var
  I: Integer;
begin
  if X <= ImageStartLeft then
    X := ImageStartLeft + 1
  else
  if X >= ImageStartLeft + ImageWidth then
    X := ImageStartLeft + ImageWidth - 1;

  if Y <= ImageStartBottom then
    Y := ImageStartBottom + 1
  else
  if Y >= ImageStartBottom + ImageHeight then
    Y := ImageStartBottom + ImageHeight - 1;

  for I := 0 to Pred(JigCount) do
    if ScreenRects[I].Contains(X, Y) then
    begin
      Result := I;
      Exit;
    end;

  //error, can't find sreen tile
  DecoLog.Log(CurrentRoutine, 'Error: Can''t find sreen tile at (' + FloatToStr(X) + ',' + FloatToStr(Y) + ') in ' + IntToStr(ImageStartLeft) + '..' + IntToStr(ImageStartLeft + ImageWidth) + ',' + IntToStr(ImageStartBottom) + '..' + IntToStr(ImageStartBottom + ImageHeight));
  Result := -1; //so that result is always defined
end;

{----------------------------------------------------------------------------}

procedure TViewGame.Shuffle;
var
  I: Integer;
begin
  //shuffle the jigsaw pieces
  repeat
    for I := Pred(JigCount) downto 1 do
      SwapTiles(I, RND.Random(I));
  until WrongTilesCount > JigCount - 2; //only one tile is allowed to be in place after shuffle

  //prepare for game
  Selected := -1;
  Window.Invalidate;
  GameStarted := false;
  Victory := false;
end;

{----------------------------------------------------------------------------}

procedure TViewGame.ClickForwardButton;
begin
  if (IsGameOver) or (not GameStarted) or
     (MessageYesNo(Window, 'Current progress will be lost, load next image?')) then
  begin
    AImageId := -1;
    NewGame;
  end;
end;

procedure TViewGame.ClickHintButton;
begin
  ShowHint := true;
end;

procedure TViewGame.ReleaseHintButton;
begin
  ShowHint := false;
  Window.Invalidate;
end;

procedure TViewGame.ClickExit;
begin
  if (IsGameOver) or (not GameStarted) or
     (MessageYesNo(Window, 'Current progress will be lost, exit to menu?')) then
    Container.View := ViewImageSelector;
end;

{----------------------------------------------------------------------------}

function TViewGame.Press(const Event: TInputPressRelease): Boolean;
var
  Pos: Integer;
begin
  Result := inherited;
  if Result then Exit;

  if (Event.EventType = itMouseButton) then
  begin
    Window.Invalidate;
    if Event.Position[0] <= MenuBarLeft then
    begin
      Pos := GetScreenTile(Event.Position[0], Event.Position[1]);

      //if something went badly wrong, then
      if Pos = -1 then
        Exit;

      if IsTileWrong(Pos) then
      begin
        if Selected = -1 then
          Selected := Pos
        else
        begin
          SwapTiles(Selected, Pos);
          GameStarted := true;
          Selected := -1;
          if isGameOver then
            DecoLog.Log(CurrentRoutine, 'Image solved!');
        end;
      end;
    end else
    begin
      if Event.Position[1] < ButtonSpacer then
        ClickExit
      else
      if Event.Position[1] < ButtonSpacer * 2 then
        ToggleSound
      else
      if Event.Position[1] < ButtonSpacer * 3 then
        ClickHintButton
      else
        ClickForwardButton;
    end;
  end;
end;

function TViewGame.Release(const Event: TInputPressRelease): Boolean;
begin
  Result := inherited;
  if Result then Exit;

  //now the only release event we catch is after ShowHint
  if ShowHint and (Event.EventType = itMouseButton) then
  begin
    ReleaseHintButton;
    Result := true;
  end;
end;

{----------------------------------------------------------------------------}

procedure TViewGame.Start;
begin
  inherited;
  NewGame;
end;

procedure TViewGame.NewGame;

  function Img(const aURL: String): String;
  begin
    Result := 'castle-data:/img/' + aURL;
  end;

var
  Ix, Iy: Integer;
  NextImagesCount: Integer;
begin
  inherited;

  EndVictory;

  if AImageID = -1 then
  begin
    NextImagesCount := SortListCount;  //image list is sorted only here, so it's perfectly safe to use CurrentImage as image reference
    CurrentImage := RND.Random(NextImagesCount);
  end else
    CurrentImage := AImageID;

  //increase image shows
  Inc(ImageDataList[CurrentImage].Shows);

  //NewImage := Pred(ImageDataList.Count);

  FreeAndNil(Image);
  Image := TDrawableImage.Create(Img(ImageDataList[CurrentImage].URL), [TRGBImage], ImageWidth, ImageHeight, riLanczos);
  DecoLog.Log(CurrentRoutine, 'New image: ' + ImageDataList[CurrentImage].URL);

  JigCount := 0;
  SetLength(JigsawRects, SlicesX * SlicesY);
  SetLength(ScreenRects, SlicesX * SlicesY);
  for Iy := 0 to Pred(SlicesY) do
    for Ix := 0 to Pred(SlicesX) do
    begin
      JigsawRects[JigCount] := FloatRectangle(Ix * ScaleX, Iy * ScaleY, ScaleX, ScaleY);
      ScreenRects[JigCount] := FloatRectangle(ImageStartLeft + Ix * ScaleX,
        ImageStartBottom + Iy * ScaleY, ScaleX, ScaleY);
      Inc(JigCount); //JigCount should be last index + 1, as it's meaning is "count"
    end;
  SetLength(WrongRects, JigCount); //we don't care about it's current length, Count will do its job

  Shuffle;
end;

{----------------------------------------------------------------------------}

constructor TViewGame.Create(AOwner: TComponent);
begin
  inherited;
  StarFall := TStarFallEffect.Create(nil);
  StarFall.URL := 'castle-data:/Star.png';
  StarFall.Duration := 1.5; //=default
  StarFall.Number := 250; //=default
  StarFall.Width := Window.Width;
  StarFall.Height := Window.Height;

  CurrentImage := -1;
end;

{----------------------------------------------------------------------------}

destructor TViewGame.Destroy;
begin
  EndVictory;
  FreeAndNil(Image);
  StarFall.Free;
  inherited;
end;

end.

