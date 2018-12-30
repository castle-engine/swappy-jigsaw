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

(* Read/Write game configuration/settings *)

unit Settings;

{$INCLUDE compilerconfig.inc}

interface

{ Save images solution statistics and configuration to disk }
procedure SaveConfig;
{ Load images solution statistics and configuration from disk }
procedure LoadConfig;

implementation
uses
  CastleConfig,
  ImageList, DecoLog, SoundMusic;

procedure SaveConfig;
var
  I: TImageData;
begin
  Log(CurrentRoutine, 'Saving configruation...');
  for I in ImageDataList do
    UserConfig.SetValue(I.URL, I.Hits);
  UserConfig.SetValue('$SOUND_ON', PlaySound);
  UserConfig.Save;
end;

procedure LoadConfig;
var
  i: Integer;
begin
  Log(CurrentRoutine, 'Reading configruation...');
  UserConfig.Load;
  for i := 0 to Pred(ImageDataList.Count) do
    ImageDataList[i].Hits := UserConfig.GetValue(ImageDataList[i].URL, 0);
  FPlaySound := UserConfig.GetValue('$SOUND_ON', true);
end;

end.

