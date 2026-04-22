unit TrackViewFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AprChkBx, ExtCtrls, AprSpin, StdCtrls, LCD;

type
  TTrackViewFrm = class(TForm)
    PaintBox: TPaintBox;
    BlowUpTargetPanel: TPanel;
    Label20: TLabel;
    Label21: TLabel;
    TenactiyLbl: TLabel;
    BlowUpToBestBlobRB: TRadioButton;
    BlowUpToForeGndRB: TRadioButton;
    BlowUpToBackGndRB: TRadioButton;
    BlowUpToAnythingRB: TRadioButton;
    KeepBlowUpYCB: TAprCheckBox;
    BlowUpYFractionEdit: TAprSpinEdit;
    TenacityEdit: TAprSpinEdit;
    DrawPanel: TPanel;
    Label22: TLabel;
    StripsCB: TAprCheckBox;
    BlobsCB: TAprCheckBox;
    CellWindowsCB: TAprCheckBox;
    BlowUpParametersPanel: TPanel;
    Label14: TLabel;
    TrackerEnabledCB: TAprCheckBox;
    MinLevelLbl: TLabel;
    TriggerLevelEdit: TAprSpinEdit;
    Label1: TLabel;
    CurrentLevelLCD: TLCD;
    BlowUpToZoomRB: TRadioButton;
    ZoomScaleEdit: TAprSpinEdit;
    Label2: TLabel;
    AveragesLbl: TLabel;
    Label7: TLabel;
    TrackerYAveragesEdit: TAprSpinEdit;
    TrackerXAveragesEdit: TAprSpinEdit;
    Label33: TLabel;
    TrackerMaxSpeedEdit: TAprSpinEdit;
    Label3: TLabel;
    SpeedLcd: TLCD;
    Label4: TLabel;
    UntriggerLevelEdit: TAprSpinEdit;
    SuperCellsCB: TAprCheckBox;
    TargetCB: TAprCheckBox;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BlowUpToBestBlobRBClick(Sender: TObject);
    procedure BlowUpToForeGndRBClick(Sender: TObject);
    procedure BlowUpToBackGndRBClick(Sender: TObject);
    procedure BlowUpToAnythingRBClick(Sender: TObject);
    procedure KeepBlowUpYCBClick(Sender: TObject);
    procedure BlowUpYFractionEditChange(Sender: TObject);
    procedure TenacityEditChange(Sender: TObject);
    procedure TrackerEnabledCBClick(Sender: TObject);
    procedure TriggerLevelEditChange(Sender: TObject);
    procedure BlowUpToZoomRBClick(Sender: TObject);
    procedure ZoomScaleEditChange(Sender: TObject);
    procedure TrackerXAveragesEditChange(Sender: TObject);
    procedure TrackerYAveragesEditChange(Sender: TObject);
    procedure ChangeBtnClick(Sender: TObject);
    procedure TrackerMaxSpeedEditChange(Sender: TObject);
    procedure UntriggerLevelEditChange(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure DrawBmp;

  public
    procedure Initialize;
    procedure Redraw;
  end;

var
  TrackViewFrm        : TTrackViewFrm;
  TrackViewFrmCreated : Boolean = False;

procedure ShowTrackViewFrm;

implementation

{$R *.dfm}

uses
  BmpUtils, CameraU, BlobFind, TilerU, TrackerU, StopWatchU, Global, SegmenterU,
  CellTrackerU;

procedure ShowTrackViewFrm;
begin
  if not TrackViewFrmCreated then begin
    TrackViewFrm:=TTrackViewFrm.Create(Application);
    TrackViewFrmCreated:=True;
  end;
  TrackViewFrm.Initialize;
  TrackViewFrm.Show;
end;

procedure TTrackViewFrm.FormCreate(Sender: TObject);
begin
  Bmp:=CreateImageBmp;
end;

procedure TTrackViewFrm.Initialize;
begin
  if TrackMethod=tmSegmenter then begin
    StripsCB.Caption:='Covered cells';
    BlobsCB.Visible:=False;
  end;
  Case Tiler.BlowUpTarget of
    btBestBlob : BlowUpToBestBlobRB.Checked:=True;
    btForeGnd  : BlowUpToForeGndRB.Checked:=True;
    btBackGnd  : BlowUpToBackGndRB.Checked:=True;
    btAnything : BlowUpToAnythingRB.Checked:=True;
    btZoom     : BlowUpToZoomRB.Checked:=True;
  end;
  ZoomScaleEdit.Value:=Tiler.ZoomScale;
  KeepBlowUpYCB.Checked:=Tiler.KeepBlowUpY;
  BlowUpYFractionEdit.Value:=Tiler.BlowUpYFraction*100;
  TenacityEdit.Value:=Tiler.Tenacity;

  TriggerLevelEdit.Value:=Tiler.TriggerLevel*100;
  UntriggerLevelEdit.Value:=Tiler.UntriggerLevel*100;

  TrackerEnabledCB.Checked:=Tracker.Enabled;
  TrackerXAveragesEdit.Value:=Tracker.XAverages;
  TrackerYAveragesEdit.Value:=Tracker.YAverages;
  TrackerMaxSpeedEdit.Value:=Tracker.MaxSpeed;
end;

procedure TTrackViewFrm.FormClose(Sender: TObject;var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TTrackViewFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
  TrackViewFrmCreated:=False;
  Tiler.InitForTracking;
end;

procedure TTrackViewFrm.DrawBmp;
begin
  Bmp.Canvas.Draw(0,0,Camera.Bmp);
  Case TrackMethod of
    tmBlobs :
      begin
        if StripsCB.Checked then BlobFinder.DrawStrips(Bmp);
        if BlobsCB.Checked then BlobFinder.DrawBlobs(Bmp,0);
      end;
    tmSegmenter :
      if StripsCB.Checked then CellTracker.ShowActiveCellsOnTrackBmp(Bmp);
  end;
  if CellWindowsCB.Checked then Tiler.DrawCellsOnCamBmp(Bmp);
  if SuperCellsCB.Checked then Tiler.DrawSuperCellsOnCamBmp(Bmp);
  if TargetCB.Checked then Tracker.DrawTarget(Bmp);
end;

procedure TTrackViewFrm.Redraw;
begin
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
  CurrentLevelLcd.Value:=Round(Tiler.Coverage*100);
  SpeedLcd.Value:=Round(Tracker.Speed);
end;

procedure TTrackViewFrm.BlowUpToBestBlobRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btBestBlob;
end;

procedure TTrackViewFrm.BlowUpToForeGndRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btForeGnd;
end;

procedure TTrackViewFrm.BlowUpToBackGndRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btBackGnd;
end;

procedure TTrackViewFrm.BlowUpToAnythingRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btAnything;
end;

procedure TTrackViewFrm.KeepBlowUpYCBClick(Sender: TObject);
begin
  Tiler.KeepBlowUpY:=KeepBlowUpYCB.Checked;
end;

procedure TTrackViewFrm.BlowUpYFractionEditChange(Sender: TObject);
begin
  Tiler.BlowUpYFraction:=BlowUpYFractionEdit.Value/100;
end;

procedure TTrackViewFrm.TenacityEditChange(Sender: TObject);
begin
  Tiler.Tenacity:=Round(TenacityEdit.Value);
end;

procedure TTrackViewFrm.TrackerEnabledCBClick(Sender: TObject);
begin
  Tracker.Enabled:=TrackerEnabledCB.Checked;
end;

procedure TTrackViewFrm.TriggerLevelEditChange(Sender: TObject);
begin
  Tiler.TriggerLevel:=TriggerLevelEdit.Value/100;
end;

procedure TTrackViewFrm.UntriggerLevelEditChange(Sender: TObject);
begin
  Tiler.UntriggerLevel:=UntriggerLevelEdit.Value/100;
end;

procedure TTrackViewFrm.BlowUpToZoomRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btZoom;
end;

procedure TTrackViewFrm.ZoomScaleEditChange(Sender: TObject);
begin
  Tiler.ZoomScale:=ZoomScaleEdit.Value;
  Tiler.FindZoomWindows;
end;

procedure TTrackViewFrm.TrackerXAveragesEditChange(Sender: TObject);
begin
  Tracker.XAverages:=Round(TrackerXAveragesEdit.Value);
end;

procedure TTrackViewFrm.TrackerYAveragesEditChange(Sender: TObject);
begin
  Tracker.YAverages:=Round(TrackerYAveragesEdit.Value);
end;

procedure TTrackViewFrm.ChangeBtnClick(Sender: TObject);
begin
  Tiler.NextChangeTime:=0;
end;

procedure TTrackViewFrm.TrackerMaxSpeedEditChange(Sender: TObject);
begin
  Tracker.MaxSpeed:=TrackerMaxSpeedEdit.Value;
end;

end.

