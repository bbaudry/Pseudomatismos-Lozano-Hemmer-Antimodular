unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Z_prof, ComCtrls, ImgList, Menus,
  StopWatchU, CPanel;

const
  Debugging     : Boolean = False;
  CountDownTime = 10450;

type
  TMainFrm = class(TForm)
    BackGndTimer: TTimer;
    PopupMenu: TPopupMenu;
    CalibrateItem: TMenuItem;
    QuitProgramItem: TMenuItem;
    N4: TMenuItem;
    DebugMenu: TPopupMenu;
    TakeBackGndIn10sItem: TMenuItem;
    SetupDisplayItem: TMenuItem;
    SecretMenu: TPopupMenu;
    CameraTimer: TTimer;
    N8: TMenuItem;
    SetupTrackingItem: TMenuItem;
    N2: TMenuItem;
    CellTestItem: TMenuItem;
    GLPanel: TCanvasPanel;
    ViewTrackingItem: TMenuItem;
    N3: TMenuItem;
    SettingsItem: TMenuItem;
    ShowSuperCellsItem: TMenuItem;
    N1: TMenuItem;
    StopWatchItem: TMenuItem;
    TrackTestItem: TMenuItem;
    BlowUpTestItem: TMenuItem;
    TestCellsItem: TMenuItem;
    ShowTestPatternItem: TMenuItem;
    Usesegmentertracking1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BackGndTimerTimer(Sender: TObject);
    procedure CalibrateItemClick(Sender: TObject);
    procedure QuitProgramItemClick(Sender: TObject);
    procedure SetupTrackingItemClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CameraSettingsItemClick(Sender: TObject);
    procedure TakeBackGndIn10sItemClick(Sender: TObject);
    procedure SetupDisplayItemClick(Sender: TObject);
    procedure ShowCpuUsageItemClick(Sender: TObject);
    procedure CameraTimerTimer(Sender: TObject);
    procedure CellTestItemClick(Sender: TObject);
    procedure RandomBlobItemClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure GLPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ViewTrackingItemClick(Sender: TObject);
    procedure SettingsItemClick(Sender: TObject);
    procedure GLPanelPaint(Sender: TObject);
    procedure ShowSuperCellsItemClick(Sender: TObject);
    procedure StopWatchItemClick(Sender: TObject);
    procedure TrackTestItemClick(Sender: TObject);
    procedure BlowUpTestItemClick(Sender: TObject);
    procedure TestCellsItemClick(Sender: TObject);
    procedure ShowTestPatternItemClick(Sender: TObject);

  private
    StartTime           : DWord;
    WindowsShuttingDown : Boolean;
    Bmp                 : TBitmap;
    WBDone              : Boolean;

    procedure WMQueryEndSession(var Msg:TWMQueryEndSession); message(WM_QueryEndSession);
    procedure UpdateCountDown;

    procedure UpdateLoop;
    procedure GLSceneRender(Sender:TObject);

  public
    procedure Pause;
    procedure Resume;

    procedure NewCameraFrame(Sender:TObject);
    procedure FlashScreen;
    procedure TakeReference;
    procedure InitAfterResolutionChange;
    procedure InitMenusForTrackMethod;
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

uses
  CameraU, TrackerU, TilerU, CfgFile, BmpUtils, DisplaySetupFrmU, Routines,
  FileUtils, Cpu, TrackingSetupFrmU, CalWarningFrmU, MemoFrmU, BlobFind, DDrawU,
  BackGndFind, CellTestFrmU, NVidia, GLSceneU, OpenGL, TrackViewFrmU,Global,
  SettingsFrmU, TrackTestFrmU, BlowUpTestFrmU, CameraSettingsFrmU,
  TrackingSettingsFrmU, SegmenterU, CellTrackerU, SegmenterSetupFrmU, PopUpFrmU,
  DebugMenuFrmU, SecretMenuFrmU;

procedure TMainFrm.WMQueryEndSession(var Msg:TWMQueryEndSession);
begin
  WindowsShuttingDown:=True;
  SaveCfgFile;
  Camera.ShutDown;
  Msg.Result:=1;
end;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  NativeW:=2560;//Screen.Width;
  NativeH:=1600;//Screen.Height;
  GLPanel.Cursor:=crNone;
  WBDone:=False;

  Color:=clBlack;
  StopWatch:=TStopWatch.Create;
  if not Debugging then begin
    Randomize;
    InitNVidiaDisplays;
  end;
  WindowsShuttingDown:=False;

// camera
  Camera:=TCamera.Create;

// background finder
  BackGndFinder:=TBackGndFinder.Create;

// blob finder
  BlobFinder:=TBlobFinder.Create;

// tracker
  Tracker:=TTracker.Create;

// segmenter
  Segmenter:=TSegmenter.Create;
  CellTracker:=TCellTracker.Create;

// tiler
  Tiler:=TTiler.Create;

// load the settings
  LoadCfgFile;

  Camera.UseFirstDevice;

// go full screen
  ApplyResolution;
  ControlStyle:=ControlStyle + [csOpaque];
  if Debugging then begin
    ClientWidth:=1024;
    ClientHeight:=768;
  end
  else begin
    HideTaskBar;
    Cursor:=crNone;
    BorderStyle:=bsNone;
    Color:=clBlack;
    Left:=0; Top:=0;
    ClientWidth:=Screen.Width;
    ClientHeight:=Screen.Height;
    CaptureMouse(Self);
    CenterCursor(Self);
  end;
  Tiler.Width:=ClientWidth;
  Tiler.Height:=ClientHeight;

// bmp
  Bmp:=TBitmap.Create;
  Bmp.PixelFormat:=pf24Bit;
  Bmp.Width:=ClientWidth;
  Bmp.Height:=ClientHeight;

// GLScene
  GLScene:=TGLScene.Create(GLPanel);
  try
    GLScene.BackColor:=clBlack;
    GLScene.MouseMode:=mmNone;
    GLScene.DrawStage:=False;
    GLScene.DrawGrid:=False;
    GLScene.GridSize:=1.0;
    GLScene.CameraFOV:=45;
    GLScene.OnRender:=GLSceneRender;
    GLScene.EnableTextures;
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);
  except
    ShowMessage('Error creating GLScene.');
    Halt;
  end;

  ShowSuperCellsItem.Checked:=Tiler.ShowSuperCells;

  RunMode:=rmNone;
  StartTime:=GetTickCount;

// prepare for tracking
  Camera.Start;  // must start camera before setting any avt controls
  Camera.InitForTracking;

  BlobFinder.InitForTracking;
  Tracker.InitForTracking;

  Segmenter.InitForTracking;
  CellTracker.InitForTracking;
  
  Tiler.InitForTracking;

// start things off
  Camera.OnNewFrame:=NewCameraFrame;
  CameraTimer.Enabled:=True;
end;

procedure TMainFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RestoreResolution;
  if not WindowsShuttingDown then begin
    SaveCfgFile;
    if Assigned(Camera) then Camera.ShutDown;
  end;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
  if Assigned(GLScene) then GLScene.Free;
  if Assigned(StopWatch) then StopWatch.Free;

  if Assigned(BackGndFinder) then BackGndFinder.Free;
  if Assigned(BlobFinder) then BlobFinder.Free;
  if Assigned(Tracker) then Tracker.Free;

  if Assigned(Segmenter) then Segmenter.Free;
  if Assigned(CellTracker) then CellTracker.Free;

  if Assigned(Tiler) then Tiler.Free;

  ShowTaskBar;
  ReleaseMouse;
  Cursor:=crDefault;
end;

procedure TMainFrm.UpdateLoop;
begin
  Case RunMode of
    rmNone :
      if (GetTickCount-StartTime)>1000 then begin
        RunMode:=rmStarting;
        StartTime:=GetTickCount;
        Camera.SetAvtDriverSettings(Camera.AvtDriverSettings);
      end;

    rmStarting :
      begin
        if (not WBDone) and ((GetTickCount-StartTime)>5000) then begin
          Camera.SetAvtDriverSettings(Camera.AvtDriverSettings);
          WBDone:=True;
        end;
        UpdateCountDown;
      end;

    rmRunning,rmCalibrating :
      begin
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
        GLScene.Render;
        if TrackViewFrmCreated then TrackViewFrm.Redraw;
        if CameraSettingsFrmCreated then CameraSettingsFrm.UpdateTracking;
        if TrackingSettingsFrmCreated then TrackingSettingsFrm.UpdateTracking;
      end;
  end;
end;

procedure TMainFrm.NewCameraFrame(Sender:TObject);
begin
  CameraTimer.Enabled:=False;
  UpdateLoop;
end;

procedure TMainFrm.BackGndTimerTimer(Sender: TObject);
begin
  BackGndTimer.Enabled:=False;
  Case TrackMethod of
    tmBlobs     : BackGndFinder.SetBackGndBmp(Camera.Bmp);
    tmSegmenter : Segmenter.ForceAllToBackGnd(Camera.SmallBmp);
  end;
  FlashScreen;
end;

procedure TMainFrm.UpdateCountDown;
var
  TimeElapsed : DWord;
  TimeLeft    : Integer;
  X,Y         : Integer;
  Line1,Line2 : String;
  Line3       : String;
begin
  TimeElapsed:=(GetTickCount-StartTime);
  TimeLeft:=Integer(CountDownTime)-Integer(TimeElapsed);
  if Debugging then TimeLeft:=-1;
  if TimeLeft<0 then begin
    RunMode:=rmRunning;
    BackGndFinder.SetBackGndBmp(Camera.Bmp);
    Segmenter.ForceAllToBackGnd(Camera.SmallBmp);
    FlashScreen;
    for X:=1 to 8 do StopWatch.Reset(X);
  end
  else with Bmp.Canvas do begin
    StretchDraw(ClientRect,Camera.Bmp);
    Brush.Color:=clBlack;
    Brush.Style:=bsSolid;
    Font.Name:='Arial';
    Font.Size:=36;
    Font.Color:=clWhite;
    Line1:='Please stand out of sight of the camera for';
    Line2:='a few seconds so an image can be taken.';
    Line3:='Calibration begins in '+IntToStr(TimeLeft div 1000)+' seconds';
    X:=(Bmp.Width-TextWidth(Line1)) div 2;
    while (X<0) and (Font.Size>7) do begin
      Font.Size:=Font.Size-1;
      X:=(Bmp.Width-TextWidth(Line1)) div 2;
    end;
    Y:=(Bmp.Height div 2)-TextHeight(Line2)-TextHeight(Line1);
    TextOut(X,Y,Line1);
    X:=(Bmp.Width-TextWidth(Line2)) div 2;
    Y:=(Bmp.Height div 2)-TextHeight(Line2);
    TextOut(X,Y,Line2);
    X:=(Bmp.Width-TextWidth(Line3)) div 2;
    Y:=(Bmp.Height div 2)+TextHeight(Line3);
    TextOut(X,Y,Line3);
    GLPanel.Canvas.Draw(0,0,Bmp);
  end;
end;

procedure TMainFrm.FlashScreen;
begin
  GLScene.FlashScreen;
  Sleep(200);
end;

procedure TMainFrm.CalibrateItemClick(Sender: TObject);
begin
  BackGndTimer.Interval:=3000;
  BackGndTimer.Enabled:=True;
end;

procedure TMainFrm.QuitProgramItemClick(Sender: TObject);
begin
  Close;
end;

procedure TMainFrm.SetupTrackingItemClick(Sender: TObject);
begin
  Case TrackMethod of
    tmBlobs :
      begin
        TrackingSetupFrm:=TTrackingSetupFrm.Create(Application);
        try
          TrackingSetupFrm.Initialize;
          TrackingSetupFrm.ShowModal;
        finally
          TrackingSetupFrm.Free;
        end;
      end;
    tmSegmenter :
      begin
        SegmenterSetupFrm:=TSegmenterSetupFrm.Create(Application);
        try
          SegmenterSetupFrm.Initialize;
          SegmenterSetupFrm.ShowModal;
        finally
          SegmenterSetupFrm.Free;
        end;
      end;
  end;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TMainFrm.TakeReference;
begin
  CalWarningFrm:=TCalWarningFrm.Create(Application);
  CalWarningFrm.Initialize;
  CalWarningFrm.Show;
end;

procedure TMainFrm.FormMouseDown(Sender: TObject; Button: TMouseButton;
                                 Shift: TShiftState; X, Y: Integer);
var
  Pt : TPoint;
begin
    if RunMode in [rmRunning,rmCalibrating] then begin
    Pt.X:=X; Pt.Y:=Y;
    Pt:=ClientToScreen(Pt);

    if Button=mbRight then begin

// secret debug menu
      if ssCtrl in Shift then begin
        if ssShift in Shift then SecretMenuFrm.ShowAt(Pt.X,Pt.Y)
        else DebugMenuFrm.ShowAt(Pt.X,Pt.Y)
      end
      else begin
        PopupFrm.ShowAt(Pt.X,Pt.Y);
      end;
//        PopupMenu.PopUp(Pt.X,Pt.Y);
    end
    else if Button=mbMiddle then DebugMenuFrm.ShowAt(Pt.X,Pt.Y);
  end;
end;

procedure TMainFrm.CameraSettingsItemClick(Sender: TObject);
begin
 Camera.ShowCameraSettingsFrm;
end;

procedure TMainFrm.TakeBackGndIn10sItemClick(Sender: TObject);
begin
  BackGndTimer.Interval:=10000;
  BackGndTimer.Enabled:=True;
end;

procedure TMainFrm.SetupDisplayItemClick(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
  CameraTimer.Enabled:=False;
  DisplaySetupFrm:=TDisplaySetupFrm.Create(Application);
  try
    DisplaySetupFrm.Initialize;
    DisplaySetupFrm.ShowModal;
  finally
    DisplaySetupFrm.Free;
  end;
  Resume;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TMainFrm.ShowCpuUsageItemClick(Sender: TObject);
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    ShowCpuUsage(MemoFrm.Memo.Lines);
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

procedure TMainFrm.Pause;
begin
  Camera.Stop;
  CameraTimer.Enabled:=False;
end;

procedure TMainFrm.Resume;
begin
  Camera.Start;
  CameraTimer.Enabled:=True;
end;

procedure TMainFrm.CameraTimerTimer(Sender: TObject);
begin
  Inc(Camera.FrameCount);
  UpdateLoop;
end;

procedure TMainFrm.CellTestItemClick(Sender: TObject);
begin
  CameraTimer.Enabled:=False;
  CellTestFrm:=TCellTestFrm.Create(Application);
  try
    CellTestFrm.Initialize;
    CellTestFrm.ShowModal;
  finally
    CellTestFrm.Free;
  end;
  Resume;
end;

procedure TMainFrm.RandomBlobItemClick(Sender: TObject);
var
  Blob : TBlob;
begin
  Blob.Width:=100+Random(400);
  Blob.Height:=80+Random(300);
  Blob.XMin:=Random(TrackW-Blob.Width);
  Blob.XMax:=Blob.XMin+Blob.Width-1;
  Blob.YMin:=Random(TrackH-Blob.Height);
  Blob.YMax:=Blob.YMin+Blob.Height-1;

  Tiler.ZoomToBlob(Blob);
end;

procedure TMainFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#32 then begin
    Case Tiler.Mode of
      tmIdle :RandomBlobItemClick(nil);
      else Tiler.ZoomOut;
    end;
  end;
end;

procedure TMainFrm.GLSceneRender;
begin
  Tiler.Render;
end;

procedure TMainFrm.GLPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  X:=ClientWidth div 2;
  Y:=ClientHeight div 2;
  SetCursorPos(X,Y);
  FormMouseDown(Sender,Button,Shift,X,Y);
end;

procedure TMainFrm.InitAfterResolutionChange;
begin
  ClientWidth:=Screen.Width;
  ClientHeight:=Screen.Height;
  Tiler.Width:=ClientWidth;
  Tiler.Height:=ClientHeight;
  Bmp.Width:=ClientWidth;
  Bmp.Height:=ClientHeight;
  GLPanel.Width:=ClientWidth;
  GLPanel.Height:=ClientHeight;
  GLScene.Resize;
  Tiler.PlaceCells;
end;

procedure TMainFrm.ViewTrackingItemClick(Sender: TObject);
begin
  ShowTrackViewFrm;
end;

procedure TMainFrm.SettingsItemClick(Sender: TObject);
begin
  SettingsFrm:=TSettingsFrm.Create(Application);
  try
    SettingsFrm.Initialize;
    SettingsFrm.ShowModal;
  finally
    SettingsFrm.Free;
  end;
end;

procedure TMainFrm.GLPanelPaint(Sender: TObject);
begin
  if RunMode in [rmRunning,rmCalibrating] then GLScene.Render;
end;

procedure TMainFrm.ShowSuperCellsItemClick(Sender: TObject);
begin
  ShowSuperCellsItem.Checked:=not ShowSuperCellsItem.Checked;
  Tiler.ShowSuperCells:=ShowSuperCellsItem.Checked;
end;

procedure TMainFrm.StopWatchItemClick(Sender: TObject);
var
  C : Integer;
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    MemoFrm.Memo.Lines.Add('Total loop: '+StopWatch.ChannelStr(1));
    MemoFrm.Memo.Lines.Add('Bmps from camera: '+StopWatch.ChannelStr(2));
    MemoFrm.Memo.Lines.Add('BackGnd: '+StopWatch.ChannelStr(3));
    MemoFrm.Memo.Lines.Add('Tracking: '+StopWatch.ChannelStr(4));
    MemoFrm.Memo.Lines.Add('Tiler: '+StopWatch.ChannelStr(5));
    MemoFrm.Memo.Lines.Add('Rendering: '+StopWatch.ChannelStr(6));

    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
  for C:=1 to 8 do StopWatch.Reset(8);
end;

procedure TMainFrm.TrackTestItemClick(Sender: TObject);
begin
  TrackTestFrm:=TTrackTestFrm.Create(Application);
  try
    TrackTestFrm.Initialize;
    TrackTestFrm.ShowModal;
  finally
    TrackTestFrm.Free;
  end;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TMainFrm.BlowUpTestItemClick(Sender: TObject);
begin
  BlowUpTestFrm:=TBlowUpTestFrm.Create(Application);
  try
    BlowUpTestFrm.Initialize;
    BlowUpTestFrm.ShowModal;
  finally
    BlowUpTestFrm.Free;
  end;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TMainFrm.TestCellsItemClick(Sender: TObject);
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    Tiler.TestCells(MemoFrm.Memo.Lines);
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

procedure TMainFrm.ShowTestPatternItemClick(Sender: TObject);
begin
  ShowTestPatternItem.Checked:=not ShowTestPatternItem.Checked;
  Tiler.ShowTestPattern:=ShowTestPatternItem.Checked;
end;

procedure TMainFrm.InitMenusForTrackMethod;
begin
  TrackTestItem.Visible:=(TrackMethod=tmBlobs);
end;

end.



