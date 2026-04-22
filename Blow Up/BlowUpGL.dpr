program BlowUpGL;

uses
  Forms,
  Main in 'Main.pas' {MainFrm},
  BmpUtils in 'BmpUtils.pas',
  CameraU in 'CameraU.pas',
  Global in 'Global.pas',
  TilerU in 'TilerU.pas',
  DisplaySetupFrmU in 'DisplaySetupFrmU.pas' {DisplaySetupFrm},
  CfgFile in 'CfgFile.pas',
  TrackerU in 'TrackerU.pas',
  Routines in 'Routines.pas',
  VCellU in 'VCellU.pas',
  FreeImageUtils in 'FreeImageUtils.pas',
  MemoFrmU in 'MemoFrmU.pas' {MemoFrm},
  AvtSetupFrmU in 'AvtSetupFrmU.pas' {AvtSettingsFrm},
  CamSetupFrmU in 'CamSetupFrmU.pas' {CamSettingsFrm},
  FireISetupFrmU in 'FireISetupFrmU.pas' {FireISettingsFrm},
  PtGreySetupFrmU in 'PtGreySetupFrmU.pas' {PointGreySettingsFrm},
  StopWatchU in 'StopWatchU.pas',
  FileUtils in 'FileUtils.pas',
  CalWarningFrmU in 'CalWarningFrmU.pas' {CalWarningFrm},
  Cpu in 'Cpu.pas',
  BlobFind in 'BlobFind.pas',
  BackGndFind in 'BackGndFind.pas',
  TrackingSetupFrmU in 'TrackingSetupFrmU.pas' {TrackingSetupFrm},
  CellTestFrmU in 'CellTestFrmU.pas' {CellTestFrm},
  NVidia in 'NVidia.pas',
  DDrawU in 'DDrawU.pas',
  BlowUpHelpFrmU in 'BlowUpHelpFrmU.pas' {BlowUpHelpFrm},
  GLSceneU in 'GLSceneU.pas',
  GLDraw in 'GLDraw.pas',
  TrackViewFrmU in 'TrackViewFrmU.pas' {TrackViewFrm},
  CameraSettingsFrmU in 'CameraSettingsFrmU.pas' {CameraSettingsFrm},
  TrackTestFrmU in 'TrackTestFrmU.pas' {TrackTestFrm},
  BlowUpTestFrmU in 'BlowUpTestFrmU.pas' {BlowUpTestFrm},
  SettingsFrmU in 'SettingsFrmU.pas' {SettingsFrm},
  TrackingSettingsFrmU in 'TrackingSettingsFrmU.pas' {TrackingSettingsFrm},
  SegmenterSetupFrmU in 'SegmenterSetupFrmU.pas' {SegmenterSetupFrm},
  CellTrackerU in 'CellTrackerU.pas',
  SegmenterU in 'SegmenterU.pas',
  CropWindowFrmU in 'CropWindowFrmU.pas' {CropWindowFrm},
  PopUpFrmU in 'PopUpFrmU.pas' {PopUpFrm},
  DebugMenuFrmU in 'DebugMenuFrmU.pas' {DebugMenuFrm},
  SecretMenuFrmU in 'SecretMenuFrmU.pas' {SecretMenuFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.CreateForm(TPopUpFrm, PopUpFrm);
  Application.CreateForm(TDebugMenuFrm, DebugMenuFrm);
  Application.CreateForm(TSecretMenuFrm, SecretMenuFrm);
  Application.Run;
end.
