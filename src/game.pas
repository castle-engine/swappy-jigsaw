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
  CastleFilesUtils, CastleWindow,
  CastleRectangles, CastleImages, CastleGLImages,
  Global;

{$DEFINE DynamicArray}

const
  MaxSlices = 16 * 16;
type
  TMyFloatRectangleArray = packed array {$IFNDEF DynamicArray}[0 .. MaxSlices]{$ENDIF} of TFloatRectangle;

var
  SlicesX: Integer = 8;
  SlicesY: Integer = 5;

var
  Image: TGLImage;
  JigCount: Integer;
  JigsawRects, ImageRects: TMyFloatRectangleArray; //TFloatRectangleArray;

procedure GameRender(Container: TUIContainer);
begin
  Image.Draw(@JigsawRects[0], @ImageRects[0], JigCount);
end;

procedure NewGame;
  function Img(const aURL: String): String;
  begin
    Result := ApplicationData('img/' + aURL);
  end;
var
  i, ix, iy: Integer;
  R: TFloatRectangle;
begin
  //Image := TGLImage.Create(ApplicationData('cambridge-city-architecture-1503401533iOz_CC0_by_George_Hodan.jpg'), true);
  Image := TGLImage.Create(img('cambridge-city-architecture-1503401533iOz_CC0_by_George_Hodan.jpg'), [TRGBImage], Window.Width, Window.Height, riBilinear);

  JigCount := 0;
  {$IFDEF DynamicArray}
  SetLength(JigsawRects, SlicesX * SlicesY);
  SetLength(ImageRects, SlicesX * SlicesY);
  {$ENDIF}
  for ix := 0 to Pred(SlicesX) do
    for iy := 0 to Pred(SlicesY) do
    begin
      JigsawRects[JigCount] := FloatRectangle(ix * Image.Width / SlicesX, iy * Image.Height / SlicesY, Image.Width / SlicesX, Image.Height / SlicesY);
      ImageRects[JigCount] := JigsawRects[JigCount];
      inc(JigCount); //JigCount should be last index + 1, as it's meaning is "count"
    end;

  //shuffle the jigsaw pieces
  for i := 0 to 100 do
  begin
    iy := RND.Random(JigCount);
    ix := RND.Random(JigCount);
    R := ImageRects[iy];
    ImageRects[iy] := ImageRects[ix];
    ImageRects[ix] := R;
  end;
end;

procedure InitGame;
begin
  Window.OnRender := @GameRender;
  //Window.OnPress := ;
  NewGame;
end;

procedure FreeGame;
begin
  Window.OnRender := nil;
  Window.OnPress := nil;
  FreeAndNil(Image);
end;




end.

