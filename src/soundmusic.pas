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
  {}
  FPlaySound: Boolean = true;

{ Should the sound be played? }
function PlaySound: Boolean;
{$IFDEF AndroidVibrate}
function DoVibrate: Boolean;
{$ENDIF}
{toggles sound on/off}
procedure ToggleSound;
{}
procedure InitMusic;
procedure FreeMusic;
implementation
uses
  SysUtils,
  CastleSoundEngine, CastleFilesUtils,
  Settings, Global;

var
  {}
  CurrentMusic: TSoundBuffer;
  {}
  CurrentMusicID: Integer = -1;

function PlaySound: Boolean;
begin
  Result := FPlaySound;
end;

{$IFDEF AndroidVibrate}
function DoVibrate: Boolean;
begin
  Result := PlaySound;
end;
{$ENDIF}


function GetMusicFile: String;
var
  NewMusic: Integer;
begin
  repeat
    NewMusic := RND.Random(4);
  until NewMusic <> CurrentMusicID;
  CurrentMusicID := NewMusic;

  case CurrentMusicID of
    0: Result := 'Daniel_Veesey_-_01_-_Sonata_No_1_in_F_Minor_Op_2_No_1_-_I_Allegro.ogg';
    1: Result := 'Daniel_Veesey_-_02_-_Sonata_No_1_in_F_Minor_Op_2_No_1_-_II_Adagio.ogg';
    2: Result := 'Daniel_Veesey_-_03_-_Sonata_No_1_in_F_Minor_Op_2_No_1_-_III_Menuetto_Allegretto.ogg';
    else
      Result := 'Daniel_Veesey_-_04_-_Sonata_No_1_in_F_Minor_Op_2_No_1_-_IV_Prestissimo.ogg';
  end;

  Result := ApplicationData('music/' + Result);
end;

procedure StartMusic;
begin
  FreeMusic;
  CurrentMusic := SoundEngine.LoadBuffer(GetMusicFile);
  SoundEngine.PlaySound(CurrentMusic);
end;

procedure StopMusic;
begin
  FreeMusic;
end;

procedure ToggleSound;
begin
  FPlaySound := not FPlaySound;
  if FPlaySound then
    StartMusic
  else
    StopMusic;
  SaveConfig;
end;

procedure InitMusic;
begin
  if FPlaySound then
    StartMusic;
end;

procedure FreeMusic;
begin
  SoundEngine.StopAllSources;
  SoundEngine.FreeBuffer(CurrentMusic);
end;

end.

