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

(* Game mode, showing credits screen (actually, just a JPG image)
   Returns to image Selector on any press *)

unit CreditsScreen;
{$INCLUDE compilerconfig.inc}

interface

{ Stops the game and shows credits until press event }
procedure DisplayCredits;
{ Free up memory, used by Credits image
  in case Player exits when in Credits, to avoid memory leak}
procedure FreeCredits;
implementation
uses
  SysUtils,
  CastleGLImages, CastleImages, CastleFilesUtils, CastleKeysMouse, CastleWindow,
  SelectImage,
  WindowUnit;

var
  { Credits image }
  Credits: TDrawableImage;

{$PUSH}{$WARN 5024 off : Parameter "$1" not used}
procedure CreditsRender(Container: TUIContainer);
begin
  //normally we do this only once, as Window.AutoRedisplay = false
  Credits.Draw(0, 0, Window.Width, Window.Height);
end;

procedure CreditsPress(Container: TUIContainer; const Event: TInputPressRelease);
begin
  FreeAndNil(Credits); //we don't keep the image, as hardly anybody will use it twice :)
  ShowImageSelector;
end;
{$POP}

procedure InitCredits;
begin
  Credits := TDrawableImage.Create(ApplicationData('credits.jpg'), [TRGBImage], true);

  Window.OnPress := @CreditsPress;
  Window.OnRender := @CreditsRender;
end;

procedure DisplayCredits;
begin
  InitCredits; //we init it every time, as "credits" is a seldomly used thing, so no need to waste RAM on preloading
  Window.Invalidate;
end;

procedure FreeCredits;
begin
  FreeAndNil(Credits);
end;

end.
