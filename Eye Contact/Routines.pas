unit Routines;

interface

uses
  StdCtrls, ComCtrls, Forms, Windows, Classes, Graphics, StrUtils, Controls;

function  Path:String;
procedure HideTaskBar;
procedure ShowTaskBar;

function LeftMouseBtnDown : Boolean;
function RightMouseBtnDown : Boolean;

function ExtractOnlyFileName(FileName:String):String;
function QuickTimeStringToSeconds(QTStr:String):Single;
function QuickTimeStringToFrames(QTStr:String):Integer;

procedure HideCursor;
procedure ShowCursor;

function ThreeDigitIntStr(I:Integer):String;
function FourDigitIntStr(I:Integer):String;

function RandomFraction:Single;

function TimeStr(Time:Single):String;
function VelocityStr(V:Single):String;

implementation

uses
  SysUtils, Jpeg, Math, Global;

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

// 12345678901234567890
// 0:00:00:11.1116/2500
// ?:HH:MM:SS.FFFF/DDDD
function QuickTimeStringToSeconds(QTStr:String):Single;
var
  SubStr           : String;
  Fraction,Divisor : Integer;
  Hours,Minutes    : Integer;
  Seconds          : Single;
  SlashI           : Integer;
begin
  SubStr:=Copy(QTStr,3,2);
  Hours:=StrToInt(SubStr);
  SubStr:=Copy(QTStr,6,2);
  Minutes:=StrToInt(SubStr);
  SubStr:=Copy(QTStr,9,2);
  Seconds:=StrToFloat(SubStr);
  SlashI:=PosEx('/',QTStr,12);
  if SlashI>0 then begin
    SubStr:=Copy(QTStr,12,SlashI-12);
    Fraction:=StrToInt(SubStr);
    SubStr:=Copy(QTStr,SlashI+1,Length(QTStr)-SlashI);
    Divisor:=StrToInt(SubStr);
    Seconds:=Seconds+Fraction/Divisor;
  end;
  Result:=Hours*3600+Minutes*60+Seconds;
end;

function QuickTimeStringToFrames(QTStr:String):Integer;
var
  Seconds : Single;
begin
  Seconds:=QuickTimeStringToSeconds(QTStr);
  Result:=1+Round(Seconds*VideoFPS);
end;

procedure HideCursor;
begin
  Screen.Cursor:=crNone;
end;

procedure ShowCursor;
begin
  Screen.Cursor:=crDefault;
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

end.






