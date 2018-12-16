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

unit GUI;

{$INCLUDE compilerconfig.inc}

interface

uses
  CastleGLImages;

var
  {}
  PlaySound: Boolean = true;
  {}
  SlicesX: Integer = 7;
  SlicesY: Integer = 6;
  {}
  ImageStartLeft, ImageStartBottom, ImageWidth, ImageHeight: Integer;
  ScaleX, ScaleY: Integer;
  {}
  GameScreenRight, GameScreenLeft: TGLImage;
  MenuBarLeft, MenuBarWidth, GameWidth: Integer;
  {}
  WhiteBorder, BlackBorder: TGlImage;
  {}
  ButtonForward, ButtonRestart, ButtonSoundOn, ButtonSoundOff, ButtonExit: TGLImage;
  ButtonSize, ButtonSpacer: Integer;
  {}
  WindowWidth, WindowHeight, WindowLeft, WindowBottom: Integer;

{}
procedure InitUI;
{}
procedure FreeUI;
implementation
uses
  SysUtils, CastleFilesUtils, CastleVectors, CastleImages,
  WindowUnit,
  DecoLog;

procedure InitUI;
const
  FrameWidth = 10; {not 19! as the frame is semi-tranparent with rounded corners}
begin
  //load borders
  BlackBorder := TGLImage.Create(ApplicationData('BlackBorder.png'), true);
  BlackBorder.Color := Vector4(1, 1, 1, 0.8);
  WhiteBorder := TGLImage.Create(ApplicationData('WhiteBorder.png'), true);
  WhiteBorder.Color := Vector4(1, 1, 1, 0.8);

  GameScreenRight := TGLImage.Create(ApplicationData('GameScreenRight.png'), true);
  GameScreenLeft := TGLImage.Create(ApplicationData('GameScreenLeft.png'), true);
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
  if ButtonSize < 122 then
  begin
    //scale buttons down on loading if displayed size is smaller than button image size
    ButtonForward := TGLImage.Create(ApplicationData('buttons/ButtonForward.png'), [TRGBAlphaImage], ButtonSize, ButtonSize, riBilinear);
    ButtonRestart := TGLImage.Create(ApplicationData('buttons/ButtonRestart.png'), [TRGBAlphaImage], ButtonSize, ButtonSize, riBilinear);
    ButtonSoundOn := TGLImage.Create(ApplicationData('buttons/ButtonSoundOn.png'), [TRGBAlphaImage], ButtonSize, ButtonSize, riBilinear);
    ButtonSoundOff := TGLImage.Create(ApplicationData('buttons/ButtonSoundOff.png'), [TRGBAlphaImage], ButtonSize, ButtonSize, riBilinear);
    ButtonExit := TGLImage.Create(ApplicationData('buttons/ButtonExit.png'), [TRGBAlphaImage], ButtonSize, ButtonSize, riBilinear);
  end else
  begin
    //otherwise don't scale buttons
    ButtonForward := TGLImage.Create(ApplicationData('buttons/ButtonForward.png'), true);
    ButtonRestart := TGLImage.Create(ApplicationData('buttons/ButtonRestart.png'), true);
    ButtonSoundOn := TGLImage.Create(ApplicationData('buttons/ButtonSoundOn.png'), true);
    ButtonSoundOff := TGLImage.Create(ApplicationData('buttons/ButtonSoundOff.png'), true);
    ButtonExit := TGLImage.Create(ApplicationData('buttons/ButtonExit.png'), true);
  end;
end;

{ --------------------------------------------------------------------------- }

procedure FreeUI;
begin
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

