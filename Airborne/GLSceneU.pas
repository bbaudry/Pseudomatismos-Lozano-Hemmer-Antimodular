unit GLSceneU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, OpenGL1x, OpenGLTokens, CPanel, Global, MatrixU, GLDraw, Jpeg,
  VectorTypes;
  
const
  SelectBufferLength = 1024;
  DistNear = 1;//0.05;
  DistFar  = 30;//0;

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

    FOnFindMouseSelection : TNotifyEvent;


// the panel the scene is rendered on
    OwnerPanel : TCanvasPanel;

// misc private vars
    MouseDown     : Boolean;
    StartXPixel   : Integer;
    StartYPixel   : Integer;
    StartX        : Single;
    StartY        : Single;
    StartCam      : TCamInfo;
    ViewWidth     : Single;
    ViewHeight    : Single;
    ZoomVector    : TPoint3D;
    MouseViewport : TVector4I; // ewPortArray;

// grid routines
    procedure SetDrawGrid(NewSetting:Boolean);
    procedure SetGridSize(NewSize:Single);
    procedure SetGridColor(NewColor:TColor);
    function  GetGridColor:TColor;
    procedure SetOriginColor(NewColor:TColor);
    function  GetOriginColor:TColor;
    procedure DrawTheGrid;

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
    FirstHitName : Integer;
    Width,Height : Integer; // in pixels

// needed for 2D draw
    MVMatrix   : TMatrix;
    ProjMatrix : TMatrix;
    VPort      : TViewPortArray;
    MouseMode  : TMouseMode;

// handles and DC's
    HRC : HGLRC;
    DC  : HDC;

// camera vars
    SceneRx     : Single;
    SceneRz     : Single;
    CamLocation : TPose;
    CameraFOV   : Single;
    Pan,Tilt    : Single;

    CalPose     : TPose;
    CalFileName : TFileName;

// matrices
    Matrix      : TMatrix;
    IntMatrix   : TMatrix;
    ExtMatrix   : TMatrix;
    ZoomMatrix  : TMatrix;
    KMatrix     : TMatrix;
    HMatrix     : TMatrix;
    HInvMatrix  : TMatrix;
    PixelMatrix : TMatrix;
    StageMatrix : TMatrix;

// if true we ignore SceneRx and SceneRz and use the camera Rx,Ry,Rz instead
    UseCamOrientation : Boolean;

    property DrawGrid:Boolean read FDrawGrid write SetDrawGrid default True;
    property BackColor:TColor read GetBackColor write SetBackColor default clBlack;
    property GridColor:TColor read GetGridColor write SetGridColor default clSilver;
    property OriginColor:TColor read GetOriginColor write SetOriginColor default clWhite;
    property StageColor:TColor read GetStageColor write SetStageColor default clBlue;
    property DrawStage:Boolean read FDrawStage write SetDrawStage default True;
    property StageSize:Single read FStageSize write SetStageSize;
    property GridSize:Single read FGridSize write SetGridSize;
    property OnRender:TNotifyEvent read FOnRender write FOnRender;
    property OnFindMouseSelection:TNotifyEvent read FOnFindMouseSelection write FOnFindMouseSelection;

// constructor/destructor
    constructor Create(iOwnerPanel:TCanvasPanel);
    destructor  Destroy; override;

// public routines
    procedure Render;
    procedure Render2;

    procedure ConvertMouseXYToStageXY(var X,Y:Single);
    procedure FindMouseSelection(X,Y:Integer);
    procedure SwitchTo2D(W,H:Integer);
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
    procedure DrawOnBmp(Bmp:TBitmap);
    procedure SaveBmp(FileName:String);
    procedure DrawOnBmp2(Bmp:TBitmap);
    procedure SaveBmp2(FileName:String);

    procedure FindHMatrix;
    function  MouseXYToStageXY(X,Y:Single):TPoint2D;
    procedure SetupShadowProjection(LightPos:TPoint3D);
    procedure SetupXPlaneShadowProjection(LightPos:TPoint3D;X:Single);
    procedure SetupYPlaneShadowProjection(LightPos:TPoint3D;Y:Single);
    procedure FindPanAndTiltToPixel(var P,T:Single;X,Y:Single);
    function  StagePt(X,Y:Single):TPoint2D;

    procedure EnableStencilDraw;
    procedure DisableStencilDraw;
  end;

var
  GLScene : TGLScene;

implementation

uses
  Math, Routines, Math3D, QMatrix;

constructor TGLScene.Create(iOwnerPanel:TCanvasPanel);
begin
  inherited Create;
  OwnerPanel:=iOwnerPanel;
  Resize;
  UseCamOrientation:=False;

// create the matrices
  Matrix:=TMatrix.Create(3,4);     // projection matrix
  IntMatrix:=TMatrix.Create(4,4);  // internal matrix - camera parameters
  ExtMatrix:=TMatrix.Create(4,4);  // eternal matrix - camera location
  ZoomMatrix:=TMatrix.Create(4,4); // for zooming
  MVMatrix:=TMatrix.Create(4,4);
  ProjMatrix:=TMatrix.Create(4,4);
  KMatrix:=TMatrix.Create(3,3);
  HMatrix:=TMatrix.Create(3,3);
  HInvMatrix:=TMatrix.Create(3,3);
  PixelMatrix:=TMatrix.Create(3,1);
  StageMatrix:=TMatrix.Create(3,1);

// camera vars
  with CamLocation do begin
    X:=0; Y:=0; Z:=10;
    Rx:=0; Ry:=0; Rz:=0;
  end;
  CameraFOV:=90;
  SceneRx:=0; SceneRz:=0;
  Pan:=0; Tilt:=0;

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
  if Assigned(KMatrix) then KMatrix.Free;
  if Assigned(HMatrix) then HMatrix.Free;
  if Assigned(HInvMatrix) then HInvMatrix.Free;
  if Assigned(PixelMatrix) then PixelMatrix.Free;
  if Assigned(StageMatrix) then StageMatrix.Free;

  inherited;
end;

{function TGLScene.GetInfo:TGLSceneInfo;
begin
  Result.KInfo:=KInfo;
  Result.CalPose:=CalPose;
  Result.CalHMatrixData:=CalHMatrixData;
  Result.CalFileName:=CalFileName;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TGLScene.SetInfo(NewInfo:TGLSceneInfo);
begin
  KInfo:=NewInfo.KInfo;
  InitKMatrix;
  CalPose:=NewInfo.CalPose;
  CalHMatrixData:=NewInfo.CalHMatrixData;
  CalFileName:=NewInfo.CalFileName;
end;}

procedure TGLScene.Resize;
var
  Angle : Single;
begin
  Width:=OwnerPanel.Width;
  Height:=OwnerPanel.Height;
  Angle:=DegToRad(CameraFOV)/2;
  ViewHeight:=2*DistNear*Tan(Angle);
  ViewWidth:=ViewHeight*Width/Height;
 // InitKMatrix;
end;

procedure TGLScene.ConvertMouseXYToStageXY(var X,Y:Single);
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
  Target : TPoint3D;
begin
  StartY:=Y;
  ConvertMouseXYToStageXY(X,Y);

  Target.X:=X; Target.Y:=Y; Target.Z:=0;
  ZoomMatrix.InitAsRx4x4(DegToRad(-SceneRx));
  Target:=ZoomMatrix.MultiplyPoint3D(Target);
  ZoomMatrix.InitAsRz4x4(DegToRad(-SceneRz));
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
          Render;
        end;
      mmMove :
        begin
          CamLocation.X:=StartX+ViewWidth*75*((StartXPixel-X)/Width);
          CamLocation.Y:=StartY+ViewHeight*75*((Y-StartYPixel)/Height);
          Render;
        end;
      mmZoom :
        begin
          T:=(StartY-Y)/Height;
          CamLocation.X:=StartCam.X+ZoomVector.X*T;
          CamLocation.Y:=StartCam.Y+ZoomVector.Y*T;
          CamLocation.Z:=StartCam.Z+ZoomVector.Z*T;
          Render;
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
    cDepthBits:=0;
    cStencilBits:=0;
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
Exit;

// gl parameters
  glCullFace(GL_BACK);
  glEnable(GL_CULL_FACE);
  glEnable(GL_DEPTH_TEST);

// lighting
  InitLighting;
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

procedure TGLScene.DrawTheGrid;
const
  Lines   = 5; // total lines = 2*lines+1
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
    glVertex3F(I*FGridSize,Range,0);
    glVertex3F(I*FGridSize,-Range,0);

// horizontal
    glVertex3F(-Range,I*FGridSize,0);
    glVertex3F(+Range,I*FGridSize,0);
  end;
  glEnd;
end;

procedure TGLScene.DrawTheStage;
begin
  glMaterialFV(GL_FRONT,GL_AMBIENT_AND_DIFFUSE,@FStageColor);
  glNormal3F(0,0,1);
  glRectF(+StageSize,+StageSize,-StageSize,-StageSize);
end;

// 2-D items never change size and are always on top
procedure TGLScene.SwitchTo2D(W,H:Integer);
begin
// we won't need lighting
  glDisable(GL_LIGHTING);
  glDisable(GL_LINE_SMOOTH);
  glPolygonMode(GL_FRONT,GL_FILL);

// establish a 1/1 relationship between pixels and OpenGL units
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluOrtho2D(0,W,0,H);
//  glViewPort(0,0,Width,Height);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

procedure TGLScene.FindMouseSelection(X,Y:Integer);
begin
  if HRC<=0 then Exit;

// make our context the current one
  if not wglMakeCurrent(DC,HRC) then begin
    wglMakeCurrent(DC,0);
    wglDeleteContext(HRC);
    ReleaseDC(OwnerPanel.Handle,DC);
    DC:=GetDC(OwnerPanel.Handle);
    HRC:=wglCreateContext(DC);
    FirstHitName:=0;
    Exit;
  end;

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
  gluPickMatrix(X,Y,7,7,MouseViewPort);

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

  if Assigned(FOnFindMouseSelection) then FOnFindMouseSelection(Self);

// flush it
  glFlush;

// restore the render mode and record the hits we found
  Hits:=glRenderMode(GL_RENDER);

// don't go past our select buffer
  if Hits>0 then FirstHitName:=SelectBuffer[4]
  else FirstHitName:=0;
end;

procedure TGLScene.DrawLine(Pt1,Pt2:TPoint3D);
begin
  glBegin(GL_LINES);
    glVertex3FV(@Pt1);
    glVertex3FV(@Pt2);
  glEnd;
end;

//  glRotateF(RadToDeg(CamLocation.Rx),1,0,0);
//  glRotateF(RadToDeg(CamLocation.Ry),0,1,0);
//  glRotateF(RadToDeg(CamLocation.Rz),0,0,1);

procedure TGLScene.PlaceCamera;
begin
// camera Rx,Ry,Rz
  if UseCamOrientation then begin
    glRotateF(RadToDeg(+Tilt),1,0,0);
    glRotateF(RadToDeg(-Pan),0,1,0);

    glRotateF(RadToDeg(+CamLocation.Rx),1,0,0);
    glRotateF(RadToDeg(-CamLocation.Ry),0,1,0);
    glRotateF(RadToDeg(-CamLocation.Rz),0,0,1);
  end;

// view translation
  glTranslateF(-CamLocation.X,-CamLocation.Y,-CamLocation.Z);

// rotate the entire scene
  if not UseCamOrientation then begin
    glRotateF(SceneRx,1,0,0);
    glRotateF(SceneRz,0,0,1);
  end;
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

procedure TGLScene.Render2;
begin
  if HRC<=0 then Exit;

// make our context the current one
  if not wglMakeCurrent(DC,HRC) then begin
    CheckOpenGLError;
    ClearGLError;
    Exit;
  end;
  if Assigned(FOnRender) then FOnRender(Self);

  SwapBuffers(DC);
end;

procedure TGLScene.Render;
begin
  if HRC<=0 then Exit;

// make our context the current one
  if not wglMakeCurrent(DC,HRC) then Exit;

// set the back ground color
  with FBackColor do glClearColor(R,G,B,A);

// set up the viewport
  glViewport(0,0,Width,Height);

// clear the color and depth buffers
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

// set up the projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(CameraFOV,Width/Height,DistNear,DistFar);

// model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

// place the camera
  PlaceCamera;

// refresh our internal vars
  GetMatricesAndViewPort;

// draw the grid and the stage
  if FDrawStage then begin
    glDisable(GL_DEPTH_TEST);
    InitLighting;
    DrawTheStage;
  end;

// draw the grid
  if FDrawGrid then begin
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);
    DrawTheGrid;
  end;

// call the user routine
  if Assigned(FOnRender) then begin
    InitLighting;
    glEnable(GL_DEPTH_TEST);
    FOnRender(Self);
  end;

// finish
  SwapBuffers(DC);
end;

procedure TGLScene.DrawOnBmp(Bmp:TBitmap);
const
  GL_BGR = $80E0;
var
  Data   : PByte;
  SrcPtr : PByte;
  Line   : PByteArray;
  Y      : Integer;
begin
  if not wglMakeCurrent(DC,HRC) then Exit;
  GetMem(Data,Width*Height*3);
  try
    Bmp.Width:=Width;
    Bmp.Height:=Height;
    Bmp.PixelFormat:=pf24Bit;

// set the back ground color
    with FBackColor do glClearColor(R,G,B,A);

// clear the color and depth buffers
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

// set up the viewport
    glViewport(0,0,Width,Height);

// set up the projection matrix
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    gluPerspective(CameraFOV,Width/Height,DistNear,DistFar);

// model view matrix
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;

// place the camera
    PlaceCamera;

// draw the grid and the stage
    if FDrawStage then begin
      glDisable(GL_DEPTH_TEST);
      InitLighting;
      DrawTheStage;
    end;

// draw the grid
    if FDrawGrid then begin
      glDisable(GL_LIGHTING);
      glDisable(GL_DEPTH_TEST);
      DrawTheGrid;
    end;

// call the user routine
    if Assigned(FOnRender) then begin
      InitLighting;
      glEnable(GL_DEPTH_TEST);
      FOnRender(Self);
    end;

// read the data
    glPixelStoreI(GL_PACK_ALIGNMENT,1);

    glReadPixels(0,0,Width,Height,GL_BGR,GL_UNSIGNED_BYTE,Data);

// finish
    SwapBuffers(DC);

// save the data to the bmp
    SrcPtr:=Data;
    for Y:=0 to Height-1 do begin
      Line:=Bmp.ScanLine[Height-1-Y];
      Move(SrcPtr^,Line^,Width*3);
      Inc(SrcPtr,Width*3);
    end;
  finally
    FreeMem(Data);
  end;
end;

procedure TGLScene.SaveBmp(FileName:String);
var
  Bmp : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    DrawOnBmp(Bmp);
    Bmp.SaveToFile(FileName);
  finally
    Bmp.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Find the H matrix between the LCD and the stage at this pose / pan / tilt
// H = [K][R1R2T]
// T = -[R][C]
////////////////////////////////////////////////////////////////////////////////
procedure TGLScene.FindHMatrix;
var
  R1R2T   : TMatrix;
  T,C,Rot : TMatrix;
  R       : Integer;
begin
// create some matrices
  R1R2T:=TMatrix.Create(3,3);
  Rot:=TMatrix.Create(3,3);
  C:=TMatrix.Create(3,1);
  T:=TMatrix.Create(3,1);
  try
    with CamLocation do begin

// build the rotation matrix
      if UseCamOrientation then Rot.InitAsRotation(Rx,Ry,Rz)
      else Rot.InitAsRotation(0,0,0);

// C holds the camera center
      C.Cell[1,1]:=X;
      C.Cell[2,1]:=Y;
      C.Cell[3,1]:=Z;
    end;

// [T] = -[R][C]
    T.InitFromProduct(Rot,C);
    T.MultiplyByScalar(-1);

// build [R1R2T]
    for R:=1 to 3 do begin
      R1R2T.Cell[R,1]:=Rot.Cell[R,1];
      R1R2T.Cell[R,2]:=Rot.Cell[R,2];
      R1R2T.Cell[R,3]:=T.Cell[R,1];
    end;

// find H
    HMatrix.InitFromProduct(KMatrix,R1R2T);
    HMatrix.Normalize;
    HInvMatrix.Equals(HMatrix);
    HInvMatrix.PseudoInvert;

// clean up
  finally
    R1R2T.Free;
    Rot.Free;
    C.Free;
    T.Free;
  end;
end;

// converts from pixels to a stage (z=0 plane) X,Y coordinate with the HMatrix
function TGLScene.MouseXYToStageXY(X,Y:Single):TPoint2D;
var
  D : Single;
begin
  PixelMatrix.Cell[1,1]:=X;
  PixelMatrix.Cell[2,1]:=Y;
  PixelMatrix.Cell[3,1]:=1;
  StageMatrix.InitFromProduct(HInvMatrix,PixelMatrix);
  D:=StageMatrix.Cell[3,1];
  if Abs(D)<>1E-6 then begin
    Result.X:=StageMatrix.Cell[1,1]/D;
    Result.Y:=StageMatrix.Cell[2,1]/D;
  end
  else FillChar(Result,SizeOf(Result),0);
end;

// translated from "Shadow Projection in OpenGL" devmaster.net
procedure TGLScene.SetupShadowProjection(LightPos:TPoint3D);
const
  Origin : TPoint3D = (X:0;Y:0;Z:0.02);
  Normal : TPoint3D = (X:0;Y:0;Z:1);
var
  D,C   : Single;
  Mat   : array[0..15] of Single;
  L,E,N : TPoint3D;
begin
  L:=LightPos; E:=Origin; N:=Normal;
  N.Z:=-N.Z;

// These are c and d (corresponding to the tutorial)
  D:=N.X*L.X + N.Y*L.Y + N.Z*L.Z;
  C:=E.X*N.X + E.Y*N.Y + E.Z*N.Z - D;

// Create the matrix. OpenGL uses column by column ordering
  Mat[0]:=L.X*N.X+C; Mat[4]:=L.X*N.Y;   Mat[8]:=L.X*N.Z;    Mat[12]:=-L.X*(C+D);
  Mat[1]:=L.Y*N.X;   Mat[5]:=L.Y*N.Y+C; Mat[9]:=L.Y*N.Z;    Mat[13]:=-L.Y*(C+D);
  Mat[2]:=L.Z*N.X;   Mat[6]:=L.Z*N.Y;   Mat[10]:=L.Z*N.Z+C; Mat[14]:=-L.Z*(C+D);
  Mat[3]:=N.X;       Mat[7]:=N.Y;       Mat[11]:=N.Z;       Mat[15]:=-D;

// add this matrix to the pipeline
  glMultMatrixF(@Mat);
end;

procedure TGLScene.SetupXPlaneShadowProjection(LightPos:TPoint3D;X:Single);
var
  D,C   : Single;
  Mat   : array[0..15] of Single;
  L,E,N : TPoint3D;
  Origin : TPoint3D;
  Normal : TPoint3D;
begin
  Origin.X:=X; Origin.Y:=0; Origin.Z:=0;
  Normal.X:=-1; Normal.Y:=0; Normal.Z:=0;

  L:=LightPos; E:=Origin; N:=Normal;
  N.X:=-N.X;

// These are c and d (corresponding to the tutorial)
  D:=N.X*L.X + N.Y*L.Y + N.Z*L.Z;
  C:=E.X*N.X + E.Y*N.Y + E.Z*N.Z - D;

// Create the matrix. OpenGL uses column by column ordering
  Mat[0]:=L.X*N.X+C; Mat[4]:=L.X*N.Y;   Mat[8]:=L.X*N.Z;    Mat[12]:=-L.X*(C+D);
  Mat[1]:=L.Y*N.X;   Mat[5]:=L.Y*N.Y+C; Mat[9]:=L.Y*N.Z;    Mat[13]:=-L.Y*(C+D);
  Mat[2]:=L.Z*N.X;   Mat[6]:=L.Z*N.Y;   Mat[10]:=L.Z*N.Z+C; Mat[14]:=-L.Z*(C+D);
  Mat[3]:=N.X;       Mat[7]:=N.Y;       Mat[11]:=N.Z;       Mat[15]:=-D;

// add this matrix to the pipeline
  glMultMatrixF(@Mat);
end;

procedure TGLScene.SetupYPlaneShadowProjection(LightPos:TPoint3D;Y:Single);
var
  D,C   : Single;
  Mat   : array[0..15] of Single;
  L,E,N : TPoint3D;
  Origin : TPoint3D;
  Normal : TPoint3D;
begin
  Origin.X:=0; Origin.Y:=Y; Origin.Z:=0;
  Normal.X:=0; Normal.Y:=-1; Normal.Z:=0;

  L:=LightPos; E:=Origin; N:=Normal;
  N.Y:=-N.Y;

// These are c and d (corresponding to the tutorial)
  D:=N.X*L.X + N.Y*L.Y + N.Z*L.Z;
  C:=E.X*N.X + E.Y*N.Y + E.Z*N.Z - D;

// Create the matrix. OpenGL uses column by column ordering
  Mat[0]:=L.X*N.X+C; Mat[4]:=L.X*N.Y;   Mat[8]:=L.X*N.Z;    Mat[12]:=-L.X*(C+D);
  Mat[1]:=L.Y*N.X;   Mat[5]:=L.Y*N.Y+C; Mat[9]:=L.Y*N.Z;    Mat[13]:=-L.Y*(C+D);
  Mat[2]:=L.Z*N.X;   Mat[6]:=L.Z*N.Y;   Mat[10]:=L.Z*N.Z+C; Mat[14]:=-L.Z*(C+D);
  Mat[3]:=N.X;       Mat[7]:=N.Y;       Mat[11]:=N.Z;       Mat[15]:=-D;

// add this matrix to the pipeline
  glMultMatrixF(@Mat);
end;

procedure TGLScene.FindPanAndTiltToPixel(var P,T:Single;X,Y:Single);
var
  A,Z,R : Single;
begin
  X:=X-Width/2;
  Y:=Y-Height/2;
  A:=DegToRad(CameraFov/2);
  Z:=Y/Tan(A);
  R:=Sqrt(Sqr(X)+Sqr(Y)+Sqr(Z));
  T:=ArcSin(Y/R);
  P:=-ArcTan(X/Z);
end;

function TGLScene.StagePt(X,Y:Single):TPoint2D;
var
  V   : TPoint3D;
  P,T : Single;
begin
{  FindPanAndTiltToPixel(P,T,X,Y);
  V:=VectorToStage(CamLocation,P,T);
  Result:=StageIntersectionPoint(CamLocation,V);}
end;

procedure TGLScene.DrawOnBmp2(Bmp:TBitmap);
const
  GL_BGR = $80E0;
var
  Data   : PByte;
  SrcPtr : PByte;
  Line   : PByteArray;
  Y      : Integer;
begin
  if not wglMakeCurrent(DC,HRC) then Exit;
  GetMem(Data,ViewPortWidth*ViewPortHeight*3);
  try
    Bmp.Width:=Width;
    Bmp.Height:=Height;
    Bmp.PixelFormat:=pf24Bit;

// read the data
    glPixelStoreI(GL_PACK_ALIGNMENT,1);

    glReadPixels(0,0,ViewPortWidth,ViewPortHeight,GL_BGR,GL_UNSIGNED_BYTE,Data);

// finish
    SwapBuffers(DC);

// save the data to the bmp
    SrcPtr:=Data;
    for Y:=0 to Height-1 do begin
      Line:=Bmp.ScanLine[Height-1-Y];
      Move(SrcPtr^,Line^,Width*3);
      Inc(SrcPtr,Width*3);
    end;
  finally
    FreeMem(Data);
  end;
end;

procedure TGLScene.SaveBmp2(FileName:String);
var
  Bmp : TBitmap;
  Jpg : TJpegImage;
begin
  Bmp:=TBitmap.Create;
  Jpg:=TJpegImage.Create;
  try
    DrawOnBmp2(Bmp);
    Bmp.SaveToFile(FileName);
    Jpg.Assign(Bmp);
    FileName:=Copy(FileName,1,Length(FileName)-4)+'.jpg';
    Jpg.SaveToFile(FileName);
  finally
    Bmp.Free;
    Jpg.Free;
  end;
end;

procedure TGLScene.EnableStencilDraw;
begin
Exit;
// clear the stencil buffer - this will enable drawing everywhere
  glStencilMask(1);                     // write to the stencil buffer
  glColorMask(False,False,False,False); // don't write to the color buffers

// write 1s wherever we draw - wherever we write we won't draw
  glStencilFunc(GL_ALWAYS,1,1);
  glStencilOp(GL_REPLACE,GL_REPLACE,GL_REPLACE);
  glClear(GL_STENCIL_BUFFER_BIT);
end;

procedure TGLScene.DisableStencilDraw;
begin
Exit;
  glStencilMask(0);   // don't write to the stencil buffer
  glColorMask(True,True,True,True); // write to the color buffers
  glStencilFunc(GL_NOTEQUAL,1,1);
  glStencilOp(GL_KEEP,GL_KEEP,GL_KEEP);
end;

end.



