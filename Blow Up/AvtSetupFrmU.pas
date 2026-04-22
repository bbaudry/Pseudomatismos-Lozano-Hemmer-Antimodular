unit AvtSetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CameraU, ExtCtrls, AprChkBx, NBFill, Buttons;

type
  TAvtSettingsFrm = class(TForm)
    GainEdit: TNBFillEdit;
    GainAutoCB: TAprCheckBox;
    AutoPropertyLbl: TLabel;
    PropertyOnOffLbl: TLabel;
    WhiteBalanceUEdit: TNBFillEdit;
    WhiteBalanceUAutoCB: TAprCheckBox;
    WhiteBalanceVEdit: TNBFillEdit;
    WhiteBalanceVAutoCB: TAprCheckBox;
    BrightnessEdit: TNBFillEdit;
    BrightnessAutoCB: TAprCheckBox;
    ExposureEdit: TNBFillEdit;
    ExposureAutoCB: TAprCheckBox;
    Memo: TMemo;
    CamBtn: TButton;
    GainOnePushBtn: TButton;
    WhiteBalanceUOnePushBtn: TButton;
    WhiteBalanceVOnePushBtn: TButton;
    BrightnessOnePushBtn: TButton;
    ExposureOnePushBtn: TButton;
    Timer: TTimer;
    procedure EditChange(Sender: TObject);
    procedure CamBtnClick(Sender: TObject);
    procedure GainOnePushBtnClick(Sender: TObject);
    procedure WhiteBalanceUOnePushBtnClick(Sender: TObject);
    procedure WhiteBalanceVOnePushBtnClick(Sender: TObject);
    procedure BrightnessOnePushBtnClick(Sender: TObject);
    procedure ExposureOnePushBtnClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);

  private
    function  GetFormSettings:TAvtDriverSettings;
    procedure InitFormControls;

  public
    procedure Initialize;
  end;

var
  AvtSettingsFrm: TAvtSettingsFrm;

implementation

{$R *.dfm}

uses
  BmpUtils, TrackerU;

procedure TAvtSettingsFrm.Initialize;
begin
  InitFormControls;

  Timer.Enabled:=True;
end;

procedure TAvtSettingsFrm.InitFormControls;
var
  Settings : TAvtDriverSettings;
begin
  Settings:=Camera.GetAvtDriverSettings;

// gain
  with Settings.Gain do begin
    GainEdit.Min:=Min;
    GainEdit.Max:=Max;
    GainEdit.Value:=Value;
    GainAutoCB.Enabled:=(AutoPossible=1);
    GainAutoCB.Checked:=(Auto=1);
    GainOnePushBtn.Visible:=(OnePushPossible=1);
  end;

// White balance U
  with Settings.WhiteBalanceU do begin
    WhiteBalanceUEdit.Min:=Min;
    WhiteBalanceUEdit.Max:=Max;
    WhiteBalanceUEdit.Value:=Value;
    WhiteBalanceUAutoCB.Enabled:=(AutoPossible=1);
    WhiteBalanceUAutoCB.Checked:=(Auto=1);
    WhiteBalanceUOnePushBtn.Visible:=(OnePushPossible=1);
  end;

// White balance V
  with Settings.WhiteBalanceV do begin
    WhiteBalanceVEdit.Min:=Min;
    WhiteBalanceVEdit.Max:=Max;
    WhiteBalanceVEdit.Value:=Value;
    WhiteBalanceVAutoCB.Enabled:=(AutoPossible=1);
    WhiteBalanceVAutoCB.Checked:=(Auto=1);
    WhiteBalanceVOnePushBtn.Visible:=(OnePushPossible=1);
  end;

// Brightness
  with Settings.Brightness do begin
    BrightnessEdit.Min:=Min;
    BrightnessEdit.Max:=Max;
    BrightnessEdit.Value:=Value;
    BrightnessAutoCB.Enabled:=(AutoPossible=1);
    BrightnessAutoCB.Checked:=(Auto=1);
    BrightnessOnePushBtn.Visible:=(OnePushPossible=1);
  end;

// Exposure
  with Settings.Exposure do begin
    ExposureEdit.Min:=Min;
    ExposureEdit.Max:=Max;
    ExposureEdit.Value:=Value;
    ExposureAutoCB.Enabled:=(AutoPossible=1);
    ExposureAutoCB.Checked:=(Auto=1);
    ExposureOnePushBtn.Visible:=(OnePushPossible=1);
  end;
end;

function TAvtSettingsFrm.GetFormSettings:TAvtDriverSettings;
begin
  with Result do begin
    FlipImage:=0;
    RGB32:=1;
    Debayering:=1;
    BWDebayering:=0;

// Gamma
    GammaOn:=0;

// Gain
    Gain.Value:=Round(GainEdit.Value);
    Gain.Auto:=Integer(GainAutoCB.Checked);
    Gain.OnePush:=0;

// White Balance U
    WhiteBalanceU.Value:=Round(WhiteBalanceUEdit.Value);
    WhiteBalanceU.Auto:=Integer(WhiteBalanceUAutoCB.Checked);
    WhiteBalanceU.OnePush:=0;

// White Balance V
    WhiteBalanceV.Value:=Round(WhiteBalanceVEdit.Value);
    WhiteBalanceV.Auto:=Integer(WhiteBalanceVAutoCB.Checked);
    WhiteBalanceV.OnePush:=0;

// Brightness
    Brightness.Value:=Round(BrightnessEdit.Value);
    Brightness.Auto:=Integer(BrightnessAutoCB.Checked);
    Brightness.OnePush:=0;

// Exposure
    Exposure.Value:=Round(ExposureEdit.Value);
    Exposure.Auto:=Integer(ExposureAutoCB.Checked);
    Exposure.OnePush:=0;
  end;
end;

procedure TAvtSettingsFrm.EditChange(Sender: TObject);
var
  Settings : TAvtDriverSettings;
begin
  Settings:=GetFormSettings;
  Camera.SetAvtDriverSettings(Settings);
end;

procedure TAvtSettingsFrm.CamBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPropertyPages;
end;

procedure TAvtSettingsFrm.GainOnePushBtnClick(Sender: TObject);
var
  Settings : TAvtDriverSettings;
begin
  Settings:=GetFormSettings;
  Settings.Gain.OnePush:=1;
  Camera.SetAvtDriverSettings(Settings);
end;

procedure TAvtSettingsFrm.WhiteBalanceUOnePushBtnClick(Sender: TObject);
var
  Settings : TAvtDriverSettings;
begin
  Settings:=GetFormSettings;
  Settings.WhiteBalanceU.OnePush:=1;
  Camera.SetAvtDriverSettings(Settings);
  InitFormControls;
end;

procedure TAvtSettingsFrm.WhiteBalanceVOnePushBtnClick(Sender: TObject);
var
  Settings : TAvtDriverSettings;
begin
  Settings:=GetFormSettings;
  Settings.WhiteBalanceV.OnePush:=1;
  Camera.SetAvtDriverSettings(Settings);
  InitFormControls;
end;

procedure TAvtSettingsFrm.BrightnessOnePushBtnClick(Sender: TObject);
var
  Settings : TAvtDriverSettings;
begin
  Settings:=GetFormSettings;
  Settings.Brightness.OnePush:=1;
  Camera.SetAvtDriverSettings(Settings);
end;

procedure TAvtSettingsFrm.ExposureOnePushBtnClick(Sender: TObject);
var
  Settings : TAvtDriverSettings;
begin
  Settings:=GetFormSettings;
  Settings.Exposure.OnePush:=1;
  Camera.SetAvtDriverSettings(Settings);
end;

procedure TAvtSettingsFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

end.


