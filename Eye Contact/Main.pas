unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Z_prof, ComCtrls;

type
  TMainFrm = class(TForm)
    RunBtn: TBitBtn;
    PaintBox: TPaintBox;
    CameraSetupBtn: TBitBtn;
    AutoStartTimer: TTimer;
    AdvancedBtn: TBitBtn;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PaintBoxPaint(Sender: TObject);
    procedure CameraSetupBtnClick(Sender: TObject);
    procedure RunBtnClick(Sender: TObject);
    procedure DisplaySetupBtnClick(Sender: TObject);
    procedure AutoStartTimerTimer(Sender: TObject);
    procedure AdvancedBtnClick(Sender: TObject);

  private
    Bmp : TBitmap;
    WindowsShuttingDown : Boolean;

    procedure NewCameraFrame(Sender:TObject);
    procedure DrawBmp;
    procedure WMEndSession(var Msg:TWMEndSession); message(WM_EndSession);
    procedure InitStatusBar;

  public

  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

uses
  CameraU, TrackerU, TilerU, BmpView, CfgFile, TrackingCfg, RunFrmU, BmpLoadU,
  BmpUtils, DisplayCfg, Routines, ScrubTst, VidFile, PixelBackGndFind,
  CellBackGndFind, AdvancedFrmU;

procedure TMainFrm.WMEndSession(var Msg:TWMEndSession);
begin
  if Msg.EndSession then begin
    WindowsShuttingDown:=True;
    Camera.ShutDown;
  end;
end;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  Randomize;
  WindowsShuttingDown:=False;

// bmp for this form
  Bmp:=TBitmap.Create;
  Bmp.Width:=PaintBox.Width;
  Bmp.Height:=PaintBox.Height;
  Bmp.PixelFormat:=pf24Bit;

// camera
  Camera:=TCamera.Create;

// background finders
  PixelBackGndFinder:=TPixelBackGndFinder.Create;
  CellBackGndFinder:=TCellBackGndFinder.Create;

// tracker
  Tracker:=TTracker.Create;

// tiler
  Tiler:=TTiler.Create;

// load the settings
  LoadCfgFile;

  Camera.UseFirstDevice;
  Camera.OnNewFrame:=NewCameraFrame;

// start things off
  InitStatusBar;
  DrawBmp;
  Camera.Start;
  AutoStartTimer.Enabled:=True;
end;

procedure TMainFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(Camera) and not(WindowsShuttingDown) then Camera.ShutDown;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
  if Assigned(PixelBackGndFinder) then PixelBackGndFinder.Free;
  if Assigned(CellBackGndFinder) then CellBackGndFinder.Free;
  if Assigned(Tracker) then Tracker.Free;
  if Assigned(Tiler) then Tiler.Free;
  ShowTaskBar;
end;

procedure TMainFrm.DrawBmp;
begin
  Bmp.Canvas.StretchDraw(PaintBox.ClientRect,Camera.SmallBmp);
  ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
end;

procedure TMainFrm.NewCameraFrame(Sender:TObject);
begin
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TMainFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TMainFrm.CameraSetupBtnClick(Sender: TObject);
begin
  AutoStartTimer.Enabled:=False;
  Camera.ShowCameraSettingsFrm(True);
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TMainFrm.RunBtnClick(Sender: TObject);
begin
  AutoStartTimer.Enabled:=False;
  if Tiler.BmpsLoadedOk then begin
    RunFrm:=TRunFrm.Create(Application);
    try
      RunFrm.Initialize;
      RunFrm.ShowModal;
    finally
      RunFrm.Free;
      Camera.OnNewFrame:=NewCameraFrame;
    end;
  end;
end;

procedure TMainFrm.DisplaySetupBtnClick(Sender: TObject);
begin
  AutoStartTimer.Enabled:=False;
  DisplaySetupFrm:=TDisplaySetupFrm.Create(Application);
  try
    DisplaySetupFrm.Initialize;
    DisplaySetupFrm.ShowModal;
  finally
    DisplaySetupFrm.Free;
  end;
end;

procedure TMainFrm.AutoStartTimerTimer(Sender: TObject);
begin
  AutoStartTimer.Enabled:=False;
  RunBtnClick(nil);
end;

procedure TMainFrm.AdvancedBtnClick(Sender: TObject);
begin
 AutoStartTimer.Enabled:=False;
  AdvancedSetupFrm:=TAdvancedSetupFrm.Create(Application);
  try
    AdvancedSetupFrm.Initialize;
    AdvancedSetupFrm.ShowModal;
  finally
    AdvancedSetupFrm.Free;
  end;

// re-init
  InitStatusBar;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TMainFrm.InitStatusBar;
begin
  if Camera.Found then begin
    StatusBar.Panels[0].Text:=Camera.CameraName+' - '+Camera.DriverName;
  end
  else StatusBar.Panels[0].Text:='Camera not found';
  if Tiler.Videos=1 then StatusBar.Panels[1].Text:='1 video loaded'
  else StatusBar.Panels[1].Text:=IntToStr(Tiler.Videos)+' videos loaded';
end;

end.
