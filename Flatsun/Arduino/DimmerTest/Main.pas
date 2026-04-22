unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, NBFill, IdGlobal, CPDrv, StdCtrls, AprSpin, AprChkBx,
  LCD, ComCtrls;

type
  TMainFrm = class(TForm)
    ComPort: TCommPortDriver;
    ReadBtn: TButton;
    Timer: TTimer;
    AutoCB: TAprCheckBox;
    Lcd: TLCD;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure ComPortReceiveData(Sender: TObject; DataPtr: Pointer;
      DataSize: Cardinal);
    procedure ReadBtnClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure AutoCBClick(Sender: TObject);

  private

  public
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

procedure TMainFrm.FormCreate(Sender: TObject);
var
  PostFix : String;
begin
  ComPort.Connect;
  ComPort.Port:=pnCom4;
  PostFix:=' on '+ComPort.PortName;
  if ComPort.Connected then StatusBar.SimpleText:='Connected '+PostFix
  else StatusBar.SimpleText:='Unable to connect '+PostFix;
end;

procedure TMainFrm.ComPortReceiveData(Sender: TObject; DataPtr: Pointer;
  DataSize: Cardinal);
var
  Hi,Lo,V : Integer;
  BytePtr : PByte;
  RxStr   : String;
  Buffer : TBytes;
begin
  Caption:=IntToStr(GetTickCount);
  BytePtr:=PByte(DataPtr);
  Lcd.Value:=BytePtr^;
end;

procedure TMainFrm.ReadBtnClick(Sender: TObject);
var
  Data : Byte;
begin
  Data:=7;
  ComPort.SendData(@Data,1);
end;

procedure TMainFrm.TimerTimer(Sender: TObject);
begin
  ReadBtnClick(nil);
end;

procedure TMainFrm.AutoCBClick(Sender: TObject);
begin
  Timer.Enabled:=AutoCB.Checked;
end;

end.


