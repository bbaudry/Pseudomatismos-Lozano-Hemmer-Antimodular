program BlowUp;

uses
  Forms,
  Main in 'Main.pas' {MainFrm},
  BmpUtils in 'BmpUtils.pas',
  CameraU in 'CameraU.pas',
  Global in 'Global.pas',
  TilerU in 'TilerU.pas',
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
  SegmenterU in 'SegmenterU.pas',
  SegmenterSetupFrmU in 'SegmenterSetupFrmU.pas' {SegmenterSetupFrm},
  CellTrackerU in 'CellTrackerU.pas',
  SettingsFrmU in 'SettingsFrmU.pas' {SettingsFrm},
  SegHelpFrmU in 'SegHelpFrmU.pas' {SegmenterHelpFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
