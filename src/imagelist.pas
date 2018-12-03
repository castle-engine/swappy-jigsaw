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

unit ImageList;
{$INCLUDE compilerconfig.inc}

interface

uses
  CastleUtils;

type
  {}
  TImageData = record
    URL: String;
    Hits: Integer;
  end;

type
  TImageDataList = specialize TStructList<TImageData>;

var
  ImageDataList: TImageDataList;

procedure LoadImageList;
procedure FreeImageList;
implementation

procedure LoadImageList;
  function Img(const aString: String): TImageData;
  begin
    Result.URL := aString;
    Result.Hits := 0;
  end;
begin
  ImageDataList := TImageDataList.Create;
  With ImageDataList do
  begin
    Add(Img('cambridge-city-architecture-1503401533iOz_CC0_by_George_Hodan.jpg'));
    Add(Img('big-ben-clockface-871280326109rQZh_CC0_by_Vera_Kratochvil.jpg'));
    Add(Img('essential-oils-flower_CC0_by_mohamed_mohamed_mahmoud_hassan.jpg'));
    //Add(Img(''));
  end;
end;

procedure FreeImageList;
begin
  ImageDataList.Free;
end;

end.

