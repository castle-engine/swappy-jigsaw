{ Copyright (C) 2018-2026 Yevhen Loza, Michalis Kamburelis

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

uses
  Math, Classes,
  CastleWindow, CastleKeysMouse, CastleRectangles, CastleVectors,
  CastleGLUtils, CastleColors, CastleRenderContext, CastleUiControls,
  //DrawBatched3x3,
  WindowUnit, ImageList, GUI, CreditsScreen,
  Game, SoundMusic;

type
  TViewImageSelector = class(TCastleView)
  private
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

      Swipe: Boolean;
      SwipeStart: TVector2;

    const
      { Quantity of images per page }
      ImagesX = 3;
      ImagesY = 4;
      ImagesPerPage = ImagesX * ImagesY;

    procedure IncPage;
    procedure DecPage;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Render; override;
    function Press(const Event: TInputPressRelease): Boolean; override;
    function Release(const Event: TInputPressRelease): Boolean; override;
  end;

var
  ViewImageSelector: TViewImageSelector;

implementation

procedure TViewImageSelector.Render;
var
  I, Ix, Iy: Integer;
begin
  inherited;

  CheckMusic; //check if the music has finished and load a new one

  RenderContext.Clear([cbColor], Black); //we need clear screen here to avoid bleeding pixels

  for Ix := 0 to Pred(ImagesX) do
    for Iy := 0 to Pred(ImagesY) do
    begin
      I := Page * ImagesPerPage + Ix + Iy * 3;
      if I < ImageDataList.Count then
      begin
        ImageDataList[I].Thumbnail.Draw(
          ImageStartLeft + RightLeftButtonWidth + Ix * SelectorScaleX,
          ImageStartBottom + (Pred(ImagesY) - Iy) * SelectorScaleY,
          SelectorScaleX, SelectorScaleY);
        BlackBorder.Draw3x3(ImageStartLeft + RightLeftButtonWidth + Ix * SelectorScaleX,
          ImageStartBottom + (Pred(ImagesY) - Iy) * SelectorScaleY, SelectorScaleX, SelectorScaleY,
          Vector4Integer(5, 5, 5, 5));
        if ImageDataList[I].Hits > 0 then
          SolvedImage.Draw(
            ImageStartLeft + RightLeftButtonWidth + (Ix + 1) * SelectorScaleX - ButtonSize,
            ImageStartBottom + (Pred(ImagesY) - Iy) * SelectorScaleY,
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

procedure TViewImageSelector.DecPage;
begin
  if Page > 0 then
    Dec(Page)
  else
    Page := Pred(TotalPages);
end;

procedure TViewImageSelector.IncPage;
begin
  if Page < Pred(TotalPages) then
    Inc(Page)
  else
    Page := 0;
end;

function TViewImageSelector.Press(const Event: TInputPressRelease): Boolean;

  procedure StartSwipe;
  begin
    if Event.FingerIndex = 0 then
    begin
      Swipe := true;
      SwipeStart := Event.Position;
    end;
  end;

begin
  Result := inherited;
  if Result then Exit;

  if (Event.EventType = itMouseButton) then
  begin
    Window.Invalidate;
    if Event.Position[0] <= MenuBarLeft then
    begin
      if Event.Position[0] <= ImageStartLeft + RightLeftButtonWidth then
        DecPage //click "LEFT"
      else
      if Event.Position[0] >= ImageStartLeft + ImageWidth - RightLeftButtonWidth then
        IncPage //click "RIGHT"
      else
        StartSwipe;
    end else
    begin
      if Event.Position[1] < ButtonSpacer then
        Container.View := ViewCredits
      else
      if Event.Position[1] < ButtonSpacer * 2 then
        ToggleSound
      else
      if Event.Position[1] < ButtonSpacer * 3 then
        //ClickHintButton
      else
        NewGame(-1);
    end;
  end;
end;

function TViewImageSelector.Release(const Event: TInputPressRelease): Boolean;
var
  Ix, Iy: Integer;
begin
  Result := inherited;
  if Result then Exit;

  if (Swipe) and (Event.FingerIndex = 0) then
  begin
    Window.Invalidate;
    if (Abs(Event.Position[0] - SwipeStart[0]) < SelectorScaleY) then
    begin
      //if finger didn't move too far away, start the image under finger
      Ix := Trunc((Event.Position[0] - (ImageStartLeft + RightLeftButtonWidth)) / SelectorScaleX);
      if Ix < 0 then
        Ix := 0;
      if Ix >= ImagesX then
        Ix := Pred(ImagesX);
      Iy := Trunc((Event.Position[1] - ImageStartBottom) / SelectorScaleY);
      if Iy < 0 then
        Iy := 0;
      if Iy >= ImagesY then
        Iy := Pred(ImagesY);
      Iy := Pred(ImagesY) - Iy;

      NewGame(Ix + Iy * ImagesX + Page * ImagesPerPage);
    end else
    begin
      //else do a swipe page change
      if Event.Position[0] > SwipeStart[0] then
        IncPage
      else
        DecPage;
    end
  end;
end;

procedure TViewImageSelector.Start;
begin
  inherited;

  SortListCount; //not optimal

  Swipe := false;

  Window.Invalidate;

  Page := 0;
  TotalPages := Ceil(Single(ImageDataList.Count) / Single(ImagesPerPage));
end;

constructor TViewImageSelector.Create(AOwner: TComponent);
begin
  inherited;

  RightLeftButtonWidth := ImageWidth div 20;
  SelectorWidth := ImageWidth - 2 * RightLeftButtonWidth;
  SelectorScaleX := SelectorWidth div 3;
  SelectorScaleY := ImageHeight div 4;
end;

end.
