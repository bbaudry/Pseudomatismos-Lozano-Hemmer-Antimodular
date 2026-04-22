unit MenuFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ThreadU, StopWatchU, ComCtrls, ExtCtrls,
  AprSpin;

type
  TMenuFrm = class(TForm)
    SetupBtn: TBitBtn;
    ExitBtn: TBitBtn;
    CameraBtn: TButton;
    ViewTrackingBtn: TButton;
    CalibrateBtn: TButton;
    MouseTestBtn: TButton;
    ProjectorMaskBtn: TButton;
    StatusBar: TStatusBar;
    FountainBtn: TButton;
    SaveBmpBtn: TButton;
    ShowRG: TRadioGroup;
    ResetBtn: TButton;
    HomeThresholdEdit: TAprSpinEdit;
    Label1: TLabel;
    procedure SetupBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure CameraBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ViewTrackingBtnClick(Sender: TObject);
    procedure CalibrateBtnClick(Sender: TObject);
    procedure MouseTestBtnClick(Sender: TObject);
    procedure ProjectorMaskBtnClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FountainBtnClick(Sender: TObject);
    procedure WatchBmpBtnClick(Sender: TObject);
    procedure SaveBmpBtnClick(Sender: TObject);
    procedure ShowRGClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure HomeThresholdEditChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private

  public

  end;

var
  MenuFrm: TMenuFrm;

implementation

uses
  SetupFrmU, CameraU, Main, Global, TrackingSetupFrmU, CalibrateFrmU, CfgFile,
  MouseTestFrmU, CloudSetupFrmU, ProjectorMaskFrmU, TrackViewFrmU, AlphabetU,
  FountainFrmU, CloudU, BmpFrmU, FountainU;

{$R *.dfm}

procedure TMenuFrm.FormCreate(Sender: TObject);
var
  L : Integer;
begin
  L:=Length(VersionStr);
  Caption:=Copy(VersionStr,L-4,5);
  HomeThresholdEdit.Value:=Fountain.HomeThreshold;
end;

procedure TMenuFrm.SetupBtnClick(Sender: TObject);
begin
  CloudSetupFrm:=TCloudSetupFrm.Create(Application);
  try
    CloudSetupFrm.Initialize;
    CloudSetupFrm.ShowModal;
  finally
    CloudSetupFrm.Free;
  end;
  SaveCfgFile;
end;

procedure TMenuFrm.ExitBtnClick(Sender: TObject);
begin
  SaveCfgFile;
  MainFrm.Close;
end;

procedure TMenuFrm.CameraBtnClick(Sender: TObject);
begin
  Camera.ShowSettingsFrm;
  SaveCfgFile;
end;

procedure TMenuFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  MainFrm.GLPanel.Cursor:=crNone;
//  TrackViewFrm.Cursor:=crNone;
  SaveCfgFile;
end;

procedure TMenuFrm.ViewTrackingBtnClick(Sender: TObject);
begin
  TrackingSetupFrm:=TTrackingSetupFrm.Create(Application);
  try
    TrackingSetupFrm.Initialize;
    TrackingSetupFrm.ShowModal;
  finally
    TrackingSetupFrm.Free;
  end;
  SaveCfgFile;
  Camera.OnNewFrame:=MainFrm.NewCameraFrame;
end;

procedure TMenuFrm.CalibrateBtnClick(Sender: TObject);
begin
  CalibrateFrm:=TCalibrateFrm.Create(Application);
  try
    CalibrateFrm.Initialize;
    CalibrateFrm.ShowModal;
  finally
    CalibrateFrm.Free;
  end;
  Camera.OnNewFrame:=MainFrm.NewCameraFrame;
  SaveCfgFile;
end;

procedure TMenuFrm.MouseTestBtnClick(Sender: TObject);
begin
  MouseTestFrm:=TMouseTestFrm.Create(Application);
  try
    MouseTestFrm.Initialize;
    MouseTestFrm.ShowModal;
  finally
    MouseTestFrm.Free;
  end;
  Camera.OnNewFrame:=MainFrm.NewCameraFrame;
end;

procedure TMenuFrm.ProjectorMaskBtnClick(Sender: TObject);
begin
  ProjectorMaskFrm:=TProjectorMaskFrm.Create(Application);
  try
    ProjectorMaskFrm.Initialize;
    ProjectorMaskFrm.ShowModal;
  finally
    ProjectorMaskFrm.Free;
  end;
  SaveCfgFile;
end;

procedure TMenuFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#27 then Close;
end;

procedure TMenuFrm.FountainBtnClick(Sender: TObject);
begin
  FountainFrm:=TFountainFrm.Create(Application);
  try
    FountainFrm.Initialize;
    FountainFrm.ShowModal;
  finally
    FountainFrm.Free;
  end;
end;

procedure TMenuFrm.WatchBmpBtnClick(Sender: TObject);
begin
  if not Assigned(BmpFrm) then BmpFrm:=TBmpFrm.Create(Application);
  BmpFrm.Initialize;
  BmpFrm.Show;
end;

procedure TMenuFrm.SaveBmpBtnClick(Sender: TObject);
begin
  Cloud.Save:=True;
end;

procedure TMenuFrm.ShowRGClick(Sender: TObject);
begin
  Case ShowRG.ItemIndex of
    0 : Cloud.RenderMode:=rmVelocity;
    1 : Cloud.RenderMode:=rmTemperature;
    2 : Cloud.RenderMode:=rmPressure;
    3 : Cloud.RenderMode:=rmDensity;
  end;
end;

procedure TMenuFrm.ResetBtnClick(Sender: TObject);
begin
  Fountain.Reset:=True;
end;

procedure TMenuFrm.HomeThresholdEditChange(Sender: TObject);
begin
  Fountain.HomeThreshold:=HomeThresholdEdit.Value;
end;

procedure TMenuFrm.Button1Click(Sender: TObject);
begin
  Cloud.RedrawObstacles:=True;
//  Cloud.DrawObstacles;
 // Cloud.ObstacleBmp.SaveToFile('Obs.bmp');
end;

end.

procedure TMenuFrm.FadeTestCBClick(Sender: TObject);
begin
  Collector.Fade.Test:=FadeTestCB.Checked;
end;

procedure TMenuFrm.FadeSBChange(Sender: TObject);
begin
  Collector.Fade.Fraction:=FadeSB.Position/100;
end;

procedure TMenuFrm.Button1Click(Sender: TObject);
var
  Bmp : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    Bmp.Width:=800;
    Bmp.Height:=600;
    Bmp.PixelFormat:=pf24Bit;
    StopWatch.ShowHistory(Bmp,2,0,0,Bmp.Width,Bmp.Height,0.066);
    Bmp.SaveToFile('c:\Times.bmp');
  finally
    Bmp.Free;
  end;
end;

end.

KSPROPERTY_LP1_VERSION_S
Bmp.Height div 2
