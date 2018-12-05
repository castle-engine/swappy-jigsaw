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

unit WindowUnit;

{$INCLUDE compilerconfig.inc}

interface

uses
  CastleWindow;

var
  Window: TCastleWindowCustom;

procedure InitWindow;
implementation
uses
  SysUtils, DecoLog;

procedure InitWindow;
begin
  Log(CurrentRoutine, 'Initializing window');
  Window := TCastleWindowCustom.Create(Application);
  Window.ResizeAllowed := raOnlyAtOpen;
  Window.AutoRedisplay := false;

  Window.Height := 700;
  Window.Width := Round(Window.Height * 1.61);
end;

end.

