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
  Classes, SysUtils;

{initialize and show Load screen}
procedure ShowLoadScreen;
{free memory used by Load screen}
procedure FreeLoadScreen;
implementation
uses
  CastleWindow, CastleGLImages, CastleUiControls,
  WindowUnit;

var
  LoadScreenImage: TDrawableImage;

type
  TViewLoad = class(TCastleView)
  public
    procedure Render; override;
  end;
var
  ViewLoad: TViewLoad;

procedure TViewLoad.Render;
begin
  inherited;
  LoadScreenImage.Draw(0, 0, Window.Width, Window.Height);
end;

procedure ShowLoadScreen;
begin
  LoadScreenImage := TDrawableImage.Create('castle-data:/loadscreen.jpg');

  Application.MainWindow.Container.View := ViewLoad;
  Window.Invalidate;
  Application.ProcessAllMessages;
end;

procedure FreeLoadScreen;
begin
  LoadScreenImage.Free;
end;

initialization
  ViewLoad := TViewLoad.Create(Application);
end.

