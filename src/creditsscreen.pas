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

(* Game mode, showing credits screen (actually, just a JPG image)
   Returns to image Selector on any press *)

unit CreditsScreen;
{$INCLUDE compilerconfig.inc}

interface

{ Stops the game and shows credits until press event }
procedure DisplayCredits;
{ Free up memory, used by Credits image
  in case Player exits when in Credits, to avoid memory leak}
procedure FreeCredits;
implementation
uses
  SysUtils,
  CastleGLImages, CastleImages, CastleKeysMouse, CastleWindow, CastleUiControls,
  SelectImage,
  WindowUnit;

var
  { Credits image }
  Credits: TDrawableImage;

type
  TViewCredits = class(TCastleView)
  public
    procedure Render; override;
    function Press(const Event: TInputPressRelease): Boolean; override;
  end;
var
  ViewCredits: TViewCredits;

procedure TViewCredits.Render;
begin
  inherited;
  //normally we do this only once, as Window.AutoRedisplay = false
  Credits.Draw(0, 0, Window.Width, Window.Height);
end;

function TViewCredits.Press(const Event: TInputPressRelease): Boolean;
begin
  Result := inherited;
  if Result then Exit;

  FreeAndNil(Credits); //we don't keep the image, as hardly anybody will use it twice :)
  Container.View := ViewImageSelector;
  Result := true;
end;

procedure InitCredits;
begin
  Credits := TDrawableImage.Create('castle-data:/credits.jpg', [TRGBImage], true);

  Application.MainWindow.Container.View := ViewCredits;
end;

procedure DisplayCredits;
begin
  InitCredits; //we init it every time, as "credits" is a seldomly used thing, so no need to waste RAM on preloading
  Window.Invalidate;
end;

procedure FreeCredits;
begin
  FreeAndNil(Credits);
end;

initialization
  ViewCredits := TViewCredits.Create(Application);
end.
