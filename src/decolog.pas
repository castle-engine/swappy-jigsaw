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

(* Logging utility supporting different verbosity levels
   Most of it is just a wrapper to CastleLog *)

{$INCLUDE compilerconfig.inc}

unit DecoLog;

interface

{ Initializes Castle Log and display basic info }
procedure InitLog;
procedure FreeLog;
{ Writes a log string
  should be used like Log(true, CurrentRoutine, 'message');}
procedure Log(const aPrefix, aMessage: String);
{............................................................................}
implementation
uses
  SysUtils,
  {$IFDEF WriteLog}Classes, DecoTime,{$ENDIF}
  {$IFDEF LogShaders}CastleGlShaders,{$ENDIF}
  CastleApplicationProperties, CastleLog {%Profiler%};

{$IFDEF WriteLog}
var
  LogStream: TFileStream;
{$ENDIF}

procedure Log(const aPrefix, aMessage: String);
begin
  WriteLnLog(aPrefix, aMessage);
end;

{............................................................................}

procedure InitLog;
begin
  {StartProfiler}

  //initialize the log
  {$IFDEF WriteLog}
  LogStream := TFileStream.Create(NiceDate + '.log', fmCreate);
  InitializeLog(LogStream, ltTime);
  {$ELSE}
  //ApplicationProperties.Version := Version;
  InitializeLog(nil, ltTime);
  {$ENDIF}
  {$IFDEF LogShaders}
  LogShaders := true;
  {$ENDIF}

  {this is basic information, so just output directly}
  WriteLnLog('(i) Compilation Date',{$I %DATE%} + ' Time: ' + {$I %TIME%});
  WriteLnLog('(i) Pointer is', IntToStr(SizeOf(Pointer) * 8) + ' bit');

  {StopProfiler}
end;

{-----------------------------------------------------------------------------}

procedure FreeLog;
begin
  {$IFDEF WriteLog}
  LogStream.Free;
  {$ENDIF}
end;

end.
