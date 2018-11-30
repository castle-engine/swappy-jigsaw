{ Copyright (C) 2012-2018 Michalis Kamburelis, Yevhen Loza

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

(* Crop of Castle Game Engine Time utilities plus a threaded timer.
   Provides for accurate and fast time access, hopefully thread-safe :)
   GetNow should be used to access immediate time value.
   Everywhere possible, DecoNow and DecoNowWorld should be used (updated once per frame).
   GetNowThread and ForceGetNowThread are very specific and should be used
   only in extremely time-critical routines often calculating time like World.Manage *)

{$INCLUDE compilerconfig.inc}

unit DecoTime;

{$DEFINE UseFloatTimer}

interface

uses
  {$ifdef MSWINDOWS} Windows, {$endif}
  {$ifdef UNIX} Unix, {$endif}
  CastleTimeUtils;

type
  DTime = TFloatTime;
  {see note for CastleTimeUtils.TTimerResult}
  DIntTime = int64;

  DThreadedTime = {$IFDEF UseFloatTimer}DTime{$ELSE}DIntTime{$ENDIF};

var
  { Analogue to Now function, but a fast-access variable, representing
    current global time (time where animations take place)
    works ~200 times faster than SysUtils.Now so should be used anywhere possible
    Updated once per frame}
  DecoNow: DTime;
  DeltaT: DTime;
  FrameStart: DThreadedTime;

{ Advance time for the frame }
procedure doTime;
{ Gets Timer value from some "starting point" in a thread-safe way }
function GetNow: DTime; TryInline
function GetNowInt: DIntTime; TryInline
{ This is a less accurate but accelerated (~130 times) version
  of the timer by using threads. Should be used after ForceGetNowThread.
  Should be used only in time-critical cases, such as World.Manage }
function GetNowThread: DThreadedTime; TryInline
{ Forces initialization of the threaded timer value. }
function ForceGetNowThread: DThreadedTime; TryInline

{ Returns a nice date and time as a String (e.g. for naming files) }
function NiceDate: String;
{ Reset time to safe values }
procedure ResetTime;
{ Initialize Time routines/classes }
procedure InitTime;
{ Free Time routines/classes }
procedure FreeTime;
{.......................................................................}
implementation

uses
  SysUtils, Classes, {$IFDEF Windows}SyncObjs,{$ENDIF}
  DecoLog {%Profiler%};

function NiceDate: String;
begin
  Result := FormatDateTime('YYYY-MM-DD_hh-nn-ss', Now); //the only place where I'm using SysUtils.Now
end;

{----------------------------------------------------------------------------}

var
  LastGlobalTime: DTime = -1;

procedure doTime;
begin
  DecoNow := GetNow;
  if LastGlobalTime = -1 then
    LastGlobalTime := DecoNow;
  DeltaT := DecoNow - LastGlobalTime;

  LastGlobalTime := DecoNow;

  {this gets threaded time for start of the frame
   and also forces initialization of the timer thread,
   because if not initialized frequently enough it may return wrong values.
   well, nothing critical may happen, but let's be on a safe side}
  FrameStart := ForceGetNowThread;
end;

{----------------------------------------------------------------------------}

procedure ResetTime;
begin
  DecoNow := GetNow;
  LastGlobalTime := DecoNow;
  DeltaT := 0;
  FrameStart := ForceGetNowThread;
end;

{================================= TIMERS ===================================}

{$IFDEF Windows}
{************************* WINDOWS TIME **************************************}
type
  TTimerFrequency = int64;
  TTimerState = (tsQueryPerformance, tsGetTickCount64);

var
  FTimerState: TTimerState;
  TimerFrequency: TTimerFrequency;
  TimerLock: TCriticalSection;  //we'll need a critical section as we access FTimerState.

function Timer: DIntTime; TryInline
var
  QueryPerformance: Boolean;
begin
  TimerLock.Acquire;   //maybe, this is redundant, but let it be here for now...
  QueryPerformance := FTimerState = tsQueryPerformance;
  TimerLock.Release;

  if QueryPerformance then
    QueryPerformanceCounter(
{$hints off}
      Result
{$hints on}
      )
  else
    {in case of ancient Windows version fall back to GetTickCount :)}
    Result :=
{$warnings off}
      GetTickCount64
{$warnings on}
  ;
end;

{$ENDIF}

{$IFDEF Unix}
{************************* UNIX TIME **************************************}

type
  TTimerFrequency = longword;

const
  TimerFrequency: TTimerFrequency = 1000000;

function Timer: DIntTime; TryInline
var
  tv: TTimeval;
begin
  FpGettimeofday(@tv, nil);
  Result := int64(tv.tv_sec) * 1000000 + int64(tv.tv_usec);
  {overflows may occur here, as Thaddy@LazarusForum suggests}
end;

{$ENDIF}

{============================= GET TIME DIRECTLY =============================}

function GetNow: DTime; TryInline
begin
  Result := Timer / TimerFrequency;
end;

function GetNowInt: DIntTime; TryInline
begin
  Result := Timer;
end;

{========================== GET TIME IN A THREAD =============================}

type
  TTimerThread = class(TThread)
  protected
    procedure Execute; override;
  public
    Time: DIntTime;
  end;

var
  ThreadedTimer: TTimerThread;

procedure TTimerThread.Execute;
begin
  Time := Timer;
end;

{----------------------------------------------------------------------------}

var
  LastTime: DThreadedTime;

function GetNowThread: DThreadedTime; TryInline
begin
  if ThreadedTimer.Finished then
  begin
    LastTime := ThreadedTimer.Time{$IFDEF UseFloatTimer} / TimerFrequency{$ENDIF};
    ThreadedTimer.Start;
  end;
  Result := LastTime;
end;

{----------------------------------------------------------------------------}

{ This procedure forces correct initialization of ThreadedTimer
  and must always be used once before starting accessing the GetNowThread sequentially
  so that the first value will be correct (otherwise it might be extermely wrong,
  which is bad for World.Manage) }
function ForceGetNowThread: DThreadedTime; TryInline
begin
  if ThreadedTimer.Finished then
  begin
    LastTime := {$IFDEF UseFloatTimer}GetNow{$ELSE}GetNowInt{$ENDIF};
    ThreadedTimer.Start;
  end;
  Result := LastTime;
end;

{.............................................................................}

{$IFDEF Windows}
procedure InitWindowsTimer;
begin
  if QueryPerformanceFrequency(TimerFrequency) then
    FTimerState := tsQueryPerformance
  else
  begin
    FTimerState := tsGetTickCount64;
    TimerFrequency := 1000;
  end;
end;
{$ENDIF}

procedure InitTime;
begin
  //create threaded timer and run it immediately to make sure everything is initialized properly
  ThreadedTimer := TTimerThread.Create(true);
  ThreadedTimer.Priority := tpLower;
  ThreadedTimer.FreeOnTerminate := false;
  //ForceGetNowThread;
  FrameStart := -1;

  {$IFDEF Windows}
  //initialize the timer in Windows and determine TimerFrequency
  InitWindowsTimer;
  TimerLock := TCriticalSection.Create;
  {$ENDIF}

  doTime; //init all timer variables
end;

{------------------------------------------------------------------------------}

procedure FreeTime;
begin
  ThreadedTimer.Free;
  {$IFDEF Windows}
  TimerLock.Free;
  {$ENDIF}
end;

end.
