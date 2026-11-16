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

uses
  SysUtils, Classes,
  CastleGLImages, CastleImages, CastleKeysMouse, CastleWindow, CastleUiControls,
  WindowUnit;

type
  TViewCredits = class(TCastleView)
  private
    Credits: TDrawableImage;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Render; override;
    function Press(const Event: TInputPressRelease): Boolean; override;
  end;
var
  ViewCredits: TViewCredits;

implementation

uses SelectImage;

constructor TViewCredits.Create(AOwner: TComponent);
begin
  inherited;
  Credits := TDrawableImage.Create('castle-data:/credits.jpg', [TRGBImage], true);
end;

destructor TViewCredits.Destroy;
begin
  FreeAndNil(Credits);
  inherited;
end;

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

  Container.View := ViewImageSelector;
  Result := true;
end;

end.
