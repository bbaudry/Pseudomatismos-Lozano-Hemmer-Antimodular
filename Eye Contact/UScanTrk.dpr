program UScanTrk;

uses
  Forms,
  Main in 'Main.pas' {MainFrm},
  BmpUtils in 'BmpUtils.pas',
  CameraU in 'CameraU.pas',
  Global in 'Global.pas',
  TilerU in 'TilerU.pas',
  JpgView in 'JpgView.pas' {JpgViewFrm},
  SetupU in 'SetupU.pas' {SetupFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
