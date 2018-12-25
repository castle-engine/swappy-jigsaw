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

unit SelectImage;
{$INCLUDE compilerconfig.inc}

interface

{}
procedure ShowImageSelector;
{}
procedure InitImageSelector;
//procedure FreeImageSelector;

implementation
uses
  CastleWindow, CastleKeysMouse,
  WindowUnit, ImageList, GUI,
  Game;

var
  {}
  SelectorScaleX, SelectorScaleY: Integer;
  {}
  SelectorWidth: Integer;
  {}
  RightLeftButtonWidth: Integer;

procedure ImageSelectorRender(Container: TUIContainer);
const
  Page = 1;
  ImagesPerPage = 12;
var
  i, ix, iy: Integer;
begin
  for ix := 0 to 2 do
    for iy := 0 to 3 do
    begin
      i := Page * ImagesPerPage + ix + iy * 3;
      if i < ImageDataList.Count then
        ImageDataList[i].Thumbnail.Draw(
          ImageStartLeft + RightLeftButtonWidth + ix * SelectorScaleX,
          ImageStartBottom + iy * SelectorScaleY, SelectorScaleX, SelectorScaleY);
    end;
  GameScreenLeft.Draw3x3(WindowLeft, WindowBottom, GameWidth, WindowHeight, 19, 19, 19, 19);
  GameScreenRight.Draw3x3(MenuBarLeft, WindowBottom, MenuBarWidth, WindowHeight, 19, 9, 19, 0);
  ButtonForward.Draw(ImageStartLeft + RightLeftButtonWidth,
    ImageStartBottom, -RightLeftButtonWidth, ImageHeight);
  ButtonForward.Draw(ImageStartLeft + ImageWidth - RightLeftButtonWidth,
    ImageStartBottom, RightLeftButtonWidth, ImageHeight);
end;

procedure ImageSelectorPress(Container: TUIContainer; const Event: TInputPressRelease);
begin
  NewGame(-1);
end;

procedure ShowImageSelector;
begin
  Window.OnRender := @ImageSelectorRender;
  Window.OnPress := @ImageSelectorPress;

  Window.Invalidate;

  NewGame(-1); //temporarily here
end;

procedure InitImageSelector;
begin
  RightLeftButtonWidth := ImageWidth div 20;
  SelectorWidth := ImageWidth - 2 * RightLeftButtonWidth;
  SelectorScaleX := SelectorWidth div 3;
  SelectorScaleY := ImageHeight div 4;

end;

end.

