unit GLSceneU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, OpenGL, CPanel, Global, MatrixU, GLDraw;

const
  SelectBufferLength = 1024;

type
  TStencilMask = record
    Enabled : Boolean;
    X1,X2   : Integer;
    DrawX1  : Integer;
    DrawX2  : Integer;
  end;

  TMouseMode = (mmNone,mmMove,mmZoom,mmExamine);

  TViewPortArray = array[0..3] of glInt;
  TMatrixDblArray = array[0..15] of glDouble;

  TCamInfo = record
    X,Y,Z : Single;
    Rx,Rz : Single;
  end;

  TGLScene = class(TObject)
  private

// property vars
    FDrawGrid    : Boolean;
    FGridSize    : Single;
    FDrawStage   : Boolean;
    FStageColor  : TGLColor;
    FStageSize   : Single;
    FBackColor   : TGLColor;
    FGridColor   : TGLColor;
    FOriginColor : TGLColor;
    FOnRender    : TNotifyEvent;

// the panel the scene is rendered on
    OwnerPanel : TCanvasPanel;

// misc private vars
    StartXPixel   : Integer;
    StartYPixel   : Integer;
    StartX        : Single;
    StartY        : Single;
    StartCam      : TCamInfo;
    ViewWidth     : Single;
    ViewHeight    : Single;
    ZoomVector    : TPoint3D;
    MouseViewport : TViewPortArray;

// grid routines
    procedure SetDrawGrid(NewSetting:Boolean);
    procedure SetGridSize(NewSize:Single);
    procedure SetGridColor(NewColor:TColor);
    function  GetGridColor:TColor;
    procedure SetOriginColor(NewColor:TColor);
    function  GetOriginColor:TColor;

// stage routines
    procedure SetStageColor(NewColor:TColor);
    function  GetStageColor:TColor;
    procedure SetStageSize(NewSize:Single);
    procedure SetDrawStage(NewSetting:Boolean);
    procedure DrawTheStage;

// background color routines
    procedure SetBackColor(NewColor:TColor);
    function  GetBackColor:TColor;

// OpenGL routines
    procedure ShutDownOpenGL;

// misc private routines
    procedure StartZoom(X,Y:Single);
    procedure PlaceCamera;
    procedure CopyMatrixDblArrayIntoMatrix(DblArray:TMatrixDblArray;
                                           iMatrix:TMatrix);
    procedure GetMatricesAndViewPort;

  public
    SelectBuffer : array[1..SelectBufferLength] of glUInt;
    Hits         : glInt;
    Width,Height : Integer; // in pixels
    FirstHitName : Integer;

// needed for 2D draw
    MVMatrix   : TMatrix;
    ProjMatrix : TMatrix;
    VPort      : TViewPortArray;

    MouseDown : Boolean;
    MouseMode : TMouseMode;

// handles and DC's
    HRC : HGLRC;
    DC  : HDC;

// camera vars
    SceneRx     : Single;
    SceneRz     : Single;
    CamLocation : TPose;
    CameraFOV   : Single;
    Matrix      : TMatrix;
    IntMatrix   : TMatrix;
    ExtMatrix   : TMatrix;
    ZoomMatrix  : TMatrix;

    property DrawGrid:Boolean read FDrawGrid write SetDrawGrid default True;
    property BackColor:TColor read GetBackColor write SetBackColor default clBlack;
    property GridColor:TColor read GetGridColor write SetGridColor default clSilver;
    property OriginColor:TColor read GetOriginColor write SetOriginColor default clWhite;
    property StageColor:TColor read GetStageColor write SetStageColor default clBlue;
    property DrawStage:Boolean read FDrawStage write SetDrawStage default True;
    property StageSize:Single read FStageSize write SetStageSize;
    property GridSize:Single read FGridSize write SetGridSize;
    property OnRender:TNotifyEvent read FOnRender write FOnRender;

// constructor/destructor
    constructor Create(iOwnerPanel:TCanvasPanel);
    destructor  Destroy; override;

// public routines
    procedure Render;
    procedure ConvertMouseXYToSceneXY(var X,Y:Single);
    procedure FindMouseSelection(X,Y:Integer);
    procedure SwitchTo2D;
    procedure InitOpenGL;

// called by the owner form
    procedure Resize;
    procedure MouseBtnDown(X,Y:Integer);
    procedure MouseBtnUp;
    procedure MouseMove(X,Y:Integer);
    procedure ShowLastError;
    procedure ClearErrors;
    procedure InitLighting;
    procedure DrawLine(Pt1,Pt2:TPoint3D);
    procedure DrawStageGrid;

    procedure EnableAlpha;
    procedure DisableAlpha;

    procedure EnableTextures;
    procedure DisableTextures;
    procedure ClearTextureMemory;
    procedure EnableStencilDraw;
    procedure DisableStencilDraw;
    procedure DrawMask(Mask:TStencilMask);
    procedure PrepareToStoreTextures;
    procedure FinishStoringTextures;
    procedure FlashScreen;
  end;

var
  GLScene : TGLScene;

implementation

uses
  Math, Routines, Math3D;

const
  DistNear = 0.05;
  DistFar  = 300;

constructor TGLScene.Create(iOwnerPanel:TCanvasPanel);
begin
  inherited Create;
  OwnerPanel:=iOwnerPanel;

// create the matrices
  Matrix:=TMatrix.Create(3,4);     // projection matrix
  IntMatrix:=TMatrix.Create(4,4);  // internal matrix - camera parameters
  ExtMatrix:=TMatrix.Create(4,4);  // eternal matrix - camera location
  ZoomMatrix:=TMatrix.Create(4,4); // for zooming
  MVMatrix:=TMatrix.Create(4,4);
  ProjMatrix:=TMatrix.Create(4,4);

// camera vars
  with CamLocation do begin
    X:=0; Y:=0; Z:=10;
    Rx:=0; Ry:=0; Rz:=0;
  end;
  CameraFOV:=90;
  SceneRx:=0; SceneRz:=0;

  Resize;
  FDrawGrid:=True;
  FDrawStage:=True;
  FBackColor:=ColorToGLColor(clBlack);
  FGridColor:=ColorToGLColor($808080);
  FOriginColor:=ColorToGLColor($A0A0A0);
  FStageColor:=ColorToGLColor($803050);
  FStageSize:=5;
  FGridSize:=10;
  FOnRender:=nil;
  MouseDown:=False;
  HRC:=0; DC:=0;
  MouseMode:=mmNone;
  FirstHitName:=0;
  InitOpenGL;
end;

destructor TGLScene.Destroy;
begin
  ShutDownOpenGL;

// free the matrices
  if Assigned(Matrix) then Matrix.Free;
  if Assigned(IntMatrix) then IntMatrix.Free;
  if Assigned(ExtMatrix) then ExtMatrix.Free;
  if Assigned(ZoomMatrix) then ZoomMatrix.Free;
  if Assigned(MVMatrix) then MVMatrix.Free;
  if Assigned(ProjMatrix) then ProjMatrix.Free;
  inherited;
end;

procedure TGLScene.Resize;
var
  Angle : Single;
begin
  Width:=OwnerPanel.Width;
  Height:=OwnerPanel.Height;
  Angle:=DegToRad(CameraFOV)/2;
  ViewHeight:=2*DistNear*Tan(Angle);
  ViewWidth:=ViewHeight*Width/Height;
end;

procedure TGLScene.ConvertMouseXYToSceneXY(var X,Y:Single);
var
  Xc,Yc,Zc,Rx,Rz : Single;
  XCtr,YCtr      : Single;
begin
// convert X and Y so that they're relative to the StageCam viewport center
  XCtr:=Width/2;
  YCtr:=Height/2;
  X:=X-XCtr;
  Y:=(Height-Y)-YCtr;

// convert X and Y to "GL-Units"
  X:=(X*ViewWidth)/Width;
  Y:=(Y*ViewHeight)/Height;

  Rx:=DegToRad(SceneRx); Rz:=DegToRad(SceneRz);
  Xc:=-CamLocation.X; Yc:=-CamLocation.Y; Zc:=CamLocation.Z;

// find X,Y assuming no scene rotations
  X:=Zc*X/DistNear;
  Y:=Zc*Y/DistNear;

// do an "inverse" [Rx]*[Translation]*[Perspective] operation
  Y:=Zc*(Y-Yc)/(Zc*Cos(Rx)+Y*Sin(Rx));
  X:=X-Xc-(X*Y*Sin(Rx))/Zc;

// make up for the scene Rz
  RotateXYPoint(X,Y,-Rz);
end;

procedure TGLScene.StartZoom(X,Y:Single);
var
  Matrix : TMatrix;
  Target : TPoint3D;
begin
  StartY:=Y;
  ConvertMouseXYToSceneXY(X,Y);

  Target.X:=X; Target.Y:=Y; Target.Z:=0;
  ZoomMatrix.InitAsRx(DegToRad(-SceneRx));
  Target:=ZoomMatrix.MultiplyPoint3D(Target);
  ZoomMatrix.InitAsRz(DegToRad(-SceneRz));
  Target:=ZoomMatrix.MultiplyPoint3D(Target);

  StartCam.X:=CamLocation.X;
  StartCam.Y:=CamLocation.Y;
  StartCam.Z:=CamLocation.Z;

  ZoomVector.X:=Target.X-StartCam.X;
  ZoomVector.Y:=Target.Y-StartCam.Y;
  ZoomVector.Z:=Target.Z-StartCam.Z;
end;

procedure TGLScene.MouseBtnDown(X,Y:Integer);
begin
  MouseDown:=True;
  StartXPixel:=X;
  StartYPixel:=Y;
  if MouseMode=mmMove then begin
    StartX:=CamLocation.X;
    StartY:=CamLocation.Y;
  end
  else if MouseMode=mmZoom then StartZoom(X,Y);
end;

procedure TGLScene.MouseBtnUp;
begin
  MouseDown:=False;
end;

procedure TGLScene.MouseMove(X,Y:Integer);
var
  T : Single;
begin
  if MouseDown then begin
    Case MouseMode of
      mmExamine :
        begin
          SceneRx:=SceneRx+180*(Y-StartYPixel)/Height;
          SceneRz:=SceneRz-180*(X-StartXPixel)/Width;
          StartXPixel:=X; StartYPixel:=Y;
        end;
      mmMove :
        begin
          CamLocation.X:=StartX+ViewWidth*25*((StartXPixel-X)/Width);
          CamLocation.Y:=StartY+ViewHeight*25*((Y-StartYPixel)/Height);
        end;
      mmZoom :
        begin
          T:=(StartY-Y)/Height;
          CamLocation.X:=StartCam.X+ZoomVector.X*T;
          CamLocation.Y:=StartCam.Y+ZoomVector.Y*T;
          CamLocation.Z:=StartCam.Z+ZoomVector.Z*T;
        end;
    end;
  end;
end;

procedure TGLScene.ClearErrors;
begin
  while glGetError>0 do;
end;

procedure TGLScene.ShowLastError;
var
  Error    : Integer;
  ErrorStr : String;
begin
  Error:=glGetError;
  if Error>0 then begin
    ErrorStr:=gluErrorString(Error);
    ShowMessage('Error #'+IntToStr(Error)+':'+ErrorStr);
  end;
end;

procedure TGLScene.InitOpenGL;
var
  FormatIndex : Integer;
  pfd         : TPixelFormatDescriptor;
begin
//ClearErrors;
  DC:=GetDC(OwnerPanel.Handle);
  FillChar(pfd,SizeOf(pfd),0);
  with pfd do begin
    nSize:=SizeOf(pfd);
    nVersion:=1;
    dwFlags:=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
    iPixelType:=PFD_TYPE_RGBA;
    cColorBits:=24;
    cDepthBits:=32;
    iLayerType:=PFD_MAIN_PLANE;
  end;

// request an index in the pfd descriptor table as close as possible to what
// we asked for
  FormatIndex:=ChoosePixelFormat(DC,@pfd);

// make sure there was a reasonable match
  if FormatIndex>0 then begin
    if SetPixelFormat(DC,FormatIndex,@pfd) then begin

// create a handle to the resource context
      HRC:=wglCreateContext(DC);

// if it succeeded activate it
      if HRC>0 then begin
        wglMakeCurrent(DC,HRC); // takes a bit more than 2ms on K6-233 16M Voodoo PCI
      end
      else ShowLastError;
    end;
  end;

// gl parameters
  glCullFace(GL_BACK);
  glEnable(GL_CULL_FACE);
  glEnable(GL_DEPTH_TEST);

// we won't need lighting
  glDisable(GL_LIGHTING);
  glDisable(GL_LINE_SMOOTH);
  glPolygonMode(GL_FRONT,GL_FILL);
//  ReleaseDC(OwnerPanel.Handle,DC);
end;

procedure TGLScene.InitLighting;
const
  AmbientLight   : array[1..4] of GLFloat = (0.5,0.5,0.5,1);
  Light0Position : array[1..4] of GLFloat = (-25,-25,25,1);
  Light1Position : array[1..4] of GLFloat = (+25,-25,25,1);
  GLWhite        : array[1..4] of GLFloat = (1,1,1,1);
begin
  glLightModelI(GL_LIGHT_MODEL_LOCAL_VIEWER,0);//GL_FALSE);
  glLightModelI(GL_LIGHT_MODEL_TWO_SIDE,0);//GL_FALSE);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @glWhite);
  glLightfv(GL_LIGHT0, GL_SPECULAR,@glWhite);
  glLightfv(GL_LIGHT1, GL_DIFFUSE, @glWhite);
  glLightfv(GL_LIGHT1, GL_SPECULAR,@glWhite);
  glLightFV(GL_LIGHT0,GL_Position,@Light0Position);
  glLightFV(GL_LIGHT0,GL_AMBIENT,@AmbientLight);
  glLightF(GL_LIGHT0,GL_Linear_Attenuation,0.05);
  glLightFV(GL_LIGHT1,GL_Position,@Light1Position);
  glLightFV(GL_LIGHT1,GL_AMBIENT,@AmbientLight);
  glLightF(GL_LIGHT1,GL_Linear_Attenuation,0.05);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_LIGHT1);
end;

procedure TGLScene.ShutDownOpenGL;
begin
  if HRC>0 then begin
    wglMakeCurrent(DC,0);
    wglDeleteContext(HRC);
  end;
  if DC>0 then ReleaseDC(OwnerPanel.Handle,DC);
end;

procedure TGLScene.SetDrawGrid(NewSetting:Boolean);
begin
  FDrawGrid:=NewSetting;
end;

procedure TGLScene.SetDrawStage(NewSetting:Boolean);
begin
  FDrawStage:=NewSetting;
end;

procedure TGLScene.SetGridColor(NewColor:TColor);
begin
  FGridColor:=ColorToGLColor(NewColor);
end;

procedure TGLScene.SetBackColor(NewColor:TColor);
begin
  FBackColor:=ColorToGLColor(NewColor);
end;

function TGLScene.GetGridColor:TColor;
begin
  Result:=GLColorToColor(FGridColor);
end;

function TGLScene.GetBackColor:TColor;
begin
  Result:=GLColorToColor(FBackColor);
end;

procedure TGLScene.SetOriginColor(NewColor:TColor);
begin
  FOriginColor:=ColorToGLColor(NewColor);
end;

function TGLScene.GetOriginColor:TColor;
begin
  Result:=GLColorToColor(FOriginColor);
end;

procedure TGLScene.SetStageSize(NewSize:Single);
begin
  if FStageSize<>NewSize then begin
    FStageSize:=NewSize;
  end;
end;

procedure TGLScene.SetStageColor(NewColor:TColor);
begin
  FStageColor:=ColorToGLColor(NewColor);
end;

function TGLScene.GetStageColor:TColor;
begin
  Result:=GLColorToColor(FStageColor);
end;

procedure TGLScene.SetGridSize(NewSize:Single);
begin
  if FGridSize<>NewSize then begin
    FGridSize:=NewSize;
  end;
end;

procedure TGLScene.DrawStageGrid;
const
  Lines = 5; // total lines = 2*lines+1
  Z = 0.01;
var
  I     : Integer;
  Range : Single;
begin
  Range:=Lines*FGridSize;
  glBegin(GL_LINES);
  for I:=-Lines to +Lines do begin
    if I=0 then glColor3FV(@FOriginColor)
    else glColor3FV(@FGridColor);

// vertical
    glVertex3F(I*FGridSize,Range,Z);
    glVertex3F(I*FGridSize,-Range,Z);

// horizontal
    glVertex3F(-Range,I*FGridSize,Z);
    glVertex3F(+Range,I*FGridSize,Z);
  end;
  glEnd;
end;

procedure TGLScene.DrawTheStage;
const
  StageW = 15;
  StageD = 14;
begin
  glMaterialFV(GL_FRONT,GL_AMBIENT,@FStageColor);
  glNormal3F(0,0,1);
  glRectF(+StageW/2,+StageD/2,-StageW/2,-StageD/2);
end;

procedure TGLScene.FindMouseSelection(X,Y:Integer);
begin
  if HRC<=0 then Exit;

// make our context the current one
  if not wglMakeCurrent(DC,HRC) then Exit;

// flip Y (Windows Y=0 is the top, OpenGL Y=0 is the bottom
  Y:=Height-1-Y;

// set up the selection buffer
  glSelectBuffer(SelectBufferLength,@SelectBuffer);

// set the render mode to "select"
  glRenderMode(GL_SELECT);

// init the names stack
  glInitNames;
  glPushName(0);

// set up the projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;

// get the viewport
  glViewport(0,0,Width,Height);
  glGetIntegerv(GL_VIEWPORT,@MouseViewPort);

// set the clipping volume to be +/- 7 pixels around the cursor
  gluPickMatrix(X,Y,7,7,@MouseViewPort);

// apply perspective
  gluPerspective(CameraFOV,Width/Height,DistNear,DistFar);

// model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

// set the viewport
  glViewport(0,0,Width,Height);

// place the camera
  PlaceCamera;

// get the modelview & projection matrices - used for later 2-D drawing
  GetMatricesAndViewPort;

  if Assigned(FOnRender) then FOnRender(Self);

// flush it
  glFlush;

// restore the render mode and record the hits we found
  Hits:=glRenderMode(GL_RENDER);

// don't go past our select buffer
  if Hits>(SelectBufferLength/4) then begin
    Hits:=SafeTrunc(SelectBufferLength/4);
    FirstHitName:=SelectBuffer[4];
  end;
end;

procedure TGLScene.DrawLine(Pt1,Pt2:TPoint3D);
begin
  glBegin(GL_LINES);
    glVertex3FV(@Pt1);
    glVertex3FV(@Pt2);
  glEnd;
end;

procedure TGLScene.PlaceCamera;
begin
// view translation
  glTranslateF(-CamLocation.X,-CamLocation.Y,-CamLocation.Z);

// rotate the entire scene
  glRotateF(SceneRx,1,0,0);
  glRotateF(SceneRz,0,0,1);
end;

procedure TGLScene.CopyMatrixDblArrayIntoMatrix(DblArray:TMatrixDblArray;
                                                iMatrix:TMatrix);
var
  I,R,C : Integer;
begin
  for R:=1 to 4 do for C:=1 to 4 do begin
    I:=(R-1)+(C-1)*4;
    iMatrix.Cell[R,C]:=DblArray[I];
  end;
end;

procedure TGLScene.GetMatricesAndViewPort;
var
  DblArray : TMatrixDblArray;
begin
// model view
  glGetDoubleV(GL_MODELVIEW_MATRIX,@DblArray);
  CopyMatrixDblArrayIntoMatrix(DblArray,MVMatrix);

// projection
  glGetDoubleV(GL_PROJECTION_MATRIX,@DblArray);
  CopyMatrixDblArrayIntoMatrix(DblArray,ProjMatrix);

// view port
  glGetIntegerV(GL_VIEWPORT,@VPort);
end;

// 2-D items never change size and are always on top
procedure TGLScene.SwitchTo2D;
begin
// establish a 1/1 relationship between pixels and OpenGL units
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluOrtho2D(0,Width,0,Height);
  glViewPort(0,0,Width,Height);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

procedure TGLScene.PrepareToStoreTextures;
begin
  if HRC<=0 then Exit;

// make our context the current one
  if not wglMakeCurrent(DC,HRC) then Exit;
  SwitchTo2D;

// set the back ground color
  with FBackColor do glClearColor(R,G,B,A);
//  glClearDepth(0);
//  glClearStencil(0);
//  glClearAccum(0,0,0,0);

// clear the color and depth buffers
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
end;

procedure TGLScene.FinishStoringTextures;
begin
  SwapBuffers(DC);
end;

procedure TGLScene.EnableAlpha;
begin
  glDisable(GL_DEPTH_TEST);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
  glTexEnvF(GL_TEXTURE_ENV,GL_TEXTURE_ENV_COLOR,GL_BLEND);
end;

procedure TGLScene.DisableAlpha;
begin
  glDisable(GL_BLEND);
  glShadeModel(GL_SMOOTH);
end;

procedure TGLScene.EnableTextures;
begin
  glColor4UB(255,255,255,255);
  glEnable(GL_TEXTURE_2D);

// set it to repeat in S and T
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

// set the filters
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
end;

procedure TGLScene.DisableTextures;
begin
  glDisable(GL_TEXTURE_2D);
end;

procedure TGLScene.ClearTextureMemory;
var
  Buffer : PByte;
begin
  GetMem(Buffer,1024*1024*4);
  FillChar(Buffer^,1024*1024*4,0);
  glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,1024,1024,0,GL_RGBA,GL_UNSIGNED_BYTE,
               Buffer);
  FreeMem(Buffer);
end;

procedure TGLScene.EnableStencilDraw;
begin
// clear the stencil buffer - this will enable drawing everywhere
  glStencilMask(1);                     // write to the stencil buffer
  glColorMask(False,False,False,False); // don't write to the color buffers

// write 1s wherever we draw
  glStencilFunc(GL_ALWAYS,1,1);
  glStencilOp(GL_REPLACE,GL_REPLACE,GL_REPLACE);
  glClear(GL_STENCIL_BUFFER_BIT);
end;

procedure TGLScene.DisableStencilDraw;
begin
  glStencilMask(0);   // don't write to the stencil buffer
  glColorMask(True,True,True,True); // write to the color buffers
  glStencilFunc(GL_NOTEQUAL,1,1);
  glStencilOp(GL_KEEP,GL_KEEP,GL_KEEP);
end;

procedure TGLScene.DrawMask(Mask:TStencilMask);
begin
  with Mask do glRect(X1,0,X2,Height);
end;

procedure TGLScene.FlashScreen;
begin
  if HRC<=0 then Exit;

// make our context the current one
  OwnerPanel.Canvas.Lock;

  if wglMakeCurrent(DC,HRC) then begin

// set the back ground color
    with FBackColor do glClearColor(1,1,1,1);

// clear the color and depth buffers
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

// finish
    SwapBuffers(DC);
  end;
  OwnerPanel.Canvas.Unlock;
end;

procedure TGLScene.Render;
begin
  if HRC<=0 then Exit;

// make our context the current one
  OwnerPanel.Canvas.Lock;

  if wglMakeCurrent(DC,HRC) then begin
    SwitchTo2D;

// set the back ground color
    with FBackColor do glClearColor(R,G,B,A);

// clear the color and depth buffers
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

// call the user routine
    if Assigned(FOnRender) then FOnRender(Self);

// finish
    SwapBuffers(DC);
  end;
  OwnerPanel.Canvas.Unlock;
end;

end.




