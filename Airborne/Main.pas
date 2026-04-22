unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, CPanel, OpenGL1x, OpenGLTokens, ProgramU, AprChkBx,
  StdCtrls, ComCtrls, Buttons, ColorBtn, AprSpin, UnitLCD, Menus, TextureU;

type
  TMainFrm = class(TForm)
    GLPanel: TCanvasPanel;
    Timer: TTimer;
    PopupMenu: TPopupMenu;
    SetupItem: TMenuItem;
    ExitItem: TMenuItem;
    DelayTimer: TTimer;
    CameraTimer: TTimer;
    SaveItem: TMenuItem;
    N1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SetupItemClick(Sender: TObject);
    procedure ExitItemClick(Sender: TObject);
    procedure GLPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DelayTimerTimer(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure CameraTimerTimer(Sender: TObject);
    procedure GLPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SaveItemClick(Sender: TObject);
    procedure GLPanelResize(Sender: TObject);

  private
    procedure GLSceneRender(Sender:TObject);
    procedure SetSize;
    procedure TestDraw;

  public
    procedure ThreadStart(Sender:TObject);
    procedure ThreadStop(Sender:TObject);
    procedure NewCameraFrame(Sender:TObject);
    procedure InitGL;
  end;

var
  MainFrm   : TMainFrm;
  SrcBlend  : Integer = $302;
  DestBlend : Integer = 1;

  BackTexture  : TTexture;
  FrontTexture : TTexture;

implementation

{$R *.dfm}

uses
  Routines, GLSceneU, GLDraw, CloudU, BlobFindU, CfgFile, CameraU, SetupFrmU,
  Global, BmpUtils, MenuFrmU, StopWatchU, ThreadU, BackGndFind, ProjectorU,
  ProjectorMaskU, TrackViewFrmU, FountainU, AlphabetU, ShadTrkr;

procedure TMainFrm.SetSize;
begin
  PlaceFormInWindow(Self,Projector.Window);

  if not Debug then begin
    BorderStyle:=bsNone;
    HideTaskBar;
    GLPanel.Cursor:=crNone;
    Screen.Cursor:=crNone;
  end;

//  GLPanel.Width:=ClientWidth;
//  GLPanel.Height:=ClientHeight;

  ViewPortWidth:=ClientWidth;
  ViewPortHeight:=ClientHeight;

  Cloud.GridWidth:=Camera.ImageW;
  Cloud.GridHeight:=Camera.ImageH;
end;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  StopWatch:=TStopWatch.Create;

  Cloud:=TCloud.Create;

  Camera:=TCamera.Create(Handle);
  Tracker:=TShadowTracker.Create;

  BlobFinder:=TBlobFinder.Create;
  BackGndFinder:=TBackGndFinder.Create;

  Projector:=TProjector.Create;
  ProjectorMask:=TProjectorMask.Create;

  Fountain:=TFountain.Create;
  Alphabet:=TAlphabet.Create;

  LoadCfgFile;
  Tracker.Info:=DefaultShadowTrackerInfo;
  SetSize;
  BlobFinder.InitForTracking;

  Thread:=TCallBackThread.Create;
  DelayTimer.Enabled:=True;
end;

procedure TMainFrm.InitGL;
begin
{  GLPanel:=TCanvasPanel.Create(Self);
  GLPanel.ParentWindow:=Self.Handle;
  GLPanel.Left:=0;
  GLPanel.Top:=0;
  GLPanel.Width:=ClientWidth;
  GLPanel.Height:=ClientHeight;}

  GLScene:=TGLScene.Create(GLPanel);
  GLScene.OnRender:=GLSceneRender;

  Cloud.LoadPrograms;
  Cloud.Initialize(GLPanel.Width,GLPanel.Height);
  Cloud.ProgramsLoaded:=True;

  Camera.MouseX:=-1;

  Fountain.PrepareForShow;
end;

procedure TMainFrm.DelayTimerTimer(Sender: TObject);
begin
  DelayTimer.Enabled:=False;
  Camera.UseFirstDevice;

// show the camera name
  MenuFrm.StatusBar.SimpleText:=Camera.CameraName;

  Camera.Start;
  Camera.AssertSettings;

  if not Camera.Found then begin
    Camera.Bmp.Width:=Camera.Window.W;
    Camera.Bmp.Height:=Camera.Window.H;
    CameraTimer.Enabled:=True;
  end;

//  TrackViewFrm.Show;
  Camera.OnNewFrame:=NewCameraFrame;

  InitGL;
  Timer.Enabled:=True;

//  Thread.Start(0.033);
end;

procedure TMainFrm.ThreadStart(Sender:TObject);
begin
  GLScene:=TGLScene.Create(GLPanel);
  try
    GLScene.OnRender:=GLSceneRender;
    GLScene.BackColor:=$808080;
  except
    ShowMessage('Error creating GLScene.');
    Halt;
  end;
  Cloud.LoadPrograms;
  Cloud.Initialize(GLPanel.Width,GLPanel.Height);
  Cloud.ProgramsLoaded:=True;
end;

procedure TMainFrm.ThreadStop(Sender:TObject);
begin
  if Assigned(GLScene) then GLScene.Free;
end;

procedure TMainFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Thread.Stop;
//  if Assigned(Camera) then Camera.ShutDown;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Camera) then Camera.Free;
  if Assigned(BlobFinder) then BlobFinder.Free;
  if Assigned(Tracker) then Tracker.Free;

  if Assigned(BackGndFinder) then BackGndFinder.Free;
  if Assigned(Projector) then Projector.Free;
  if Assigned(ProjectorMask) then ProjectorMask.Free;

  if Assigned(Thread) then Thread.Free;

  if Assigned(GLScene) then GLScene.Free;
  if Assigned(Cloud) then Cloud.Free;

  if Assigned(Fountain) then Fountain.Free;
  if Assigned(Alphabet) then Alphabet.Free;

  if Assigned(StopWatch) then StopWatch.Free;

  if not Debug then begin
    ShowTaskBar;
//    SetScreenResolution(2560,1600);
  end;
end;

procedure TMainFrm.TestDraw;
begin
  glColor3F(0,0,0);
  glBegin(GL_LINES);
    glVertex2I(0,0);
    glVertex2I(ViewPortWidth,ViewPortHeight);
  glEnd;
end;

procedure TMainFrm.GLSceneRender(Sender:TObject);
begin
  Cloud.Update;

// draw the smoke
  Cloud.Render;
  glBindTexture(GL_TEXTURE_2D,0);

  glPushMatrix;
    Fountain.Update;
    Fountain.Render;

// clean up
    glDisable(GL_BLEND);
    glBindTexture(GL_TEXTURE_2D,0);
  glPopMatrix;

glEnable(GL_TEXTURE_2D);
//Cloud.DrawObstacles;

end;

procedure TMainFrm.SetupItemClick(Sender: TObject);
begin
  Cursor:=crDefault;
//  ShowCursor;
  SetupFrm:=TSetupFrm.Create(Application);
  try
    SetupFrm.Initialize;
    SetupFrm.ShowModal;
  finally
    SetupFrm.Free;
  end;
end;

procedure TMainFrm.ExitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TMainFrm.GLPanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  MousePt : TPoint;
begin
  MenuFrm.Show;
  MousePt.X:=X;
  MousePt.Y:=Y;
  MousePt:=ClientToScreen(MousePt);
  MenuFrm.Left:=MousePt.X-(MenuFrm.Width div 2);
  MenuFrm.Top:=MousePt.Y-(MenuFrm.Height div 2);
  GLPanel.Cursor:=crDefault;
  Screen.Cursor:=crDefault;
end;

procedure TMainFrm.TimerTimer(Sender: TObject);
begin
  GLScene.Render2;
end;

procedure TMainFrm.NewCameraFrame(Sender:TObject);
begin
  if FakeCamera then Camera.FakeBmp;
  BackGndFinder.Update(Camera.Bmp);
  BlobFinder.Update(BackGndFinder.SubtractedBmp);
//  TrackViewFrm.Update;
end;

procedure TMainFrm.CameraTimerTimer(Sender: TObject);
begin
//  Camera.FakeBmp;
  Camera.OnNewFrame(nil);
end;

procedure TMainFrm.GLPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Camera.MouseX:=X;
  Camera.MouseY:=Y;
end;

procedure TMainFrm.SaveItemClick(Sender: TObject);
begin
  Cloud.Save:=True;
end;

procedure TMainFrm.GLPanelResize(Sender: TObject);
begin
{  if Active and Assigned(GLScene) then begin
    GLScene.Resize;
  end;}
end;

end.




