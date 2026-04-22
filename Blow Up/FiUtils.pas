unit FiUtils;

interface

uses
  Windows, SysUtils, DirectShow9;

function FiLicenceTypeToStr(LicenceType:Integer):String;

function GuidsEqual(G1,G2:TGUID):Boolean;
function MediaSubTypeStr(G:TGUID):String;
function FireIFpsStr(FireIFps:Integer):String;
function FiFpsSupported(FpsMask:Integer;FireIFps:Integer):Boolean;

function FiFpsToFps(FiFPS:Integer):Single;
function FpsToFiFps(Fps:Single):Integer;

implementation

uses
  FireI;

function FiLicenceTypeToStr(LicenceType:Integer):String;
begin
  Case LicenceType of
    LICENCE_TYPE_HASP_VGA   : Result:='VGA';
    LICENCE_TYPE_HASP_PRO   : Result:='Pro';
    LICENCE_TYPE_UB_ADAPTER : Result:='Adapter';
    LICENCE_TYPE_UB_CAMERA  : Result:='Camera';
    LICENCE_TYPE_PK         : Result:='PK';
    LICENCE_TYPE_DEMO       : Result:='Demo';
  end;
end;

function GuidsEqual(G1,G2:TGUID):Boolean;
begin
  Result:=CompareMem(@G1,@G2,SizeOf(TGUID));
end;

function MediaSubTypeStr(G:TGUID):String;
begin
  if GuidsEqual(G,MEDIASUBTYPE_Y800) then Result:='Y8'
  else if GuidsEqual(G,MEDIASUBTYPE_RGB24) then Result:='RGB24'
  else if GuidsEqual(G,MEDIASUBTYPE_RGB32) then Result:='RGB32'
  else if GuidsEqual(G,MEDIASUBTYPE_YUYV) then Result:='YUYV'
  else if GuidsEqual(G,MEDIASUBTYPE_IYUV) then Result:='IYUV'
  else if GuidsEqual(G,MEDIASUBTYPE_YVU9) then Result:='YVU9'
  else if GuidsEqual(G,MEDIASUBTYPE_Y411) then Result:='Y411'
  else if GuidsEqual(G,MEDIASUBTYPE_Y41P) then Result:='Y41P'
  else if GuidsEqual(G,MEDIASUBTYPE_YUY2) then Result:='YUY2'
  else if GuidsEqual(G,MEDIASUBTYPE_YVYU) then Result:='YVYU'
  else if GuidsEqual(G,MEDIASUBTYPE_UYVY) then Result:='UYVY'
  else if GuidsEqual(G,MEDIASUBTYPE_Y211) then Result:='Y211'
  else if GuidsEqual(G,MEDIASUBTYPE_YV12) then Result:='YV12'
  else if GuidsEqual(G,MEDIASUBTYPE_CLPL) then Result:='CLPL'
  else if GuidsEqual(G,MEDIASUBTYPE_CLJR) then Result:='CLJR'
  else if GuidsEqual(G,MEDIASUBTYPE_IF09) then Result:='IF09'
  else if GuidsEqual(G,MEDIASUBTYPE_CPLA) then Result:='CPLA'
  else if GuidsEqual(G,MEDIASUBTYPE_MJPG) then Result:='MJPG'
  else if GuidsEqual(G,MEDIASUBTYPE_TVMJ) then Result:='TVMJ'
  else if GuidsEqual(G,MEDIASUBTYPE_WAKE) then Result:='WAKE'
  else if GuidsEqual(G,MEDIASUBTYPE_CFCC) then Result:='CFCC'
  else if GuidsEqual(G,MEDIASUBTYPE_IJPG) then Result:='IJPG'
  else if GuidsEqual(G,MEDIASUBTYPE_Plum) then Result:='Plum'
  else if GuidsEqual(G,MEDIASUBTYPE_DVCS) then Result:='DVCS'
  else if GuidsEqual(G,MEDIASUBTYPE_DVSD) then Result:='DVSD'
  else if GuidsEqual(G,MEDIASUBTYPE_MDVF) then Result:='MDVF'
  else if GuidsEqual(G,MEDIASUBTYPE_RGB1) then Result:='RGB1'
  else if GuidsEqual(G,MEDIASUBTYPE_RGB4) then Result:='RGB4'
  else if GuidsEqual(G,MEDIASUBTYPE_RGB8) then Result:='RGB8'
  else if GuidsEqual(G,MEDIASUBTYPE_AYUV) then Result:='AYUV'
  else if GuidsEqual(G,MEDIASUBTYPE_AI44) then Result:='AI44'
  else if GuidsEqual(G,MEDIASUBTYPE_IA44) then Result:='IA44'
  else if GuidsEqual(G,MEDIASUBTYPE_Y444) then Result:='Y444'
  else if GuidsEqual(G,MEDIASUBTYPE_RGB565) then Result:='RGB565'
  else if GuidsEqual(G,MEDIASUBTYPE_RGB555) then Result:='RGB555'
  else if GuidsEqual(G,MEDIASUBTYPE_ARGB32) then Result:='ARGB32'
  else if GuidsEqual(G,MEDIASUBTYPE_ARGB1555) then Result:='ARGB1555'
  else if GuidsEqual(G,MEDIASUBTYPE_ARGB4444) then Result:='ARGB4444'
  else Result:='???';
end;

function FireIFpsStr(FireIFps:Integer):String;
begin
  Case FireIFps of
    FPS_NONE  : Result:='None';
    FPS_1_875 : Result:='1.875';
    FPS_3_75  : Result:='3.75';
    FPS_7_5   : Result:='7.5';
    FPS_15    : Result:='15';
    FPS_30    : Result:='30';
    FPS_60    : Result:='60';
    FPS_120   : Result:='120';
  end;
end;

function FiFpsSupported(FpsMask:Integer;FireIFps:Integer):Boolean;
begin
  Result:=(FpsMask and ($80 shr FireIFps))>0;
end;

function FiFpsToFPS(FiFPS:Integer):Single;
begin
  Case FiFPS of
    FPS_NONE  : Result:=0;
    FPS_1_875 : Result:=1.875;
    FPS_3_75  : Result:=3.75;
    FPS_7_5   : Result:=7.5;
    FPS_15    : Result:=15;
    FPS_30    : Result:=30;
    FPS_60    : Result:=60;
    FPS_120   : Result:=120;
  end;
end;

function FpsToFiFps(Fps:Single):Integer;
begin
  if Fps=1.875 then Result:=FPS_1_875
  else if Fps=3.75 then Result:=FPS_3_75
  else if Fps=7.5 then Result:=FPS_7_5
  else if Fps=15 then Result:=FPS_15
  else if Fps=30 then Result:=FPS_30
  else if Fps=60 then Result:=FPS_60
  else if Fps=120 then Result:=FPS_120
  else Result:=FPS_NONE;
end;

end.
