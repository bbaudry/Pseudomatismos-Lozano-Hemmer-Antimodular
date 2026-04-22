unit UBrainCamSetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AprChkBx, NBFill, StdCtrls, FireI, DirectShow9;

type
  TUBrainCamSettingsFrm = class(TForm)
    ShutterEdit: TNBFillEdit;
    ShutterCB: TAprCheckBox;
    GainEdit: TNBFillEdit;
    GainCB: TAprCheckBox;
    UBEdit: TNBFillEdit;
    UbCB: TAprCheckBox;
    VREdit: TNBFillEdit;
    VrCB: TAprCheckBox;
    HueEdit: TNBFillEdit;
    HueCB: TAprCheckBox;
    SaturationEdit: TNBFillEdit;
    SaturationCB: TAprCheckBox;
    BrightnessEdit: TNBFillEdit;
    BrightnessCB: TAprCheckBox;
    SharpnessEdit: TNBFillEdit;
    SharpnessCB: TAprCheckBox;
    GammaEdit: TNBFillEdit;
    GammaCB: TAprCheckBox;
    ShowListBtn: TButton;
    VenderInfoBtn: TButton;

    procedure InitExposureEditAndCB(ExpoCtrl:Integer);
    procedure InitColorEditAndCB(ColorCtrl:Integer);
    procedure InitBasicEditAndCB(BasicCtrl:Integer);
    procedure ExpoCtrlChanged(ExpoCtrl:Integer);
    procedure ExposureEditValueChange(Sender: TObject);
    procedure ExposureCBClick(Sender: TObject);
    procedure ColorCtrlChanged(ColorCtrl:Integer);
    procedure ColorEditValueChange(Sender: TObject);
    procedure ColorCBClick(Sender: TObject);
    procedure BasicCtrlChanged(BasicCtrl:Integer);
    procedure BasicEditValueChange(Sender: TObject);
    procedure BasicCBClick(Sender: TObject);
    procedure ShowListBtnClick(Sender: TObject);
    procedure VenderInfoBtnClick(Sender: TObject);

  private
    ExpoEdit : array[FiExpoControl_Shutter..FiExpoControl_Gain] of TNBFillEdit;
    ExpoCB   : array[FiExpoControl_Shutter..FiExpoControl_Gain] of TAprCheckBox;

    ColorEdit : array[FiColorControl_UB..FiColorControl_Saturation] of TNBFillEdit;
    ColorCB   : array[FiColorControl_UB..FiColorControl_Saturation] of TAprCheckBox;

    BasicEdit : array[FiBasicControl_Brightness..FiBasicControl_Gamma] of TNBFillEdit;
    BasicCB   : array[FiBasicControl_Brightness..FiBasicControl_Gamma] of TAprCheckBox;

  public
    procedure Initialize;

  end;

var
  UBrainCamSettingsFrm: TUBrainCamSettingsFrm;

implementation

{$R *.dfm}

uses
  MemoFrmU, CameraU;

procedure TUBrainCamSettingsFrm.Initialize;
begin
// shutter
  ExpoEdit[FiExpoControl_Shutter]:=ShutterEdit;
  ExpoEdit[FiExpoControl_Shutter].Tag:=FiExpoControl_Shutter;
  ExpoCB[FiExpoControl_Shutter]:=ShutterCB;
  ExpoCB[FiExpoControl_Shutter].Tag:=FiExpoControl_Shutter;
  InitExposureEditAndCB(FiExpoControl_Shutter);

// gain
  ExpoEdit[FiExpoControl_Gain]:=GainEdit;
  ExpoEdit[FiExpoControl_Gain].Tag:=FiExpoControl_Gain;
  ExpoCB[FiExpoControl_Gain]:=GainCB;
  ExpoCB[FiExpoControl_Gain].Tag:=FiExpoControl_Gain;
  InitExposureEditAndCB(FiExpoControl_Gain);

// U/B
  ColorEdit[FiColorControl_UB]:=UBEdit;
  ColorEdit[FiColorControl_UB].Tag:=FiColorControl_UB;
  ColorCB[FiColorControl_UB]:=UbCB;
  ColorCB[FiColorControl_UB].Tag:=FiColorControl_UB;
  InitColorEditAndCB(FiColorControl_UB);

// V/R
  ColorEdit[FiColorControl_VR]:=VREdit;
  ColorEdit[FiColorControl_VR].Tag:=FiColorControl_VR;
  ColorCB[FiColorControl_VR]:=VRCB;
  ColorCB[FiColorControl_VR].Tag:=FiColorControl_VR;
  InitColorEditAndCB(FiColorControl_VR);

// Hue
  ColorEdit[FiColorControl_Hue]:=HueEdit;
  ColorEdit[FiColorControl_Hue].Tag:=FiColorControl_Hue;
  ColorCB[FiColorControl_Hue]:=HueCB;
  ColorCB[FiColorControl_Hue].Tag:=FiColorControl_Hue;
  InitColorEditAndCB(FiColorControl_Hue);

// saturation
  ColorEdit[FiColorControl_Saturation]:=SaturationEdit;
  ColorEdit[FiColorControl_Saturation].Tag:=FiColorControl_Saturation;
  ColorCB[FiColorControl_Saturation]:=SaturationCB;
  ColorCB[FiColorControl_Saturation].Tag:=FiColorControl_Saturation;
  InitColorEditAndCB(FiColorControl_Saturation);

// brightness
  BasicEdit[FiBasicControl_Brightness]:=BrightnessEdit;
  BasicEdit[FiBasicControl_Brightness].Tag:=FiBasicControl_Brightness;
  BasicCB[FiBasicControl_Brightness]:=BrightnessCB;
  BasicCB[FiBasicControl_Brightness].Tag:=FiBasicControl_Brightness;
  InitBasicEditAndCB(FiBasicControl_Brightness);

// sharpness
  BasicEdit[FiBasicControl_Sharpness]:=SharpnessEdit;
  BasicEdit[FiBasicControl_Sharpness].Tag:=FiBasicControl_Sharpness;
  BasicCB[FiBasicControl_Sharpness]:=SharpnessCB;
  BasicCB[FiBasicControl_Sharpness].Tag:=FiBasicControl_Sharpness;
  InitBasicEditAndCB(FiBasicControl_Sharpness);

// gamma
  BasicEdit[FiBasicControl_Gamma]:=GammaEdit;
  BasicEdit[FiBasicControl_Gamma].Tag:=FiBasicControl_Gamma;
  BasicCB[FiBasicControl_Gamma]:=GammaCB;
  BasicCB[FiBasicControl_Gamma].Tag:=FiBasicControl_Gamma;
  InitBasicEditAndCB(FiBasicControl_Gamma);
end;

procedure TUBrainCamSettingsFrm.InitExposureEditAndCB(ExpoCtrl:Integer);
var
  Min,Max,Value      : Single;
  AutoEnabled,AutoOn : Boolean;
begin
  if Camera.AbleToGetFireIExposureControlDetails(ExpoCtrl,Min,Max,Value,
                                                 AutoEnabled,AutoOn) then
  begin
    ExpoEdit[ExpoCtrl].Enabled:=True;
    ExpoEdit[ExpoCtrl].Min:=Round(Min);
    ExpoEdit[ExpoCtrl].Max:=Round(Max);
    ExpoEdit[ExpoCtrl].Value:=Round(Value);
    ExpoEdit[ExpoCtrl].OnValueChange:=ExposureEditValueChange;
    ExpoCB[ExpoCtrl].Enabled:=AutoEnabled;
    ExpoCB[ExpoCtrl].Checked:=AutoOn;
    ExpoCB[ExpoCtrl].OnClick:=ExposureCBClick;
  end
  else begin
    ExpoEdit[ExpoCtrl].Enabled:=False;
    ExpoCB[ExpoCtrl].Enabled:=False;
    ExpoCB[ExpoCtrl].Checked:=False;
  end;
end;

procedure TUBrainCamSettingsFrm.InitColorEditAndCB(ColorCtrl:Integer);
var
  Min,Max,Value      : Single;
  AutoEnabled,AutoOn : Boolean;
begin
  if Camera.AbleToGetFireIColorControlDetails(ColorCtrl,Min,Max,Value,
                                              AutoEnabled,AutoOn) then
  begin
    ColorEdit[ColorCtrl].Enabled:=True;
    ColorEdit[ColorCtrl].Min:=Round(Min);
    ColorEdit[ColorCtrl].Max:=Round(Max);
    ColorEdit[ColorCtrl].Value:=Round(Value);
    ColorEdit[ColorCtrl].OnValueChange:=ColorEditValueChange;
    ColorCB[ColorCtrl].Enabled:=AutoEnabled;
    ColorCB[ColorCtrl].Checked:=AutoOn;
    ColorCB[ColorCtrl].OnClick:=ColorCBClick;
  end
  else begin
    ColorEdit[ColorCtrl].Enabled:=False;
    ColorCB[ColorCtrl].Enabled:=False;
    ColorCB[ColorCtrl].Checked:=False;
  end;
end;

procedure TUBrainCamSettingsFrm.InitBasicEditAndCB(BasicCtrl:Integer);
var
  Min,Max,Value      : Single;
  AutoEnabled,AutoOn : Boolean;
begin
  if Camera.AbleToGetFireIBasicControlDetails(BasicCtrl,Min,Max,Value,
                                              AutoEnabled,AutoOn) then
  begin
    BasicEdit[BasicCtrl].Enabled:=True;
    BasicEdit[BasicCtrl].Min:=Round(Min);
    BasicEdit[BasicCtrl].Max:=Round(Max);
    BasicEdit[BasicCtrl].Value:=Round(Value);
    BasicEdit[BasicCtrl].OnValueChange:=BasicEditValueChange;
    BasicCB[BasicCtrl].Enabled:=AutoEnabled;
    BasicCB[BasicCtrl].Checked:=AutoOn;
    BasicCB[BasicCtrl].OnClick:=BasicCBClick;
  end
  else begin
    BasicEdit[BasicCtrl].Enabled:=False;
    BasicCB[BasicCtrl].Enabled:=False;
    BasicCB[BasicCtrl].Checked:=False;
  end;
end;

procedure TUBrainCamSettingsFrm.ExpoCtrlChanged(ExpoCtrl:Integer);
var
  Value : Integer;
  Auto  : Boolean;
begin
  Value:=ExpoEdit[ExpoCtrl].Value;
  Auto:=ExpoCB[ExpoCtrl].Checked;
  Camera.AbleToSetFireIExposureControl(ExpoCtrl,Value,Auto);
end;

procedure TUBrainCamSettingsFrm.ExposureEditValueChange(Sender: TObject);
var
  ExpoCtrl : Integer;
begin
  ExpoCtrl:=(Sender as TNBFillEdit).Tag;
  ExpoCtrlChanged(ExpoCtrl);
end;

procedure TUBrainCamSettingsFrm.ExposureCBClick(Sender: TObject);
var
  ExpoCtrl : Integer;
begin
  ExpoCtrl:=(Sender as TAprCheckBox).Tag;
  ExpoCtrlChanged(ExpoCtrl);
end;

procedure TUBrainCamSettingsFrm.ColorCtrlChanged(ColorCtrl:Integer);
var
  Value : Integer;
  Auto  : Boolean;
begin
  Value:=ColorEdit[ColorCtrl].Value;
  Auto:=ColorCB[ColorCtrl].Checked;
  Camera.AbleToSetFireIColorControl(ColorCtrl,Value,Auto);
end;

procedure TUBrainCamSettingsFrm.ColorEditValueChange(Sender: TObject);
var
  ColorCtrl : Integer;
begin
  ColorCtrl:=(Sender as TNBFillEdit).Tag;
  ColorCtrlChanged(ColorCtrl);
end;

procedure TUBrainCamSettingsFrm.ColorCBClick(Sender: TObject);
var
  ColorCtrl : Integer;
begin
  ColorCtrl:=(Sender as TAprCheckBox).Tag;
  ColorCtrlChanged(ColorCtrl);
end;

procedure TUBrainCamSettingsFrm.BasicCtrlChanged(BasicCtrl:Integer);
var
  Value : Integer;
  Auto  : Boolean;
begin
  Value:=BasicEdit[BasicCtrl].Value;
  Auto:=BasicCB[BasicCtrl].Checked;
  Camera.AbleToSetFireIBasicControl(BasicCtrl,Value,Auto);
end;

procedure TUBrainCamSettingsFrm.BasicEditValueChange(Sender: TObject);
var
  BasicCtrl : Integer;
begin
  BasicCtrl:=(Sender as TNBFillEdit).Tag;
  BasicCtrlChanged(BasicCtrl);
end;

procedure TUBrainCamSettingsFrm.BasicCBClick(Sender: TObject);
var
  BasicCtrl : Integer;
begin
  BasicCtrl:=(Sender as TAprCheckBox).Tag;
  BasicCtrlChanged(BasicCtrl);
end;

procedure TUBrainCamSettingsFrm.ShowListBtnClick(Sender: TObject);
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    Camera.ShowFireIVideoFormatList(MemoFrm.Memo.Lines);
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

procedure TUBrainCamSettingsFrm.VenderInfoBtnClick(Sender: TObject);
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    Camera.ShowFireIVenderInfo(MemoFrm.Memo.Lines);
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

end.



