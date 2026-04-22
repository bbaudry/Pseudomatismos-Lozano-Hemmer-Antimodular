unit CalibrateFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, PBar;

type
  TCalibrateFrm = class(TForm)
    ProgressBar: TAprProgBar;
    PaintBox: TPaintBox;
    Timer: TTimer;
    procedure TimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    Bmp               : TBitmap;
    StartTime         : DWord;
    OldNewCameraFrame : TNotifyEvent;
    WaitingForCamera  : Boolean; 

    procedure NewCameraFrame(Sender:TObject);
    procedure DrawBmp;

  public
    procedure Initialize;
  end;

var
  CalibrateFrm: TCalibrateFrm;

implementation

{$R *.dfm}

uses
  CameraU, SegmenterU, BmpUtils;

procedure TCalibrateFrm.Initialize;
var
  Settings : TAvtDriverSettings;
begin
  Bmp:=CreateSmallBmp;
  OldNewCameraFrame:=Camera.OnNewFrame;
  Camera.OnNewFrame:=NewCameraFrame;

  Camera.SetAllAvtControlsToAuto;
  WaitingForCamera:=True;
  StartTime:=GetTickCount;
  Timer.Enabled:=True;
end;

procedure TCalibrateFrm.TimerTimer(Sender: TObject);
var
  Percent : Integer;
begin
  if WaitingForCamera then begin
    Percent:=Round(100*(GetTickCount-StartTime)/2000);
    if Percent>=100 then begin
      WaitingForCamera:=False;
      Camera.SetAllAvtControlsToFixed;
      Segmenter.ForceAllToBackGnd(Camera.SmallBmp);
      ProgressBar.Value:=100;
    end
    else begin
      ProgressBar.Title:='Waiting for camera...';
      ProgressBar.Value:=Percent;
    end;
  end
  else Close;
end;

procedure TCalibrateFrm.NewCameraFrame(Sender:TObject);
begin
  if Assigned(OldNewCameraFrame) then OldNewCameraFrame(Sender);
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TCalibrateFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=OldNewCameraFrame;
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TCalibrateFrm.DrawBmp;
begin
  Bmp.Canvas.Draw(0,0,Camera.SmallBmp);
end;

end.
