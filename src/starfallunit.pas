{ MIT License

  Copyright (c) 2018 Yevhen Loza

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
}

{----------------------------------------------------------------------------}

(* {} *)

unit StarFallUnit;

//{$I castleconf.inc}

interface

uses
  SysUtils, Classes, Generics.Collections,
  CastleRectangles, CastleUIControls;

type
  TMyFloatRectangleArray = packed array of TFloatRectangle;

type
  {}
  TStar = class(TObject)
    {}
    X, Y, Vx, Vy, Size: Single;
    {}
    function Rect: TFloatRectangle;
    {}
    function isRender: Boolean;
    {}
    procedure Update;
    constructor Create;
  end;

type
  {}
  TStarList = specialize TObjectList<TStar>;

type
  {}
  TStarFall = class(TUIControl)
  strict private
    FStarList: TStarList;
    StarScreen, StarSource: TMyFloatRectangleArray;
    procedure AddStar;
  public
    procedure Render; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published

  end;

const
  VictoryDuration = 2 /24/60/60; {2 seconds}

var
  {}
  VictoryStartTime: TDateTime;

procedure FreeStars;
implementation
uses
  CastleVectors,
  WindowUnit, Global, Gui;

procedure TStarFall.AddStar;
begin
  FStarList.Add(TStar.Create);
  SetLength(StarScreen, FStarList.Count);
  SetLength(StarSource, FStarList.Count);
  StarSource[High(StarSource)] := FloatRectangle(0, 0, StarSize, StarSize);
end;

procedure TStarFall.Render;
var
  {}
  Star: TStar;
  {}
  i: Integer;
begin
  if Now - VictoryStartTime < VictoryDuration / 3 then
    for i := 0 to 6 do  //add 7 stars each frame
      AddStar;

  i := 0;
  for Star in FStarList do
    if Star.isRender then
    begin
      Star.Update;
      StarScreen[i] := Star.Rect;
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

constructor TStarFall.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStarList := TStarList.Create(true);
end;

destructor TStarFall.Destroy;
begin
  FreeAndNil(FStarList);
  inherited Destroy;
end;

{=========================================================================}

function TStar.Rect: TFloatRectangle;
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

procedure FreeStars;
begin
  Window.Invalidate; //clear the stars remaining on screen
end;

end.

