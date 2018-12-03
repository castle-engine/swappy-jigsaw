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

(* {} *)

unit Game;
{$INCLUDE compilerconfig.inc}

interface

uses
  WindowUnit;

procedure NewGame;

procedure InitGame;
procedure FreeGame;
implementation
uses
  SysUtils,
  CastleFilesUtils, CastleWindow, CastleKeysMouse,
  CastleVectors,
  CastleRectangles, CastleImages, CastleGLImages,
  Global,
  DecoLog;

type
  TMyFloatRectangleArray = packed array of TFloatRectangle;

var
  {}
  SlicesX: Integer = 8;
  SlicesY: Integer = 5;

var
  {}
  Image: TGLImage;
  {}
  ImageStartLeft, ImageStartBottom, ImageWidth, ImageHeight: Integer;
  ScaleX, ScaleY: Single;
  {}
  GameScreenRight, GameScreenLeft: TGLImage;
  MenuBarLeft, MenuBarWidth: Integer;
  {}
  WhiteBorder, BlackBorder: TGlImage;
  {}
  Selected: Integer;
  {}
  JigCount: Integer;
  JigsawRects, ScreenRects: TMyFloatRectangleArray; //TFloatRectangleArray;
  {}
  WrongRects: TMyFloatRectangleArray;
  {}
  ButtonForward, ButtonRestart, ButtonSoundOn, ButtonSoundOff, ButtonExit: TGLImage;
  ButtonSize, ButtonSpacer: Integer;


function GetLinearCoord(const A: TVector2Integer): Integer;
begin
  Result := A[0] + A[1] * SlicesX;
end;

procedure SwapTiles(const A, B: TVector2Integer);
var
  R: TFloatRectangle;
begin
  R := ScreenRects[GetLinearCoord(A)];
  ScreenRects[GetLinearCoord(A)] := ScreenRects[GetLinearCoord(B)];
  ScreenRects[GetLinearCoord(B)] := R;
end;

procedure SwapTiles(const A, B: Integer);
var
  R: TFloatRectangle;
begin
  R := ScreenRects[A];
  ScreenRects[A] := ScreenRects[B];
  ScreenRects[B] := R;
end;

function IsTileWrong(const ScreenLinearCoordinates: Integer): Boolean;
begin
  Result := (Abs(JigsawRects[ScreenLinearCoordinates].Bottom - ScreenRects[ScreenLinearCoordinates].Bottom) > ScaleY / 2) or
            (Abs(JigsawRects[ScreenLinearCoordinates].Left - ScreenRects[ScreenLinearCoordinates].Left) > ScaleX / 2);
end;

function IsTileWrong(const ScreenCoordinates: TVector2Integer): Boolean;
begin
  Result := IsTileWrong(GetLinearCoord(ScreenCoordinates));
end;

function IsGameOver: Boolean;
var
  i: Integer;
begin
  Result := true;
  for i := 0 to Pred(JigCount) do
    Result := Result and (not IsTileWrong(i));
end;

{$INCLUDE GLImageHelper.inc}

{$PUSH}{$WARN 5024 off : Parameter "$1" not used}
procedure GameRender(Container: TUIContainer);
var
  i, ix, iy: Integer;

  Count: Integer;
begin
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
  BlackBorder.Draw3x3Batched(@WrongRects[0], Count, 15, 15, 15, 15);

  if Selected >= 0 then
    WhiteBorder.Draw3x3(ScreenRects[Selected], Vector4Integer(15, 15, 15, 15));

  {DRAW UI}

  GameScreenLeft.Draw3x3(0, 0, MenuBarLeft, Window.Height, 19, 19, 19, 19);
  GameScreenRight.Draw3x3(MenuBarLeft, 0, MenuBarWidth, Window.Height, 19, 9, 19, 0);

  ButtonForward.Draw(MenuBarLeft, ButtonSpacer * 3.5 - ButtonSize / 2, ButtonSize, ButtonSize);
  ButtonRestart.Draw(MenuBarLeft, ButtonSpacer * 2.5 - ButtonSize / 2, ButtonSize, ButtonSize);
  ButtonSoundOn.Draw(MenuBarLeft, ButtonSpacer * 1.5 - ButtonSize / 2, ButtonSize, ButtonSize);
  //ButtonSoundOff.Draw(MenuBarLeft, ButtonSpacer * 1.5 - ButtonSize / 2, ButtonSize, ButtonSize);
  ButtonExit.Draw(MenuBarLeft, ButtonSpacer * 0.5 - ButtonSize / 2, ButtonSize, ButtonSize);
end;

{function ScreenToCoord(X, Y: Single): TVector2Integer;
begin
  Result[0] := Trunc((X - ImageStartLeft) / ScaleX);
  Result[1] := Trunc((Y - ImageStartBottom) / ScaleY);

  //fix screen coordinates
  if Result[0] < 0 then
    Result[0] := 0
  else
    if Result[0] >= SlicesX then
      Result[0] := Pred(SlicesX);
  if Result[1] < 0 then
    Result[1] := 0
  else
    if Result[1] >= SlicesY then
      Result[1] := Pred(SlicesY);
end;

function GetScreenTile(ScreenCoordinates: TVector2Integer): TVector2Integer;
var
  i: Integer;
  Jig: TFloatRectangle;
begin
  Jig := JigsawRects[GetLinearCoord(ScreenCoordinates)];
  for i := 0 to Pred(JigCount) do
    if (Abs(Jig.Bottom - ScreenRects[i].Bottom) < ScaleY / 2) or
       (Abs(Jig.Left - ScreenRects[i].Left) < ScaleX / 2) then
    begin
      Result := ScreenToCoord(JigsawRects[i].Left + ScaleX / 2, JigsawRects[i].Bottom + ScaleY / 2);
      Exit;
    end;
end;}

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
  if Y >= ImageStartBottom + ImageWidth then
    Y := ImageStartBottom + ImageWidth - 1;

  for i := 0 to Pred(JigCount) do
    if ScreenRects[i].Contains(X, Y) then
    begin
      Result := i;
      Exit;
    end;
end;

procedure GamePress(Container: TUIContainer; const Event: TInputPressRelease);
var
  Pos: Integer;
begin
  if (Event.EventType = itMouseButton) {and (Event.MouseButton = mbLeft)} then
  begin
    Window.Invalidate;
    if Event.Position[0] <= MenuBarLeft then
    begin
      Pos := GetScreenTile(Event.Position[0], Event.Position[1]);

      if IsTileWrong(Pos) then
      begin
        if Selected = -1 then
          Selected := Pos
        else
        begin
          SwapTiles(Selected, Pos);
          Selected := -1;
          if isGameOver then
            Log(CurrentRoutine, 'HOOORAY!');
        end;
      end;
    end else
    begin
      if Event.Position[1] < ButtonSpacer then
        //click button 1
      else
      if Event.Position[1] < ButtonSpacer * 2 then
        //click button 2
      else
      if Event.Position[1] < ButtonSpacer * 3 then
        //click button 3
      else
        //click button 4
    end;
  end;
end;
{$POP}

procedure NewGame;
  function Img(const aURL: String): String;
  begin
    Result := ApplicationData('img/' + aURL);
  end;
var
  i, ix, iy: Integer;
begin
  Image := TGLImage.Create(img('cambridge-city-architecture-1503401533iOz_CC0_by_George_Hodan.jpg'), [TRGBImage], ImageWidth, ImageHeight, riBilinear);

  ScaleX := ImageWidth / SlicesX;
  ScaleY := ImageHeight / SlicesY;

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

  //shuffle the jigsaw pieces
  for i := Pred(JigCount) downto 1 do
    SwapTiles(i, RND.Random(i));

  SetLength(WrongRects, JigCount); //we don't care about it's current length, Count will do its job

  Selected := -1;
  Window.Invalidate;
end;

procedure InitGame;
begin
  BlackBorder := TGLImage.Create(ApplicationData('BlackBorder.png'), true);
  BlackBorder.Color := Vector4(1, 1, 1, 0.8);
  WhiteBorder := TGLImage.Create(ApplicationData('WhiteBorder.png'), true);
  WhiteBorder.Color := Vector4(1, 1, 1, 0.8);

  GameScreenRight := TGLImage.Create(ApplicationData('GameScreenRight.png'), true);
  GameScreenLeft := TGLImage.Create(ApplicationData('GameScreenLeft.png'), true);
  GameScreenLeft.Color := Vector4(1, 1, 1, 1);

  Window.OnRender := @GameRender;
  Window.OnPress := @GamePress;

  MenuBarWidth := Round(Window.Width * 0.07);
  MenuBarLeft := Window.Width - MenuBarWidth;
  ImageWidth := MenuBarLeft - 20;
  ImageHeight := Window.Height - 20;
  ImageStartLeft := 10;
  ImageStartBottom := 10;

  ButtonSize := MenuBarWidth - 10;
  ButtonSpacer := Window.Height div 4;
  ButtonForward := TGLImage.Create(ApplicationData('buttons/ButtonForward.png'), true);
  ButtonRestart := TGLImage.Create(ApplicationData('buttons/ButtonRestart.png'), true);
  ButtonSoundOn := TGLImage.Create(ApplicationData('buttons/ButtonSoundOn.png'), true);
  ButtonSoundOff := TGLImage.Create(ApplicationData('buttons/ButtonSoundOff.png'), true);
  ButtonExit := TGLImage.Create(ApplicationData('buttons/ButtonExit.png'), true);

  NewGame;
end;

procedure FreeGame;
begin
  Window.OnRender := nil;
  Window.OnPress := nil;
  FreeAndNil(Image);
  FreeAndNil(WhiteBorder);
  FreeAndNil(BlackBorder);
  FreeAndNil(GameScreenRight);
  FreeAndNil(GameScreenLeft);

  FreeAndNil(ButtonForward);
  FreeAndNil(ButtonRestart);
  FreeAndNil(ButtonSoundOn);
  FreeAndNil(ButtonSoundOff);
  FreeAndNil(ButtonExit);
end;




end.

