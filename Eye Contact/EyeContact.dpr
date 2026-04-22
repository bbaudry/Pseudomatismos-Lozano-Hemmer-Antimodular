program EyeContact;

uses
  Forms,
  Main in 'Main.pas' {MainFrm},
  BmpUtils in 'BmpUtils.pas',
  CameraU in 'CameraU.pas',
  Global in 'Global.pas',
  TilerU in 'TilerU.pas',
  DisplayCfg in 'DisplayCfg.pas' {DisplaySetupFrm},
  CfgFile in 'CfgFile.pas',
  TrackerU in 'TrackerU.pas',
  Routines in 'Routines.pas',
  TrackingCfg in 'TrackingCfg.pas' {TrackingSetupFrm},
  RunFrmU in 'RunFrmU.pas' {RunFrm},
  VCellU in 'VCellU.pas',
  ScrubTst in 'ScrubTst.pas' {ScrubTestFrm},
  BmpMakerU in 'BmpMakerU.pas',
  BmpMakeFrmU in 'BmpMakeFrmU.pas' {BmpMakeFrm},
  BmpLoadU in 'BmpLoadU.pas' {BmpLoadFrm},
  BmpView in 'BmpView.pas' {BmpViewFrm},
  FreeImageUtils in 'FreeImageUtils.pas',
  VidFile in 'VidFile.pas',
  MemoFrmU in 'memofrmu.pas' {MemoFrm},
  ThreadU in 'ThreadU.pas',
  AdvancedFrmU in 'AdvancedFrmU.pas' {AdvancedSetupFrm},
  AvtSetupFrmU in 'AvtSetupFrmU.pas' {AvtSettingsFrm},
  CamSetupFrmU in 'CamSetupFrmU.pas' {CamSettingsFrm},
  CellBackGndFind in 'CellBackGndFind.pas',
  CellBackGndFrmU in 'CellBackGndFrmU.pas' {CellBackGndFrm},
  CropWindowFrmU in 'CropWindowFrmU.pas' {CropWindowFrm},
  FireISetupFrmU in 'FireISetupFrmU.pas' {FireISettingsFrm},
  PixelBackGndFind in 'PixelBackGndFind.pas',
  PixelBackGndFrmU in 'PixelBackGndFrmU.pas' {PixelBackGndFrm},
  PtGreySetupFrmU in 'PtGreySetupFrmU.pas' {PointGreySettingsFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
