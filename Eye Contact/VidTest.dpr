program VidTest;

uses
  Forms,
  VidTestMain in 'VidTestMain.pas' {VidTestMainFrm},
  VidFile in 'VidFile.pas',
  FreeImageUtils in 'FreeImageUtils.pas',
  BmpUtils in 'BmpUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TVidTestMainFrm, VidTestMainFrm);
  Application.Run;
end.
