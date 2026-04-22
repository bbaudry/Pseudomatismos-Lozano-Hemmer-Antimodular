unit TrackingSettingsFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, NBFill, Buttons, AprSpin, StdCtrls, AprChkBx, ComCtrls,
  CameraU, Math, CfgFile, LCD;

type
  TTrackingSettingsFrm = class(TForm)
    CamPB: TPaintBox;
    Memo: TMemo;
    StatusBar: TStatusBar;
    Label1: TLabel;
    ThresholdEdit: TAprSpinEdit;
    BlowUpTriggerPanel: TPanel;
    Label3: TLabel;
    Label15: TLabel;
    TriggerLevelEdit: TAprSpinEdit;
    Panel1: TPanel;
    Label18: TLabel;
    CurrentLevelLCD: TLCD;
    procedure FormDestroy(Sender: TObject);
    procedure CamPBPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ThresholdEditChange(Sender: TObject);
    procedure TriggerLevelEditChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);

  private
    Bmp               : TBitmap;
    Settings          : TAvtDriverSettings;
    ThresholdAdjusted : Boolean;
    StartLoT,StartHiT : Integer;

    procedure DrawBmp;

  public
    procedure Initialize;
    procedure UpdateTracking;

  end;

var
  TrackingSettingsFrm: TTrackingSettingsFrm;
  TrackingSettingsFrmCreated : Boolean =False;

implementation

{$R *.dfm}

uses
  Global, BmpUtils, TrackerU, Main, CalWarningFrmU, BlobFind, TilerU,
  SegmenterU, CellTrackerU;

procedure TTrackingSettingsFrm.FormCreate(Sender: TObject);
begin
  TrackingSettingsFrmCreated:=True;
end;

procedure TTrackingSettingsFrm.Initialize;
begin
  StartLoT:=BlobFinder.LoT;
  StartHiT:=BlobFinder.HiT;

  ThresholdAdjusted:=False;
  Caption:=VersionStr;
  Bmp:=CreateImageBmp;

// tracking panel
  Case TrackMethod of
    tmBlobs     : ThresholdEdit.Value:=BlobFinder.LoT;
    tmSegmenter : ThresholdEdit.Value:=Segmenter.Threshold;
  end;

  TriggerLevelEdit.Value:=Tiler.TriggerLevel*100;

  if Camera.Found then begin
    StatusBar.SimpleText:=Camera.CameraName+' - '+Camera.DriverName;
  end
  else StatusBar.SimpleText:='Camera not found';

  MainFrm.Cursor:=crDefault;
end;

procedure TTrackingSettingsFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
  TrackingSettingsFrmCreated:=False;
  MainFrm.Cursor:=crNone;
end;

procedure TTrackingSettingsFrm.CamPBPaint(Sender: TObject);
begin
  CamPB.Canvas.Draw(0,0,Bmp);
end;

procedure TTrackingSettingsFrm.DrawBmp;
begin
  Case TrackMethod of
    tmBlobs :
      begin
        Bmp.Canvas.Draw(0,0,Camera.Bmp);
        BlobFinder.DrawStrips(Bmp);
      end;
    tmSegmenter :
      begin
        if (Camera.MirrorImage) or (Camera.FlipImage) then begin
          Camera.DrawFlippedBmp;
          Bmp.Canvas.Draw(0,0,Camera.FlippedBmp);
        end
        else Bmp.Canvas.Draw(0,0,Camera.Bmp);
        CellTracker.ShowActiveCellsOnTrackBmp(Bmp);
      end;
  end;
  ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
end;

procedure TTrackingSettingsFrm.UpdateTracking;
begin
  DrawBmp;
  CamPB.Canvas.Draw(0,0,Bmp);
  CurrentLevelLcd.Value:=Round(Tiler.Coverage*100);
end;

procedure TTrackingSettingsFrm.FormClose(Sender: TObject;var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TTrackingSettingsFrm.ThresholdEditChange(Sender: TObject);
var
  V1,V2 : Integer;
begin
  Case TrackMethod of
    tmBlobs :
      begin
        BlobFinder.LoT:=Round(ThresholdEdit.Value);
        V1:=BlobFinder.LoT+StartHiT-StartLoT;
        V2:=Round(ThresholdEdit.Value*StartHiT/StartLoT);

// take the highest
        if V1>V2 then BlobFinder.HiT:=V1
        else BlobFinder.HiT:=V2;
      end;
    tmSegmenter : Segmenter.Threshold:=Round(ThresholdEdit.Value);
  end;
end;

procedure TTrackingSettingsFrm.TriggerLevelEditChange(Sender: TObject);
begin
  Tiler.TriggerLevel:=TriggerLevelEdit.Value/100;
end;

procedure TTrackingSettingsFrm.FormActivate(Sender: TObject);
begin
  MainFrm.TakeReference;
end;

end.




