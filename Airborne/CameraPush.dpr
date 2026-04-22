program CameraPush;

uses
  Forms,
  Main in 'Main.pas' {MainFrm},
  SmAPI in 'SmAPI.pas',
  SmApiReturnCodes in 'SmApiReturnCodes.pas',
  FaceTrackerU in 'FaceTrackerU.pas',
  CameraSetupFrmU in 'CameraSetupFrmU.pas' {CameraSetupFrm},
  CameraU in 'CameraU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
