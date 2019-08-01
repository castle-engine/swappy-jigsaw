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

(* Initialize and use Window of the game *)

unit WindowUnit;

{$INCLUDE compilerconfig.inc}

interface

uses
  CastleWindow;

var
  { Game window - everything happens here
    We use the lowest type of Window - Base }
  Window: TCastleWindowBase;

{ Create and nitialize game Window
  at Desktop, Window is created with golden section proportions }
procedure InitWindow;
implementation
uses
  SysUtils, DecoLog;

procedure InitWindow;
begin
  Log(CurrentRoutine, 'Initializing window');
  Window := TCastleWindowBase.Create(Application);
  Window.ResizeAllowed := raOnlyAtOpen;
  Window.AutoRedisplay := false;

  Window.Height := 700;
  Window.Width := Round(Window.Height * 1.61);
end;

end.

