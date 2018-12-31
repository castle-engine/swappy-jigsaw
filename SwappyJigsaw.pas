{ Copyright (C) 2012-2018 Yevhen Loza

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

{---------------------------------------------------------------------------}

(* Swappy Jigsaw is a simple puzzle game for Linux, Windows and Android
   See README.md for more details
   See README_compile.md for compilation instructions *)

program SwappyJigsaw;

{$IFDEF Windows}{$APPTYPE GUI}{$ENDIF}

uses
  {$IFDEF Linux}CThreads,{$ENDIF}
  InitUnit, WindowUnit;

{$R *.res}

begin
  Window.OpenAndRun;
end.
