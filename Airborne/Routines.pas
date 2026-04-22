unit Routines;

interface

uses
  Forms, SysUtils, StdCtrls, Graphics, Classes, Controls, ShellApi, Windows,
  Global;

function Path:String;

procedure HideTaskBar;
procedure ShowTaskBar;
procedure HideStartButton;
procedure ShowStartButton;

function LeftMouseBtnDown : Boolean;
function MiddleMouseBtnDown : Boolean;
function RightMouseBtnDown : Boolean;

function KeyPressed(Key:Integer):Boolean;
function SetScreenResolution(Width, Height: integer): Longint;

function GoodTextureW(W:Integer):Integer;

function RGBColorToColor(RGBColor:TRGBColor):TColor;
function ColorToRGBColor(Color:TColor):TRGBColor;

function ClipToByte(V:Single):Byte;

function TwoDigitIntStr(I:Integer):String;
function ThreeDigitIntStr(I:Integer):String;
function FourDigitIntStr(I:Integer):String;

procedure PlaceFormInWindow(Form:TForm;Window:TWindow);
procedure CenterFormInWindow(Form:TForm;Window:TWindow);

function MetreStr(V:Single):String;

function RandomSingle(V1,V2:Single):Single;

implementation

function RandomSingle(V1,V2:Single):Single;
var
  F : Single;
begin
  F:=Random(1001)/1000;
  Result:=V1+F*(V2-V1);
end;

function MetreStr(V:Single):String;
begin
  Result:=FloatToStrF(V,ffFixed,9,2);
end;

function ClipToByte(V:Single):Byte;
begin
  if V<0 then Result:=0
  else if V>255 then Result:=255
  else Result:=Round(V);
end;

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

procedure HideStartButton;
begin
  ShowWindow(FindWindow('Button','Start'),SW_HIDE);
end;

procedure ShowStartButton;
begin
  ShowWindow(FindWindow('Button','Start'),SW_SHOW);
end;

function SetScreenResolution(Width, Height: integer): Longint;
var
  DeviceMode: TDeviceMode;
begin
  with DeviceMode do begin
    dmSize := SizeOf(TDeviceMode);
    dmPelsWidth:=Width;
    dmPelsHeight:=Height;
    dmFields:=DM_PELSWIDTH or DM_PELSHEIGHT;
  end;
  Result:=ChangeDisplaySettings(DeviceMode,CDS_UPDATEREGISTRY);
end;

function LeftMouseBtnDown : Boolean;
begin
  Result:=(GetASyncKeyState(VK_LButton)<0);
end;

function MiddleMouseBtnDown : Boolean;
begin
  Result:=(GetASyncKeyState(VK_MButton)<0);
end;

function RightMouseBtnDown : Boolean;
begin
  Result:=(GetASyncKeyState(VK_RButton)<0);
end;

function KeyPressed(Key:Integer):Boolean;
begin
  Result:=(GetASyncKeyState(Key)<0);
end;

// the textures must be 4 byte aligned in width
function GoodTextureW(W:Integer):Integer;
begin
  Result:=(W shr 2) shl 2;

// make sure its not smaller
  if Result<W then Inc(Result,4);
end;

function RGBColorToColor(RGBColor:TRGBColor):TColor;
var
  R,G,B : Byte;
begin
  R:=Round(RGBColor.R*255);
  G:=Round(RGBColor.G*255);
  B:=Round(RGBColor.B*255);
  Result:=(B shl 16)+(G shl 8)+R;
end;

function ColorToRGBColor(Color:TColor):TRGBColor;
begin
  Result.B:=((Color and $FF0000) shr 16)/255;
  Result.G:=((Color and $00FF00) shr 8)/255;
  Result.R:=(Color and $0000FF)/255;
end;

function TwoDigitIntStr(I:Integer):String;
begin
  if I<10 then Result:='0'+IntToStr(I)
  else Result:=IntToStr(I);
end;

function ThreeDigitIntStr(I:Integer):String;
begin
  if I<10 then Result:='00'+IntToStr(I)
  else if I<100 then Result:='0'+IntToStr(I)
  else Result:=IntToStr(I);
end;

function FourDigitIntStr(I:Integer):String;
begin
  if I<10 then Result:='000'+IntToStr(I)
  else if I<100 then Result:='00'+IntToStr(I)
  else if I<1000 then Result:='0'+IntToStr(I)
  else Result:=IntToStr(I);
end;

procedure PlaceFormInWindow(Form:TForm;Window:TWindow);
begin
  with Window do begin
    Form.Left:=Left;
    Form.Top:=Top;
    Form.Width:=Width;
    Form.Height:=Height;
  end;
end;

procedure CenterFormInWindow(Form:TForm;Window:TWindow);
begin
  with Form do begin
    Left:=Window.Left+(Window.Width-Width) div 2;
    if Left<0 then Left:=0;
    Top:=Window.Top+(Window.Height-Height) div 2;
    if Top<0 then Top:=0;
  end;
end;

end.
