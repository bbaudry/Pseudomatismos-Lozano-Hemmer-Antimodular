unit AvtSetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CameraU, ExtCtrls, AprChkBx, NBFill, Buttons;

type
  TAvtSettingsFrm = class(TForm)
    GainEdit: TNBFillEdit;
    GainAutoCB: TAprCheckBox;
    GainOnePushCB: TAprCheckBox;
    AutoPropertyLbl: TLabel;
    PropertyOnOffLbl: TLabel;
    DebayeringCB: TAprCheckBox;
    BWDebayeringCB: TAprCheckBox;
    GammaCB: TCheckBox;
    WhiteBalanceUEdit: TNBFillEdit;
    WhiteBalanceUAutoCB: TAprCheckBox;
    WhiteBalanceUOnePushCB: TAprCheckBox;
    WhiteBalanceVEdit: TNBFillEdit;
    WhiteBalanceVAutoCB: TAprCheckBox;
    WhiteBalanceVOnePushCB: TAprCheckBox;
    BrightnessEdit: TNBFillEdit;
    BrightnessAutoCB: TAprCheckBox;
    BrightnessOnePushCB: TAprCheckBox;
    ExposureEdit: TNBFillEdit;
    ExposureAutoCB: TAprCheckBox;
    ExposureOnePushCB: TAprCheckBox;
    PaintBox: TPaintBox;
    ShowPixelsOverThresholdCB: TAprCheckBox;
    Memo: TMemo;
    CamBtn: TButton;
    procedure EditChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure CamBtnClick(Sender: TObject);

  private
    OldNewCameraFrame : TNotifyEvent;
    Bmp               : TBitmap;
    ShowVideo         : Boolean;

    function  GetFormSettings:TAvtDriverSettings;
    procedure NewCameraFrame(Sender:TObject);
    procedure DrawBmp;

  public
    procedure Initialize(iShowVideo:Boolean);
  end;

var
  AvtSettingsFrm: TAvtSettingsFrm;

implementation

{$R *.dfm}

uses
  BmpUtils, TrackerU, TrackingCfg;

procedure TAvtSettingsFrm.Initialize(iShowVideo:Boolean);
var
  Settings : TAvtDriverSettings;
begin
  ShowVideo:=iShowVideo;
  Settings:=Camera.GetAvtDriverSettings;
  DebayeringCB.Checked:=(Settings.Debayering=1);
  BwDebayeringCB.Checked:=(Settings.BWDebayering=1);

// gamma
  GammaCB.Checked:=(Settings.GammaOn=1);

// gain
  with Settings.Gain do begin
    GainEdit.Min:=Min;
    GainEdit.Max:=Max;
    GainEdit.Value:=Value;
    GainAutoCB.Enabled:=(AutoPossible=1);
    GainAutoCB.Checked:=(Auto=1);
    GainOnePushCB.Enabled:=(OnePushPossible=1);
    GainOnePushCB.Checked:=(OnePush=1);
  end;

// White balance U
  with Settings.WhiteBalanceU do begin
    WhiteBalanceUEdit.Min:=Min;
    WhiteBalanceUEdit.Max:=Max;
    WhiteBalanceUEdit.Value:=Value;
    WhiteBalanceUAutoCB.Enabled:=(AutoPossible=1);
    WhiteBalanceUAutoCB.Checked:=(Auto=1);
    WhiteBalanceUOnePushCB.Enabled:=(OnePushPossible=1);
    WhiteBalanceUOnePushCB.Checked:=(OnePush=1);
  end;

// White balance V
  with Settings.WhiteBalanceV do begin
    WhiteBalanceVEdit.Min:=Min;
    WhiteBalanceVEdit.Max:=Max;
    WhiteBalanceVEdit.Value:=Value;
    WhiteBalanceVAutoCB.Enabled:=(AutoPossible=1);
    WhiteBalanceVAutoCB.Checked:=(Auto=1);
    WhiteBalanceVOnePushCB.Enabled:=(OnePushPossible=1);
    WhiteBalanceVOnePushCB.Checked:=(OnePush=1);
  end;

// Brightness
  with Settings.Brightness do begin
    BrightnessEdit.Min:=Min;
    BrightnessEdit.Max:=Max;
    BrightnessEdit.Value:=Value;
    BrightnessAutoCB.Enabled:=(AutoPossible=1);
    BrightnessAutoCB.Checked:=(Auto=1);
    BrightnessOnePushCB.Enabled:=(OnePushPossible=1);
    BrightnessOnePushCB.Checked:=(OnePush=1);
  end;

// Exposure
  with Settings.Exposure do begin
    ExposureEdit.Min:=Min;
    ExposureEdit.Max:=Max;
    ExposureEdit.Value:=Value;
    ExposureAutoCB.Enabled:=(AutoPossible=1);
    ExposureAutoCB.Checked:=(Auto=1);
    ExposureOnePushCB.Enabled:=(OnePushPossible=1);
    ExposureOnePushCB.Checked:=(OnePush=1);
  end;
  if ShowVideo then begin
    Bmp:=CreateSmallBmp;
    DrawBmp;
    OldNewCameraFrame:=Camera.OnNewFrame;
    Camera.OnNewFrame:=NewCameraFrame;
  end
  else ClientWidth:=Memo.Left+Memo.Width+Memo.Left;
end;

procedure TAvtSettingsFrm.FormDestroy(Sender: TObject);
begin
  if ShowVideo then begin
    Camera.OnNewFrame:=OldNewCameraFrame;
    if Assigned(Bmp) then Bmp.Free;
  end;
end;

function TAvtSettingsFrm.GetFormSettings:TAvtDriverSettings;
begin
  with Result do begin
    FlipImage:=0;
    RGB32:=1;
    Debayering:=Integer(DebayeringCB.Checked);
    BWDebayering:=Integer(BwDebayeringCB.Checked);

// Gamma
    GammaOn:=Integer(GammaCB.Checked);

// Gain
    Gain.Value:=Round(GainEdit.Value);
    Gain.Auto:=Integer(GainAutoCB.Checked);
    Gain.OnePush:=Integer(GainOnePushCB.Checked);

// White Balance U
    WhiteBalanceU.Value:=Round(WhiteBalanceUEdit.Value);
    WhiteBalanceU.Auto:=Integer(WhiteBalanceUAutoCB.Checked);
    WhiteBalanceU.OnePush:=Integer(WhiteBalanceUOnePushCB.Checked);

// White Balance V
    WhiteBalanceV.Value:=Round(WhiteBalanceVEdit.Value);
    WhiteBalanceV.Auto:=Integer(WhiteBalanceVAutoCB.Checked);
    WhiteBalanceV.OnePush:=Integer(WhiteBalanceVOnePushCB.Checked);

// Brightness
    Brightness.Value:=Round(BrightnessEdit.Value);
    Brightness.Auto:=Integer(BrightnessAutoCB.Checked);
    Brightness.OnePush:=Integer(BrightnessOnePushCB.Checked);

// Exposure
    Exposure.Value:=Round(ExposureEdit.Value);
    Exposure.Auto:=Integer(ExposureAutoCB.Checked);
    Exposure.OnePush:=Integer(ExposureOnePushCB.Checked);
  end;
end;

procedure TAvtSettingsFrm.EditChange(Sender: TObject);
var
  Settings : TAvtDriverSettings;
begin
  Settings:=GetFormSettings;
  Camera.SetAvtDriverSettings(Settings);
end;

procedure TAvtSettingsFrm.DrawBmp;
begin
  Bmp.Canvas.Draw(0,0,Camera.SmallBmp);
  ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
  if ShowPixelsOverThresholdCB.Checked then begin
    Tracker.ShowPixelsOverThreshold(Bmp);
  end;
end;

procedure TAvtSettingsFrm.NewCameraFrame(Sender:TObject);
begin
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
  if Assigned(OldNewCameraFrame) then OldNewCameraFrame(Sender);
end;

procedure TAvtSettingsFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TAvtSettingsFrm.CamBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPropertyPages;
end;

end.


