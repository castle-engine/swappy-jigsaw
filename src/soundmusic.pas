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

(* Load and play sound/music *)

unit SoundMusic;

{$INCLUDE compilerconfig.inc}

interface

var
  { Should the sound be played?
    TODO: replace with procedure MusicUnit.ToggleSound }
  PlaySound: Boolean = true;

procedure ToggleSound;
implementation
uses
  Settings;

procedure ToggleSound;
begin
  PlaySound := not PlaySound;
  SaveConfig;
end;

end.

