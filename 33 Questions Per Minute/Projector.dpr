program Projector;

uses
  Forms,
  Main in 'Main.pas' {MainFrm},
  QMakerU in 'QMakerU.pas',
  Setup in 'Setup.pas' {SetupFrm},
  Global in 'Global.pas',
  Routines in 'Routines.pas',
  CfgFile in 'CfgFile.pas',
  LogFile in 'LogFile.pas',
//  MemCheck,
  Password in 'Password.pas' {PasswordFrm};

{$R *.res}

begin
  Application.Initialize;
//MemChk;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.CreateForm(TPasswordFrm, PasswordFrm);
  Application.Run;
end.
