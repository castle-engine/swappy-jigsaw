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

unit InitUnit;

{$INCLUDE compilerconfig.inc}

interface

{uses
  Classes, SysUtils;}

implementation
uses
  SysUtils, CastleWindow, CastleApplicationProperties,
  Game, ImageList, GUI, SelectImage,
  DecoTime, WindowUnit, DecoLog, Global;

function GetApplicationName: String;
begin
  Result := 'SwappyJigsaw';
end;

procedure ApplicationInitialize;
begin
  Log(CurrentRoutine, 'Init sequence started.');
  LoadImageList;
  InitUI;
  InitGame;
  InitImageSelector;
  ShowImageSelector;

  Log(CurrentRoutine, 'Init sequence finished.');
end;

initialization
InitLog;
InitTime;
InitGlobal;
InitWindow;

//init CastleWindow.Application properties
Application.MainWindow := Window;
Application.OnInitialize := @ApplicationInitialize;

//set application name (tree copies)
SysUtils.OnGetApplicationName := @GetApplicationName;
ApplicationProperties(true).ApplicationName := GetApplicationName;
Window.Caption := 'Swappy Jigsaw';

finalization
FreeGame;
FreeUI;
FreeImageList;
FreeLog;
FreeGlobal;
FreeTime;

end.

