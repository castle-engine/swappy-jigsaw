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
  ImageWidth, ImageHeight: Integer;
  {}
  WhiteBorder, BlackBorder: TGlImage;
  {}
  Selected: TVector2Integer;
  {}
  JigCount: Integer;
  JigsawRects, ImageRects: TMyFloatRectangleArray; //TFloatRectangleArray;


function GetLinearCoord(const A: TVector2Integer): Integer;
begin
  Result := A[0] + A[1] * SlicesX;
end;

procedure SwapTiles(const A, B: TVector2Integer);
var
  R: TFloatRectangle;
begin
  R := JigsawRects[GetLinearCoord(A)];
  JigsawRects[GetLinearCoord(A)] := JigsawRects[GetLinearCoord(B)];
  JigsawRects[GetLinearCoord(B)] := R;
end;

procedure SwapTiles(const A, B: Integer);
var
  R: TFloatRectangle;
begin
  R := JigsawRects[A];
  JigsawRects[A] := JigsawRects[B];
  JigsawRects[B] := R;
end;

function IsTileWrong(const ScreenLinearCoordinates: Integer): Boolean;
begin
  Result := (JigsawRects[ScreenLinearCoordinates].Bottom <> ImageRects[ScreenLinearCoordinates].Bottom) or
            (JigsawRects[ScreenLinearCoordinates].Left <> ImageRects[ScreenLinearCoordinates].Left);
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
  WrongRects: TMyFloatRectangleArray;

begin
  Image.Draw(@ImageRects[0], @JigsawRects[0], JigCount);

  i := 0;

  Count := 0;
  SetLength(WrongRects, JigCount); //we don't care about it's current length, Count will do its job
  for ix := 0 to Pred(SlicesX) do
    for iy := 0 to Pred(SlicesY) do
    begin
      if IsTileWrong(i) then
      begin
        WrongRects[Count] := JigsawRects[i];
        inc(Count);
      end;
      inc(i);
    end;
  BlackBorder.Draw3x3Batched(@WrongRects[0], Count, 15, 15, 15, 15);

  if Selected[0] >= 0 then
    WhiteBorder.Draw3x3(ImageRects[GetLinearCoord(Selected)], Vector4Integer(15, 15, 15, 15));
end;

procedure GamePress(Container: TUIContainer; const Event: TInputPressRelease);
var
  Pos: TVector2Integer;
begin
  if (Event.EventType = itMouseButton) {and (Event.MouseButton = mbLeft)} then
  begin
    Pos := Vector2Integer(Trunc(Event.Position[0] / ImageWidth * SlicesX), Trunc(Event.Position[1] / ImageHeight * SlicesY));
    if IsTileWrong(Pos) then
    begin
      if Selected[0] = -1 then
        Selected := Pos
      else
      begin
        SwapTiles(Selected, Pos);
        Selected := Vector2Integer(-1, -1);
        if isGameOver then
          Log(CurrentRoutine, 'HOOORAY!');
      end;
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
  BlackBorder := TGLImage.Create(ApplicationData('BlackBorder.png'), true);
  BlackBorder.Color := Vector4(1, 1, 1, 0.8);
  WhiteBorder := TGLImage.Create(ApplicationData('WhiteBorder.png'), true);
  WhiteBorder.Color := Vector4(1, 1, 1, 0.8);

  Image := TGLImage.Create(img('cambridge-city-architecture-1503401533iOz_CC0_by_George_Hodan.jpg'), [TRGBImage], ImageWidth, ImageHeight, riBilinear);

  JigCount := 0;
  SetLength(JigsawRects, SlicesX * SlicesY);
  SetLength(ImageRects, SlicesX * SlicesY);
  for iy := 0 to Pred(SlicesY) do
    for ix := 0 to Pred(SlicesX) do
    begin
      JigsawRects[JigCount] := FloatRectangle(ix * Image.Width / SlicesX, iy * Image.Height / SlicesY, Image.Width / SlicesX, Image.Height / SlicesY);
      ImageRects[JigCount] := JigsawRects[JigCount];
      inc(JigCount); //JigCount should be last index + 1, as it's meaning is "count"
    end;

  //shuffle the jigsaw pieces
  for i := Pred(JigCount) downto 1 do
    SwapTiles(i, RND.Random(i));

  Selected := Vector2Integer(-1, -1);
end;

procedure InitGame;
begin
  Window.OnRender := @GameRender;
  Window.OnPress := @GamePress;

  ImageWidth := Window.Width;
  ImageHeight := Window.Height;

  NewGame;
end;

procedure FreeGame;
begin
  Window.OnRender := nil;
  Window.OnPress := nil;
  FreeAndNil(Image);
  FreeAndNil(WhiteBorder);
  FreeAndNil(BlackBorder);
end;




end.

