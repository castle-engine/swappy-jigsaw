{ Copyright (C) 2018 Yevhen Loza

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

{ Start a new game with a specified ImageID
  (Pay attention, ImageID is changed after every NewGame as image list is sorted) }
procedure NewGame(const AImageID: Integer = -1);
{ Init/release game events and game-specific objects }
procedure InitGame;
procedure FreeGame;
{...........................................................................}
implementation
uses
  SysUtils,
  CastleFilesUtils, CastleWindow, CastleKeysMouse,
  CastleVectors,
  CastleGLUtils, CastleColors,
  CastleMessages,
  CastleRectangles, CastleImages, CastleGLImages,
  {$IFDEF AndroidVibrate}CastleOpenDocument,{$ENDIF}
  Global, GUI,
  StarFallUnit, DrawBatched3x3,
  ImageList, WindowUnit, SelectImage, Settings, SoundMusic,
  DecoLog;

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
  CurrentImage: Integer = -1;

{----------------------------------------------------------------------------}

function GetLinearCoord(const A: TVector2Integer): Integer;
begin
  Result := A[0] + A[1] * SlicesX;
end;

{----------------------------------------------------------------------------}

function IsTileWrong(const ScreenLinearCoordinates: Integer): Boolean;
begin
  Result := (Abs(JigsawRects[ScreenLinearCoordinates].Bottom - ScreenRects[ScreenLinearCoordinates].Bottom + ImageStartBottom) > ScaleY / 2) or
            (Abs(JigsawRects[ScreenLinearCoordinates].Left - ScreenRects[ScreenLinearCoordinates].Left + ImageStartLeft) > ScaleX / 2);
end;

function IsTileWrong(const ScreenCoordinates: TVector2Integer): Boolean;
begin
  Result := IsTileWrong(GetLinearCoord(ScreenCoordinates));
end;

{----------------------------------------------------------------------------}

procedure SwapTiles(const A, B: TVector2Integer);
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

procedure SwapTiles(const A, B: Integer);
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

procedure StartVictory;
begin
  //increase image score
  inc(ImageDataList[CurrentImage].Hits);
  SaveConfig;
  //prepare Window for rendering victory effect
  Window.AutoRedisplay := true;
  StarFall.Start;
  {$IFDEF Android}
  if DoVibrate then
    Vibrate(500);
  {$ENDIF}
end;

procedure EndVictory;
begin
  StarFall.Stop;
  //return window in low-resources mode
  Window.AutoRedisplay := false;
  Window.Invalidate;
end;

{----------------------------------------------------------------------------}

{this procedure happens inside Window.onRender event, so rendering can be done here
 Moreover, it renders the last, i.e. on top of all other elements.}
procedure DoVictory;
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

function WrongTilesCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Pred(JigCount) do
    if IsTileWrong(i) then
      inc(Result);
end;

function IsGameOver: Boolean;
var
  i: Integer;
begin
  Result := true;
  for i := 0 to Pred(JigCount) do
    Result := Result and (not IsTileWrong(i));

  if (not Victory) and Result then
  begin
    Victory := true;
    StartVictory;
  end;
end;

{----------------------------------------------------------------------------}

{$PUSH}{$WARN 5024 off : Parameter "$1" not used}
procedure GameRender(Container: TUIContainer);
var
  i, ix, iy: Integer;

  Count: Integer;
begin
  CheckMusic; //check if the music has finished and load a new one

  RenderContext.Clear([cbColor], Black);

  if ShowHint then
    Image.Draw(ImageStartLeft, ImageStartBottom, ImageWidth, ImageHeight)
  else begin

    Image.Draw(@ScreenRects[0], @JigsawRects[0], JigCount);

    i := 0;

    Count := 0;
    for ix := 0 to Pred(SlicesX) do
      for iy := 0 to Pred(SlicesY) do
      begin
        if IsTileWrong(i) then
        begin
          WrongRects[Count] := ScreenRects[i];
          inc(Count);
        end;
        inc(i);
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

function GetScreenTile(X, Y: Single): Integer;
var
  i: Integer;
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

  for i := 0 to Pred(JigCount) do
    if ScreenRects[i].Contains(X, Y) then
    begin
      Result := i;
      Exit;
    end;

  //error, can't find sreen tile
  Log(CurrentRoutine, 'Error: Can''t find sreen tile at (' + FloatToStr(X) + ',' + FloatToStr(Y) + ') in ' + IntToStr(ImageStartLeft) + '..' + IntToStr(ImageStartLeft + ImageWidth) + ',' + IntToStr(ImageStartBottom) + '..' + IntToStr(ImageStartBottom + ImageHeight));
  Result := -1; //so that result is always defined
end;

{----------------------------------------------------------------------------}

procedure Shuffle;
var
  i: Integer;
begin
  //shuffle the jigsaw pieces
  repeat
    for i := Pred(JigCount) downto 1 do
      SwapTiles(i, RND.Random(i));
  until WrongTilesCount > JigCount - 2; //only one tile is allowed to be in place after shuffle

  //prepare for game
  Selected := -1;
  Window.Invalidate;
  GameStarted := false;
  Victory := false;
end;

{----------------------------------------------------------------------------}

procedure ClickForwardButton;
begin
  if (IsGameOver) or (not GameStarted) or
     (MessageYesNo(Window, 'Current progress will be lost, load next image?')) then
    NewGame;
end;

procedure ClickHintButton;
begin
  ShowHint := true;
end;

procedure ReleaseHintButton;
begin
  ShowHint := false;
  Window.Invalidate;
end;

procedure ClickExit;
begin
  if (IsGameOver) or (not GameStarted) or
     (MessageYesNo(Window, 'Current progress will be lost, exit to menu?')) then
    ShowImageSelector;
end;

{----------------------------------------------------------------------------}

procedure GamePress(Container: TUIContainer; const Event: TInputPressRelease);
var
  Pos: Integer;
begin
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
            Log(CurrentRoutine, 'Image solved!');
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

procedure GameRelease(Container: TUIContainer; const Event: TInputPressRelease);
begin
  //now the only release event we catch is after ShowHint
  if ShowHint and (Event.EventType = itMouseButton) then
    ReleaseHintButton;
end;
{$POP}

{----------------------------------------------------------------------------}

procedure NewGame(const AImageID: Integer = -1);
  function Img(const aURL: String): String;
  begin
    Result := ApplicationData('img/' + aURL);
  end;
var
  ix, iy: Integer;
  NextImagesCount: Integer;
begin
  Window.OnRender := @GameRender;
  Window.OnPress := @GamePress;
  Window.OnRelease := @GameRelease;

  EndVictory;

  if AImageID = -1 then
  begin
    NextImagesCount := SortListCount;  //image list is sorted only here, so it's perfectly safe to use CurrentImage as image reference
    CurrentImage := RND.Random(NextImagesCount);
  end else
    CurrentImage := AImageID;

  //increase image shows
  inc(ImageDataList[CurrentImage].Shows);

  //NewImage := Pred(ImageDataList.Count);

  FreeAndNil(Image);
  Image := TDrawableImage.Create(Img(ImageDataList[CurrentImage].URL), [TRGBImage], ImageWidth, ImageHeight, riLanczos);
  Log(CurrentRoutine, 'New image: ' + ImageDataList[CurrentImage].URL);

  JigCount := 0;
  SetLength(JigsawRects, SlicesX * SlicesY);
  SetLength(ScreenRects, SlicesX * SlicesY);
  for iy := 0 to Pred(SlicesY) do
    for ix := 0 to Pred(SlicesX) do
    begin
      JigsawRects[JigCount] := FloatRectangle(ix * ScaleX, iy * ScaleY, ScaleX, ScaleY);
      ScreenRects[JigCount] := FloatRectangle(ImageStartLeft + ix * ScaleX,
        ImageStartBottom + iy * ScaleY, ScaleX, ScaleY);
      inc(JigCount); //JigCount should be last index + 1, as it's meaning is "count"
    end;
  SetLength(WrongRects, JigCount); //we don't care about it's current length, Count will do its job

  Shuffle;
end;

{----------------------------------------------------------------------------}

procedure InitGame;
begin
  StarFall := TStarFallEffect.Create(nil);
  StarFall.URL := ApplicationData('Star.png');
  StarFall.Duration := 1.5; //=default
  StarFall.Number := 250; //=default
  StarFall.Left := 0;
  StarFall.Bottom := 0;
  StarFall.Width := Window.Width;
  StarFall.Height := Window.Height;
end;

{----------------------------------------------------------------------------}

procedure FreeGame;
begin
  EndVictory;

  Window.OnRender := nil;
  Window.OnPress := nil;
  Window.OnRelease := nil;

  FreeAndNil(Image);
  StarFall.Free;
end;

end.

