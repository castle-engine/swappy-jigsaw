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

unit StarFallUnit;

{$INCLUDE compilerconfig.inc}

interface

uses
  SysUtils;

const
  VictoryDuration = 2 /24/60/60; {2 seconds}

var
  {}
  VictoryStartTime: TDateTime;

procedure DoStars;
procedure FreeStars;
implementation
uses
  Generics.Collections,
  CastleRectangles, CastleVectors,
  WindowUnit, Global, Gui;

type
  {}
  TStar = class(TObject)
    {}
    X, Y, Vx, Vy, Size: Single;
    {}
    function StarRect: TFloatRectangle;
    {}
    function isRender: Boolean;
    {}
    procedure Update;
    constructor Create;
  end;

type
  {}
  TStarList = specialize TObjectList<TStar>;

var
  {}
  StarList: TStarList;



function TStar.StarRect: TFloatRectangle;
begin
  Result := FloatRectangle(X, Y, Size, Size);
end;
function TStar.isRender: Boolean;
begin
  Result := (Y > 0) {and (Size < StarSize)};
end;
procedure TStar.Update;
begin
  Vy -= RND.Random;
  Vx += (RND.Random - 0.5) / 2;
  X += Vx;
  Y += Vy;
  Size += 1.4 * RND.Random;
end;
constructor TStar.Create;
begin
  X := WindowLeft + RND.Random(WindowWidth);
  Y := WindowBottom + WindowHeight * (1 + 1.2 * RND.Random) / 2; //stars may start 50% to 110% of WindowHeight
  Vy := -RND.Random;
  Vx := 10 * (RND.Random - 0.5);
  Size := StarSize / 10;
end;

{=========================================================================}

type
  TMyFloatRectangleArray = packed array of TFloatRectangle;

procedure DoStars;
var
  {}
  Star: TStar;
  {}
  StarScreen, StarSource: TMyFloatRectangleArray;
  i: Integer;
begin
  if StarList = nil then
    StarList := TStarList.Create(true);

  if Now - VictoryStartTime < VictoryDuration / 3 then
    for i := 0 to 6 do  //add 7 stars each frame
    begin
      Star := TStar.Create;
      StarList.Add(Star);
    end;

  SetLength(StarScreen, StarList.Count);
  SetLength(StarSource, StarList.Count);
  i := 0;
  for Star in StarList do
    if Star.isRender then
    begin
      Star.Update;
      StarScreen[i] := Star.StarRect;
      StarSource[i] := FloatRectangle(0, 0, StarSize, StarSize);
      inc(i);
    end;

  if (Now - VictoryStartTime < VictoryDuration / 2) then
    StarImage.Color := Vector4(1, 1, 1, 1)
  else
    StarImage.Color := Vector4(1, 1, 1, 1 - (Now - VictoryStartTime - VictoryDuration / 2) / (VictoryDuration / 2) );

  if i > 0 then
    StarImage.Draw(@StarScreen[0], @StarSource[0], i);

  if i = 0 then
    VictoryStartTime -= VictoryDuration;
end;

procedure FreeStars;
begin
  FreeAndNil(StarList);
  Window.Invalidate; //clear the stars remaining on screen
end;

end.

