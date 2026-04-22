program CamTest;

uses
  Forms,
  CTMain in 'CTMain.pas' {CTMainFrm},
  CameraU in 'CameraU.pas',
  Global in 'Global.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TCTMainFrm, CTMainFrm);
  Application.Run;
end.
