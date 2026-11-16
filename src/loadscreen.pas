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

(* Just load and show an image before the game loads *)

unit LoadScreen;
{$INCLUDE compilerconfig.inc}

interface

uses
  Classes, SysUtils,
  CastleWindow, CastleGLImages, CastleUiControls,
  WindowUnit;

type
  TViewLoad = class(TCastleView)
  private
    LoadScreenImage: TDrawableImage;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Render; override;
  end;

var
  ViewLoad: TViewLoad;

implementation

constructor TViewLoad.Create(AOwner: TComponent);
begin
  inherited;
  LoadScreenImage := TDrawableImage.Create('castle-data:/loadscreen.jpg');
end;

destructor TViewLoad.Destroy;
begin
  LoadScreenImage.Free;
  inherited;
end;

procedure TViewLoad.Render;
begin
  inherited;
  LoadScreenImage.Draw(0, 0, Window.Width, Window.Height);
end;

end.

