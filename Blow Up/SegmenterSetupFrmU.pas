unit SegmenterSetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AprChkBx, ExtCtrls, ComCtrls, AprSpin, FileCtrl, PBar,
  Z_prof, Jpeg, Buttons, LCD;

const
  MaxJpgs = 500;
  Avgs    = 16;

type
  TSegmenterSetupFrm = class(TForm)
    CameraPanel: TPanel;
    CamBtn: TButton;
    PinBtn: TButton;
    CameraLbl: TLabel;
    SegmenterPanel: TPanel;
    ThresholdLbl: TLabel;
    TimeLbl: TLabel;
    SegmenterLbl: TLabel;
    ThresholdEdit: TAprSpinEdit;
    MaxFGTimeEdit: TAprSpinEdit;
    CamSettingsBtn: TButton;
    SegmenterPB: TPaintBox;
    MeanRB: TRadioButton;
    CamPB: TPaintBox;
    ThresholdedRB: TRadioButton;
    StatesRB: TRadioButton;
    BackGndShape: TShape;
    BackGndLbl: TLabel;
    ForeGroundShape: TShape;
    ForeGndLbl: TLabel;
    Button1: TButton;
    DeviationRB: TRadioButton;
    Label2: TLabel;
    Shape2: TShape;
    IntensityRB: TRadioButton;
    DelayCB: TAprCheckBox;
    DelayTimer: TTimer;
    MagPB: TPaintBox;
    XLcd: TLCD;
    YLcd: TLCD;
    XLbl: TLabel;
    YLbl: TLabel;
    BackGndAvgRB: TRadioButton;
    AgesRB: TRadioButton;
    DriftThresholdLbl: TLabel;
    DriftThresholdEdit: TAprSpinEdit;
    SegmenterHelpBtn: TBitBtn;
    DriftingRB: TRadioButton;
    ILcd: TLCD;
    Label4: TLabel;
    TrackerPanel: TPanel;
    Label9: TLabel;
    TrackerPB: TPaintBox;
    TrackerPercentageLbl: TLabel;
    TriggerAgeLbl: TLabel;
    UntriggerAgeLbl: TLabel;
    ShowLbl: TLabel;
    TrackerPercentageEdit: TAprSpinEdit;
    TriggerAgeEdit: TAprSpinEdit;
    UntriggerAgeEdit: TAprSpinEdit;
    DilateCB: TAprCheckBox;
    DilateREdit: TAprSpinEdit;
    ShowCellOutlinesCB: TAprCheckBox;
    ShowCoveredCellsCB: TAprCheckBox;
    ShowTriggeredCellsCB: TAprCheckBox;
    ShowActiveCellsCB: TAprCheckBox;
    FillInteriorCB: TAprCheckBox;
    SuppressLoneCellsCB: TAprCheckBox;
    SupressIslandsCB: TAprCheckBox;
    MinBlobAreaEdit: TAprSpinEdit;
    ShowBlobsCB: TAprCheckBox;
    UseITableCB: TAprCheckBox;
    FlipImageCB: TAprCheckBox;
    MirrorImageCB: TAprCheckBox;
    ShowCellGroupsCB: TAprCheckBox;
    CropWindowBtn: TBitBtn;
    procedure FormDestroy(Sender: TObject);
    procedure CamPBPaint(Sender: TObject);
    procedure ThresholdEditChange(Sender: TObject);
    procedure MaxFGTimeEditChange(Sender: TObject);
    procedure CamBtnClick(Sender: TObject);
    procedure PinBtnClick(Sender: TObject);
    procedure SetBackGndBtnClick(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CamSettingsBtnClick(Sender: TObject);
    procedure ShowCBClick(Sender: TObject);
    procedure TrackerPercentageEditChange(Sender: TObject);
    procedure TriggerAgeEditChange(Sender: TObject);
    procedure UntriggerAgeEditChange(Sender: TObject);
    procedure DilateCBClick(Sender: TObject);
    procedure DilateREditChange(Sender: TObject);
    procedure TrackerPBPaint(Sender: TObject);
    procedure SegmenterPBPaint(Sender: TObject);
    procedure FillInteriorCBClick(Sender: TObject);
    procedure DelayTimerTimer(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
                                Shift: TShiftState; X, Y: Integer);
    procedure MagPBPaint(Sender: TObject);
    procedure DriftThresholdEditChange(Sender: TObject);
    procedure SegmenterHelpBtnClick(Sender: TObject);
    procedure AutoCalibrateBtnClick(Sender: TObject);
    procedure SuppressLoneCellsCBClick(Sender: TObject);
    procedure SupressIslandsCBClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure UseITableCBClick(Sender: TObject);
    procedure FlipImageCBClick(Sender: TObject);
    procedure MirrorImageCBClick(Sender: TObject);
    procedure MinBlobAreaEditChange(Sender: TObject);
    procedure CropWindowBtnClick(Sender: TObject);

  private
    CamBmp : TBitmap;
    SegBmp : TBitmap;
    TrkBmp : TBitmap;
    MagBmp : TBitmap;
    TmpBmp : TBitmap;

    MouseX   : Integer;
    MouseY   : Integer;
    MouseBmp : TBitmap;

    TestX,TestY : Integer;

    MinI : Integer;
    MaxI : Integer;

    procedure NewCameraFrame(Sender:TObject);

    procedure DrawCamBmp;
    procedure DrawSegBmp;
    procedure DrawTrkBmp;
    procedure DrawMagBmp;

  public
    procedure Initialize;

  end;

var
  SegmenterSetupFrm: TSegmenterSetupFrm;

implementation

{$R *.dfm}

uses
  CameraU, BmpUtils, SegmenterU, CellTrackerU, Global, Routines, CfgFile,
  TilerU, SegHelpFrmU, CalibrateFrmU, TrackerU, CropWindowFrmU;

procedure TSegmenterSetupFrm.Initialize;
begin
  CamBmp:=CreateSmallBmp;
  SegBmp:=CreateSmallBmp;
  TrkBmp:=CreateSmallBmp;

  MagBmp:=TBitmap.Create;
  MagBmp.PixelFormat:=pf24Bit;
  MagBmp.Width:=MagPB.Width;
  MagBmp.Height:=MagPB.Height;
  TmpBmp:=CreateSmallBmp;

  MouseX:=0;
  MouseY:=0;
  MouseBmp:=CamBmp;

  UseITableCB.Checked:=Camera.UseITable;
  FlipImageCB.Checked:=Camera.FlipImage;
  MirrorImageCB.Checked:=Camera.MirrorImage;

  ThresholdEdit.Value:=Segmenter.Threshold;
  MaxFGTimeEdit.Value:=(Segmenter.MaxFGTime)/1000;
  DriftThresholdEdit.Value:=Segmenter.DriftThreshold;

// show options
  ShowCellOutlinesCB.Checked:=(soCellOutlines in TrackingShowOptions);
  ShowCoveredCellsCB.Checked:=(soCoveredCells in TrackingShowOptions);
  ShowTriggeredCellsCB.Checked:=(soTriggeredCells in TrackingShowOptions);
  ShowActiveCellsCB.Checked:=(soActiveCells in TrackingShowOptions);
  ShowCellGroupsCB.Checked:=(soCellGroups in TrackingShowOptions);

// CellTracker controls
  TrackerPercentageEdit.Value:=CellTracker.Fraction*100;
  TriggerAgeEdit.Value:=CellTracker.MinCoverAge;
  UntriggerAgeEdit.Value:=CellTracker.MinUnCoverAge;
  DilateCB.Checked:=CellTracker.Dilate;
  DilateREdit.Value:=CellTracker.DilateR;
  FillInteriorCB.Checked:=CellTracker.FillInside;
  SuppressLoneCellsCB.Checked:=CellTracker.SuppressLoneCells;
  SupressIslandsCB.Checked:=CellTracker.SuppressIslands;
  MinBlobAreaEdit.Value:=CellTracker.MinBlobArea;

// start things going
  Segmenter.InitForTracking;
  CellTracker.InitForTracking;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TSegmenterSetupFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(CamBmp) then CamBmp.Free;
  if Assigned(SegBmp) then SegBmp.Free;
  if Assigned(TrkBmp) then TrkBmp.Free;

  Camera.OnNewFrame:=nil;
  if SegmenterHelpFrmCreated then SegmenterHelpFrm.Close;
end;

procedure TSegmenterSetupFrm.DrawCamBmp;
begin
  CamBmp.Canvas.Draw(0,0,Camera.SmallBmp);
  ShowFrameRateOnBmp(CamBmp,Camera.MeasuredFPS);
end;

procedure TSegmenterSetupFrm.DrawSegBmp;
begin
  with Segmenter do begin
    if IntensityRB.Checked then DrawIntensityBmp(SegBmp)
    else if MeanRB.Checked then DrawMeanBmp(SegBmp)
    else if BackGndAvgRB.Checked then DrawBackGndMeanBmp(SegBmp)
    else if DeviationRB.Checked then DrawDeviatedBmp(SegBmp)
    else if ThresholdedRB.Checked then DrawThresholdedBmp(SegBmp)
    else if DriftingRB.Checked then DrawDriftingBmp(SegBmp)
    else if AgesRB.Checked then DrawAgesBmp(SegBmp)
    else DrawPixelStatesBmp(SegBmp);
  end;
end;

procedure TSegmenterSetupFrm.DrawTrkBmp;
begin
  ClearBmp(TrkBmp,clBlack);
  if soCellOutlines in TrackingShowOptions then CellTracker.DrawCells(TrkBmp);
  if soCoveredCells in TrackingShowOptions then CellTracker.ShowCoveredCells(TrkBmp);
  if soTriggeredCells in TrackingShowOptions then CellTracker.ShowTriggeredCells(TrkBmp);
  if soActiveCells in TrackingShowOptions then CellTracker.ShowActiveCells(TrkBmp);
  if soCellGroups in TrackingShowOptions then CellTracker.DrawSegmentedBmp(TrkBmp);
end;

procedure TSegmenterSetupFrm.CamPBPaint(Sender: TObject);
begin
  CamPB.Canvas.Draw(0,0,CamBmp);
end;

procedure TSegmenterSetupFrm.SegmenterPBPaint(Sender: TObject);
begin
  SegmenterPB.Canvas.Draw(0,0,SegBmp);
end;

procedure TSegmenterSetupFrm.TrackerPBPaint(Sender: TObject);
begin
  TrackerPB.Canvas.Draw(0,0,TrkBmp);
end;

procedure TSegmenterSetupFrm.ThresholdEditChange(Sender: TObject);
begin
  Segmenter.Threshold:=Round(ThresholdEdit.Value);
end;

procedure TSegmenterSetupFrm.MaxFGTimeEditChange(Sender: TObject);
begin
  Segmenter.SetMaxFGTime(Round(MaxFGTimeEdit.Value*1000));
end;

procedure TSegmenterSetupFrm.CamSettingsBtnClick(Sender: TObject);
begin
  Camera.ShowCameraSettingsFrm;
end;

procedure TSegmenterSetupFrm.CamBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPropertyPages;
end;

procedure TSegmenterSetupFrm.PinBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPinPropertyPages;
end;

procedure TSegmenterSetupFrm.SetBackGndBtnClick(Sender: TObject);
begin
  if DelayCB.Checked then DelayTimer.Enabled:=True
  else DelayTimerTimer(nil);
end;

procedure TSegmenterSetupFrm.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if (X>=0) and (X<SmallRect.Right) and (Y>=0) and (Y<SmallRect.Bottom) then
  begin
    MouseX:=X; MouseY:=Y;
    XLcd.Value:=X;
    YLcd.Value:=Y;
    if Sender=CamPB then MouseBmp:=CamBmp
    else if Sender=SegmenterPB then MouseBmp:=SegBmp
    else MouseBmp:=TrkBmp;
  end;  
end;

procedure TSegmenterSetupFrm.DrawMagBmp;
begin
  MagnifyCopy(MouseBmp,TmpBmp,MagBmp,MouseX,MouseY,11);
end;

procedure TSegmenterSetupFrm.ShowCBClick(Sender: TObject);
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
  if ShowCellGroupsCB.Checked then begin
    TrackingShowOptions:=TrackingShowOptions + [soCellGroups];
  end;
end;

procedure TSegmenterSetupFrm.TrackerPercentageEditChange(Sender: TObject);
begin
  CellTracker.Fraction:=TrackerPercentageEdit.Value/100;
end;

procedure TSegmenterSetupFrm.TriggerAgeEditChange(Sender: TObject);
begin
  CellTracker.MinCoverAge:=Round(TriggerAgeEdit.Value);
end;

procedure TSegmenterSetupFrm.UntriggerAgeEditChange(Sender: TObject);
begin
  CellTracker.MinUnCoverAge:=Round(UnTriggerAgeEdit.Value);
end;

procedure TSegmenterSetupFrm.DilateCBClick(Sender: TObject);
begin
  CellTracker.Dilate:=DilateCB.Checked;
end;

procedure TSegmenterSetupFrm.DilateREditChange(Sender: TObject);
begin
  CellTracker.DilateR:=DilateREdit.Value;
  CellTracker.InitDilateMask;
end;

procedure TSegmenterSetupFrm.FillInteriorCBClick(Sender: TObject);
begin
  CellTracker.FillInside:=FillInteriorCB.Checked;
end;

procedure TSegmenterSetupFrm.DelayTimerTimer(Sender: TObject);
begin
  DelayTimer.Enabled:=False;
  Segmenter.ForceAllToBackGnd(Camera.SmallBmp);
end;

procedure TSegmenterSetupFrm.PaintBoxMouseDown(Sender: TObject;Button: TMouseButton;
                                     Shift: TShiftState; X, Y: Integer);
begin
  TestX:=X;
  TestY:=Y;
  MinI:=Segmenter.Pixel[TestX,TestY].Intensity;
  MaxI:=MinI;
  Camera.FrameCount:=0;
end;

procedure TSegmenterSetupFrm.MagPBPaint(Sender: TObject);
begin
  MagPB.Canvas.Draw(0,0,MagBmp);
end;

procedure TSegmenterSetupFrm.NewCameraFrame(Sender:TObject);
var
  M    : Single;
  I    : Integer;
  Line : PByteArray;
begin
  Segmenter.Update(Camera.SmallBmp);
  CellTracker.Update;
  Tracker.Update;
  DrawCamBmp;
  DrawSegBmp;
  DrawTrkBmp;
  DrawMagBmp;
  Line:=MouseBmp.ScanLine[MouseY];
  I:=Line^[MouseX*3];
  ILcd.Value:=I;

  DrawXHairs(CamBmp,MouseX,MouseY,3);
  DrawXHairs(SegBmp,MouseX,MouseY,3);
  DrawXHairs(TrkBmp,MouseX,MouseY,3);

  CamPB.Canvas.Draw(0,0,CamBmp);
  SegmenterPB.Canvas.Draw(0,0,SegBmp);
  TrackerPB.Canvas.Draw(0,0,TrkBmp);
  MagPB.Canvas.Draw(0,0,MagBmp);
end;

procedure TSegmenterSetupFrm.DriftThresholdEditChange(Sender: TObject);
begin
  Segmenter.DriftThreshold:=Round(DriftThresholdEdit.Value);
end;

procedure TSegmenterSetupFrm.SegmenterHelpBtnClick(Sender: TObject);
begin
  if not SegmenterHelpFrmCreated then begin
    SegmenterHelpFrm:=TSegmenterHelpFrm.Create(Application);
  end;
  SegmenterHelpFrm.Show;
end;

procedure TSegmenterSetupFrm.AutoCalibrateBtnClick(Sender: TObject);
begin
  CalibrateFrm:=TCalibrateFrm.Create(Application);
  try
    CalibrateFrm.Initialize;
    CalibrateFrm.ShowModal;
  finally
    CalibrateFrm.Free;
  end;
end;

procedure TSegmenterSetupFrm.SuppressLoneCellsCBClick(Sender: TObject);
begin
  CellTracker.SuppressLoneCells:=SuppressLoneCellsCB.Checked;
end;

procedure TSegmenterSetupFrm.SupressIslandsCBClick(Sender: TObject);
begin
  CellTracker.SuppressIslands:=SupressIslandsCB.Checked;
end;

procedure TSegmenterSetupFrm.MinBlobAreaEditChange(Sender: TObject);
begin
  CellTracker.MinBlobArea:=Round(MinBlobAreaEdit.Value);
end;

procedure TSegmenterSetupFrm.FormActivate(Sender: TObject);
begin
  CenterCursor(Self);
end;

procedure TSegmenterSetupFrm.UseITableCBClick(Sender: TObject);
begin
  Camera.UseITable:=UseITableCB.Checked;
end;

procedure TSegmenterSetupFrm.FlipImageCBClick(Sender: TObject);
begin
  Camera.FlipImage:=FlipImageCB.Checked;
  Camera.BuildDrawTable;
end;

procedure TSegmenterSetupFrm.MirrorImageCBClick(Sender: TObject);
begin
  Camera.MirrorImage:=MirrorImageCB.Checked;
  Camera.BuildDrawTable;
end;

procedure TSegmenterSetupFrm.CropWindowBtnClick(Sender: TObject);
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

end.

  M:=Segmenter.Pixel[MouseX,MouseY].Mean;
  I:=Segmenter.Pixel[MouseX,MouseY].Intensity;
  Caption:='M = '+FloatToStrF(M,ffFixed,9,1)+' I = '+IntToStr(I);



