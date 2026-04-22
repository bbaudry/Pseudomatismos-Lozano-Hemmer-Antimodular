program Airborne;

{%File 'Shaders\Particle.vert'}
{%File 'Shaders\Particle.frag'}

uses
  Forms,
  Main in 'Main.pas' {MainFrm},
  ShaderU in 'ShaderU.pas',
  ProgramU in 'ProgramU.pas',
  Routines in 'Routines.pas',
  CloudU in 'CloudU.pas',
  GLSceneU in 'GLSceneU.pas',
  TextureU in 'TextureU.pas',
  GLDraw in 'GLDraw.pas',
  Global in 'Global.pas',
  CfgFile in 'CfgFile.pas',
  IplUtils in 'IplUtils.pas',
  CloudSetupFrmU in 'CloudSetupFrmU.pas' {CloudSetupFrm},
  MenuFrmU in 'MenuFrmU.pas' {MenuFrm},
  BMPUTILS in 'BMPUTILS.PAS',
  Math2D in 'Math2D.pas',
  ThreadU in 'ThreadU.pas',
  memofrmu in 'memofrmu.pas' {MemoFrm},
  OpenCV1 in 'OpenCV1.pas',
  BmpFrmU in 'BmpFrmU.pas' {BmpFrm},
  BackGndFind in 'BackGndFind.pas',
  BlobFindU in 'BlobFindU.pas',
  CameraU in 'CameraU.pas',
  TrackingSetupFrmU in 'TrackingSetupFrmU.pas' {TrackingSetupFrm},
  BackGndFinderFrmU in 'BackGndFinderFrmU.pas' {BackGndFinderFrm},
  CalibrateFrmU in 'CalibrateFrmU.pas' {CalibrateFrm},
  MouseTestFrmU in 'MouseTestFrmU.pas' {MouseTestFrm},
  ProjectorU in 'ProjectorU.pas',
  CalU in 'CalU.pas',
  CamSettingsFrmU in 'CamSettingsFrmU.pas' {CamSettingsFrm},
  ProjectorCalFrmU in 'ProjectorCalFrmU.pas' {ProjectorCalFrm},
  ProjectorMaskFrmU in 'ProjectorMaskFrmU.pas' {ProjectorMaskFrm},
  ProjectorMaskU in 'ProjectorMaskU.pas',
  MaskFrmU in 'MaskFrmU.pas' {MaskFrm},
  TrackViewFrmU in 'TrackViewFrmU.pas' {TrackViewFrm},
  MaskU in 'MaskU.pas',
  FountainFrmU in 'FountainFrmU.pas' {FountainFrm},
  FountainU in 'FountainU.pas',
  AlphabetU in 'AlphabetU.pas',
  ShadTrkr in 'ShadTrkr.pas',
  CamWindowFrmU in 'CamWindowFrmU.pas' {CamWindowFrm};

{$R *.res}

begin
  Application.Initialize;
  IsMultiThread:=True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.CreateForm(TMenuFrm, MenuFrm);
  Application.CreateForm(TCamWindowFrm, CamWindowFrm);
  Application.Run;
end.
