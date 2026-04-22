unit Routines;

interface

uses
  StdCtrls, ComCtrls, Forms, Windows, Classes, Graphics, StrUtils, Controls,
  Global;

function  Path:String;
procedure HideTaskBar;
procedure ShowTaskBar;

function LeftMouseBtnDown : Boolean;
function RightMouseBtnDown : Boolean;

function ExtractOnlyFileName(FileName:String):String;

procedure HideCursor;
procedure ShowCursor;
procedure CenterCursor(Form:TForm);

procedure CaptureMouse(Form:TForm);
procedure ReleaseMouse;

function TwoDigitIntStr(I:Integer):String;
function ThreeDigitIntStr(I:Integer):String;
function FourDigitIntStr(I:Integer):String;
function FiveDigitIntStr(I:Integer):String;

function RandomFraction:Single;

function TimeStr(Time:Single):String;
function MinuteSecondStr(Milliseconds:DWord):String;
function VelocityStr(V:Single):String;

function AvailableRam:Single;
function TotalRam:Single;

function ClipToByte(V:Single):Byte;
function MByteStr(Bytes:Integer):String;

procedure InitFontFromFontRecord(Font:TFont;FontRecord:TFontRecord);
procedure InitFontRecordFromFont(var FontRecord:TFontRecord;Font:TFont);
procedure SwapInt(var I1,I2:Integer);
function  SetScreenResolution(Width,Height:Integer):Longint;
function  RandomInteger(V1,V2:Integer):Integer;

procedure ApplyResolution;
procedure RestoreResolution;

function TrackYToCameraY(TrackY:Integer):Integer;
function SafeTrunc(Value:Single):Integer;

implementation

uses
  SysUtils, Jpeg, Math, CameraU;

function Path:String;
begin
  Result:=ExtractFilePath(Application.ExeName);
end;

procedure HideTaskBar;
var
  HTaskBar : THandle;
begin
  HTaskbar:=FindWindow('Shell_TrayWnd',nil);
  if HTaskBar>0 then ShowWindow(HTaskBar,SW_Hide)
end;

procedure ShowTaskBar;
var
  HTaskBar : THandle;
begin
  HTaskbar:=FindWindow('Shell_TrayWnd',nil);
  if HTaskBar>0 then ShowWindow(HTaskBar,SW_Show)
end;

function LeftMouseBtnDown : Boolean;
begin
  Result:=(GetASyncKeyState(VK_LButton)<0);
end;

function RightMouseBtnDown : Boolean;
begin
  Result:=(GetASyncKeyState(VK_RButton)<0);
end;

function ExtractOnlyFileName(FileName:string) : string;
var
  Ext : string;
begin
  Result:=ExtractFileName(FileName);
  Ext:=ExtractFileExt(Result);
  if Ext<>'' then Result:=Copy(Result,1,Length(Result)-Length(Ext));
end;

procedure HideCursor;
begin
  Screen.Cursor:=crNone;
end;

procedure ShowCursor;
begin
  Screen.Cursor:=crDefault;
end;

function TwoDigitIntStr(I:Integer):String;
var
  IStr : String;
begin
  IStr:=IntToStr(I);
  if I<10 then Result:='0'+IStr
  else Result:=IStr;
end;

function ThreeDigitIntStr(I:Integer):String;
var
  IStr : String;
begin
  IStr:=IntToStr(I);
  if I<10 then Result:='00'+IStr
  else if I<100 then Result:='0'+IStr
  else Result:=IStr;
end;

function FourDigitIntStr(I:Integer):String;
var
  IStr : String;
begin
  IStr:=IntToStr(I);
  if I<10 then Result:='000'+IStr
  else if I<100 then Result:='00'+IStr
  else if I<1000 then Result:='0'+IStr
  else Result:=IStr;
end;

function FiveDigitIntStr(I:Integer):String;
var
  IStr : String;
begin
  IStr:=IntToStr(I);
  if I<10 then Result:='0000'+IStr
  else if I<100 then Result:='000'+IStr
  else if I<1000 then Result:='00'+IStr
  else if I<10000 then Result:='0'+IStr
  else Result:=IStr;
end;

function RandomFraction:Single;
begin
  Result:=Random(1001)/1000;
end;

function TimeStr(Time:Single):String;
begin
  Result:=FloatToStrF(Time,ffFixed,9,3);
end;

function VelocityStr(V:Single):String;
begin
  Result:=FloatToStrF(V,ffFixed,9,3);
end;

procedure CaptureMouse(Form:TForm);
var
  ClipRect : TRect;
begin
  ClipRect:=Form.ClientRect;
  ClipCursor(@ClipRect);
end;

procedure ReleaseMouse;
begin
  ClipCursor(nil);
end;

procedure CenterCursor(Form:TForm);
begin
  with Form do SetCursorPos(Left+(Width div 2),Top+(Height div 2));
end;

function AvailableRam:Single;
var
  GlobalMemoryInfo : TMemoryStatus;
begin
// set the size
  GlobalMemoryInfo.dwLength:=SizeOf(GlobalMemoryInfo);

// retrieve memory info
  GlobalMemoryStatus(GlobalMemoryInfo);

  Result:=GlobalMemoryInfo.dwAvailPhys/(1024*1024);;
end;

function TotalRam:Single;
var
  GlobalMemoryInfo : TMemoryStatus;
begin
// set the size
  GlobalMemoryInfo.dwLength:=SizeOf(GlobalMemoryInfo);

// retrieve memory info
  GlobalMemoryStatus(GlobalMemoryInfo);

  Result:=GlobalMemoryInfo.dwTotalPhys/(1024*1024);
end;

function ClipToByte(V:Single):Byte;
begin
  if V>255 then Result:=255
  else Result:=Round(V);
end;

function MinuteSecondStr(Milliseconds:DWord):String;
var
  Minutes : Integer;
  Seconds : Integer;
begin
  Seconds:=Milliseconds div 1000;
  Minutes:=Seconds div 60;
  Seconds:=Seconds-Minutes*60;
  Result:=TwoDigitIntStr(Minutes)+':'+TwoDigitIntStr(Seconds);
end;

function MByteStr(Bytes:Integer):String;
begin
  Result:=FloatToStrF(Bytes/(1024*1024),ffFixed,9,1)+' MB';
end;

procedure InitFontFromFontRecord(Font:TFont;FontRecord:TFontRecord);
begin
  Font.Name:=FontRecord.Name;
  Font.Color:=FontRecord.Color;
  Font.Size:=FontRecord.Size; // not really used
  Font.Style:=FontRecord.Style;
end;

procedure InitFontRecordFromFont(var FontRecord:TFontRecord;Font:TFont);
begin
  FontRecord.Name:=Font.Name;
  FontRecord.Color:=Font.Color;
  FontRecord.Size:=Font.Size; // not really used
  FontRecord.Style:=Font.Style;
end;

procedure SwapInt(var I1,I2:Integer);
var
  Temp : Integer;
begin
  Temp:=I1;
  I1:=I2;
  I2:=Temp;
end;

function SetScreenResolution(Width, Height: integer): Longint;
var
  DeviceMode: TDeviceMode;
begin
  if (Screen.Width=Width) and (Screen.Height=Height) then Exit;
  with DeviceMode do begin
    dmSize := SizeOf(TDeviceMode);
    dmPelsWidth:=Width;
    dmPelsHeight:=Height;
    dmFields:=DM_PELSWIDTH or DM_PELSHEIGHT;
  end;
  Result:=ChangeDisplaySettings(DeviceMode,CDS_UPDATEREGISTRY);
end;

function RandomInteger(V1,V2:Integer):Integer;
begin
  if V1<V2 then Result:=V1+Random(V2-V1+1)
  else Result:=V2+Random(V1-V2+1);
end;

procedure ApplyResolution;
begin
Exit;
  if LowRes then SetScreenResolution(NativeW div 2,NativeH div 2)
  else SetScreenResolution(NativeW,NativeH);
end;

procedure RestoreResolution;
begin
Exit;
  SetScreenResolution(NativeW,NativeH);
end;

function TrackYToCameraY(TrackY:Integer):Integer;
begin
  Result:=Round(TrackY*Camera.ImageH/TrackH);
end;

function SafeTrunc(Value:Single):Integer;
begin
  Result:=Round(Value);
  if Value>=0 then begin
    if Result>Value then Dec(Result);
  end
  else begin
    if Result<Value then Inc(Result);
  end;
end;

end.





