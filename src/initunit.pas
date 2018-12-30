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

(* Initialize and load all data, start the game *)

unit InitUnit;

{$INCLUDE compilerconfig.inc}

interface

implementation
uses
  SysUtils, CastleWindow, CastleApplicationProperties,
  Game, ImageList, GUI, SelectImage, CreditsScreen,
  WindowUnit, DecoLog, Global, SoundMusic, Settings;

function GetApplicationName: String;
begin
  Result := 'SwappyJigsaw';
end;

procedure ApplicationInitialize;
begin
  Log(CurrentRoutine, 'Init sequence started.');
  LoadImageList;
  LoadConfig;
  InitUI;
  InitGame;
  InitImageSelector;
  InitMusic;
  ShowImageSelector;

  Log(CurrentRoutine, 'Init sequence finished.');
end;

initialization
InitLog;
InitGlobal;
InitWindow;

//init CastleWindow.Application properties
Application.MainWindow := Window;
Application.OnInitialize := @ApplicationInitialize;

//set application name (three copies)
SysUtils.OnGetApplicationName := @GetApplicationName;
ApplicationProperties(true).ApplicationName := GetApplicationName;
Window.Caption := 'Swappy Jigsaw';

finalization
FreeGame;
FreeMusic; //redundant
FreeUI;
FreeImageList;
FreeLog;
FreeGlobal;
FreeCredits;

end.

