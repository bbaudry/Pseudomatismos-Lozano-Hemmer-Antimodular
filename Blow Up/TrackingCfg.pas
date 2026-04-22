unit TrackingCfg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, AprSpin, ExtCtrls, ComCtrls, AprChkBx, NBFill;

type
  TTrackingSetupFrm = class(TForm)
    ShowCellOutlinesCB: TAprCheckBox;
    ShowPixelsOverThresholdCB: TAprCheckBox;
    TabControl: TTabControl;
    PaintBox: TPaintBox;
    CameraLbl: TLabel;
    ShowLbl: TLabel;
    CamBtn: TButton;
    PinBtn: TButton;
    TrackerLbl: TLabel;
    TrackerThresholdLbl: TLabel;
    TrackerThresholdEdit: TAprSpinEdit;
    TrackerPercentageLbl: TLabel;
    TrackerPercentageEdit: TAprSpinEdit;
    SaveBtn: TBitBtn;
    ShowActiveCellsCB: TAprCheckBox;
    TakeBackGndBtn: TButton;
    AutoBackGndLbl: TLabel;
    AutoBackGndTestBtn: TBitBtn;
    TriggerAgeLbl: TLabel;
    TriggerAgeEdit: TAprSpinEdit;
    UntriggerAgeLbl: TLabel;
    UntriggerAgeEdit: TAprSpinEdit;
    DilateCB: TAprCheckBox;
    ShowCoveredCellsCB: TAprCheckBox;
    ShowTriggeredCellsCB: TAprCheckBox;
    DelayTimer: TTimer;
    DilateREdit: TAprSpinEdit;
    FlipImageCB: TAprCheckBox;
    CamSettingsBtn: TBitBtn;
    procedure FormDestroy(Sender: TObject);
    procedure CamBtnClick(Sender: TObject);
    procedure PinBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure TrackerThresholdEditChange(Sender: TObject);
    procedure TrackerPercentageEditChange(Sender: TObject);
    procedure ShowCBClick(Sender: TObject);
    procedure TakeBackGndBtnClick(Sender: TObject);
    procedure AutoBackGndTestBtnClick(Sender: TObject);
    procedure TriggerAgeEditChange(Sender: TObject);
    procedure UntriggerAgeEditChange(Sender: TObject);
    procedure DilateCBClick(Sender: TObject);
    procedure DelayTimerTimer(Sender: TObject);
    procedure DilateREditChange(Sender: TObject);
    procedure CamSettingsBtnClick(Sender: TObject);
    procedure FlipImageCBClick(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure NewCameraFrame(Sender:TObject);
    procedure DrawBmp;

  public
    procedure Initialize;

  end;

var
  TrackingSetupFrm: TTrackingSetupFrm;

implementation

{$R *.dfm}

uses
  CameraU, TrackerU, Global, CfgFile, BmpUtils, TilerU, BackGndFrmU,
  BackGndFind;

procedure TTrackingSetupFrm.Initialize;
begin
  Bmp:=CreateSmallBmp;

// camera
  FlipImageCB.Checked:=Camera.FlipImage;
  PaintBox.Width:=Camera.SmallBmp.Width;
  PaintBox.Height:=Camera.SmallBmp.Height;
  PaintBox.Left:=(TabControl.Width-PaintBox.Width) div 2;
  PaintBox.Top:=10+(TabControl.Height-PaintBox.Height) div 2;

// tracker
  TrackerThresholdEdit.Value:=Tracker.Threshold;
  TrackerPercentageEdit.Value:=Tracker.Fraction*100;
  TriggerAgeEdit.Value:=Tracker.MinCoverAge;
  UntriggerAgeEdit.Value:=Tracker.MinUnCoverAge;
  DilateCB.Checked:=Tracker.Dilate;
  DilateREdit.Max:=MaxDilateR;
  DilateREdit.Value:=Tracker.DilateR;

// show options
  ShowCellOutlinesCB.Checked:=(soCellOutlines in TrackingShowOptions);
  ShowCoveredCellsCB.Checked:=(soCoveredCells in TrackingShowOptions);
  ShowTriggeredCellsCB.Checked:=(soTriggeredCells in TrackingShowOptions);
  ShowActiveCellsCB.Checked:=(soActiveCells in TrackingShowOptions);
  ShowPixelsOverThresholdCB.Checked:=(soPixelsOverThreshold in TrackingShowOptions);

// start it
  Camera.InitForTracking;
  BackGndFinder.InitForTracking;
  Tracker.InitForTracking;
  DrawBmp;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TTrackingSetupFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
  Camera.OnNewFrame:=nil;
  SaveCfgFile;
end;


procedure TTrackingSetupFrm.CamBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPropertyPages;
end;

procedure TTrackingSetupFrm.PinBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPinPropertyPages;
end;

procedure TTrackingSetupFrm.DrawBmp;
begin
// backgnd
  Case TabControl.TabIndex of
    0: Bmp.Canvas.Draw(0,0,Camera.SmallBmp);
    1: Bmp.Canvas.Draw(0,0,BackGndFinder.BackGndBmp);
    2: Bmp.Canvas.Draw(0,0,BackGndFinder.SubtractedBmp);
  end;

// foreground
  if soPixelsOverThreshold in TrackingShowOptions then begin
    Tracker.ShowPixelsOverThreshold(Bmp);
  end;
  if soCellOutlines in TrackingShowOptions then Tracker.DrawCells(Bmp);
  if soCoveredCells in TrackingShowOptions then Tracker.ShowCoveredCells(Bmp);
  if soTriggeredCells in TrackingShowOptions then Tracker.ShowTriggeredCells(Bmp);
  if soActiveCells in TrackingShowOptions then Tracker.ShowActiveCells(Bmp);
  ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
end;

procedure TTrackingSetupFrm.NewCameraFrame(Sender:TObject);
begin
  BackGndFinder.Update(Camera.SmallBmp);
  Tracker.Update(BackGndFinder.SubtractedBmp);
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TTrackingSetupFrm.SaveBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TTrackingSetupFrm.TrackerThresholdEditChange(Sender: TObject);
begin
  Tracker.Threshold:=Round(TrackerThresholdEdit.Value);
end;

procedure TTrackingSetupFrm.TrackerPercentageEditChange(Sender: TObject);
begin
  Tracker.Fraction:=TrackerPercentageEdit.Value/100;
end;

procedure TTrackingSetupFrm.ShowCBClick(Sender: TObject);
begin
  TrackingShowOptions:=[];
  if ShowCellOutlinesCB.Checked then begin
    TrackingShowOptions:=TrackingShowOptions + [soCellOutlines];
  end;
  if ShowCoveredCellsCB.Checked then begin
    TrackingShowOptions:=TrackingShowOptions + [soCoveredCells];
  end;
  if ShowTriggeredCellsCB.Checked then begin
    TrackingShowOptions:=TrackingShowOptions + [soTriggeredCells];
  end;
  if ShowActiveCellsCB.Checked then begin
    TrackingShowOptions:=TrackingShowOptions + [soActiveCells];
  end;
  if ShowPixelsOverThresholdCB.Checked then begin
    TrackingShowOptions:=TrackingShowOptions + [soPixelsOverThreshold];
  end;
end;


procedure TTrackingSetupFrm.AutoBackGndTestBtnClick(Sender: TObject);
begin
  BackGndFrm:=TBackGndFrm.Create(Application);
  try
    BackGndFrm.Initialize;
    BackGndFrm.ShowModal;
  finally
    BackGndFrm.Free;
  end;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TTrackingSetupFrm.TriggerAgeEditChange(Sender: TObject);
begin
  Tracker.MinCoverAge:=Round(TriggerAgeEdit.Value);
end;

procedure TTrackingSetupFrm.UntriggerAgeEditChange(Sender: TObject);
begin
  Tracker.MinUnCoverAge:=Round(UntriggerAgeEdit.Value);
end;

procedure TTrackingSetupFrm.DilateCBClick(Sender: TObject);
begin
  Tracker.Dilate:=DilateCB.Checked;
end;

procedure TTrackingSetupFrm.TakeBackGndBtnClick(Sender: TObject);
begin
  DelayTimer.Enabled:=True
end;

procedure TTrackingSetupFrm.DelayTimerTimer(Sender: TObject);
begin
  DelayTimer.Enabled:=False;
  BackGndFinder.BackGndBmp.Assign(Camera.SmallBmp);
  Caption:='BackGnd updated '+DateTimeToStr(Now);
end;

procedure TTrackingSetupFrm.DilateREditChange(Sender: TObject);
begin
  Tracker.DilateR:=DilateREdit.Value;
  Tracker.InitDilateMask;
end;

procedure TTrackingSetupFrm.CamSettingsBtnClick(Sender: TObject);
begin
  Camera.ShowCameraSettingsFrm;
end;

procedure TTrackingSetupFrm.FlipImageCBClick(Sender: TObject);
begin
  Camera.FlipImage:=FlipImageCB.Checked;
end;

end.
