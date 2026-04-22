unit TrackTestFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls, AprSpin, AprChkBx, UnitLCD, LCD, Jpeg,
  FileCtrl, NudgeBtn;

type
  TTrackTestFrm = class(TForm)
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
    DrawBackGndPanel: TPanel;
    Label11: TLabel;
    NormalRB: TRadioButton;
    BackGndRB: TRadioButton;
    SubtractedRB: TRadioButton;
    DrawForeGndPanel: TPanel;
    Label14: TLabel;
    TrackThresholdsRB: TRadioButton;
    TrackingViewRB: TRadioButton;
    StripsCB: TAprCheckBox;
    BlobsCB: TAprCheckBox;
    BackGndThresholdsRB: TRadioButton;
    BlobOutlinesCB: TAprCheckBox;
    BackGndStatusRB: TRadioButton;
    CellWindowsCB: TAprCheckBox;
    SmearRG: TRadioGroup;
    Label2: TLabel;
    CullAreaEdit: TAprSpinEdit;
    ClearBtn: TButton;
    LoadBtn: TButton;
    SaveBtn: TButton;
    Label3: TLabel;
    PenWidthEdit: TAprSpinEdit;
    ColorStripsCB: TAprCheckBox;
    AntiMergeCB: TAprCheckBox;
    AccumulatedCB: TAprCheckBox;
    procedure SettingsBtnClick(Sender: TObject);
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
    procedure ClearBtnClick(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AccumulatedCBClick(Sender: TObject);

  private
    Bmp,MagBmp : TBitmap;
    MagTempBmp : TBitmap;
    CamBmp     : TBitmap;

    MouseX : Integer;
    MouseY : Integer;

    procedure DrawBmp;
    procedure DrawMagBmp;
    function  MouseBmp:TBitmap;
    procedure NewCameraFrame(Sender:TObject);
    function  CamBmpFileName:String;

  public
    procedure Initialize;
  end;

var
  TrackTestFrm: TTrackTestFrm;

implementation

{$R *.dfm}

uses
  BlobFind, CameraU, TrackerU, CfgFile, Global, Routines, BackGndFind, BmpUtils,
  TilerU, StopWatchU, Main, GLSceneU;

procedure TTrackTestFrm.Initialize;
begin
  Bmp:=CreateImageBmp;
  CamBmp:=CreateImageBmp;
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
  end;
  CullAreaEdit.Value:=BlobFinder.CullArea;
  AntiMergeCB.Checked:=BlobFinder.AntiMerge;

  Case BlobFinder.SmearMode of
    smClassic  : SmearRG.ItemIndex:=0;
    smSoftEdge : SmearRG.ItemIndex:=1;
    smHardEdge : SmearRG.ItemIndex:=2;
  end;

  ClearBmp(CamBmp,clBlack);
  BackGndFinder.SetBackGndBmp(CamBmp);


  DrawBmp;
  MouseX:=TrackW div 2;
  MouseY:=TrackH div 2;
  DrawMagBmp;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TTrackTestFrm.DrawMagBmp;
begin
  MagnifyCopy(MouseBmp,MagTempBmp,MagBmp,MouseX,MouseY,11);
end;

procedure TTrackTestFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
  if Assigned(CamBmp) then CamBmp.Free;
  if Assigned(MagBmp) then MagBmp.Free;
  if Assigned(MagTempBmp) then MagTempBmp.Free;
  Camera.OnNewFrame:=nil;
end;

procedure TTrackTestFrm.SettingsBtnClick(Sender: TObject);
begin
  Camera.ShowCameraSettingsFrm;
end;

function TTrackTestFrm.MouseBmp:TBitmap;
begin
  if NormalRB.Checked then Result:=Camera.Bmp
  else if BackGndRB.Checked then Result:=BackGndFinder.BackGndBmp
  else Result:=BackGndFinder.SubtractedBmp;
end;

procedure TTrackTestFrm.NewCameraFrame(Sender:TObject);
var
  Line : PByteArray;
  I    : Integer;
begin
  Camera.Bmp.Canvas.Draw(0,0,CamBmp);

// update the tracking objects
  BackGndFinder.DrawSubtractedBmp(Camera.Bmp);
  BlobFinder.Update(BackGndFinder.SubtractedBmp);

// re-draw
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);

  DrawMagBmp;
  MagPB.Canvas.Draw(0,0,MagBmp);

  Line:=MouseBmp.ScanLine[MouseY];
  I:=MouseX*BytesPerPixel(MouseBmp);
  ILcd.Value:=Line^[I];
end;

procedure TTrackTestFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TTrackTestFrm.DrawBmp;
begin
  if AccumulatedCB.Checked then begin
    BackGndFinder.ShowPixelsAboveThreshold(Bmp);
    Exit;
  end;

// background
  if NormalRB.Checked then Bmp.Canvas.Draw(0,0,Camera.Bmp)
  else if BackGndRB.Checked then Bmp.Canvas.Draw(0,0,BackGndFinder.BackGndBmp)
  else Bmp.Canvas.Draw(0,0,BackGndFinder.SubtractedBmp);

// foreground
  if BackGndThresholdsRB.Checked then begin
    ClearBmp(Bmp,clBlack);
    BackGndFinder.ShowPixelsAboveThreshold(Bmp);
  end
  else if BackGndStatusRB.Checked then begin
    BackGndFinder.ShowPixelStates(Bmp);
  end
  else if TrackThresholdsRB.Checked then begin
    BlobFinder.ShowPixelsAboveThreshold(Bmp);
  end
  else begin
    if StripsCB.Checked then begin
      if ColorStripsCB.Checked then BlobFinder.DrawStripsInColor(Bmp)
      else BlobFinder.DrawStrips(Bmp);
    end;
    if BlobsCB.Checked then BlobFinder.DrawBlobs(Bmp,0);
    if CellWindowsCB.Checked then Tiler.DrawCellsOnCamBmp(Bmp);
  end;
  Bmp.Canvas.Pen.Color:=clYellow;
  DrawXHairs(Bmp,MouseX,MouseY,4);
  ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
end;

procedure TTrackTestFrm.FlipCBClick(Sender: TObject);
begin
  Camera.FlipImage:=FlipCB.Checked;
end;

procedure TTrackTestFrm.MirrorCBClick(Sender: TObject);
begin
  Camera.MirrorImage:=MirrorCB.Checked;
end;

procedure TTrackTestFrm.CamBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPropertyPages;
end;

procedure TTrackTestFrm.PinBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPinPropertyPages;
end;

procedure TTrackTestFrm.BackGndFinderEnabledCBClick(Sender: TObject);
begin
  BackGndFinder.Enabled:=BackGndFinderEnabledCB.Checked;
end;

procedure TTrackTestFrm.BackGndFinderThresholdEditChange(Sender: TObject);
begin
  BackGndFinder.Threshold:=Round(BackGndFinderThresholdEdit.Value);
end;

procedure TTrackTestFrm.BackGndFinderMinTimeEditChange(Sender: TObject);
begin
  BackGndFinder.MinTime:=Round(BackGndFinderMinTimeEdit.Value*1000);
end;

procedure TTrackTestFrm.ForceBackGndBtnClick(Sender: TObject);
begin
  if DelayCB.Checked then DelayTimer.Enabled:=True
  else DelayTimerTimer(nil);
end;

procedure TTrackTestFrm.DelayTimerTimer(Sender: TObject);
begin
  DelayTimer.Enabled:=False;
  BackGndFinder.SetBackGndBmp(Camera.Bmp);
end;

procedure TTrackTestFrm.LowThresholdEditChange(Sender: TObject);
begin
  BlobFinder.LoT:=Round(LowThresholdEdit.Value);
end;

procedure TTrackTestFrm.HighThresholdEditChange(Sender: TObject);
begin
  BlobFinder.HiT:=Round(HighThresholdEdit.Value);
end;

procedure TTrackTestFrm.JumpDEditChange(Sender: TObject);
begin
  BlobFinder.JumpD:=Round(JumpDEdit.Value);
end;

procedure TTrackTestFrm.MergeDEditChange(Sender: TObject);
begin
  BlobFinder.MergeD:=Round(MergeDEdit.Value);
end;

procedure TTrackTestFrm.MinAreaEditChange(Sender: TObject);
begin
  BlobFinder.MinArea:=Round(MinAreaEdit.Value);
end;

procedure TTrackTestFrm.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  XLcd.Value:=X;
  YLcd.Value:=Y;
  if LeftMouseBtnDown then CamBmp.Canvas.Pen.Color:=clWhite
  else if RightMouseBtnDown then CamBmp.Canvas.Pen.Color:=clBlack
  else Exit;
  CamBmp.Canvas.Pen.Width:=Round(PenWidthEdit.Value);
  CamBmp.Canvas.LineTo(X,Y);
  MouseX:=X;
  MouseY:=Y;
end;

procedure TTrackTestFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TTrackTestFrm.AntiSmearCBClick(Sender: TObject);
begin
//  BlobFinder.AntiSmear:=AntiSmearCB.Checked;
end;

procedure TTrackTestFrm.AntiMergeCBClick(Sender: TObject);
begin
  BlobFinder.AntiMerge:=AntiMergeCB.Checked;
end;

procedure TTrackTestFrm.SmearRGClick(Sender: TObject);
begin
  Case SmearRG.ItemIndex of
    0 : BlobFinder.SmearMode:=smClassic;
    1 : BlobFinder.SmearMode:=smSoftEdge;
    2 : BlobFinder.SmearMode:=smHardEdge;
  end;
end;

procedure TTrackTestFrm.CullAreaEditChange(Sender: TObject);
begin
  BlobFinder.CullArea:=Round(CullAreaEdit.Value);
end;

procedure TTrackTestFrm.ClearBtnClick(Sender: TObject);
begin
  ClearBmp(CamBmp,clBlack);
end;

function TTrackTestFrm.CamBmpFileName:String;
begin
  Result:=Path+'CamBmp.bmp';
end;

procedure TTrackTestFrm.LoadBtnClick(Sender: TObject);
begin
  if FileExists(CamBmpFileName) then CamBmp.LoadFromFile(CamBmpFileName)
  else ShowMessage(CamBmpFileName+' not found');
end;

procedure TTrackTestFrm.SaveBtnClick(Sender: TObject);
begin
  CamBmp.SaveToFile(CamBmpFileName);
end;

procedure TTrackTestFrm.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CamBmp.Canvas.MoveTo(X,Y);
end;

procedure TTrackTestFrm.AccumulatedCBClick(Sender: TObject);
begin
  ClearBmp(Bmp,clBlack);
end;

end.


