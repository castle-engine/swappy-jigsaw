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
  LoadScreen,
  Game, ImageList, GUI, SelectImage, CreditsScreen,
  WindowUnit, DecoLog, Global, SoundMusic, Settings;

procedure ApplicationInitialize;
begin
  Log(CurrentRoutine, 'Init sequence started.');

  ViewLoad := TViewLoad.Create(Application);
  Application.MainWindow.Container.View := ViewLoad;
  { Make sure to render load screen now.
    This is a hack to force it -- not guaranteed to work on all platforms,
    and processing messages now assumes that ViewLoad handles no input. }
  Window.Invalidate;
  Application.ProcessAllMessages;

  LoadImageList;
  LoadConfig;
  InitUI;

  { create views (except ViewLoad, created earlier) }
  ViewImageSelector := TViewImageSelector.Create(Application);
  ViewCredits := TViewCredits.Create(Application);
  ViewLoad := TViewLoad.Create(Application);
  ViewGame := TViewGame.Create(Application);

  InitMusic;

  Window.Container.View := ViewImageSelector;

  Log(CurrentRoutine, 'Init sequence finished.');
end;

initialization
InitLog;
InitGlobal;
InitWindow;

//init CastleWindow.Application properties
Application.MainWindow := Window;
Application.OnInitialize := @ApplicationInitialize;

ApplicationProperties.ApplicationName := 'SwappyJigsaw';

Window.Caption := 'Swappy Jigsaw';

finalization
FreeMusic; //redundant
FreeUI;
FreeImageList;
FreeLog;
FreeGlobal;

end.

