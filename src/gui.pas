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

(* Classes and variables handing GUI elements *)

unit GUI;

{$INCLUDE compilerconfig.inc}

interface

uses
  CastleRectangles,
  CastleGLImages;

{type
  TButtonsFloatRectangleArray = packed array of TFloatRectangle;}

var
  { How many tiles us the image sliced into? }
  SlicesX: Integer = 7;
  SlicesY: Integer = 6;
  { Rectangle area where the Image is drawn }
  ImageStartLeft, ImageStartBottom, ImageWidth, ImageHeight: Integer;
  { Size of a single tile }
  ScaleX, ScaleY: Integer;
  { Image frame, drawn on top of Image }
  GameScreenRight, GameScreenLeft: TDrawableImage;
  { Coordinates to locate interface elements }
  MenuBarLeft, MenuBarWidth, GameWidth: Integer;
  { White border (for selected tiles) and black border (for wrongly placed tiles)
    Drawn through Draw3x3 using TGLImageHelper }
  WhiteBorder, BlackBorder: TDrawableImage;
  { A set of buttons }
  Buttons: TDrawableImage;
  { Image Rectangles, that determine which button is to be drawn }
  ButtonForward, ButtonHint, ButtonSoundOn, ButtonSoundOff, ButtonMenu, ButtonCredits: TFloatRectangle;
  { Size of buttons }
  ButtonSize, ButtonSpacer: Integer;
  { A tick symbol, denoting that the image has already been solved }
  SolvedImage: TDrawableImage;
  { Arrows on the left and right of the ImageSelector to flip pages }
  PagesArrow: TDrawableImage;
  { Global window width/height/position, always guaranteed to be of golden section }
  WindowWidth, WindowHeight, WindowLeft, WindowBottom: Integer;

{ Load GUI elements and calculate their size }
procedure InitUI;
{ Free GUI elements }
procedure FreeUI;
implementation
uses
  SysUtils, CastleVectors, CastleImages,
  WindowUnit;

procedure InitUI;
const
  FrameWidth = 10; {not 19! as the frame is semi-tranparent with rounded corners}
begin
  //load borders
  BlackBorder := TDrawableImage.Create('castle-data:/BlackBorder.png', true);
  BlackBorder.Color := Vector4(1, 1, 1, 0.8);
  WhiteBorder := TDrawableImage.Create('castle-data:/WhiteBorder.png', true);
  WhiteBorder.Color := Vector4(1, 1, 1, 0.8);

  GameScreenRight := TDrawableImage.Create('castle-data:/GameScreenRight.png', true);
  GameScreenLeft := TDrawableImage.Create('castle-data:/GameScreenLeft.png', true);
  GameScreenLeft.Color := Vector4(1, 1, 1, 1);

  //set the aspect ratio always 1:1.61, as majority of mobile devices
  WindowWidth := Window.Width;
  WindowHeight := Window.Height;
  if WindowWidth / WindowHeight > 1.61 then
    WindowWidth := Round(WindowHeight * 1.61)
  else
    WindowHeight := Round(WindowWidth / 1.61);

  MenuBarWidth := Round(WindowWidth * 0.07);

  //get integer scale for specific slices
  ScaleX := Trunc((WindowWidth - MenuBarWidth - 2 * FrameWidth) / SlicesX);
  ScaleY := Trunc((WindowHeight - 2 * FrameWidth) / SlicesY);

  WindowWidth := MenuBarWidth + 2 * FrameWidth + ScaleX * SlicesX;
  WindowHeight := 2 * FrameWidth + ScaleY * SlicesY;

  WindowLeft := (Window.Width - WindowWidth) div 2;
  WindowBottom := (Window.Height - WindowHeight) div 2;

  GameWidth := WindowWidth - MenuBarWidth;
  MenuBarLeft := WindowLeft + GameWidth;

  ImageWidth := GameWidth - 2 * FrameWidth;
  ImageHeight := WindowHeight - 2 * FrameWidth;
  ImageStartLeft := WindowLeft + FrameWidth;
  ImageStartBottom := WindowBottom + FrameWidth + 1; // I really have no idea why I need +1 here... sorry :) But otherwise image is not symmetric against the frame

  ButtonSize := MenuBarWidth - 10;
  ButtonSpacer := WindowHeight div 4;
  if ButtonSize < 256 then
  begin
    //scale buttons down on loading if displayed size is smaller than button image size, to save memory and boost performance
    Buttons := TDrawableImage.Create('castle-data:/UI.png', [TRGBAlphaImage], ButtonSize * 6, ButtonSize, riBlackmanSinc);
    SolvedImage := TDrawableImage.Create('castle-data:/Solved.png', [TRGBAlphaImage], ButtonSize * 6, ButtonSize, riBlackmanSinc);
  end else
  begin
    //otherwise don't scale buttons, to save memory
    Buttons := TDrawableImage.Create('castle-data:/UI.png', true);
    SolvedImage := TDrawableImage.Create('castle-data:/Solved.png', true);
  end;
  ButtonForward := FloatRectangle(0, 0, Buttons.Width div 6, Buttons.Height);
  ButtonHint := FloatRectangle(Buttons.Width div 6, 0, Buttons.Width div 6, Buttons.Height);
  ButtonSoundOn := FloatRectangle(2 * Buttons.Width div 6, 0, Buttons.Width div 6, Buttons.Height);
  ButtonSoundOff := FloatRectangle(3 * Buttons.Width div 6, 0, Buttons.Width div 6, Buttons.Height);
  ButtonMenu := FloatRectangle(4 * Buttons.Width div 6, 0, Buttons.Width div 6, Buttons.Height);
  ButtonCredits := FloatRectangle(5 * Buttons.Width div 6, 0, Buttons.Width div 6, Buttons.Height);

  PagesArrow := TDrawableImage.Create('castle-data:/PagesArrow.png', true);
end;

{ --------------------------------------------------------------------------- }

procedure FreeUI;
begin
  FreeAndNil(WhiteBorder);
  FreeAndNil(BlackBorder);

  FreeAndNil(GameScreenRight);
  FreeAndNil(GameScreenLeft);

  FreeAndNil(Buttons);

  FreeAndNil(SolvedImage);
  FreeAndNil(PagesArrow);
end;

end.

