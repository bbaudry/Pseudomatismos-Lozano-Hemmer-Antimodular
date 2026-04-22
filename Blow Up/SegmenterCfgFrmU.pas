unit SegmenterCfgFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AprChkBx, ExtCtrls, ComCtrls, AprSpin, FileCtrl, PBar,
  Z_prof, Jpeg, Buttons, LCD;

const
  MaxJpgs = 500;
  Avgs    = 16;

type
  TSegmenterCfgFrm = class(TForm)
    Panel1: TPanel;
    CamBtn: TButton;
    PinBtn: TButton;
    CameraLbl: TLabel;
    Panel2: TPanel;
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
    Label1: TLabel;
    Shape1: TShape;
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
    CropWindowBtn: TBitBtn;
    BackGndAvgRB: TRadioButton;
    AgesRB: TRadioButton;
    DriftThresholdLbl: TLabel;
    DriftThresholdEdit: TAprSpinEdit;
    SegmenterHelpBtn: TBitBtn;
    DriftingRB: TRadioButton;
    ILcd: TLCD;
    Label4: TLabel;
    Panel3: TPanel;
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
    AvgCellIRB: TRadioButton;
    TrackingInfoRB: TRadioButton;
    SuppressLoneCellsCB: TAprCheckBox;
    SupressIslandsCB: TAprCheckBox;
    MinBlobAreaEdit: TAprSpinEdit;
    ShowBlobsCB: TAprCheckBox;
    UseITableCB: TAprCheckBox;
    ShowOutlinesCB: TAprCheckBox;
    FlipImageCB: TAprCheckBox;
    MirrorImageCB: TAprCheckBox;
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
    procedure CropWindowBtnClick(Sender: TObject);
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
  SegmenterCfgFrm: TSegmenterCfgFrm;

implementation

{$R *.dfm}

uses
  CameraU, BmpUtils, SegmenterU, CellTrackerU, Global, Routines, CfgFile, TilerU,
  CropWindowFrmU, SegHelpFrmU, CalibrateFrmU;

procedure TSegmenterCfgFrm.Initialize;
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

// CellTracker controls
  TrackerPercentageEdit.Value:=CellTracker.Fraction*100;
  TriggerAgeEdit.Value:=CellTracker.MinCoverAge;
  UntriggerAgeEdit.Value:=CellTracker.MinUnCoverAge;
  DilateCB.Checked:=CellTracker.Dilate;
  DilateREdit.Value:=CellTracker.DilateR;
  FillInteriorCB.Checked:=CellTracker.FillInside;
  SuppressLoneCellsCB.Checked:=CellTracker.SuppressLoneCells;
  SupressIslandsCB.Checked:=CellTracker.SuppressIslands;

// start things going
  Segmenter.InitForTracking;
  CellTracker.InitForTracking;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TSegmenterCfgFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(CamBmp) then CamBmp.Free;
  if Assigned(SegBmp) then SegBmp.Free;
  if Assigned(TrkBmp) then TrkBmp.Free;

  Camera.OnNewFrame:=nil;
  if SegmenterHelpFrmCreated then SegmenterHelpFrm.Close;
end;

procedure TSegmenterCfgFrm.DrawCamBmp;
begin
  CamBmp.Canvas.Draw(0,0,Camera.SmallBmp);
  ShowFrameRateOnBmp(CamBmp,Camera.MeasuredFPS);
end;

procedure TSegmenterCfgFrm.DrawSegBmp;
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

procedure TSegmenterCfgFrm.DrawTrkBmp;
begin
  if AvgCellIRB.Checked then begin
    CellTracker.ShowCellIntensities(TrkBmp);
  end
  else begin
    ClearBmp(TrkBmp,clBlack);
    if soCellOutlines in TrackingShowOptions then CellTracker.DrawCells(TrkBmp);
    if soCoveredCells in TrackingShowOptions then CellTracker.ShowCoveredCells(TrkBmp);
    if soTriggeredCells in TrackingShowOptions then CellTracker.ShowTriggeredCells(TrkBmp);
    if soActiveCells in TrackingShowOptions then CellTracker.ShowActiveCells(TrkBmp);
  end;
end;

procedure TSegmenterCfgFrm.CamPBPaint(Sender: TObject);
begin
  CamPB.Canvas.Draw(0,0,CamBmp);
end;

procedure TSegmenterCfgFrm.SegmenterPBPaint(Sender: TObject);
begin
  SegmenterPB.Canvas.Draw(0,0,SegBmp);
end;

procedure TSegmenterCfgFrm.TrackerPBPaint(Sender: TObject);
begin
  TrackerPB.Canvas.Draw(0,0,TrkBmp);
end;

procedure TSegmenterCfgFrm.ThresholdEditChange(Sender: TObject);
begin
  Segmenter.Threshold:=Round(ThresholdEdit.Value);
end;

procedure TSegmenterCfgFrm.MaxFGTimeEditChange(Sender: TObject);
begin
  Segmenter.SetMaxFGTime(Round(MaxFGTimeEdit.Value*1000));
end;

procedure TSegmenterCfgFrm.CamSettingsBtnClick(Sender: TObject);
begin
  Camera.ShowCameraSettingsFrm;
end;

procedure TSegmenterCfgFrm.CamBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPropertyPages;
end;

procedure TSegmenterCfgFrm.PinBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPinPropertyPages;
end;

procedure TSegmenterCfgFrm.SetBackGndBtnClick(Sender: TObject);
begin
  if DelayCB.Checked then DelayTimer.Enabled:=True
  else DelayTimerTimer(nil);
end;

procedure TSegmenterCfgFrm.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
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

procedure TSegmenterCfgFrm.DrawMagBmp;
begin
  MagnifyCopy(MouseBmp,TmpBmp,MagBmp,MouseX,MouseY,11);
end;

procedure TSegmenterCfgFrm.ShowCBClick(Sender: TObject);
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
  if ShowOutlinesCB.Checked then begin
    TrackingShowOptions:=TrackingShowOptions + [soOutlines];
  end;
end;

procedure TSegmenterCfgFrm.CropWindowBtnClick(Sender: TObject);
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

procedure TSegmenterCfgFrm.TrackerPercentageEditChange(Sender: TObject);
begin
  CellTracker.Fraction:=TrackerPercentageEdit.Value/100;
end;

procedure TSegmenterCfgFrm.TriggerAgeEditChange(Sender: TObject);
begin
  CellTracker.MinCoverAge:=Round(TriggerAgeEdit.Value);
end;

procedure TSegmenterCfgFrm.UntriggerAgeEditChange(Sender: TObject);
begin
  CellTracker.MinUnCoverAge:=Round(UnTriggerAgeEdit.Value);
end;

procedure TSegmenterCfgFrm.DilateCBClick(Sender: TObject);
begin
  CellTracker.Dilate:=DilateCB.Checked;
end;

procedure TSegmenterCfgFrm.DilateREditChange(Sender: TObject);
begin
  CellTracker.DilateR:=DilateREdit.Value;
  CellTracker.InitDilateMask;
end;

procedure TSegmenterCfgFrm.FillInteriorCBClick(Sender: TObject);
begin
  CellTracker.FillInside:=FillInteriorCB.Checked;
end;

procedure TSegmenterCfgFrm.DelayTimerTimer(Sender: TObject);
begin
  DelayTimer.Enabled:=False;
  Segmenter.ForceAllToBackGnd(Camera.SmallBmp);
end;

procedure TSegmenterCfgFrm.PaintBoxMouseDown(Sender: TObject;Button: TMouseButton;
                                     Shift: TShiftState; X, Y: Integer);
begin
  TestX:=X;
  TestY:=Y;
  MinI:=Segmenter.Pixel[TestX,TestY].Intensity;
  MaxI:=MinI;
  Camera.FrameCount:=0;
end;

procedure TSegmenterCfgFrm.MagPBPaint(Sender: TObject);
begin
  MagPB.Canvas.Draw(0,0,MagBmp);
end;

procedure TSegmenterCfgFrm.NewCameraFrame(Sender:TObject);
var
  M    : Single;
  I    : Integer;
  Line : PByteArray;
begin
  Segmenter.Update(Camera.SmallBmp);
  CellTracker.Update;
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

procedure TSegmenterCfgFrm.DriftThresholdEditChange(Sender: TObject);
begin
  Segmenter.DriftThreshold:=Round(DriftThresholdEdit.Value);
end;

procedure TSegmenterCfgFrm.SegmenterHelpBtnClick(Sender: TObject);
begin
  if not SegmenterHelpFrmCreated then begin
    SegmenterHelpFrm:=TSegmenterHelpFrm.Create(Application);
  end;
  SegmenterHelpFrm.Show;
end;

procedure TSegmenterCfgFrm.AutoCalibrateBtnClick(Sender: TObject);
begin
  CalibrateFrm:=TCalibrateFrm.Create(Application);
  try
    CalibrateFrm.Initialize;
    CalibrateFrm.ShowModal;
  finally
    CalibrateFrm.Free;
  end;
end;

procedure TSegmenterCfgFrm.SuppressLoneCellsCBClick(Sender: TObject);
begin
  CellTracker.SuppressLoneCells:=SuppressLoneCellsCB.Checked;

end;

procedure TSegmenterCfgFrm.SupressIslandsCBClick(Sender: TObject);
begin
  CellTracker.SuppressIslands:=SupressIslandsCB.Checked;
end;

procedure TSegmenterCfgFrm.MinBlobAreaEditChange(Sender: TObject);
begin
  CellTracker.MinBlobArea:=Round(MinBlobAreaEdit.Value);
end;

procedure TSegmenterCfgFrm.FormActivate(Sender: TObject);
begin
  CenterCursor(Self);
end;

procedure TSegmenterCfgFrm.UseITableCBClick(Sender: TObject);
begin
  Camera.UseITable:=UseITableCB.Checked;
end;

procedure TSegmenterCfgFrm.FlipImageCBClick(Sender: TObject);
begin
  Camera.FlipImage:=FlipImageCB.Checked;
end;

procedure TSegmenterCfgFrm.MirrorImageCBClick(Sender: TObject);
begin
  Camera.MirrorImage:=MirrorImageCB.Checked;
end;

end.

  M:=Segmenter.Pixel[MouseX,MouseY].Mean;
  I:=Segmenter.Pixel[MouseX,MouseY].Intensity;
  Caption:='M = '+FloatToStrF(M,ffFixed,9,1)+' I = '+IntToStr(I);



