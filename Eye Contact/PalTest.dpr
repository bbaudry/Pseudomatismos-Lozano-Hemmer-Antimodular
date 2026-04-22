program PalTest;

uses
  Forms,
  PTMain in 'PTMain.pas' {PTMainFrm},
  TilerU in 'TilerU.pas',
  BmpUtils in 'BmpUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TPTMainFrm, PTMainFrm);
  Application.Run;
end.
