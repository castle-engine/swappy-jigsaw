{Copyright (C) 2018 Yevhen Loza

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.}

{---------------------------------------------------------------------------}

(* Compiler directives/options to include in every unit *)

{====================== PASCAL-SPECIFIC DIRECTIVES =========================}

{$SMARTLINK ON} // Enable smart-linking

{$MODE objfpc} // FreePascal style code
{$H+} // AnsiStrings
{$J-} // non-writeable constants
{$COPERATORS ON} // allow += style operators, I like them
{$GOTO OFF} // Disallow goto and label
{$EXTENDEDSYNTAX ON} //allow discarding function result

{ Write heap trace to file or to log? }
//{$DEFINE HEAP_FILE}

{ Use simple corba interfaces }
{$INTERFACES corba}

{ Can use definition of `procedure is nested` }
{$MODESWITCH nestedprocvars}

{================================ MOBILE-OS =================================}

{ Determines whether we're running a Desktop or Mobile OS
  used to optimize code concerning input and memory usage }
{$IFDEF ANDROID}{$DEFINE MOBILE}{$ENDIF}
{$IFDEF IOS}{$DEFINE MOBILE}{$ENDIF}
{$IFNDEF MOBILE}{$DEFINE DESKTOP}{$ENDIF}

{============================== ENABLE MACRO ================================}

{ Activate useful macros }
{$INCLUDE macro.inc}

