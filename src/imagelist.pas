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
    Add(Img('restaurant-at-night_CC0_by_Petr_Kratochvil.jpg'));
    Add(Img('1-1257247268bJAm_CC0_by_Petr_Kratochvil.jpg'));
    Add(Img('brooklyn-bridge-1506000547u6j_CC0_by_Petr_Kratochvil.jpg'));
    Add(Img('cambridge-city-architecture-1503400732zB3_CC0_by_George_Hodan.jpg'));
    Add(Img('cambridge-city-architecture-1503400878nuX_CC0_by_George_Hodan.jpg'));
    Add(Img('new-york-city-public-library-1465662237tfk_CC0_by_George_Hodan.jpg'));
    Add(Img('offices-at-night-11287917613w4vZ_CC0_by_Petr_Kratochvil.jpg'));
    Add(Img('orloj-1382994612OFQ_CC0_by_Rostislav_Kralik.jpg'));
    Add(Img('prague-astronomical-clock-detail-871291743639AGq_CC0_by_Vera_Kratochvil.jpg'));
    Add(Img('sky-forest-foliage-green-natu_CC0_by_C_Colourin.jpg'));
    Add(Img('stonehenge-1525960775BCA_CC0_by_kai_Stachowiak.jpg'));
    Add(Img('st-peter-church-harrogate_CC0_by_George_Hodan.jpg'));
    Add(Img('st-patrick-cathedral-interior-1540381157SUU_CC0_by_Petr_Kratochvil.jpg'));
    Add(Img('sydney-opera-house-15088558360Pr_CC0_by_Jean_Beaufort.jpg'));
    Add(Img('traditional-dutch-houses-11294081342QxR_CC0_by_Petr_Kratochvil.jpg'));
    Add(Img('wooden-pillars_CC0_by_George_Hodan.jpg'));
    Add(Img('2185-1273155466DXV3_CC0_by_Bobby_Mikul.jpg'));
    Add(Img('architecture-from-plzen-1502471957Hf0_CC0_by_George_Hodan.jpg'));
    Add(Img('chicago-cloud-gate-1479046062kHv_CC0_by_Petr_Kratochvil.jpg'));
    Add(Img('colosseum-in-rome_CC0_by_Jean_Beaufort.jpg'));
    Add(Img('cottage-door-and-window_CC0_by_Vera_Kratochvil.jpg'));
    Add(Img('dark-tunnel-1540991323WwN_CC0_by_Petr_Kratochvil.jpg'));
    Add(Img('gate-to-manhattan-21851292200398jhP_CC0_by_Bobby_Mikul.jpg'));
    Add(Img('interior-of-the-glasgow-cathedral-14741054659T6_CC0_by_George_Hodan.jpg'));
    Add(Img('log-cabin-bathroom_CC0_by_Kirk_F.jpg.jpg'));
    Add(Img('myerson-symphony-hall-auditorium_CC0_by_Jean_Beaufort.jpg'));
    Add(Img('moscow-metro-1491063019StZ_CC0_by_Svetlana_Tikhonova.jpg'));
    {
    Add(Img(''));
    Add(Img(''));
    Add(Img(''));
    Add(Img(''));
    }
    //Add(Img(''));
  end;
end;

procedure FreeImageList;
begin
  ImageDataList.Free;
end;

end.

