unit CalWarningFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, LCD;

type
  TCalWarningFrm = class(TForm)
    Label1: TLabel;
    Memo: TMemo;
    Label2: TLabel;
    Lcd: TLCD;
    Label3: TLabel;
    Timer: TTimer;
    Shape1: TShape;
    procedure TimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    StartTime : DWord;

    FOnCalDone : TNotifyEvent;

  public
    property OnCalDone:TNotifyEvent read FOnCalDone write FOnCalDone;
    
    procedure Initialize;

  end;

var
  CalWarningFrm        : TCalWarningFrm;
  CalWarningFrmCreated : Boolean =False;

implementation

{$R *.dfm}

uses
  CameraU, Main, BackGndFind;

const
  DelayTime = 9500;

procedure TCalWarningFrm.Initialize;
begin
  FOnCalDone:=nil;
  StartTime:=GetTickCount;
  Timer.Enabled:=True;
end;

procedure TCalWarningFrm.TimerTimer(Sender: TObject);
var
  TimeLeft    : Single;
  TimeElapsed : DWord;
begin
  TimeElapsed:=GetTickCount-StartTime;
  if TimeElapsed>=DelayTime then TimeLeft:=0
  else TimeLeft:=(DelayTime-TimeElapsed)/1000;
  Lcd.Value:=Round(TimeLeft);
  if TimeLeft=0 then begin
    MainFrm.BackGndTimerTimer(nil);
    Close;
  end;
end;

procedure TCalWarningFrm.FormClose(Sender: TObject;  var Action: TCloseAction);
begin
  Action:=caFree;
  if Assigned(FOnCalDone) then FOnCalDone(Self);
end;

procedure TCalWarningFrm.FormCreate(Sender: TObject);
begin
  CalWarningFrmCreated:=True;
end;

procedure TCalWarningFrm.FormDestroy(Sender: TObject);
begin
  CalWarningFrmCreated:=False;
end;

end.
