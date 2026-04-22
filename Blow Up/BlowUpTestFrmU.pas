unit BlowUpTestFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, LCD, AprChkBx, ExtCtrls, AprSpin;

type
  TBlowUpTestFrm = class(TForm)
    PaintBox: TPaintBox;
    Label3: TLabel;
    ClearBtn: TButton;
    LoadBtn: TButton;
    SaveBtn: TButton;
    PenWidthEdit: TAprSpinEdit;
    BlowUpTriggerPanel: TPanel;
    Label1: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label28: TLabel;
    Label24: TLabel;
    Label32: TLabel;
    TriggerLevelEdit: TAprSpinEdit;
    UntriggerLevelEdit: TAprSpinEdit;
    ForceUntriggerCB: TAprCheckBox;
    ForceUntriggerDelayEdit: TAprSpinEdit;
    Panel1: TPanel;
    Label18: TLabel;
    CurrentLevelLCD: TLCD;
    UntriggerDelayEdit: TAprSpinEdit;
    BlowUpTargetPanel: TPanel;
    Label20: TLabel;
    Label21: TLabel;
    TenactiyLbl: TLabel;
    BlowUpToBestBlobRB: TRadioButton;
    BlowUpToForeGndRB: TRadioButton;
    BlowUpToBackGndRB: TRadioButton;
    BlowUpToAnythingRB: TRadioButton;
    KeepBlowUpYCB: TAprCheckBox;
    BlowUpYFractionEdit: TAprSpinEdit;
    TenacityEdit: TAprSpinEdit;
    BlowUpToZoomRB: TRadioButton;
    BlowUpParametersPanel: TPanel;
    Label14: TLabel;
    Label17: TLabel;
    MinLevelLbl: TLabel;
    Label19: TLabel;
    MinSizeEdit: TAprSpinEdit;
    KeepAspectCB: TAprCheckBox;
    MinLevelEdit: TAprSpinEdit;
    MaxSizeEdit: TAprSpinEdit;
    FollowPanel: TPanel;
    AveragesLbl: TLabel;
    Label7: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    SpeedLcd: TLCD;
    TrackerEnabledCB: TAprCheckBox;
    TrackerXAveragesEdit: TAprSpinEdit;
    TrackerYAveragesEdit: TAprSpinEdit;
    TrackerMaxSpeedEdit: TAprSpinEdit;
    ColorDlg: TColorDialog;
    BlowUpAnimationPanel: TPanel;
    Label2: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    TransitionTimeEdit: TAprSpinEdit;
    DrawForeGndPanel: TPanel;
    Label5: TLabel;
    StripsCB: TAprCheckBox;
    BlobsCB: TAprCheckBox;
    CellWindowsCB: TAprCheckBox;
    SuperCellsCB: TAprCheckBox;
    Label8: TLabel;
    Label9: TLabel;
    ColEdit: TAprSpinEdit;
    Label10: TLabel;
    RowEdit: TAprSpinEdit;
    procedure TriggerLevelEditChange(Sender: TObject);
    procedure UntriggerLevelEditChange(Sender: TObject);
    procedure UntriggerDelayEditChange(Sender: TObject);
    procedure ForceUntriggerCBClick(Sender: TObject);
    procedure ForceUntriggerDelayEditChange(Sender: TObject);
    procedure BlowUpToBestBlobRBClick(Sender: TObject);
    procedure BlowUpToForeGndRBClick(Sender: TObject);
    procedure BlowUpToBackGndRBClick(Sender: TObject);
    procedure BlowUpToZoomRBClick(Sender: TObject);
    procedure KeepBlowUpYCBClick(Sender: TObject);
    procedure BlowUpYFractionEditChange(Sender: TObject);
    procedure TenacityEditChange(Sender: TObject);
    procedure MinSizeEditChange(Sender: TObject);
    procedure MaxSizeEditChange(Sender: TObject);
    procedure MinLevelEditChange(Sender: TObject);
    procedure KeepAspectCBClick(Sender: TObject);
    procedure TrackerEnabledCBClick(Sender: TObject);
    procedure TrackerXAveragesEditChange(Sender: TObject);
    procedure TrackerYAveragesEditChange(Sender: TObject);
    procedure TrackerMaxSpeedEditChange(Sender: TObject);
    procedure TransitionTimeEditChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
    Bmp,CamBmp : TBitmap;

    procedure UpdateMainFrm;
    procedure NewCameraFrame(Sender:TObject);
    procedure DrawBmp;
    function  CamBmpFileName:String;

  public
    procedure Initialize;
  end;

var
  BlowUpTestFrm: TBlowUpTestFrm;

implementation

{$R *.dfm}

uses
  GLSceneU, CameraU, TilerU,  BmpUtils, BackGndFind, BlobFind, TrackerU,
  Routines;

procedure TBlowUpTestFrm.Initialize;
begin
  Bmp:=CreateImageBmp;
  ClearBmp(Bmp,clBlack);
  CamBmp:=CreateImageBmp;
  ClearBmp(CamBmp,clBlack);

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

procedure TBlowUpTestFrm.UpdateMainFrm;
begin
  GLScene.Render;
end;

procedure TBlowUpTestFrm.NewCameraFrame(Sender:TObject);
begin
  Camera.Bmp.Canvas.Draw(0,0,CamBmp);

// update the tracking objects
  BackGndFinder.SubtractedBmp.Canvas.Draw(0,0,Camera.Bmp);
  BlobFinder.Update(BackGndFinder.SubtractedBmp);
  Tracker.Update;
  Tiler.Update;
  CurrentLevelLcd.Value:=Round(Tiler.Coverage*100);
  SpeedLcd.Value:=Round(Tracker.Speed);
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
  UpdateMainFrm;
end;

procedure TBlowUpTestFrm.TriggerLevelEditChange(Sender: TObject);
begin
  Tiler.TriggerLevel:=TriggerLevelEdit.Value/100;
end;

procedure TBlowUpTestFrm.UntriggerLevelEditChange(Sender: TObject);
begin
  Tiler.UnTriggerLevel:=UntriggerLevelEdit.Value/100;
end;

procedure TBlowUpTestFrm.UntriggerDelayEditChange(Sender: TObject);
begin
  Tiler.UnTriggerDelay:=Round(UnTriggerDelayEdit.Value*1000);
end;

procedure TBlowUpTestFrm.ForceUntriggerCBClick(Sender: TObject);
begin
  Tiler.ForceUntrigger:=ForceUntriggerCB.Checked;
end;

procedure TBlowUpTestFrm.ForceUntriggerDelayEditChange(Sender: TObject);
begin
  Tiler.ForceUnTriggerDelay:=Round(ForceUnTriggerDelayEdit.Value*1000);
end;

procedure TBlowUpTestFrm.BlowUpToBestBlobRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btBestBlob;
  MinLevelLbl.Caption:='Min level:';
end;

procedure TBlowUpTestFrm.BlowUpToForeGndRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btForeGnd;
  MinLevelLbl.Caption:='Min level:';
end;

procedure TBlowUpTestFrm.BlowUpToBackGndRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btBackGnd;
  MinLevelLbl.Caption:='Max level:';
end;

procedure TBlowUpTestFrm.BlowUpToZoomRBClick(Sender: TObject);
begin
  Tiler.BlowUpTarget:=btAnything;
end;

procedure TBlowUpTestFrm.KeepBlowUpYCBClick(Sender: TObject);
begin
  Tiler.KeepBlowUpY:=KeepBlowUpYCB.Checked;
end;

procedure TBlowUpTestFrm.BlowUpYFractionEditChange(Sender: TObject);
begin
  Tiler.BlowUpYFraction:=BlowUpYFractionEdit.Value/100;
end;

procedure TBlowUpTestFrm.TenacityEditChange(Sender: TObject);
begin
  Tiler.Tenacity:=Round(TenacityEdit.Value);
end;

procedure TBlowUpTestFrm.MinSizeEditChange(Sender: TObject);
begin
  Tiler.MinCamSize:=Round(MinSizeEdit.Value);
end;

procedure TBlowUpTestFrm.MaxSizeEditChange(Sender: TObject);
begin
  Tiler.MaxCamSize:=Round(MaxSizeEdit.Value);
end;

procedure TBlowUpTestFrm.MinLevelEditChange(Sender: TObject);
begin
  Tiler.MinLevel:=MinLevelEdit.Value/100;
end;

procedure TBlowUpTestFrm.KeepAspectCBClick(Sender: TObject);
begin
  Tiler.KeepAspect:=KeepAspectCB.Checked;
end;

procedure TBlowUpTestFrm.TrackerEnabledCBClick(Sender: TObject);
begin
  Tracker.Enabled:=TrackerEnabledCB.Checked;
end;

procedure TBlowUpTestFrm.TrackerXAveragesEditChange(Sender: TObject);
begin
  Tracker.XAverages:=Round(TrackerXAveragesEdit.Value);
end;

procedure TBlowUpTestFrm.TrackerYAveragesEditChange(Sender: TObject);
begin
  Tracker.YAverages:=Round(TrackerYAveragesEdit.Value);
end;

procedure TBlowUpTestFrm.TrackerMaxSpeedEditChange(Sender: TObject);
begin
  Tracker.MaxSpeed:=TrackerMaxSpeedEdit.Value;
end;

procedure TBlowUpTestFrm.TransitionTimeEditChange(Sender: TObject);
begin
  Tiler.ZoomTime:=Round(TransitionTimeEdit.Value*1000);
end;

procedure TBlowUpTestFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
  if Assigned(CamBmp) then CamBmp.Free;
  Camera.OnNewFrame:=nil;
end;

procedure TBlowUpTestFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TBlowUpTestFrm.DrawBmp;
var
  C,R : Integer;
begin
  Bmp.Canvas.Draw(0,0,Camera.Bmp);
  Bmp.Canvas.Pen.Style:=psSolid;
  if StripsCB.Checked then BlobFinder.DrawStrips(Bmp);
  if BlobsCB.Checked then BlobFinder.DrawBlobs(Bmp,0);
  if CellWindowsCB.Checked then begin
    Tiler.DrawCellsOnCamBmp(Bmp);
    C:=Round(ColEdit.Value);
    R:=Round(RowEdit.Value);
    if (C<=Tiler.XCells) and (R<=Tiler.YCells) then begin
      if (Tiler.Mode in [tmIdle,tmForcedIdle]) or
          (not Tiler.Cell[C,R].PartOfSuperCell) then
      begin
        Tiler.Cell[C,R].HighlightOnCamBmp(Bmp);
      end;
    end;
  end;
  if SuperCellsCB.Checked then Tiler.DrawSuperCellsOnCamBmp(Bmp);
end;

function TBlowUpTestFrm.CamBmpFileName:String;
begin
  Result:=Path+'CamBmp.bmp';
end;

procedure TBlowUpTestFrm.ClearBtnClick(Sender: TObject);
begin
  ClearBmp(CamBmp,clBlack);
end;

procedure TBlowUpTestFrm.LoadBtnClick(Sender: TObject);
begin
  if FileExists(CamBmpFileName) then CamBmp.LoadFromFile(CamBmpFileName)
  else ShowMessage(CamBmpFileName+' not found');
end;

procedure TBlowUpTestFrm.SaveBtnClick(Sender: TObject);
begin
  CamBmp.SaveToFile(CamBmpFileName);
end;

procedure TBlowUpTestFrm.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CamBmp.Canvas.MoveTo(X,Y);
end;

procedure TBlowUpTestFrm.PaintBoxMouseMove(Sender:TObject;Shift:TShiftState;
                                           X,Y:Integer);
begin
  if LeftMouseBtnDown then CamBmp.Canvas.Pen.Color:=clWhite
  else if RightMouseBtnDown then CamBmp.Canvas.Pen.Color:=clBlack
  else Exit;
  CamBmp.Canvas.Pen.Width:=Round(PenWidthEdit.Value);
  CamBmp.Canvas.LineTo(X,Y);
end;

end.


