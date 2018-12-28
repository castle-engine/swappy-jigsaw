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

(* Image selector, to choose an image to solve *)

unit SelectImage;
{$INCLUDE compilerconfig.inc}

interface

{ Show Image selector on screen (and stop all other game modes) }
procedure ShowImageSelector;
{ Init Image-selector specific data }
procedure InitImageSelector;
//procedure FreeImageSelector;

implementation
uses
  CastleWindow, CastleKeysMouse, CastleRectangles, CastleVectors,
  CastleGLUtils, CastleColors,
  //DrawBatched3x3,
  WindowUnit, ImageList, GUI, CreditsScreen,
  Game;

var
  { Sizes of each image in Image Selector }
  SelectorScaleX, SelectorScaleY: Integer;
  { Total width of the Image Selector }
  SelectorWidth: Integer;
  { Width of arrow buttons, that filp pages left and right }
  RightLeftButtonWidth: Integer;
  { Current page }
  Page: Integer;
  { Total pages }
  TotalPages: Integer;

const
  { Quantity of images per page }
  ImagesX = 3;
  ImagesY = 4;
  ImagesPerPage = ImagesX * ImagesY;

procedure ImageSelectorRender(Container: TUIContainer);
var
  i, ix, iy: Integer;
begin
  RenderContext.Clear([cbColor], Black); //we need clear screen here to avoid bleeding pixels

  for ix := 0 to Pred(ImagesX) do
    for iy := 0 to Pred(ImagesY) do
    begin
      i := Page * ImagesPerPage + ix + iy * 3;
      if i < ImageDataList.Count then
      begin
        ImageDataList[i].Thumbnail.Draw(
          ImageStartLeft + RightLeftButtonWidth + ix * SelectorScaleX,
          ImageStartBottom + (Pred(ImagesY) - iy) * SelectorScaleY,
          SelectorScaleX, SelectorScaleY);
        BlackBorder.Draw3x3(ImageStartLeft + RightLeftButtonWidth + ix * SelectorScaleX,
          ImageStartBottom + (Pred(ImagesY) - iy) * SelectorScaleY, SelectorScaleX, SelectorScaleY,
          Vector4Integer(5, 5, 5, 5));
        if ImageDataList[i].Hits > 0 then
          SolvedImage.Draw(
            ImageStartLeft + RightLeftButtonWidth + (ix + 1) * SelectorScaleX - ButtonSize,
            ImageStartBottom + (Pred(ImagesY) - iy) * SelectorScaleY,
            ButtonSize, ButtonSize);
      end;
    end;

  PagesArrow.Draw(ImageStartLeft + RightLeftButtonWidth,
    ImageStartBottom, -RightLeftButtonWidth, ImageHeight);
  PagesArrow.Draw(ImageStartLeft + ImageWidth - RightLeftButtonWidth,
    ImageStartBottom, RightLeftButtonWidth, ImageHeight);

  GameScreenLeft.Draw3x3(WindowLeft, WindowBottom, GameWidth, WindowHeight, 19, 19, 19, 19);
  GameScreenRight.Draw3x3(MenuBarLeft, WindowBottom, MenuBarWidth, WindowHeight, 19, 9, 19, 0);

  Buttons.Draw(FloatRectangle(MenuBarLeft, WindowBottom + ButtonSpacer * 3.5 - ButtonSize / 2, ButtonSize, ButtonSize),
    ButtonForward);
  if PlaySound then
    Buttons.Draw(FloatRectangle(MenuBarLeft, WindowBottom + ButtonSpacer * 1.5 - ButtonSize / 2, ButtonSize, ButtonSize),
      ButtonSoundOn)
  else
    Buttons.Draw(FloatRectangle(MenuBarLeft, WindowBottom + ButtonSpacer * 1.5 - ButtonSize / 2, ButtonSize, ButtonSize),
      ButtonSoundOff);
  Buttons.Draw(FloatRectangle(MenuBarLeft, WindowBottom + ButtonSpacer * 0.5 - ButtonSize / 2, ButtonSize, ButtonSize),
    ButtonCredits);
end;

procedure ClickSound;
begin
  PlaySound := not PlaySound;
end;

procedure ImageSelectorPress(Container: TUIContainer; const Event: TInputPressRelease);
var
  ix, iy: Integer;
begin
  if (Event.EventType = itMouseButton) then
  begin
    Window.Invalidate;
    if Event.Position[0] <= MenuBarLeft then
    begin
      if Event.Position[0] <= ImageStartLeft + RightLeftButtonWidth then
      begin
        //click "LEFT"
        if Page < Pred(TotalPages) then
          inc(Page)
        else
          Page := 0;
      end else
      if Event.Position[0] >= ImageStartLeft + ImageWidth - RightLeftButtonWidth then
      begin
        //click "RIGHT"
        if Page >0 then
          dec(Page)
        else
          Page := Pred(TotalPages);
      end else
      begin
        ix := Trunc((Event.Position[0] - (ImageStartLeft + RightLeftButtonWidth)) / SelectorScaleX);
        if ix < 0 then
          ix := 0;
        if ix >= ImagesX then
          ix := Pred(ImagesX);
        iy := Trunc((Event.Position[1] - ImageStartBottom) / SelectorScaleY);
        if iy < 0 then
          iy := 0;
        if iy >= ImagesY then
          iy := Pred(ImagesY);

        NewGame(ix + iy * ImagesX + Page * ImagesPerPage);
      end;
    end else
    begin
      if Event.Position[1] < ButtonSpacer then
        DisplayCredits
      else
      if Event.Position[1] < ButtonSpacer * 2 then
        ClickSound
      else
      if Event.Position[1] < ButtonSpacer * 3 then
        //ClickHintButton
      else
        NewGame(-1);
    end;
  end;
end;

procedure ShowImageSelector;
begin
  SortListCount; //not optimal

  Window.OnRender := @ImageSelectorRender;
  Window.OnPress := @ImageSelectorPress;

  Window.Invalidate;

  Page := 0;
  TotalPages := ImageDataList.Count div ImagesPerPage;
end;

procedure InitImageSelector;
begin
  RightLeftButtonWidth := ImageWidth div 20;
  SelectorWidth := ImageWidth - 2 * RightLeftButtonWidth;
  SelectorScaleX := SelectorWidth div 3;
  SelectorScaleY := ImageHeight div 4;
end;

end.

