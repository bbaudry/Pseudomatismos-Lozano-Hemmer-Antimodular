unit TrackingCfg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, AprSpin, ExtCtrls, ComCtrls, AprChkBx, NBFill;

type
  TTrackingSetupFrm = class(TForm)
    TabControl: TTabControl;
    PaintBox: TPaintBox;
    CameraLbl: TLabel;
    CamBtn: TButton;
    PinBtn: TButton;
    TrackerLbl: TLabel;
    TrackerThresholdLbl: TLabel;
    TrackerThresholdEdit: TAprSpinEdit;
    TrackerPercentageLbl: TLabel;
    TrackerPercentageEdit: TAprSpinEdit;
    SaveBtn: TBitBtn;
    TakeBackGndBtn: TButton;
    AutoBackGndLbl: TLabel;
    AutoBackGndSetupBtn: TBitBtn;
    TriggerAgeLbl: TLabel;
    TriggerAgeEdit: TAprSpinEdit;
    UntriggerAgeLbl: TLabel;
    UntriggerAgeEdit: TAprSpinEdit;
    DilateCB: TAprCheckBox;
    DelayTimer: TTimer;
    DilateREdit: TAprSpinEdit;
    CamSettingsBtn: TBitBtn;
    CropWindowBtn: TBitBtn;
    AutoBackGndPixelBasedRB: TRadioButton;
    AutoBackGndCellBasedRB: TRadioButton;
    AutoBackGndDisabledRB: TRadioButton;
    ShowLbl: TLabel;
    ShowCellOutlinesCB: TAprCheckBox;
    ShowPixelsOverThresholdCB: TAprCheckBox;
    ShowActiveCellsCB: TAprCheckBox;
    ShowCoveredCellsCB: TAprCheckBox;
    ShowTriggeredCellsCB: TAprCheckBox;
    procedure FormDestroy(Sender: TObject);
    procedure CamBtnClick(Sender: TObject);
    procedure PinBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure TrackerThresholdEditChange(Sender: TObject);
    procedure TrackerPercentageEditChange(Sender: TObject);
    procedure ShowCBClick(Sender: TObject);
    procedure TakeBackGndBtnClick(Sender: TObject);
    procedure AutoBackGndSetupBtnClick(Sender: TObject);
    procedure TriggerAgeEditChange(Sender: TObject);
    procedure UntriggerAgeEditChange(Sender: TObject);
    procedure DilateCBClick(Sender: TObject);
    procedure DelayTimerTimer(Sender: TObject);
    procedure DilateREditChange(Sender: TObject);
    procedure CamSettingsBtnClick(Sender: TObject);
    procedure CropWindowBtnClick(Sender: TObject);
    procedure AutoBackGndDisabledRBClick(Sender: TObject);
    procedure AutoBackGndPixelBasedRBClick(Sender: TObject);
    procedure AutoBackGndCellBasedRBClick(Sender: TObject);

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
  CameraU, TrackerU, Global, CfgFile, BmpUtils, PixelBackGndFrmU,
  PixelBackGndFind, CellBackGndFind, CropWindowFrmU, CellBackGndFrmU;

procedure TTrackingSetupFrm.Initialize;
begin
  Bmp:=CreateSmallBmp;

// camera
  PaintBox.Width:=Camera.SmallBmp.Width;
  PaintBox.Height:=Camera.SmallBmp.Height;
//  PaintBox.Left:=(TabControl.Width-PaintBox.Width) div 2;
//  PaintBox.Top:=10+(TabControl.Height-PaintBox.Height) div 2;

// tracker
  TrackerThresholdEdit.Value:=Tracker.Threshold;
  TrackerPercentageEdit.Value:=Tracker.Fraction*100;
  TriggerAgeEdit.Value:=Tracker.MinCoverAge;
  UntriggerAgeEdit.Value:=Tracker.MinUnCoverAge;
  DilateCB.Checked:=Tracker.Dilate;
  DilateREdit.Max:=MaxDilateR;
  DilateREdit.Value:=Tracker.DilateR;

// autobackgnd
  Case AutoBackGndMode of
    amNone  : AutoBackGndDisabledRB.Checked:=True;
    amPixel : AutoBackGndPixelBasedRB.Checked:=True;
    amCell  : AutoBackGndCellBasedRB.Checked:=True;
  end;

// show options
  ShowCellOutlinesCB.Checked:=(soCellOutlines in TrackingShowOptions);
  ShowCoveredCellsCB.Checked:=(soCoveredCells in TrackingShowOptions);
  ShowTriggeredCellsCB.Checked:=(soTriggeredCells in TrackingShowOptions);
  ShowActiveCellsCB.Checked:=(soActiveCells in TrackingShowOptions);
  ShowPixelsOverThresholdCB.Checked:=(soPixelsOverThreshold in TrackingShowOptions);

// start it
  Camera.InitForTracking;
  PixelBackGndFinder.InitForTracking;
  CellBackGndFinder.InitForTracking;
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
    1: Bmp.Canvas.Draw(0,0,Camera.BackGndBmp);
    2: Bmp.Canvas.Draw(0,0,Camera.SubtractedBmp);
    3: begin
         Tracker.ShowAverageCellColors(Bmp);
         ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
         Exit;
       end;
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
  Camera.DrawSubtractedBmp;
  Case AutoBackGndMode of
    amNone  : ;
    amPixel : PixelBackGndFinder.Update(Camera.SmallBmp);
    amCell  : CellBackGndFinder.Update(Camera.SmallBmp);
  end;
  Tracker.Update(Camera.SubtractedBmp);
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

procedure TTrackingSetupFrm.AutoBackGndSetupBtnClick(Sender: TObject);
begin
  Case AutoBackGndMode of
    amNone  : ShowMessage('Please select either pixel or cell based auto background.');
    amPixel :
      begin
        PixelBackGndFrm:=TPixelBackGndFrm.Create(Application);
        try
          PixelBackGndFrm.Initialize;
          PixelBackGndFrm.ShowModal;
        finally
          PixelBackGndFrm.Free;
        end;
      end;
    amCell :
      begin
        CellBackGndFrm:=TCellBackGndFrm.Create(Application);
        try
          CellBackGndFrm.Initialize;
          CellBackGndFrm.ShowModal;
        finally
          CellBackGndFrm.Free;
        end;
      end;
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
  Camera.BackGndBmp.Assign(Camera.SmallBmp);
  Caption:='BackGnd updated '+DateTimeToStr(Now);
end;

procedure TTrackingSetupFrm.DilateREditChange(Sender: TObject);
begin
  Tracker.DilateR:=DilateREdit.Value;
  Tracker.InitDilateMask;
end;

procedure TTrackingSetupFrm.CamSettingsBtnClick(Sender: TObject);
begin
  Camera.ShowCameraSettingsFrm(False);
end;

procedure TTrackingSetupFrm.CropWindowBtnClick(Sender: TObject);
begin
  CropWindowFrm:=TCropWindowFrm.Create(Application);
  try
    CropWindowFrm.Initialize;
    CropWindowFrm.ShowModal;
  finally
    CropWindowFrm.Free;
  end;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TTrackingSetupFrm.AutoBackGndDisabledRBClick(Sender: TObject);
begin
  AutoBackGndMode:=amNone;
end;

procedure TTrackingSetupFrm.AutoBackGndPixelBasedRBClick(Sender: TObject);
begin
  AutoBackGndMode:=amPixel;
end;

procedure TTrackingSetupFrm.AutoBackGndCellBasedRBClick(Sender: TObject);
begin
  AutoBackGndMode:=amCell;
end;

end.

