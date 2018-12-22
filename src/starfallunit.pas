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

(* A simple victory effect, "throws" a lot of stars or other images on screen
   and lets them fall accelerated by gravity.
   By default it'll throw yellow squares, but user can set Image or URL to load
   any image supported by Castle Game Engine. *)

unit StarFallUnit;

//{$I castleconf.inc}

interface

uses
  SysUtils, Classes, Generics.Collections,
  CastleGLImages, CastleRectangles, CastleColors,
  CastleUIControls, CastleComponentSerialize;

type
  TStarsFloatRectangleArray = packed array of TFloatRectangle;

type
  { An single object (star) properties that falls down }
  TStar = class(TObject)
  public
    { Coordinates, speed and size of the star}
    X, Y, Vx, Vy, Size: Single;
    { Rectangle of the star's current position and size }
    function Rect: TFloatRectangle;
    { Is this star on-screen? }
    function isRender: Boolean;
    { Update coordinates/properties of the Star
      should be called each frame}
    procedure Update;
    constructor Create;
  end;

type
  { A list of Stars }
  TStarList = specialize TObjectList<TStar>;

type
  { UI element, that can display a burst of stars falling down if launched }
  TStarFallEffect = class(TCastleUserInterface)
  strict private
    FImage: TGLImage;
    FDefaultColor: Boolean;
    FColor: TCastleColor;
    FURL: String;
    FOwnsImage: Boolean;
    FStarList: TStarList;
    FRenderStars: Integer;
    StarScreen, StarSource: TStarsFloatRectangleArray;
    procedure AddStar;
    procedure CreatePixel;
    procedure SetImage(const AImage: TGLImage);
    procedure SetURL(const AURL: String);
    procedure SetColor(const AColor: TCastleColor);
    procedure ClearStars;
    procedure StopEffect;
    procedure CheckIsImageValid;
  public
    { Color of StarFall objects.
      In case no image is provided, this will mean color of falling squares
      Otherwise Image.Color will be set to this value
      Defaults are White for Images and Yellow for falling squares }
    property Color: TCastleColor read FColor write SetColor;
    procedure Render; override;
    procedure Update(const SecondsPassed: Single;
      var HandleInput: boolean); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    {}
    property Image: TGLImage read FImage write SetImage;
    property URL: String read FURL write SetURL;

    { Free the @link(Image) instance automatically. }
    property OwnsImage: boolean read FOwnsImage write FOwnsImage default false;

    property FullSize default true;
  end;

const
  VictoryDuration = 2 /24/60/60; {2 seconds}

var
  {}
  VictoryStartTime: TDateTime;

implementation
uses
  CastleVectors, CastleImages,
  WindowUnit, Global, Gui;

procedure TStarFallEffect.AddStar;
begin
  FStarList.Add(TStar.Create);
  SetLength(StarScreen, FStarList.Count);
  SetLength(StarSource, FStarList.Count);
  StarSource[High(StarSource)] := FloatRectangle(0, 0, FImage.Width, FImage.Height);
end;

procedure TStarFallEffect.Update(const SecondsPassed: Single; var HandleInput: boolean);
var
  Star: TStar;
  i: Integer;
  CurrentColor: TCastleColor;
begin
  inherited Update(SecondsPassed, HandleInput);

  CheckIsImageValid;

  //Add stars if necessary
  if Now - VictoryStartTime < VictoryDuration / 3 then
    for i := 0 to 6 do
      AddStar;

  //Reset StarScreen to current values
  FRenderStars := 0;
  for Star in FStarList do
    if Star.isRender then
    begin
      Star.Update;
      StarScreen[FRenderStars] := Star.Rect;
      inc(FRenderStars);
    end;

  //fade out image after half of requested time
  CurrentColor := FColor; //can't assign to FColor directly as TGLImage.Color is a property
  if (Now - VictoryStartTime > VictoryDuration / 2) then
    CurrentColor.Data[3] := CurrentColor.Data[3] * (1 - (Now - VictoryStartTime - VictoryDuration / 2) / (VictoryDuration / 2) );
  FImage.Color := CurrentColor;
end;

procedure TStarFallEffect.SetURL(const AURL: String);
begin
  if FOwnsImage then
    FreeAndNil(FImage);
  if FDefaultColor then
    FColor := White;

  FURL := AURL;
  FImage := TGLImage.Create(FURL, [TRGBAlphaImage], true);
  FOwnsImage := true;
end;

procedure TStarFallEffect.SetImage(const AImage: TGLImage);
begin
  if FOwnsImage then
    FreeAndNil(FImage);
  if FDefaultColor then
    FColor := White;
  FImage := AImage;
end;

procedure TStarFallEffect.SetColor(const AColor: TCastleColor);
begin
  FColor := AColor;
  FDefaultColor := false; //prevent color from automatically changing
end;

procedure TStarFallEffect.CreatePixel;
var
  WhitePixel: TGrayscaleImage;
begin
  WhitePixel := TGrayscaleImage.Create(1, 1);
  WhitePixel.Clear(Vector4(1,1,1,1));
  FImage := TGLImage.Create(WhitePixel, true, true);
  FOwnsImage := true;
  if FDefaultColor then
    FColor := Yellow;
end;

procedure TStarFallEffect.Render;
begin
  //Render stars, batched
  if FRenderStars > 0 then
  begin
    CheckIsImageValid;
    FImage.Draw(@StarScreen[0], @StarSource[0], FRenderStars)
  end
  else
  begin
    VictoryStartTime -= VictoryDuration; //if no stars to render, then stop StarFall
    StopEffect
  end;
end;

procedure TStarFallEffect.CheckIsImageValid;
begin
  if FImage = nil then
    CreatePixel;
end;

procedure TStarFallEffect.ClearStars;
begin
  FStarList.Clear;
end;

procedure TStarFallEffect.StopEffect;
begin
  ClearStars;
end;




constructor TStarFallEffect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDefaultColor := true;
  FStarList := TStarList.Create(true);
end;

destructor TStarFallEffect.Destroy;
begin
  if FOwnsImage then
    FreeAndNil(FImage);
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
  Result := (Y > -Size) and (X > -Size) and (X < Window.Width); //shouldn't depend on Window.Width here!
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
  Size := 3;
end;

{=========================================================================}

initialization
  RegisterSerializableComponent(TStarFallEffect, 'StarFall Effect');
end.
