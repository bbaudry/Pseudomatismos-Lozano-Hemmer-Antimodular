unit DisplaySetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, AprSpin, StdCtrls, Buttons, AprChkBx, TriSplit, TilerU,
  CPanel, LCD;

type
  TDisplaySetupFrm = class(TForm)
    DoneBtn: TButton;
    DisplayPanel: TPanel;
    RowsLbl: TLabel;
    ColumnsLbl: TLabel;
    XCells1Edit: TAprSpinEdit;
    YCells1Edit: TAprSpinEdit;
    Label4: TLabel;
    OutlinePanel: TPanel;
    Label12: TLabel;
    GridShape: TShape;
    Label5: TLabel;
    OutlineColorBtn: TBitBtn;
    WidthLbl: TLabel;
    GridWidthEdit: TAprSpinEdit;
    ColorDlg: TColorDialog;
    BlowUpAnimationPanel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    TransitionTimeEdit: TAprSpinEdit;
    Label6: TLabel;
    BlowUpTriggerPanel: TPanel;
    Label3: TLabel;
    Label15: TLabel;
    TriggerLevelEdit: TAprSpinEdit;
    Label16: TLabel;
    UntriggerLevelEdit: TAprSpinEdit;
    BlowUpTargetPanel: TPanel;
    Label20: TLabel;
    BlowUpToBestBlobRB: TRadioButton;
    BlowUpToForeGndRB: TRadioButton;
    BlowUpToBackGndRB: TRadioButton;
    BlowUpToAnythingRB: TRadioButton;
    KeepBlowUpYCB: TAprCheckBox;
    BlowUpYFractionEdit: TAprSpinEdit;
    Label21: TLabel;
    BlowUpParametersPanel: TPanel;
    Label14: TLabel;
    Label17: TLabel;
    MinSizeEdit: TAprSpinEdit;
    KeepAspectCB: TAprCheckBox;
    MinLevelLbl: TLabel;
    MinLevelEdit: TAprSpinEdit;
    MaxSizeEdit: TAprSpinEdit;
    Label19: TLabel;
    BlowUpHelpPanel: TPanel;
    Label22: TLabel;
    BlowUpHelpBtn: TBitBtn;
    TenactiyLbl: TLabel;
    TenacityEdit: TAprSpinEdit;
    BlowUpToZoomRB: TRadioButton;
    ForceUntriggerCB: TAprCheckBox;
    ForceUntriggerDelayEdit: TAprSpinEdit;
    Label28: TLabel;
    Panel1: TPanel;
    Label18: TLabel;
    CurrentLevelLCD: TLCD;
    GroupBox1: TGroupBox;
    Label26: TLabel;
    SuperCell2x2Edit: TAprSpinEdit;
    Label27: TLabel;
    Label13: TLabel;
    SuperCell1x2Edit: TAprSpinEdit;
    Label11: TLabel;
    Label8: TLabel;
    SuperCell2x1Edit: TAprSpinEdit;
    Label9: TLabel;
    FollowPanel: TPanel;
    TrackerEnabledCB: TAprCheckBox;
    AveragesLbl: TLabel;
    TrackerXAveragesEdit: TAprSpinEdit;
    TrackerYAveragesEdit: TAprSpinEdit;
    Label7: TLabel;
    GridPeriodEdit: TAprSpinEdit;
    Label25: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    DynamicGridCB: TAprCheckBox;
    XCells2Edit: TAprSpinEdit;
    YCells2Edit: TAprSpinEdit;
    Label10: TLabel;
    Label31: TLabel;
    Label23: TLabel;
    SuperCellScaleEdit: TAprSpinEdit;
    Label24: TLabel;
    UntriggerDelayEdit: TAprSpinEdit;
    Label32: TLabel;
    Label33: TLabel;
    TrackerMaxSpeedEdit: TAprSpinEdit;
    Label34: TLabel;
    SpeedLcd: TLCD;
    Label35: TLabel;
    CamIdleYEdit: TAprSpinEdit;
    ViewCamIdleYBtn: TSpeedButton;
    procedure XCells1EditChange(Sender: TObject);
    procedure YCells1EditChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DoneBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OutlineColorBtnClick(Sender: TObject);
    procedure GridWidthEditChange(Sender: TObject);
    procedure TrackingRBClick(Sender: TObject);
    procedure TimedRBClick(Sender: TObject);
    procedure BlowUpHelpBtnClick(Sender: TObject);
    procedure BlowUpToBestBlobRBClick(Sender: TObject);
    procedure BlowUpToForeGndRBClick(Sender: TObject);
    procedure BlowUpToBackGndRBClick(Sender: TObject);
    procedure BlowUpToAnythingRBClick(Sender: TObject);
    procedure KeepBlowUpYCBClick(Sender: TObject);
    procedure BlowUpYFractionEditChange(Sender: TObject);
    procedure MinLevelEditChange(Sender: TObject);
    procedure KeepAspectCBClick(Sender: TObject);
    procedure TrackerEnabledCBClick(Sender: TObject);
    procedure TrackerXAveragesEditChange(Sender: TObject);
    procedure MinSizeEditChange(Sender: TObject);
    procedure MaxSizeEditChange(Sender: TObject);
    procedure TriggerLevelEditChange(Sender: TObject);
    procedure UntriggerLevelEditChange(Sender: TObject);
    procedure TenacityEditChange(Sender: TObject);
    procedure BlowUpToZoomRBClick(Sender: TObject);
    procedure XCells2EditChange(Sender: TObject);
    procedure YCells2EditChange(Sender: TObject);
    procedure DynamicGridCBClick(Sender: TObject);
    procedure GridPeriodEditChange(Sender: TObject);
    procedure TrackerYAveragesEditChange(Sender: TObject);
    procedure SuperCell2x1EditChange(Sender: TObject);
    procedure SuperCell2x2EditChange(Sender: TObject);
    procedure SuperCell1x2EditChange(Sender: TObject);
    procedure ForceUntriggerCBClick(Sender: TObject);
    procedure ForceUntriggerDelayEditChange(Sender: TObject);
    procedure SuperCellScaleEditChange(Sender: TObject);
    procedure UntriggerDelayEditChange(Sender: TObject);
    procedure TrackerMaxSpeedEditChange(Sender: TObject);
    procedure TransitionTimeEditChange(Sender: TObject);
    procedure CamIdleYEditChange(Sender: TObject);
    procedure ViewCamIdleYBtnClick(Sender: TObject);

  private
    procedure UpdateMainFrm;
    procedure NewCameraFrame(Sender:TObject);

  public
    procedure Initialize;

  end;

var
  DisplaySetupFrm: TDisplaySetupFrm;

implementation

{$R *.dfm}

uses
  Global, CameraU, CfgFile, Main, Routines, GLDraw, GLSceneU, BlowUpHelpFrmU,
  BackGndFind, BlobFind, TrackerU, SegmenterU, CellTrackerU;

procedure TDisplaySetupFrm.Initialize;
var
  MaxH : Integer;
begin
// display settings panel
  XCells1Edit.Value:=Tiler.XCells1;
  YCells1Edit.Value:=Tiler.YCells1;

  DynamicGridCB.Checked:=Tiler.DynamicGrid;
  GridPeriodEdit.Value:=Tiler.GridPeriod/1000;
  XCells2Edit.Value:=Tiler.XCells2;
  YCells2Edit.Value:=Tiler.YCells2;

  SuperCell1x2Edit.Max:=MaxSuperCells;
  SuperCell2x1Edit.Max:=MaxSuperCells;
  SuperCell2x2Edit.Max:=MaxSuperCells;

  SuperCell1x2Edit.Value:=Tiler.SuperCell1x2Count;
  SuperCell2x1Edit.Value:=Tiler.SuperCell2x1Count;
  SuperCell2x2Edit.Value:=Tiler.SuperCell2x2Count;

  SuperCellScaleEdit.Value:=Tiler.SuperCellScale;

  MaxH:=Round(Camera.ImageW*Screen.Height/Screen.Width);
  CamIdleYEdit.Max:=Camera.ImageH-MaxH;
  CamIdleYEdit.Value:=Tiler.CamIdleY;

// outline (grid) panel
  GridShape.Brush.Color:=GLByteColorToColor(Tiler.GridColor);
  GridWidthEdit.Value:=Tiler.GridSize;

// BlowUp trigger panel
  TriggerLevelEdit.Value:=Tiler.TriggerLevel*100;
  UntriggerLevelEdit.Value:=Tiler.UnTriggerLevel*100;
  UnTriggerDelayEdit.Value:=Tiler.UnTriggerDelay/1000;
  ForceUntriggerCB.Checked:=Tiler.ForceUntrigger;
  ForceUnTriggerDelayEdit.Value:=Tiler.ForceUnTriggerDelay/1000;

// BlowUp to panel
  Case Tiler.BlowUpTarget of
    btBestBlob :
      begin
        BlowUpToBestBlobRB.Checked:=True;
        MinLevelLbl.Caption:='Min level:';
      end;
    btForeGnd :
      begin
        BlowUpToForeGndRB.Checked:=True;
        MinLevelLbl.Caption:='Min level:';
      end;
    btBackGnd :
      begin
        BlowUpToBackGndRB.Checked:=True;
        MinLevelLbl.Caption:='Max level:';
      end;
    btAnything :
      begin
        BlowUpToAnythingRB.Checked:=True;
      end;
    btZoom :
      begin
        BlowUpToAnythingRB.Checked:=True;
      end;
  end;
  KeepBlowUpYCB.Checked:=Tiler.KeepBlowUpY;
  BlowUpYFractionEdit.Value:=Tiler.BlowUpYFraction*100;
  TenacityEdit.Value:=Tiler.Tenacity;

// BlowUp animation panel
  TransitionTimeEdit.Value:=Tiler.ZoomTime/1000;

// BlowUp parameters panel
  MinSizeEdit.Value:=Tiler.MinCamSize;
  MaxSizeEdit.Value:=Tiler.MaxCamSize;
  MinLevelEdit.Value:=Tiler.MinLevel*100;
  KeepAspectCB.Checked:=Tiler.KeepAspect;

// tracker
  TrackerEnabledCB.Checked:=Tracker.Enabled;
  TrackerXAveragesEdit.Value:=Tracker.XAverages;
  TrackerYAveragesEdit.Value:=Tracker.YAverages;
  TrackerMaxSpeedEdit.Value:=Tracker.MaxSpeed;

  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TDisplaySetupFrm.UpdateMainFrm;
begin
  GLScene.Render;
end;

procedure TDisplaySetupFrm.XCells1EditChange(Sender: TObject);
begin
  Tiler.XCells1:=Round(XCells1Edit.Value);
  Tiler.PlaceCells;
  UpdateMainFrm;
end;

procedure TDisplaySetupFrm.YCells1EditChange(Sender: TObject);
begin
  Tiler.YCells1:=Round(YCells1Edit.Value);
  Tiler.PlaceCells;
  UpdateMainFrm;
end;

procedure TDisplaySetupFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TDisplaySetupFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Camera.OnNewFrame:=nil;
  Tiler.ShowFullCamera:=False;
  Tiler.ZoomTime:=Round(TransitionTimeEdit.Value*1000);

  SaveCfgFile;
  Tiler.InitForTracking;
end;

procedure TDisplaySetupFrm.DoneBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TDisplaySetupFrm.FormActivate(Sender: TObject);
begin
  CenterCursor(Self);
end;

procedure TDisplaySetupFrm.OutlineColorBtnClick(Sender: TObject);
begin
  ColorDlg.Color:=GLByteColorToColor(Tiler.GridColor);
  if ColorDlg.Execute then begin
    Tiler.GridColor:=ColorToGLByteColor(ColorDlg.Color);
    UpdateMainFrm;
    GridShape.Brush.Color:=ColorDlg.Color; 
  end;
end;

procedure TDisplaySetupFrm.GridWidthEditChange(Sender: TObject);
begin
  Tiler.GridSize:=Round(GridWidthEdit.Value);
  UpdateMainFrm;
end;

procedure TDisplaySetupFrm.NewCameraFrame(Sender:TObject);
begin
// update the tracking objects
  Case TrackMethod of
    tmBlobs :
      begin
        BackGndFinder.Update(Camera.Bmp);
        BlobFinder.Update(BackGndFinder.SubtractedBmp);
      end;
    tmSegmenter :
      begin
        Segmenter.Update(Camera.SmallBmp);
        CellTracker.Update;
      end;
  end;
  Tracker.Update;
  Tiler.Update;
  CurrentLevelLcd.Value:=Round(Tiler.Coverage*100);
  SpeedLcd.Value:=Round(Tracker.Speed);
  UpdateMainFrm;
end;

procedure TDisplaySetupFrm.TrackingRBClick(Sender: TObject);
begin
  BlowUpMode:=bmTracking;
end;

procedure TDisplaySetupFrm.TimedRBClick(Sender: TObject);
begin
  BlowUpMode:=bmTimed;
end;

procedure TDisplaySetupFrm.BlowUpHelpBtnClick(Sender: TObject);
begin
  BlowUpHelpFrm:=TBlowUpHelpFrm.Create(Application);
  try
    BlowUpHelpFrm.ShowModal;
  finally
    BlowUpHelpFrm.Free;
  end;
end;

procedure TDisplaySetupFrm.BlowUpToBestBlobRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btBestBlob;
  MinLevelLbl.Caption:='Min level:';
end;

procedure TDisplaySetupFrm.BlowUpToForeGndRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btForeGnd;
  MinLevelLbl.Caption:='Min level:';
end;

procedure TDisplaySetupFrm.BlowUpToBackGndRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btBackGnd;
  MinLevelLbl.Caption:='Max level:';
end;

procedure TDisplaySetupFrm.BlowUpToAnythingRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btAnything;
end;

procedure TDisplaySetupFrm.KeepBlowUpYCBClick(Sender: TObject);
begin
  Tiler.KeepBlowUpY:=KeepBlowUpYCB.Checked;
end;

procedure TDisplaySetupFrm.BlowUpYFractionEditChange(Sender: TObject);
begin
  Tiler.BlowUpYFraction:=BlowUpYFractionEdit.Value/100;
end;

procedure TDisplaySetupFrm.MinSizeEditChange(Sender: TObject);
begin
  Tiler.MinCamSize:=Round(MinSizeEdit.Value);
end;

procedure TDisplaySetupFrm.MaxSizeEditChange(Sender: TObject);
begin
  Tiler.MaxCamSize:=Round(MaxSizeEdit.Value);
end;

procedure TDisplaySetupFrm.MinLevelEditChange(Sender: TObject);
begin
  Tiler.MinLevel:=MinLevelEdit.Value/100;
end;

procedure TDisplaySetupFrm.KeepAspectCBClick(Sender: TObject);
begin
  Tiler.KeepAspect:=KeepAspectCB.Checked;
end;

procedure TDisplaySetupFrm.TrackerEnabledCBClick(Sender: TObject);
begin
  Tracker.Enabled:=TrackerEnabledCB.Checked;
end;

procedure TDisplaySetupFrm.TrackerXAveragesEditChange(Sender: TObject);
begin
  Tracker.XAverages:=Round(TrackerXAveragesEdit.Value);
end;

procedure TDisplaySetupFrm.TrackerYAveragesEditChange(Sender: TObject);
begin
  Tracker.YAverages:=Round(TrackerYAveragesEdit.Value);
end;

procedure TDisplaySetupFrm.TriggerLevelEditChange(Sender: TObject);
begin
  Tiler.TriggerLevel:=TriggerLevelEdit.Value/100;
end;

procedure TDisplaySetupFrm.UntriggerLevelEditChange(Sender: TObject);
begin
  Tiler.UnTriggerLevel:=UntriggerLevelEdit.Value/100;
end;

procedure TDisplaySetupFrm.TenacityEditChange(Sender: TObject);
begin
  Tiler.Tenacity:=Round(TenacityEdit.Value);
end;

procedure TDisplaySetupFrm.BlowUpToZoomRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btZoom;
end;

procedure TDisplaySetupFrm.DynamicGridCBClick(Sender: TObject);
begin
  Tiler.DynamicGrid:=DynamicGridCB.Checked;
end;

procedure TDisplaySetupFrm.XCells2EditChange(Sender: TObject);
begin
  Tiler.XCells2:=Round(XCells2Edit.Value);
end;

procedure TDisplaySetupFrm.YCells2EditChange(Sender: TObject);
begin
  Tiler.YCells2:=Round(YCells2Edit.Value);
end;

procedure TDisplaySetupFrm.GridPeriodEditChange(Sender: TObject);
begin
  Tiler.GridPeriod:=Round(GridPeriodEdit.Value*1000);
end;

procedure TDisplaySetupFrm.SuperCell1x2EditChange(Sender: TObject);
begin
  Tiler.SuperCell1x2Count:=Round(SuperCell1x2Edit.Value);
end;

procedure TDisplaySetupFrm.SuperCell2x1EditChange(Sender: TObject);
begin
  Tiler.SuperCell2x1Count:=Round(SuperCell2x1Edit.Value);
end;

procedure TDisplaySetupFrm.SuperCell2x2EditChange(Sender: TObject);
begin
  Tiler.SuperCell2x2Count:=Round(SuperCell2x2Edit.Value);
end;

procedure TDisplaySetupFrm.ForceUntriggerCBClick(Sender: TObject);
begin
  Tiler.ForceUntrigger:=ForceUntriggerCB.Checked;
end;

procedure TDisplaySetupFrm.ForceUntriggerDelayEditChange(Sender: TObject);
begin
  Tiler.ForceUnTriggerDelay:=Round(ForceUnTriggerDelayEdit.Value*1000);
end;

procedure TDisplaySetupFrm.SuperCellScaleEditChange(Sender: TObject);
begin
  Tiler.SuperCellScale:=SuperCellScaleEdit.Value;
end;

procedure TDisplaySetupFrm.UntriggerDelayEditChange(Sender: TObject);
begin
  Tiler.UnTriggerDelay:=Round(UnTriggerDelayEdit.Value*1000);
end;

procedure TDisplaySetupFrm.TrackerMaxSpeedEditChange(Sender: TObject);
begin
  Tracker.MaxSpeed:=TrackerMaxSpeedEdit.Value;
end;

procedure TDisplaySetupFrm.TransitionTimeEditChange(Sender: TObject);
begin
  Tiler.ZoomTime:=Round(TransitionTimeEdit.Value*1000);
end;

procedure TDisplaySetupFrm.CamIdleYEditChange(Sender: TObject);
begin
  Tiler.CamIdleY:=Round(CamIdleYEdit.Value);
  Tiler.FindCamIdleVars;
  Tiler.PlaceCells;
end;

procedure TDisplaySetupFrm.ViewCamIdleYBtnClick(Sender: TObject);
begin
  Tiler.ShowFullCamera:=ViewCamIdleYBtn.Down;
end;

end.














