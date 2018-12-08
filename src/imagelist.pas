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
uses
  SysUtils,
  DecoLog;

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
    Add(Img('2510-1271756952NRs5_CC0_by_Lebin_Yuriy_[crop].jpg'));
    Add(Img('byodo-in-temple_CC0_by_Kathryn_Smith_Mrs_[crop].jpg'));
    Add(Img('new-york-skyline-at-night-1539859690ef4_CC0_by_Petr_Kratochvil_[crop].jpg'));
    Add(Img('dining-room-with-view_CC0_by_Kirk_F_[crop].jpg'));
    Add(Img('hong-kong_CC0_by_Jean_Beaufort_[crop].jpg'));
    Add(Img('lower-manhattan-view-15173081023Vc_CC0_by_Petr_Kratochvil_[crop].jpg'));
    Add(Img('lowther-castle-1538849370MBj_CC0_by_George_Hodan_[crop,gmic].jpg'));
    Add(Img('cracow-at-night-1334105008JKg_CC0_by_Bobby_Mikul_[crop,gmic].jpg'));
    Add(Img('macro-yellow-flower-vine-blossoms_CC0_by_Summer_Woods_[gmic].jpg'));
    Add(Img('kokkari-1523011951PCt_CC0_by_Petr_Kratochvil_[crop,color].jpg'));
    Add(Img('liverpool-architecture-1484316826r14_CC0_by_George_Hodan_[crop,gmic].jpg'));
    Add(Img('mall-1510328598BWm_CC0_by_Jean_Beaufort_[gmic,color].jpg'));
    Add(Img('moscow-metro-1491061867sJM_CC0_by_Svetlana_Tikhonova_[gmic,color].jpg'));
    Add(Img('statues-on-westminster-abbey-87128032616715Pc_CC0_by_Vera_Kratochvil_[color].jpg'));
    Add(Img('westminster-abbey-11297883825gkU_CC0_by_Petr_Kratochvil.jpg'));
    Add(Img('old-house-architecture-1466607823ymL_CC0_by_George_Hodan_[crop,color].jpg'));
    Add(Img('old-house-architecture-1466607475LQv_CC0_by_George_Hodan_[crop,color].jpg'));
    Add(Img('one-world-trade-center-1493879202eaY_CC0_by_CC0_Community_[color].jpg'));
    Add(Img('hall-with-hundred-pillers_CC0_by_RAJESH_misra_[color].jpg'));
    Add(Img('two-pink-daisy-blossoms-vines_CC0_by_Summer_Woods_[gmic,crop,color].jpg'));
    Add(Img('train-station-platform-1475044035rCp_CC0_by_George_Hodan.jpg'));
    Add(Img('york-a-town-in-england-1465385718lyN_CC0_by_George_Hodan.jpg'));
    Add(Img('log-home-1492017760Yv7_CC0_by_Kirk_F.jpg'));
    Add(Img('london-tube_CC0_by_Jean_Beaufort.jpg'));
    Add(Img('elegant-log-home_CC0_by_Kirk_F.jpg'));
    Add(Img('interior-of-the-uss-intrepid-1475219268cnM_CC0_by_George_Hodan_[color,crop].jpg'));
    Add(Img('new-york-street-photography-14767774038Dd_CC0_by_George_Hodan.jpg'));
    Add(Img('new-york-city-public-library-1465661149YQr_CC0_by_George_Hodan_[crop,color].jpg'));
    Add(Img('china-town-liverpool-1525143791tHs_CC0_by_George_Hodan_[crop,color].jpg'));
    Add(Img('room-interior_CC0_by_RAJESH_misra_[crop,gmic].jpg'));
    Add(Img('palazzo-reale-di-napoli_CC0_by_Enzo_Abramo_[gmic,color].jpg'));
    Add(Img('walkway-seabus-terminal-vancouver_CC0_by_Patricia_Keith_[color,gmic].jpg'));
    Add(Img('wellington-arch-1476431714529_CC0_by_George_Hodan_[gmic,color,trapeze].jpg'));
    Add(Img('train-station-1506005295b7I_CC0_by_Jean_Beaufort_[color].jpg'));
    Add(Img('storing-and-canning-room_CC0_by_Kirk_F_[color].jpg'));
    Add(Img('street-1373969121UmD_CC0_by_George_Hodan.jpg'));
    Add(Img('palatial-charm_CC0_by_RAJESH_misra_[gmic,color].jpg'));
    Add(Img('ripley-castle-1519492524MBx_CC0_by_George_Hodan_[crop,color].jpg'));
    Add(Img('moscow-metro-1493829074b5V_CC0_by_Svetlana_Tikhonova_[color,crop].jpg'));
    Add(Img('grand-central-station-in-new-york-1467650581Sca_CC0_by_George_Hodan_[color].jpg'));
    {
    Add(Img(''));
    }
  end;
  Log(CurrentRoutine, 'Images loaded: ' + IntToStr(ImageDataList.Count));
end;

procedure FreeImageList;
begin
  ImageDataList.Free;
end;

end.

