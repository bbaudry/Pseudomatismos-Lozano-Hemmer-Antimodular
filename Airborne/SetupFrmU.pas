unit SetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, CPanel, OpenGL1x, OpenGLTokens, ProgramU, AprChkBx,
  StdCtrls, ComCtrls, Buttons, ColorBtn, AprSpin, UnitLCD;

type
  TSetupFrm = class(TForm)
    ColorDlg: TColorDialog;
    SmokePanel: TPanel;
    Label26: TLabel;
    Label1: TLabel;
    AmbientTemperatureEdit: TAprSpinEdit;
    Label2: TLabel;
    ImpulseTemperatureEdit: TAprSpinEdit;
    Label3: TLabel;
    ImpulseDensityEdit: TAprSpinEdit;
    Label4: TLabel;
    JacobiIterationsEdit: TAprSpinEdit;
    Label5: TLabel;
    TimeStepEdit: TAprSpinEdit;
    Label6: TLabel;
    SmokeBuoyancyEdit: TAprSpinEdit;
    Label7: TLabel;
    SmokeWeightEdit: TAprSpinEdit;
    Label8: TLabel;
    TemperatureDissipationEdit: TAprSpinEdit;
    Label9: TLabel;
    VelocityDissipationEdit: TAprSpinEdit;
    Label10: TLabel;
    DensityDissipationEdit: TAprSpinEdit;
    Label11: TLabel;
    CellSizeEdit: TAprSpinEdit;
    Label12: TLabel;
    GradientScaleEdit: TAprSpinEdit;
    ColorBtn: TColorBtn;
    Panel2: TPanel;
    Label17: TLabel;
    Label25: TLabel;
    Label56: TLabel;
    XResEdit: TAprSpinEdit;
    YResEdit: TAprSpinEdit;
    procedure ColorBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AmbientTemperatureEditChange(Sender: TObject);
    procedure ImpulseTemperatureEditChange(Sender: TObject);
    procedure ImpulseDensityEditChange(Sender: TObject);
    procedure JacobiIterationsEditChange(Sender: TObject);
    procedure TimeStepEditChange(Sender: TObject);
    procedure SmokeBuoyancyEditChange(Sender: TObject);
    procedure SmokeWeightEditChange(Sender: TObject);
    procedure TemperatureDissipationEditChange(Sender: TObject);
    procedure VelocityDissipationEditChange(Sender: TObject);
    procedure DensityDissipationEditChange(Sender: TObject);
    procedure CellSizeEditChange(Sender: TObject);
    procedure GradientScaleEditChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure XResEditChange(Sender: TObject);
    procedure YResEditChange(Sender: TObject);

  private

  public
    procedure Initialize;

  end;

var
  SetupFrm: TSetupFrm;

implementation

{$R *.dfm}

uses
  Routines, GLSceneU, GLDraw, TextureU, CloudU, CfgFile, Global, Math, Main,
  CameraU;

procedure TSetupFrm.Initialize;
begin
  Caption:=VersionStr;

  EnterCriticalSection(Camera.CS);

  AmbientTemperatureEdit.Value:=Cloud.AmbientTemperature;
  ImpulseTemperatureEdit.Value:=Cloud.ImpulseTemperature;
  ImpulseDensityEdit.Value:=Cloud.ImpulseDensity;
  JacobiIterationsEdit.Value:=Cloud.JacobiIterations;
  TimeStepEdit.Value:=Cloud.TimeStep;
  SmokeBuoyancyEdit.Value:=Cloud.SmokeBuoyancy;
  SmokeWeightEdit.Value:=Cloud.SmokeWeight;
  TemperatureDissipationEdit.Value:=Cloud.TemperatureDissipation;
  VelocityDissipationEdit.Value:=Cloud.TemperatureDissipation;
  DensityDissipationEdit.Value:=Cloud.DensityDissipation;
  CellSizeEdit.Value:=Cloud.CellSize;
  GradientScaleEdit.Value:=Cloud.GradientScale;
  ColorBtn.Color:=Cloud.SmokeColor;
//  ClearPressureCB.Checked:=Cloud.ClearPressure;

  LeaveCriticalSection(Camera.CS);

  XResEdit.Value:=ScreenW;
  YResEdit.Value:=ScreenH;
end;

procedure TSetupFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  EnterCriticalSection(Camera.CS);

  SaveCfgFile;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.ColorBtnClick(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  ColorDlg.Color:=Cloud.SmokeColor;
  if ColorDlg.Execute then begin
    Cloud.SmokeColor:=ColorDlg.Color;
    ColorBtn.Color:=Cloud.SmokeColor;
  end;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.AmbientTemperatureEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.AmbientTemperature:=AmbientTemperatureEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.ImpulseTemperatureEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.ImpulseTemperature:=ImpulseTemperatureEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.ImpulseDensityEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.ImpulseDensity:=ImpulseDensityEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.JacobiIterationsEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.JacobiIterations:=Round(JacobiIterationsEdit.Value);

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.TimeStepEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.TimeStep:=TimeStepEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.SmokeBuoyancyEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.SmokeBuoyancy:=SmokeBuoyancyEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.SmokeWeightEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.SmokeWeight:=SmokeWeightEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.TemperatureDissipationEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.TemperatureDissipation:=TemperatureDissipationEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.VelocityDissipationEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.VelocityDissipation:=TemperatureDissipationEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.DensityDissipationEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.DensityDissipation:=DensityDissipationEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.CellSizeEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.CellSize:=CellSizeEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.GradientScaleEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.GradientScale:=GradientScaleEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TSetupFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0);
end;

procedure TSetupFrm.XResEditChange(Sender: TObject);
begin
  ScreenW:=Round(XResEdit.Value);
end;

procedure TSetupFrm.YResEditChange(Sender: TObject);
begin
  ScreenH:=Round(YResEdit.Value);
end;

end.






