unit PtGreySetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AprChkBx, NBFill, DirectShow9, ExtCtrls, AprSpin,
  HexEdits, Buttons;

const
// we leave out thess ones:
// Contrast : Point grey controls the gain with this one -
//            ie the gain edit uses the contrast property
//               and contrast is not supported
// BL comp : Point grey controls the shutter with this one
// white balance is broken into the red and blue parts
  PropCount = 8;
  CtrlCount = 7;

type
  TPointGreySettingsFrm = class(TForm)
    PropertyPanel: TPanel;
    AutoPropertyLbl: TLabel;
    PropertyLbl: TLabel;
    BrightnessEdit: TNBFillEdit;
    GainEdit: TNBFillEdit;
    SaturationEdit: TNBFillEdit;
    ShutterEdit: TNBFillEdit;
    SharpnessEdit: TNBFillEdit;
    GammaEdit: TNBFillEdit;
    BrightnessCB: TAprCheckBox;
    GainCB: TAprCheckBox;
    SaturationCB: TAprCheckBox;
    SharpnessCB: TAprCheckBox;
    GammaCB: TAprCheckBox;
    ShutterCB: TAprCheckBox;
    BrightnessOnOffCB: TAprCheckBox;
    GainOnOffCB: TAprCheckBox;
    SaturationOnOffCB: TAprCheckBox;
    SharpnessOnOffCB: TAprCheckBox;
    GammaOnOffCB: TAprCheckBox;
    ShutterOnOffCB: TAprCheckBox;
    PropertyOnOffLbl: TLabel;
    RegisterLbl: TLabel;
    Label1: TLabel;
    ReadRegisterBtn: TButton;
    WriteRegisterBtn: TButton;
    RegisterValueEdit: THexEdit;
    RegisterAddressEdit: THexEdit;
    Panel1: TPanel;
    RedWhiteBalanceEdit: TNBFillEdit;
    WhiteBalanceCB: TAprCheckBox;
    WhiteBalanceOnOffCB: TAprCheckBox;
    BlueWhiteBalanceEdit: TNBFillEdit;
    Label2: TLabel;
    ColorEnableEdit: TNBFillEdit;
    HueEdit: TNBFillEdit;
    HueCB: TAprCheckBox;
    HueOnOffCB: TAprCheckBox;
    ColorEnableOnOffCB: TAprCheckBox;
    ColorEnableCB: TAprCheckBox;
    Panel2: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    TiltEdit: TNBFillEdit;
    TiltCB: TAprCheckBox;
    PanEdit: TNBFillEdit;
    PanCB: TAprCheckBox;
    ZoomEdit: TNBFillEdit;
    ZoomCB: TAprCheckBox;
    RollEdit: TNBFillEdit;
    RollCB: TAprCheckBox;
    IrisEdit: TNBFillEdit;
    IrisCB: TAprCheckBox;
    ExposureEdit: TNBFillEdit;
    ExposureCB: TAprCheckBox;
    FocusEdit: TNBFillEdit;
    FocusCB: TAprCheckBox;
    Memo: TMemo;
    CamBtn: TButton;
    PinBtn: TButton;

    function  TagToProperty(iTag:Integer):TVideoProcAmpProperty;
    procedure SetProperty(I:Integer);
    procedure PropertyEditValueChange(Sender: TObject);
    procedure PropertyCBClick(Sender: TObject);

    function  TagToControl(iTag:Integer):TCameraControlProperty;
    procedure SetControl(I:Integer);
    procedure ControlEditValueChange(Sender: TObject);
    procedure ControlCBClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ReadRegisterBtnClick(Sender: TObject);
    procedure WriteRegisterBtnClick(Sender: TObject);
    procedure WhiteBalanceEditChange(Sender: TObject);
    procedure CamBtnClick(Sender: TObject);
    procedure PinBtnClick(Sender: TObject);

  private
    PropertyEdit    : array[1..PropCount] of TNBFillEdit;
    PropertyCB      : array[1..PropCount] of TAprCheckBox;
    PropertyOnOffCB : array[1..PropCount] of TAprCheckBox;

    ControlEdit : array[1..CtrlCount] of TNBFillEdit;
    ControlCB   : array[1..CtrlCount] of TAprCheckBox;

  public
    procedure Initialize;
  end;

var
  PointGreySettingsFrm: TPointGreySettingsFrm;

implementation

{$R *.dfm}

uses
  CameraU, BmpUtils, TrackerU;

procedure TPointGreySettingsFrm.Initialize;
var
  I,Min,Max   : Integer;
  Value       : Integer;
  Prop        : TVideoProcAmpProperty;
  Ctrl        : TCameraControlProperty;
  Auto        : Boolean;
  CanDisable  : Boolean;
  Red,Blue    : DWord;
  CtrlEnabled : Boolean;
begin
  PropertyEdit[1]:=BrightnessEdit;
  PropertyEdit[2]:=GainEdit;
  PropertyEdit[3]:=SaturationEdit;
  PropertyEdit[4]:=SharpnessEdit;
  PropertyEdit[5]:=GammaEdit;
  PropertyEdit[6]:=ShutterEdit;
  PropertyEdit[7]:=HueEdit;
  PropertyEdit[8]:=ColorEnableEdit;

  PropertyCB[1]:=BrightnessCB;
  PropertyCB[2]:=GainCB;
  PropertyCB[3]:=SaturationCB;
  PropertyCB[4]:=SharpnessCB;
  PropertyCB[5]:=GammaCB;
  PropertyCB[6]:=ShutterCB;
  PropertyCB[7]:=HueCB;
  PropertyCB[8]:=ColorEnableCB;

  PropertyOnOffCB[1]:=BrightnessOnOffCB;
  PropertyOnOffCB[2]:=GainOnOffCB;
  PropertyOnOffCB[3]:=SaturationOnOffCB;
  PropertyOnOffCB[4]:=SharpnessOnOffCB;
  PropertyOnOffCB[5]:=GammaOnOffCB;
  PropertyOnOffCB[6]:=ShutterOnOffCB;
  PropertyOnOffCB[7]:=HueOnOffCB;
  PropertyOnOffCB[8]:=ColorEnableOnOffCB;

  for I:=1 to PropCount do begin
    PropertyEdit[I].Tag:=I;
    PropertyCB[I].Tag:=I;
    PropertyOnOffCB[I].Tag:=I;
    Prop:=TagToProperty(I);

// find the range
    if Camera.AbleToGetPropertyDetails(Prop,Min,Max,Auto,CanDisable) then begin

// set the range
      PropertyEdit[I].Min:=Min;
      PropertyEdit[I].Max:=Max;
      PropertyCB[I].Enabled:=Auto;
      PropertyOnOffCB[I].Enabled:=CanDisable;

// find the current setting
      Camera.AbleToGetProperty(Prop,Value,Auto);

// show it
      PropertyEdit[I].Value:=Value;
      PropertyCB[I].Checked:=Auto;

// events
      PropertyEdit[I].OnValueChange:=PropertyEditValueChange;
      PropertyCB[I].OnClick:=PropertyCBClick;
      PropertyCB[I].OnClick:=PropertyCBClick;
    end
    else begin
      PropertyEdit[I].Enabled:=False;
      PropertyCB[I].Enabled:=False;
      PropertyOnOffCB[I].Enabled:=False;
    end;
  end;

// white balance
  Camera.GetPointGreyWhiteBalance(Red,Blue,CtrlEnabled);
  RedWhiteBalanceEdit.Value:=Red;
  BlueWhiteBalanceEdit.Value:=Blue;
  WhiteBalanceOnOffCB.Checked:=CtrlEnabled;
  RedWhiteBalanceEdit.Max:=1023;
  BlueWhiteBalanceEdit.Max:=1023;

// controls
  ControlEdit[1]:=PanEdit;      ControlCB[1]:=PanCB;
  ControlEdit[2]:=TiltEdit;     ControlCB[2]:=TiltCB;
  ControlEdit[3]:=RollEdit;     ControlCB[3]:=RollCB;
  ControlEdit[4]:=ZoomEdit;     ControlCB[4]:=ZoomCB;
  ControlEdit[5]:=ExposureEdit; ControlCB[5]:=ExposureCB;
  ControlEdit[6]:=IrisEdit;     ControlCB[6]:=IrisCB;
  ControlEdit[7]:=FocusEdit;    ControlCB[7]:=FocusCB;

  for I:=1 to CtrlCount do begin
    ControlEdit[I].Tag:=I;
    ControlCB[I].Tag:=I;
    Ctrl:=TagToControl(I);

// find the range
    if Camera.AbleToGetControlDetails(Ctrl,Min,Max,Auto) then begin

// set the range
      ControlEdit[I].Min:=Min;
      ControlEdit[I].Max:=Max;
      if I=5 then Auto:=True;

      ControlCB[I].Enabled:=Auto;

// find the current setting
      Camera.AbleToGetControl(Ctrl,Value,Auto);

// show it
      ControlEdit[I].Value:=Value;
      ControlCB[I].Checked:=Auto;

// events
      ControlEdit[I].OnValueChange:=ControlEditValueChange;
      ControlCB[I].OnClick:=ControlCBClick;
    end
    else begin
      ControlEdit[I].Enabled:=False;
      ControlCB[I].Enabled:=False;
    end;
  end;
end;

function TPointGreySettingsFrm.TagToProperty(iTag:Integer):TVideoProcAmpProperty;
begin
  Case iTag of
    1: Result:=VideoProcAmp_Brightness;
    2: Result:=VideoProcAmp_Contrast; // point grey calls it "Gain" in their property sheet
    3: Result:=VideoProcAmp_Saturation;
    4: Result:=VideoProcAmp_Sharpness;
    5: Result:=VideoProcAmp_Gamma;
    6: Result:=VideoProcAmp_BacklightCompensation; // pt grey calls it "Shutter" in their ps
    7: Result:=VideoProcAmp_Hue;
    8:Result:=VideoProcAmp_ColorEnable;
  end;
end;

function TPointGreySettingsFrm.TagToControl(iTag:Integer):TCameraControlProperty;
begin
  Case iTag of
    1: Result:=CameraControl_Pan;
    2: Result:=CameraControl_Tilt;
    3: Result:=CameraControl_Roll;
    4: Result:=CameraControl_Zoom;
    5: Result:=CameraControl_Exposure;
    6: Result:=CameraControl_Iris;
    7: Result:=CameraControl_Focus;
  end;
end;

procedure TPointGreySettingsFrm.SetProperty(I:Integer);
var
  Prop      : TVideoProcAmpProperty;
  Value     : Integer;
  CtrlType  : TCameraControlType;
begin
  Value:=PropertyEdit[I].Value;
  Prop:=TagToProperty(I);
  if PropertyOnOffCB[I].Enabled then begin
    if PropertyOnOffCB[I].Checked then CtrlType:=ccOn
    else CtrlType:=ccOff;
  end
  else if PropertyCB[I].Checked then CtrlType:=ccAuto
  else CtrlType:=ccManual;
  Camera.AbleToSetProperty(Prop,Value,CtrlType);
end;

procedure TPointGreySettingsFrm.PropertyEditValueChange(Sender: TObject);
begin
  SetProperty((Sender as TNBFillEdit).Tag);
end;

procedure TPointGreySettingsFrm.PropertyCBClick(Sender: TObject);
begin
  SetProperty((Sender as TAprCheckBox).Tag);
end;

procedure TPointGreySettingsFrm.SetControl(I:Integer);
var
  Ctrl  : TCameraControlProperty;
  Value : Integer;
  Auto  : Boolean;
begin
  Ctrl:=TagToControl(I);
  Value:=ControlEdit[I].Value;
  Auto:=ControlCB[I].Checked;
  Camera.AbleToSetControl(Ctrl,Value,Auto);
end;

procedure TPointGreySettingsFrm.ControlEditValueChange(Sender: TObject);
begin
  SetControl((Sender as TNBFillEdit).Tag);
end;

procedure TPointGreySettingsFrm.ControlCBClick(Sender: TObject);
begin
  SetControl((Sender as TAprCheckBox).Tag);
end;

procedure TPointGreySettingsFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TPointGreySettingsFrm.ReadRegisterBtnClick(Sender: TObject);
var
  Address : DWord;
begin
  Address:=RegisterAddressEdit.Value;
  RegisterValueEdit.Value:=Camera.GetPointGreyRegister(Address);
end;

procedure TPointGreySettingsFrm.WriteRegisterBtnClick(Sender: TObject);
var
  Address,Value : DWord;
begin
  Address:=RegisterAddressEdit.Value;
  Value:=RegisterValueEdit.Value;
//Value:=2151170948;
//Value:=2184725380;
  Camera.SetPointGreyRegister(Address,Value);
end;

procedure TPointGreySettingsFrm.WhiteBalanceEditChange(Sender:TObject);
var
  Red,Blue    : DWord;
  CtrlEnabled : Boolean;
begin
  Red:=RedWhiteBalanceEdit.Value;
  Blue:=BlueWhiteBalanceEdit.Value;
  CtrlEnabled:=(WhiteBalanceOnOffCB.Checked);
  Camera.SetPointGreyWhiteBalance(Red,Blue,CtrlEnabled);
end;

procedure TPointGreySettingsFrm.CamBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPropertyPages;
end;

procedure TPointGreySettingsFrm.PinBtnClick(Sender: TObject);
begin
  Camera.ShowCameraPinPropertyPages;
end;

end.


