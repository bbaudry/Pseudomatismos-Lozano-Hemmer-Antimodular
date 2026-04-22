unit TrackingSetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls, AprSpin, AprChkBx, UnitLCD, LCD, Jpeg,
  FileCtrl, NudgeBtn;

type
  TTrackingSetupFrm = class(TForm)
    MainPanel: TPanel;
    PaintBox: TPaintBox;
    MagPB: TPaintBox;
    Label12: TLabel;
    XLcd: TLCD;
    Label13: TLabel;
    YLcd: TLCD;
    Label16: TLabel;
    ILcd: TLCD;
    BackGndPanel: TPanel;
    BackGndFinderLbl: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    ForceBackGndBtn: TButton;
    DelayCB: TAprCheckBox;
    BackGndFinderThresholdEdit: TAprSpinEdit;
    BackGndFinderMinTimeEdit: TAprSpinEdit;
    BackGndFinderEnabledCB: TAprCheckBox;
    TrackingPanel: TPanel;
    TrackingSettingsLbl: TLabel;
    PrevFrameLowThresholdLbl: TLabel;
    PrevFrameHighThresholdLbl: TLabel;
    PrevFrameJumpDLbl: TLabel;
    PrevFrameMinAreaLbl: TLabel;
    PrevFrameMergeDLbl: TLabel;
    LowThresholdEdit: TAprSpinEdit;
    HighThresholdEdit: TAprSpinEdit;
    JumpDEdit: TAprSpinEdit;
    MinAreaEdit: TAprSpinEdit;
    MergeDEdit: TAprSpinEdit;
    OpenDialog: TOpenDialog;
    DelayTimer: TTimer;
    AutoStartTimer: TTimer;
    CameraPanel: TPanel;
    Label7: TLabel;
    SettingsBtn: TButton;
    CamBtn: TButton;
    PinBtn: TButton;
    FlipCB: TAprCheckBox;
    MirrorCB: TAprCheckBox;
    OpenDialog1: TOpenDialog;
    Label1: TLabel;
    SmearRG: TRadioGroup;
    Label2: TLabel;
    CullAreaEdit: TAprSpinEdit;
    DrawPanel: TPanel;
    Label3: TLabel;
    TrackThresholdsRB: TRadioButton;
    BackGndThresholdsRB: TRadioButton;
    BackGndStatusRB: TRadioButton;
    AccumulatedRB: TRadioButton;
    DrawBackGndPanel: TPanel;
    Label11: TLabel;
    NormalRB: TRadioButton;
    BackGndRB: TRadioButton;
    SubtractedRB: TRadioButton;
    DrawForeGndPanel: TPanel;
    Label14: TLabel;
    StripsCB: TAprCheckBox;
    BlobsCB: TAprCheckBox;
    TrackingInfoRB: TRadioButton;
    TimingInfoCB: TAprCheckBox;
    Panel3: TPanel;
    Label9: TLabel;
    TriggerAgeLbl: TLabel;
    UntriggerAgeLbl: TLabel;
    ShowLbl: TLabel;
    TriggerAgeEdit: TAprSpinEdit;
    UntriggerAgeEdit: TAprSpinEdit;
    DilateCB: TAprCheckBox;
    DilateREdit: TAprSpinEdit;
    ShowCoveredCellsCB: TAprCheckBox;
    ShowTriggeredCellsCB: TAprCheckBox;
    ShowActiveCellsCB: TAprCheckBox;
    FillInteriorCB: TAprCheckBox;
    SupressIslandsCB: TAprCheckBox;
    MinBlobAreaEdit: TAprSpinEdit;
    procedure SettingsBtnClick(Sender: TObject);
    procedure BlobsCBClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure FlipCBClick(Sender: TObject);
    procedure MirrorCBClick(Sender: TObject);
    procedure CamBtnClick(Sender: TObject);
    procedure PinBtnClick(Sender: TObject);
    procedure BackGndFinderEnabledCBClick(Sender: TObject);
    procedure BackGndFinderThresholdEditChange(Sender: TObject);
    procedure BackGndFinderMinTimeEditChange(Sender: TObject);
    procedure ForceBackGndBtnClick(Sender: TObject);
    procedure DelayTimerTimer(Sender: TObject);
    procedure LowThresholdEditChange(Sender: TObject);
    procedure HighThresholdEditChange(Sender: TObject);
    procedure JumpDEditChange(Sender: TObject);
    procedure MergeDEditChange(Sender: TObject);
    procedure MinAreaEditChange(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject;Shift:TShiftState;X,Y:Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure AntiSmearCBClick(Sender: TObject);
    procedure AntiMergeCBClick(Sender: TObject);
    procedure SmearRGClick(Sender: TObject);
    procedure CullAreaEditChange(Sender: TObject);
    procedure AccumulatedRBClick(Sender: TObject);

  private
    Bmp,MagBmp : TBitmap;
    MagTempBmp : TBitmap;

    MouseX : Integer;
    MouseY : Integer;

    procedure DrawBmp;
    procedure DrawMagBmp;
    function  MouseBmp:TBitmap;
    procedure NewCameraFrame(Sender:TObject);

  public
    procedure Initialize;
  end;

var
  TrackingSetupFrm: TTrackingSetupFrm;

implementation

{$R *.dfm}

uses
  BlobFind, CameraU, TrackerU, CfgFile, Global, Routines, BackGndFind, BmpUtils,
  TilerU, StopWatchU, Main, GLSceneU;

procedure TTrackingSetupFrm.Initialize;
var
  I : Integer;
begin
  Bmp:=CreateImageBmp;
  MagTempBmp:=CreateImageBmp;
  MagBmp:=CreateBmpForPaintBox(MagPB);

// camera
  FlipCB.Checked:=Camera.FlipImage;
  MirrorCB.Checked:=Camera.MirrorImage;

// background
  BackGndFinderEnabledCB.Checked:=BackGndFinder.Enabled;
  BackGndFinderThresholdEdit.Value:=BackGndFinder.Threshold;
  BackGndFinderMinTimeEdit.Value:=BackGndFinder.MinTime/1000;

// tracking panel
  with BlobFinder do begin
    LowThresholdEdit.Value:=LoT;
    HighThresholdEdit.Value:=HiT;
    JumpDEdit.Value:=JumpD;
    MergeDEdit.Value:=MergeD;
    MinAreaEdit.Value:=MinArea;
    CullAreaEdit.Value:=CullArea;
  end;
//  AntiMergeCB.Checked:=BlobFinder.AntiMerge;

  Case BlobFinder.SmearMode of
    smClassic  : SmearRG.ItemIndex:=0;
    smSoftEdge : SmearRG.ItemIndex:=1;
    smHardEdge : SmearRG.ItemIndex:=2;
  end;

  DrawBmp;
  MouseX:=TrackW div 2;
  MouseY:=TrackH div 2;
  DrawMagBmp;
  for I:=1 to 8 do StopWatch.Reset(I);
  TrackingInfoRB.Checked:=True;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TTrackingSetupFrm.DrawMagBmp;
begin
  MagnifyCopy(MouseBmp,MagTempBmp,MagBmp,MouseX,MouseY,11);
end;

procedure TTrackingSetupFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
  if Assigned(Bmp) then Bmp.Free;
  if Assigned(MagBmp) then MagBmp.Free;
  if Assigned(MagTempBmp) then MagTempBmp.Free;
end;

procedure TTrackingSetupFrm.SettingsBtnClick(Sender: TObject);
begin
  Camera.ShowCameraSettingsFrm;
end;

procedure TTrackingSetupFrm.BlobsCBClick(Sender: TObject);
begin
  //
end;

function TTrackingSetupFrm.MouseBmp:TBitmap;
begin
  if TrackingInfoRB.Checked then begin
    if NormalRB.Checked then Result:=Camera.Bmp
    else if BackGndRB.Checked then Result:=BackGndFinder.BackGndBmp
    else Result:=BackGndFinder.SubtractedBmp;
  end
  else Result:=Bmp;
end;

procedure TTrackingSetupFrm.NewCameraFrame(Sender:TObject);
var
  Line : PByteArray;
  I    : Integer;
begin
  if Camera.MeasuredFPS<10 then Exit;

// update the tracking objects
  BackGndFinder.Update(Camera.Bmp);
  BlobFinder.Update(BackGndFinder.SubtractedBmp);

// re-draw
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);

  DrawMagBmp;
  MagPB.Canvas.Draw(0,0,MagBmp);

  Line:=MouseBmp.ScanLine[MouseY];
  I:=MouseX*BytesPerPixel(MouseBmp);
  ILcd.Value:=(Line^[I]+Line^[I+1]+Line^[I+2]) div 3;
end;

procedure TTrackingSetupFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TTrackingSetupFrm.DrawBmp;
begin
  if BackGndStatusRB.Checked then begin
    Bmp.Canvas.Draw(0,0,Camera.Bmp);
    BackGndFinder.ShowPixelStates(Bmp);
  end
  else if BackGndThresholdsRB.Checked then begin
    ClearBmp(Bmp,clBlack);
    BackGndFinder.ShowPixelsAboveThreshold(Bmp);
  end
  else if TrackThresholdsRB.Checked then begin
    ClearBmp(Bmp,clBlack);
    BlobFinder.ShowPixelsAboveThreshold(Bmp);
  end
  else if AccumulatedRB.Checked then begin
    BackGndFinder.ShowPixelsAboveThreshold(Bmp);
    Exit;
  end

// tracking info
  else begin

// background
    if NormalRB.Checked then Bmp.Canvas.Draw(0,0,Camera.Bmp)
    else if BackGndRB.Checked then Bmp.Canvas.Draw(0,0,BackGndFinder.BackGndBmp)
    else Bmp.Canvas.Draw(0,0,BackGndFinder.SubtractedBmp);

// foreground
    if StripsCB.Checked then BlobFinder.DrawStrips(Bmp);
    if BlobsCB.Checked then BlobFinder.DrawBlobs(Bmp,0);
    if TimingInfoCB.Checked then StopWatch.ShowTimes(Bmp,6);

  end;
  Bmp.Canvas.Pen.Color:=clYellow;
  DrawXHairs(Bmp,MouseX,MouseY,4);
  ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
end;

procedure TTrackingSetupFrm.FlipCBClick(Sender: TObject);
begin
  Camera.FlipImage:=FlipCB.Checked;
end;

procedure TTrackingSetupFrm.MirrorCBClick(Sender: TObject);
begin
  Camera.MirrorImage:=MirrorCB.Checked;
end;

procedure TTrackingSetupFrm.CamBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPropertyPages;
end;

procedure TTrackingSetupFrm.PinBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPinPropertyPages;
end;

procedure TTrackingSetupFrm.BackGndFinderEnabledCBClick(Sender: TObject);
begin
  BackGndFinder.Enabled:=BackGndFinderEnabledCB.Checked;
end;

procedure TTrackingSetupFrm.BackGndFinderThresholdEditChange(Sender: TObject);
begin
  BackGndFinder.Threshold:=Round(BackGndFinderThresholdEdit.Value);
end;

procedure TTrackingSetupFrm.BackGndFinderMinTimeEditChange(Sender: TObject);
begin
  BackGndFinder.MinTime:=Round(BackGndFinderMinTimeEdit.Value*1000);
end;

procedure TTrackingSetupFrm.ForceBackGndBtnClick(Sender: TObject);
begin
  if DelayCB.Checked then DelayTimer.Enabled:=True
  else DelayTimerTimer(nil);
end;

procedure TTrackingSetupFrm.DelayTimerTimer(Sender: TObject);
begin
  DelayTimer.Enabled:=False;
  BackGndFinder.SetBackGndBmp(Camera.Bmp);
end;

procedure TTrackingSetupFrm.LowThresholdEditChange(Sender: TObject);
begin
  BlobFinder.LoT:=Round(LowThresholdEdit.Value);
end;

procedure TTrackingSetupFrm.HighThresholdEditChange(Sender: TObject);
begin
  BlobFinder.HiT:=Round(HighThresholdEdit.Value);
end;

procedure TTrackingSetupFrm.JumpDEditChange(Sender: TObject);
begin
  BlobFinder.JumpD:=Round(JumpDEdit.Value);
end;

procedure TTrackingSetupFrm.MergeDEditChange(Sender: TObject);
begin
  BlobFinder.MergeD:=Round(MergeDEdit.Value);
end;

procedure TTrackingSetupFrm.MinAreaEditChange(Sender: TObject);
begin
  BlobFinder.MinArea:=Round(MinAreaEdit.Value);
end;

procedure TTrackingSetupFrm.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  XLcd.Value:=X;
  YLcd.Value:=Y;
  MouseX:=X;
  MouseY:=Y;
end;

procedure TTrackingSetupFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TTrackingSetupFrm.AntiSmearCBClick(Sender: TObject);
begin
//  BlobFinder.AntiSmear:=AntiSmearCB.Checked;
end;

procedure TTrackingSetupFrm.AntiMergeCBClick(Sender: TObject);
begin
//  BlobFinder.AntiMerge:=AntiMergeCB.Checked;
end;

procedure TTrackingSetupFrm.SmearRGClick(Sender: TObject);
begin
  Case SmearRG.ItemIndex of
    0 : BlobFinder.SmearMode:=smClassic;
    1 : BlobFinder.SmearMode:=smSoftEdge;
    2 : BlobFinder.SmearMode:=smHardEdge;
  end;
end;

procedure TTrackingSetupFrm.CullAreaEditChange(Sender: TObject);
begin
  BlobFinder.CullArea:=Round(CullAreaEdit.Value);
end;

procedure TTrackingSetupFrm.AccumulatedRBClick(Sender: TObject);
begin
  ClearBmp(Bmp,clBlack);
end;

end.


