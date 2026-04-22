program Multitexture;

uses
  Forms,
  Main in 'Main.pas' {MainFrm},
  GLFountainU in 'GLFountainU.pas',
  Global in 'Global.pas',
  TextureU in 'TextureU.pas',
  GLSceneU in 'GLSceneU.pas',
  GLDraw in 'GLDraw.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
