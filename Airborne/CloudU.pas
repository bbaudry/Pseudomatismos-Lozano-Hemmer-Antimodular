unit CloudU;

interface

uses
  OpenGL1x, OpenGLTokens, ProgramU, Windows, Dialogs, SysUtils, TextureU,
  Graphics, Global, Math;

type
  TVector2 = record
    X,Y : Integer;
  end;

  TBand = record
    Pt1,Pt2 : TVector2;
  end;

  TCloudType = (ctVisor,ctEyes);

const
  SplatRadius = 25;

  PositionSlot = 0;

  ImpulsePosition : TVector2 = (X:120;Y:+55);

//  ImpulsePosition : TVector2 = (X:GridWidth div 2;Y:-(SplatRadius div 2)); //160;Y:120);
 // static const Vector2 ImpulsePosition = { GridWidth / 2, - (int) SplatRadius / 2};

  SmokeTextureData : array[1..8] of Single =    // buffer #2 is texture
    (0.0, 0.0,
     1.0, 0.0,
     0.0, 1.0,
     1.0, 1.0);

type
  TRenderMode = (rmVelocity,rmTemperature,rmPressure,rmDensity);

  TSurface = record
    FboHandle     : GLuint;
    TextureHandle : GLuint;
    Components    : Integer;
  end;
  PSurface = ^TSurface;

  TSlab = record
    Ping : TSurface;
    Pong : TSurface;
  end;
  PSlab = ^TSlab;

  TCloudInfo = packed record
    AmbientTemperature     : Single;
    ImpulseTemperature     : Single;
    ImpulseDensity         : Single;
    JacobiIterations       : Integer;
    TimeStep               : Single;
    SmokeBuoyancy          : Single;
    SmokeWeight            : Single;
    TemperatureDissipation : Single;
    VelocityDissipation    : Single;
    DensityDissipation     : Single;
    CellSize               : Single;
    GradientScale          : Single;
    SmokeColor             : TColor;
    ClearPressure          : Boolean;
    XOffset                : Integer;
    YOffset                : Integer;
    BandXScale             : Single;
    BandYScale             : Single;
    BandYDisp              : Single;
    BandR1                 : Single;
    BandR2                 : Single;
    SubtractedThreshold    : Integer;
    BackGndColor           : TColor;
    Sources                : Integer;
    YOffsetFraction        : Single;
    MaxSize                : Integer;
    Reserved               : array[1..252-12] of Byte;
  end;

  TCloud = class(TObject)
  private
// surfaces have a frame buffer object and a texture handle
    Divergence     : TSurface;
    Obstacles      : TSurface;

// from the camera
    SubtractedSurface : TSurface;
    SubtractedData    : PSingle;
    SubtractedSize    : Integer;

    PBO : GLUInt;

    ObstaclePBO : GLUInt;

    ObstacleData : PGLFloat;

    SmokeVboHandle : array[1..2] of GLUInt;  // vertex buffers
    SmokeVaoHandle : GLUInt;                 // vertex array handle

    SmokePositionBufferHandle : GLUInt;
    SmokeTextureBufferHandle  : GLUInt;

    SmokePositionData : array[1..8] of Single;

    function CreateQuad:GLuint;

    function CreateSurface(Width,Height:TGLSizeI;Components:Integer):TSurface;
    function CreateFloatSurface(Width,Height:TGLSizeI;Components:Integer):TSurface;

    function CreateSlab(Width,Height:TGLSizeI;Components:Integer):TSlab;

    procedure CreateObstacles(Dest:TSurface;Width,Height:Integer);
    procedure CreateObstaclesFromProjectorMask(Dest:TSurface;Width,Height:Integer);

    procedure SwapSurfaces(Slab:PSlab);

    procedure Advect(Velocity,Source,Obstacles,Dest:TSurface;Dissipation:Single);
    procedure Jacobi(Pressure,Divergence,Obstacles,Dest:TSurface);
    procedure SubtractGradient(Velocity,Pressure,Obstacles,Dest:TSurface);
    procedure ComputeDivergence(Velocity,Obstacles,Dest:TSurface);
    procedure ApplyImpulse(Dest:TSurface;Position:TVector2;Value,R:Single);
    procedure ApplySink(Dest:TSurface;Position:TVector2;Value,R:Single);

    procedure ApplyBuoyancy(Velocity,Temperature,Density,Dest:TSurface);
    procedure ApplySubtraction(SubtractedSurface,Dest:TSurface;Value:Single);

    procedure ApplyOval(Dest:TSurface;Ctr:TPoint2D;W,H,Rz,Value:Single);

    procedure ResetState;

    function GetInfo:TCloudInfo;
    procedure SetInfo(NewInfo:TCloudInfo);

    function SmallCamXToGridX(CamX:Integer):Integer;
    function SmallCamYToGridY(CamY:Integer):Integer;

    function CamXToGridX(CamX:Integer):Integer;
    function CamYToGridY(CamY:Integer):Integer;

    function GridXToCamX(GridX:Integer):Integer;
    function GridYToCamY(GridY:Integer):Integer;

    function ViewPortXToGridX(X:Integer):Integer;
    function ViewPortYToGridY(Y:Integer):Integer;
    function MaskXToObstacleX(MaskX: Integer): Single;
    function MaskYToObstacleY(MaskY: Integer): Single;
    procedure RenderObstacles(FillColor:GLInt);

    procedure CreatePBO;
    procedure SaveBmp;
    procedure ReadDensityData;
    procedure SaveDensityData;

    procedure ReadVelocityData;
    procedure SyncWithTracker;
    procedure ApplySmoke(Dest: TSurface; Value: Single);
    procedure SyncWithBlobFinder;
//    procedure CreateObstaclePBO;

  public
    ProgramsLoaded : Boolean;
    RenderMode     : TRenderMode;

// slabs have surfaces for swapping
    Velocity    : TSlab;
    Density     : TSlab;
    Pressure    : TSlab;
    Temperature : TSlab;

    Texture : TSlab;

    SmokeColor : TColor;
    BackGndColor : TColor;

    MousePos : TVector2;

    AmbientTemperature     : Single;
    ImpulseTemperature     : Single;
    ImpulseDensity         : Single;
    JacobiIterations       : Integer;
    TimeStep               : Single;
    SmokeBuoyancy          : Single;
    SmokeWeight            : Single;
    TemperatureDissipation : Single;
    VelocityDissipation    : Single;
    DensityDissipation     : Single;
    CellSize               : Single;
    GradientScale          : Single;
    ClearPressure          : Boolean;

    XOffset,YOffset : Integer;

    BandXScale : Single;
    BandYScale : Single;
    BandYDisp  : Single;
    BandR1     : Single;
    BandR2     : Single;

    SubtractedThreshold : Integer;
    CloudType : TCloudType;

    Blend : Boolean;

    Sources,Yo      : Integer;
    YOffsetFraction : Single;
    MaxSize         : Integer;

    Save : Boolean;

    SmokeChars : Boolean;

    DensityData  : PByte;
    VelocityData : PSingle;

    GridWidth  : Integer;
    GridHeight : Integer;

    DensityBmp  : TBitmap;
    VelocityBmp : TBitmap;

    ObstacleBmp : TBitmap;

    SmokeTexture : TTexture;

    SaveSmokeTexture : Boolean;
    RedrawObstacles  : Boolean;
    ObstacleX        : Integer;

    constructor Create;
    destructor Destroy; override;

    property Info : TCloudInfo read GetInfo write SetInfo;

    procedure Initialize(Width,Height:Integer);
    procedure Update;

    procedure Render;

    procedure RenderTexture;
    procedure RenderToTexture;

    procedure LoadPrograms;
    procedure ClearSurface(S:TSurface;V:Single);
    procedure Stir(X,Y:Integer);
    procedure DrawLine;
    procedure InvertColors;
    procedure Reset;
    procedure DrawObstacles;
  end;

var
  Cloud : TCloud;

function DefaultCloudInfo:TCloudInfo;

implementation

uses
  Main, GLDraw, Classes, OpenCV, CameraU, BlobFindU, ProjectorU, ProjectorMaskU,
  Routines, ShadTrkr, BmpUtils;

var
  AdvectProgram            : TProgram;
  JacobiProgram            : TProgram;
  SubtractGradientProgram  : TProgram;
  ComputeDivergenceProgram : TProgram;
  BuoyancyProgram          : TProgram;
  ImpulseProgram           : TProgram;
  SinkProgram              : TProgram;
  SubtractedProgram        : TProgram;

  VisualizeProgram : TProgram;
  FillProgram      : TProgram;
  OvalProgram      : TProgram;
  SmokeProgram     : TProgram;

// the quad vertex array object
  QuadVao : GLuint;

function DefaultCloudInfo:TCloudInfo;
begin
  with Result do begin
    AmbientTemperature:=0.0;
    ImpulseTemperature:=6.0;
    ImpulseDensity:=0.30;
    JacobiIterations:=10;
    TimeStep:= 0.115;
    SmokeBuoyancy:=0.30;
    SmokeWeight:=0.100;
    TemperatureDissipation:=0.9900;
    VelocityDissipation:=0.9900;
    DensityDissipation:=0.9900;
    CellSize:= 1.25;
    GradientScale:=0.90;
    SmokeColor:=clWhite;
    BackGndColor:=clBlack;
    ClearPressure:=False;

    XOffset:=0;
    YOffset:=0;
    BandXScale:=0.80;
    BandYScale:=0.25;
    BandYDisp:=0.20;
    BandR1:=0.20;
    BandR2:=0.30;
    SubtractedThreshold:=255;
    Sources:=1;
    YOffsetFraction:=0.5;
    MaxSize:=40;

    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

constructor TCloud.Create;
begin
  inherited;

  JacobiProgram:=TProgram.Create;
  SubtractGradientProgram:=TProgram.Create;
  VisualizeProgram:=TProgram.Create;
  AdvectProgram:=TProgram.Create;
  ImpulseProgram:=TProgram.Create;
  SinkProgram:=TProgram.Create;
  BuoyancyProgram:=TProgram.Create;
  ComputeDivergenceProgram:=TProgram.Create;
  VisualizeProgram:=TProgram.Create;
  FillProgram:=TProgram.Create;
  SubtractedProgram:=TProgram.Create;
  OvalProgram:=TProgram.Create;
  SmokeProgram:=TProgram.Create;

  Save:=False;
  ProgramsLoaded:=False;
  RenderMode:=rmDensity;
  RedrawObstacles:=False;
  ObstacleX:=100;

  DensityBmp:=TBitmap.Create;
  DensityBmp.PixelFormat:=pf24Bit;

  VelocityBmp:=TBitmap.Create;
  VelocityBmp.PixelFormat:=pf24Bit;

  ObstacleBmp:=TBitmap.Create;
  ObstacleBmp.PixelFormat:=pf24Bit;

  SmokeTexture:=TTexture.Create;
end;

destructor TCloud.Destroy;
begin
  FreeMem(SubtractedData);
  FreeMem(DensityData);

  DensityBmp.Free;
  VelocityBmp.Free;
  ObstacleBmp.Free;

  if Assigned(SmokeTexture) then SmokeTexture.Free;

  glDeleteBuffers(1,@PBO);
  glDeleteBuffers(1,@ObstaclePBO);

{  JacobiProgram.Free;
  SubtractGradientProgram.Free;
  VisualizeProgram.Free;
  AdvectProgram.Free;
  ImpulseProgram.Free;
  SinkProgram.Free;
  BuoyancyProgram.Free;
  ComputeDivergenceProgram.Free;
  VisualizeProgram.Free;
  FillProgram.Free;}

  inherited;
end;

function TCloud.GetInfo:TCloudInfo;
begin
  Result.AmbientTemperature:=AmbientTemperature;
  Result.ImpulseTemperature:=ImpulseTemperature;
  Result.ImpulseDensity:=ImpulseDensity;
  Result.JacobiIterations:=JacobiIterations;
  Result.TimeStep:=TimeStep;
  Result.SmokeBuoyancy:=SmokeBuoyancy;
  Result.SmokeWeight:=SmokeWeight;
  Result.TemperatureDissipation:=TemperatureDissipation;
  Result.VelocityDissipation:=VelocityDissipation;
  Result.DensityDissipation:=DensityDissipation;
  Result.CellSize:=CellSize;
  Result.GradientScale:=GradientScale;
  Result.SmokeColor:=SmokeColor;
  Result.ClearPressure:=ClearPressure;
  Result.XOffset:=XOffset;
  Result.YOffset:=YOffset;
  Result.BandXScale:=BandXScale;
  Result.BandYScale:=BandYScale;
  Result.BandYDisp:=BandYDisp;
  Result.BandR1:=BandR1;
  Result.BandR2:=BandR2;
  Result.SubtractedThreshold:=SubtractedThreshold;
  Result.BackGndColor:=BackGndColor;
  Result.Sources:=Sources;
  Result.YOffsetFraction:=YOffsetFraction;
  Result.MaxSize:=MaxSize;

  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TCloud.SetInfo(NewInfo:TCloudInfo);
begin
  AmbientTemperature:=NewInfo.AmbientTemperature;
  ImpulseTemperature:=NewInfo.ImpulseTemperature;
  ImpulseDensity:=NewInfo.ImpulseDensity;
  JacobiIterations:=NewInfo.JacobiIterations;
  TimeStep:=NewInfo.TimeStep;
  SmokeBuoyancy:=NewInfo.SmokeBuoyancy;
  SmokeWeight:=NewInfo.SmokeWeight;
  TemperatureDissipation:=NewInfo.TemperatureDissipation;
  VelocityDissipation:=NewInfo.VelocityDissipation;
  DensityDissipation:=NewInfo.DensityDissipation;
  CellSize:=NewInfo.CellSize;
  GradientScale:=NewInfo.GradientScale;
  SmokeColor:=NewInfo.SmokeColor;
  ClearPressure:=NewInfo.ClearPressure;
  XOffset:=NewInfo.XOffset;
  YOffset:=NewInfo.YOffset;
  BandXScale:=NewInfo.BandXScale;
  BandYScale:=NewInfo.BandYScale;
  BandYDisp:=NewInfo.BandYDisp;
  BandR1:=NewInfo.BandR1;
  BandR2:=NewInfo.BandR2;
  SubtractedThreshold:=NewInfo.SubtractedThreshold;
  BackGndColor:=NewInfo.BackGndColor;
  Sources:=NewInfo.Sources;
  YOffsetFraction:=NewInfo.YOffsetFraction;
  MaxSize:=NewInfo.MaxSize;
end;

procedure TCloud.LoadPrograms;
begin
  ProgramsLoaded:=True;
  JacobiProgram.LoadVertexAndFragmentFiles('Default.Vert','Jacobi.frag');
  SubtractGradientProgram.LoadVertexAndFragmentFiles('Default.Vert','SubtractGradient.frag');
  AdvectProgram.LoadVertexAndFragmentFiles('Default.Vert','Advect.frag');
  ImpulseProgram.LoadVertexAndFragmentFiles('Default.Vert','Splat.frag');
  SinkProgram.LoadVertexAndFragmentFiles('Default.Vert','Sink.frag');
  BuoyancyProgram.LoadVertexAndFragmentFiles('Default.Vert','Buoyancy.frag');
  ComputeDivergenceProgram.LoadVertexAndFragmentFiles('Default.Vert','ComputeDivergence.frag');
  VisualizeProgram.LoadVertexAndFragmentFiles('Default.Vert','Visualize.frag');
  FillProgram.LoadVertexAndFragmentFiles('Default.Vert','Fill.frag');
  OvalProgram.LoadVertexAndFragmentFiles('Default.Vert','Oval.frag');
  SubtractedProgram.LoadVertexAndFragmentFiles('Default.Vert','Subtract.frag');
  SmokeProgram.LoadVertexAndFragmentFiles('Smoke.vert','Smoke.frag');
end;

procedure TCloud.Initialize;
var
  W,H  : Integer;
  Size : Integer;
begin
  W:=GridWidth;
  H:=GridHeight;
  Velocity:=CreateSlab(W,H,2);
  Density:=CreateSlab(W,H,1);
  Pressure:=CreateSlab(W,H,1);
  Temperature:=CreateSlab(W,H,1);

  Divergence:=CreateSurface(W,H,3); // ok

  glGenTextures(1,@Obstacles.TextureHandle);
  glBindTexture(GL_TEXTURE_2D,Obstacles.TextureHandle);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, W, H, 0, GL_RGB, GL_FLOAT, nil);

  glBindTexture(GL_TEXTURE_2D,0);

  ObstacleBmp.Width:=W;
  ObstacleBmp.Height:=H;
  GetMem(ObstacleData,W*H*3*4);

  DrawObstacles;

  QuadVao:=CreateQuad();
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
  ClearSurface(Temperature.Ping,AmbientTemperature);

  Texture:=CreateSlab(W,H,3);

  SubtractedSurface:=CreateFloatSurface(W,H,1);

  Size:=W*H*3; // RGB byte

  GetMem(DensityData,Size);
  DensityBmp.Width:=W;
  DensityBmp.Height:=H;

  Size:=W*H*3*4; // RG float
  GetMem(VelocityData,Size);
  VelocityBmp.Width:=W;
  VelocityBmp.Height:=H;

  CreatePBO;

  SmokeTexture.HasAlpha:=False;
  SmokeTexture.Resize(640,480);

  SmokePositionData[1]:=-W;
  SmokePositionData[2]:=-H;
  SmokePositionData[3]:=W;
  SmokePositionData[4]:=-H;
  SmokePositionData[5]:=-W;
  SmokePositionData[6]:=H;
  SmokePositionData[7]:=W;
  SmokePositionData[8]:=H;

  glGenBuffers(2,@SmokeVboHandle[1]);
  SmokePositionBufferHandle:=SmokeVboHandle[1];
  SmokeTextureBufferHandle:=SmokeVboHandle[2];

// init the positions
  glBindBuffer(GL_ARRAY_BUFFER,SmokePositionBufferHandle);
  glBufferData(GL_ARRAY_BUFFER,8*SizeOf(Single),@SmokePositionData,GL_STATIC_DRAW);

// init the texture coordinated
  glBindBuffer(GL_ARRAY_BUFFER,SmokeTextureBufferHandle);
  glBufferData(GL_ARRAY_BUFFER,8*SizeOf(Single),@SmokeTextureData,GL_STATIC_DRAW);

// Create and set-up the vertex array object
  glGenVertexArrays(1,@SmokeVaoHandle);
  glBindVertexArray(SmokeVaoHandle);

// not needed if specified in the vertex shader
  glEnableVertexAttribArray(0);  // Vertex position
  glEnableVertexAttribArray(1);  // Vertex texture coordinate

  glBindBuffer(GL_ARRAY_BUFFER,SmokePositionBufferHandle);
  glVertexAttribPointer(0,2,GL_FLOAT,ByteBool(0),0,nil);

  glBindBuffer(GL_ARRAY_BUFFER,SmokeTextureBufferHandle);
  glVertexAttribPointer(1,2,GL_FLOAT,ByteBool(0),0,nil);
end;

procedure TCloud.ResetState;
begin
// unbind the 3 texture units
  glActiveTexture(GL_TEXTURE2); glBindTexture(GL_TEXTURE_2D,0);
  glActiveTexture(GL_TEXTURE1); glBindTexture(GL_TEXTURE_2D,0);
  glActiveTexture(GL_TEXTURE0); glBindTexture(GL_TEXTURE_2D,0);

// unbind the frame buffer and disable blending
  glBindFrameBuffer(GL_FRAMEBUFFER,0);
  glDisable(GL_BLEND);
end;

function TCloud.CreateQuad:GluInt;
const
  Positions : array[0..7] of SmallInt = (
        -1, -1,
         1, -1,
        -1,  1,
         1,  1);
var
  VAO,VBO     : GLuInt;
  Size,Stride : GLSizeIPtr;
begin
// Create the VAO
  glGenVertexArrays(1,@VAO);
  glBindVertexArray(VAO);

// Create the VBO
  Size:=SizeOf(Positions);
  glGenBuffers(1,@VBO);
  glBindBuffer(GL_ARRAY_BUFFER,VBO);
  glBufferData(GL_ARRAY_BUFFER,Size,@Positions[0],GL_STATIC_DRAW);

// Set up the vertex layout
  Stride:=2*SizeOf(Positions[0]);
  glEnableVertexAttribArray(PositionSlot);
  glVertexAttribPointer(PositionSlot,2,GL_SHORT,ByteBool(GL_FALSE),Stride,nil);

  Result:=VAO;
end;

function TCloud.CreateSlab(Width,Height:GLsizei;Components:Integer):TSlab;
begin
  Result.Ping:=CreateSurface(Width,Height,Components);
  Result.Pong:=CreateSurface(Width,Height,Components);
end;

function TCloud.CreateSurface(Width,Height:GLSizeI;Components:Integer):TSurface;
const
  UseHalfFloats = True;
var
  FboHandle     : GLuint;
  TextureHandle : GLuint;
  Colorbuffer   : GLuint;
begin
// create a single frame buffer handle
  glGenFramebuffers(1,@FboHandle);
  glBindFramebuffer(GL_FRAMEBUFFER,FboHandle);

// create a texture handle
  glGenTextures(1,@TextureHandle);
  glBindTexture(GL_TEXTURE_2D, textureHandle);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  Case Components of
    1: glTexImage2D(GL_TEXTURE_2D, 0, GL_R32F, Width, Height, 0, GL_RED, GL_FLOAT, nil);
    2: glTexImage2D(GL_TEXTURE_2D, 0, GL_RG32F, Width, Height, 0, GL_RG, GL_FLOAT, nil);
    3: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, Width, Height, 0, GL_RGB, GL_FLOAT, nil);
    4: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, Width, Height, 0, GL_RGBA, GL_FLOAT, nil);

    else ShowMessage('Illegal slab format.');
  end;
  if glGetError<>GL_NO_ERROR then begin
    ShowMessage('Error creating texture');
  end;

// create a render buffer and attach it to the frame buffer
  glGenRenderbuffers(1,@ColorBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER,Colorbuffer);
  glFrameBufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D,textureHandle,0);
  if glGetError<>GL_NO_ERROR then begin
    ShowMessage('Error setting color attachment to frame buffer');
  end;
  Result.FboHandle:=FboHandle;
  Result.TextureHandle:=TextureHandle;
  Result.Components:=Components;

  glClearColor(0, 0, 0, 0);
  glClear(GL_COLOR_BUFFER_BIT);
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
end;

procedure TCloud.CreatePBO;
const
  BPP = 3;
var
  Size : Integer;
begin
// create the pixel buffer objects
  glGenBuffers(1,@PBO);

// set the pixel buffer object size and tell the GPU we only need to read
  glBindBuffer(GL_PIXEL_PACK_BUFFER,PBO);
  Size:=GridWidth*GridHeight*2*4;//BPP;
  glBufferDataARB(GL_PIXEL_PACK_BUFFER,Size,nil,GL_STREAM_READ);
  glBindBufferARB(GL_PIXEL_PACK_BUFFER,0);
  glPixelStoreI(GL_UNPACK_ALIGNMENT,1);      // BPP pixel alignment
end;

{procedure TCloud.CreateObstaclePBO;
const
  BPP = 3;
var
  Size : Integer;
begin
// create the pixel buffer objects
  glGenBuffers(1,@ObstaclePBO);

// set the pixel buffer object size and tell the GPU we want to draw
  glBindBuffer(GL_PIXEL_UNPACK_BUFFER,ObstaclePBO);
    Size:=GridWidth*GridHeight*3*SizeOf(GL_FLOAT);
    glBufferData(GL_PIXEL_UNPACK_BUFFER,Size,nil,GL_STREAM_DRAW);
  glBindBuffer(GL_PIXEL_PACK_BUFFER,0);

//  glPixelStoreI(GL_UNPACK_ALIGNMENT,1);      // BPP pixel alignment
end;}

procedure TCloud.SaveDensityData;
var
  Bmp    : TBitmap;
  SrcPtr : PBGRPixel;
  X,Y,I  : Integer;
  V      : Byte;
  Line   : PByteArray;
begin
  Bmp:=TBitmap.Create;
  try
    Bmp.PixelFormat:=pf24Bit;
    Bmp.Width:=GridWidth;
    Bmp.Height:=GridHeight;

    SrcPtr:=PBGRPixel(DensityData);
    for Y:=Bmp.Height-1 downto 0 do begin
      Line:=Bmp.ScanLine[Y];
      for X:=0 to Bmp.Width-1 do begin
        I:=X*3;
        V:=SrcPtr^.B;
        Line^[I+0]:=V;
        Line^[I+1]:=V;
        Line^[I+2]:=V;
        Inc(SrcPtr);
      end;
    end;
    Bmp.SaveToFile(Path+'Test.bmp');
  finally
    Bmp.Free;
  end;
end;

procedure TCloud.SaveBmp;
var
  SrcPtr   : PByte;
  DataPtr  : PByte;
  DataType : Integer;
  Bpr,Y    : Integer;
  Bmp      : TBitmap;
  Line     : PByteArray;
begin
//  glBindFrameBuffer(GL_FRAMEBUFFER,Density.Ping.FboHandle);
  glBindFrameBuffer(GL_FRAMEBUFFER,Velocity.Ping.FboHandle);

// bind the PBO
  glReadBuffer(GL_FRONT);
  glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB,PBO);

  DataType:=GL_BYTE;

  glPixelStoreI(GL_PACK_ALIGNMENT,1);
  glReadPixels(0,0,GridWidth,GridHeight,GL_RGB,DataType,nil);

// map the PBO
  glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB,PBO);

  DataPtr:=PByte(glMapBufferARB(GL_PIXEL_PACK_BUFFER_ARB,GL_READ_ONLY_ARB));

  Bmp:=TBitmap.Create;
  try
    Bmp.PixelFormat:=pf24Bit;
    Bmp.Width:=GridWidth;
    Bmp.Height:=GridHeight;
    SrcPtr:=DataPtr;
    BPR:=GridWidth*3;
    for Y:=Bmp.Height-1 downto 0 do begin
      Line:=Bmp.ScanLine[Y];
      Move(SrcPtr^,Line^,BPR);
      Inc(SrcPtr,BPR);
    end;
    Bmp.SaveToFile(Path+'Test.bmp');
  finally
    Bmp.Free;
  end;

// release the pointer to the mapped buffer
  glUnmapBufferARB(GL_PIXEL_PACK_BUFFER_ARB);
  glBindFrameBuffer(GL_FRAMEBUFFER,0);
end;

procedure TCloud.ReadDensityData;
var
  SrcPtr   : PByte;
  DataPtr  : PByte;
  DataType : Integer;
  Bpr,Y    : Integer;
  Size     : Integer;
  Bmp      : TBitmap;
  Line     : PByteArray;
begin
  glBindFrameBuffer(GL_FRAMEBUFFER,Density.Ping.FboHandle);

// bind the PBO
  glReadBuffer(GL_FRONT);
  glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB,PBO);

  DataType:=GL_BYTE;

  glPixelStoreI(GL_PACK_ALIGNMENT,1);
  glReadPixels(0,0,GridWidth,GridHeight,GL_RGB,DataType,nil);

// map the PBO
  glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB,PBO);

  DataPtr:=PByte(glMapBufferARB(GL_PIXEL_PACK_BUFFER_ARB,GL_READ_ONLY_ARB));
  Size:=GridWidth*GridHeight*3;

// store it
  Move(DataPtr^,DensityData^,Size);

// release the pointer to the mapped buffer
  glUnmapBufferARB(GL_PIXEL_PACK_BUFFER_ARB);

// unbind the frame buffer
  glBindFrameBuffer(GL_FRAMEBUFFER,0);

  SrcPtr:=DensityData;
  BPR:=GridWidth*3;
  for Y:=GridHeight-1 downto 0 do begin
    Line:=DensityBmp.ScanLine[Y];
    Move(SrcPtr^,Line^,BPR);
    Inc(SrcPtr,BPR);
  end;
end;

procedure TCloud.ReadVelocityData;
var
  SrcPtr   : PSingle;
//  SrcPtr   : PByte;
  DataPtr  : PByte;
  DataType : Integer;
  Bpr,Y,X  : Integer;
  Size,I   : Integer;
  Bmp      : TBitmap;
  Line     : PByteArray;
begin
  glBindFrameBuffer(GL_FRAMEBUFFER,Velocity.Ping.FboHandle);

// bind the PBO
  glReadBuffer(GL_FRONT);
  glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB,PBO);

//  DataType:=GL_BYTE;
  DataType:=GL_FLOAT;

  glPixelStoreI(GL_PACK_ALIGNMENT,4);
  glReadPixels(0,0,GridWidth,GridHeight,GL_RG,DataType,nil);

// map the PBO
  glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB,PBO);

  DataPtr:=PByte(glMapBufferARB(GL_PIXEL_PACK_BUFFER_ARB,GL_READ_ONLY_ARB));
  Size:=GridWidth*GridHeight*2*4;

// store it
  Move(DataPtr^,VelocityData^,Size);

// release the pointer to the mapped buffer
  glUnmapBufferARB(GL_PIXEL_PACK_BUFFER_ARB);

// unbind the frame buffer
  glBindFrameBuffer(GL_FRAMEBUFFER,0);

  SrcPtr:=VelocityData;
  BPR:=GridWidth*3;
  for Y:=GridHeight-1 downto 0 do begin
    Line:=VelocityBmp.ScanLine[Y];
    for X:=0 to GridWidth-1 do begin
      I:=X*3;
      Line[I]:=ClipToByte(255*SrcPtr^);
      Inc(SrcPtr);
      Line[I+1]:=ClipToByte(255*SrcPtr^);
      Inc(SrcPtr);
      Line[I+2]:=0;//ClipToByte(255*SrcPtr^);
   //   Inc(SrcPtr);
    end;
  end;
end;

function TCloud.CreateFloatSurface(Width,Height:GLSizeI;Components:Integer):TSurface;
const
  UseHalfFloats = True;
var
  FboHandle     : GLuint;
  TextureHandle : GLuint;
  Colorbuffer   : GLuint;
begin
  glGenFramebuffers(1,@FboHandle);
  glBindFramebuffer(GL_FRAMEBUFFER,FboHandle);

  glGenTextures(1,@TextureHandle);
  glBindTexture(GL_TEXTURE_2D, textureHandle);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  Case Components of
    1: glTexImage2D(GL_TEXTURE_2D, 0, GL_R32F, width, height, 0, GL_RED, GL_FLOAT, nil);
    2: glTexImage2D(GL_TEXTURE_2D, 0, GL_RG32F, width, height, 0, GL_RG, GL_FLOAT, nil);
    3: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB32F, width, height, 0, GL_RGB, GL_FLOAT, nil);
    4: glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, width, height, 0, GL_RGBA, GL_FLOAT, nil);
    else ShowMessage('Illegal slab format.');
  end;
  if glGetError<>GL_NO_ERROR then begin
    ShowMessage('Error creating texture');
  end;

  glGenRenderbuffers(1,@ColorBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER,Colorbuffer);
  glFrameBufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D,textureHandle,0);
  if glGetError<>GL_NO_ERROR then begin
    ShowMessage('Error setting color attachment to frame buffer');
  end;
  Result.FboHandle:=FboHandle;
  Result.TextureHandle:=TextureHandle;
  Result.Components:=Components;

  glClearColor(0, 0, 0, 0);
  glClear(GL_COLOR_BUFFER_BIT);
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
end;

procedure TCloud.Stir(X,Y:Integer);
begin
  MousePos.X:=X;
  MousePos.Y:=Y;
end;

procedure TCloud.DrawObstacles;
const
  Border = 0;
var
  Data    : PGLFloat;
  DataPtr : PGLFloat;
  V       : GLFloat;
  BPR,X,Y : Integer;
  Line    : PByteArray;
begin
  ClearBmp(ObstacleBmp,clBlack);

  with ObstacleBmp.Canvas do begin
    Brush.Color:=clWhite;
    FillRect(Rect(ObstacleX,200,ObstacleX+20,220));

    Pen.Color:=clWhite;
    Pen.Width:=1;
    MoveTo(Border,Border);
    LineTo(GridWidth-Border-1,Border);
    LineTo(GridWidth-Border-1,GridHeight-Border-1);
    LineTo(Border,GridHeight-Border-1);
    LineTo(Border,Border);
  end;

  BPR:=GridWidth*SizeOf(Single)*3;  // R,G,B floats
  DataPtr:=ObstacleData;
  for Y:=0 to GridHeight-1 do begin
    Line:=ObstacleBmp.ScanLine[Y];
    for X:=0 to GridWidth-1 do begin
      if Line^[X*3]>0 then V:=1
      else V:=0;
      DataPtr^:=V; Inc(DataPtr); // R
      DataPtr^:=0; Inc(DataPtr); // G
      DataPtr^:=0; Inc(DataPtr); // B
    end;
  end;

  glBindTexture(GL_TEXTURE_2D,Obstacles.TextureHandle);
    glTexSubImage2D(GL_TEXTURE_2D,0,0,0,GridWidth,GridHeight,GL_RGB,GL_FLOAT,
                    ObstacleData);
  glBindTexture(GL_TEXTURE_2D,0);
end;

procedure TCloud.CreateObstacles(Dest:TSurface;Width,Height:Integer);
const
  DrawBorder = True;
  DrawCircle = False;

  BT = 0.9999;
//  BT = 0.7;

  BorderPositions : array[0..9] of Single = (-BT,-BT,BT,-BT,BT,BT,-BT,BT,-BT,-BT);
  Slices = 8;
  TwoPi  = Pi*2;
var
  VAO,VBO   : GLuint;
  Size      : GLsizeiptr;
  Stride    : GLsizeiptr;
  Positions : array[0..Slices*2*3-1] of Single;
  Theta     : Single;
  DTheta    : Single;
  I,S       : Integer;
begin
// write to the destination frame buffer
  glBindFramebuffer(GL_FRAMEBUFFER,Dest.FboHandle);

// setup
  glViewport(0,0,Width,Height);
  glClearColor(0,0,0,0);
  glClear(GL_COLOR_BUFFER_BIT);

  glGenVertexArrays(1,@VAO);
  glBindVertexArray(VAO);

  FillProgram.Active:=True;

  if DrawBorder then begin
    Size:=SizeOf(BorderPositions);
    glGenBuffers(1,@VBO);
    glBindBuffer(GL_ARRAY_BUFFER,VBO);
    glBufferData(GL_ARRAY_BUFFER, size,@BorderPositions,GL_STATIC_DRAW);
    Stride:=2*SizeOf(BorderPositions[0]);
    glEnableVertexAttribArray(PositionSlot);
    glVertexAttribPointer(PositionSlot, 2, GL_FLOAT,ByteBool(GL_FALSE),Stride,nil);
    glDrawArrays(GL_LINE_STRIP, 0, 5);
    glDeleteBuffers(1,@VBO);
  end;

  if DrawCircle then begin
    Theta:=0;
    DTheta:=TwoPi/(Slices-1);
    I:=0;
    for S:=1 to Slices do begin
      Positions[I+0]:=0;
      Positions[I+1]:=0;

      Positions[I+2]:=0.25*Cos(Theta)*Height/Width;
      Positions[I+3]:=0.25*Sin(Theta);
      Theta:=Theta+DTheta;

      Positions[I+4]:=0.25*Cos(Theta)*Height/Width;
      Positions[I+5]:=0.25*Sin(Theta);
      Inc(I,6);
    end;

    Size:=SizeOf(Positions);
    glGenBuffers(1,@VBO);
    glBindBuffer(GL_ARRAY_BUFFER,VBO);
    glBufferData(GL_ARRAY_BUFFER,Size,@Positions,GL_STATIC_DRAW);
    Stride:=2*SizeOf(Positions[0]);

    glEnableVertexAttribArray(PositionSlot);
    glVertexAttribPointer(PositionSlot,2,GL_FLOAT,ByteBool(GL_FALSE),Stride,nil);
    glDrawArrays(GL_TRIANGLES,0,Slices*3);
    glDeleteBuffers(1,@VBO);
  end;

// Cleanup
  FillProgram.Active:=False;
  glDeleteVertexArrays(1,@VAO);
end;

function TCloud.MaskXToObstacleX(MaskX:Integer):Single;
var
  HW : Single;
begin
  HW:=ProjectorMaskW/2;
  Result:=(MaskX-HW)/HW;
end;

function TCloud.MaskYToObstacleY(MaskY:Integer):Single;
var
  HH : Single;
begin
  HH:=ProjectorMaskH/2;
  Result:=(HH-MaskY)/HH;
end;

procedure TCloud.CreateObstaclesFromProjectorMask(Dest:TSurface;Width,Height:Integer);
const
  DrawBorder = True;
  DrawArc    = True;
  ArcPoints  = 64;
  Edge       = 15;
var
  VAO,VBO           : GLuint;
  Size,Stride       : GLsizeiptr;
  Theta,DTheta      : Single;
  I,S               : Integer;
  X1,X2,Y1,Y2       : Single;
  HH,HW,Tx,D1,D2,Vx : Single;
  BorderPositions   : array[0..7] of Single;
  ArcPoint          : array[0..ArcPoints*2-1] of Single;
  ArcX,ArcY,ArcR    : Single;
begin
//Exit;
  HW:=ProjectorMaskW/2;
  HH:=ProjectorMaskH/2;

  with ProjectorMask do begin

// top left
    BorderPositions[0]:=MaskXToObstacleX(TopLeftPt.X-Edge);
    BorderPositions[1]:=MaskYToObstacleY(TopLeftPt.Y-Edge);

// bottom left
    BorderPositions[2]:=MaskXToObstacleX(BottomLeftPt.X-Edge);
    BorderPositions[3]:=MaskYToObstacleY(BottomLeftPt.Y+Edge);

// bottom right
    BorderPositions[4]:=MaskXToObstacleX(BottomRightPt.X+Edge);
    BorderPositions[5]:=MaskYToObstacleY(BottomRightPt.Y+Edge);

// top right
    BorderPositions[6]:=MaskXToObstacleX(TopRightPt.X+Edge);
    BorderPositions[7]:=MaskYToObstacleY(TopRightPt.Y-Edge);
  end;

// write to the destination frame buffer
  glBindFramebuffer(GL_FRAMEBUFFER,Dest.FboHandle);

// setup
  glViewport(0,0,Width,Height);
  glClearColor(0,0,0,0);
  glClear(GL_COLOR_BUFFER_BIT);

  glGenVertexArrays(1,@VAO);
  glBindVertexArray(VAO);

  FillProgram.Active:=True;

  if DrawBorder then begin
    Size:=SizeOf(BorderPositions);
    glGenBuffers(1, @vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, size, @BorderPositions, GL_STATIC_DRAW);
    Stride:=2*SizeOf(BorderPositions[0]);
    glEnableVertexAttribArray(PositionSlot);
    glVertexAttribPointer(PositionSlot, 2, GL_FLOAT,ByteBool(GL_FALSE),Stride,nil);
    glDrawArrays(GL_LINE_STRIP,0,4);
    glDeleteBuffers(1,@VBO);
  end;

  if DrawArc then begin
    Theta:=0;
    DTheta:=Pi/ArcPoints;
    with ProjectorMask do begin
      ArcX:=MaskXToObstacleX(CenterPt.X);
      ArcY:=MaskYToObstacleY(CenterPt.Y);
      ArcR:=(CenterRadius+Edge)/HW;
    end;

    for I:=1 to ArcPoints do begin
      ArcPoint[(I-1)*2+0]:=ArcX+ArcR*Cos(Theta);
      ArcPoint[(I-1)*2+1]:=ArcY+ArcR*Sin(Theta)*Width/Height;
      Theta:=Theta+DTheta;
    end;

    Size:=SizeOf(ArcPoint);
    glGenBuffers(1, @VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, Size, @ArcPoint, GL_STATIC_DRAW);
    Stride:=2*SizeOf(ArcPoint[0]);
    glEnableVertexAttribArray(PositionSlot);
    glVertexAttribPointer(PositionSlot, 2, GL_FLOAT,ByteBool(GL_FALSE),Stride,nil);
    glDrawArrays(GL_LINE_STRIP, 0, ArcPoints);
    glDeleteBuffers(1,@VBO);
  end;

// Cleanup
  FillProgram.Active:=False;
  glDeleteVertexArrays(1,@VAO);
end;


procedure TCloud.SwapSurfaces(Slab:PSlab);
var
  Temp : TSurface;
begin
  Temp:=Slab^.Ping;
  Slab^.Ping:=Slab^.Pong;
  Slab^.Pong:=Temp;
end;

procedure TCloud.ClearSurface(S:TSurface;V:Single);
begin
  glBindFrameBuffer(GL_FRAMEBUFFER,S.FboHandle);
  glClearColor(V,V,V,V);
  glClear(GL_COLOR_BUFFER_BIT);
end;

procedure TCloud.Advect(Velocity,Source,Obstacles,Dest:TSurface;Dissipation:Single);
var
  InverseSize      : GLInt;
  TimeStepLoc      : GLInt;
  DissLoc          : GLInt;
  SourceTexture    : GLInt;
  ObstaclesTexture : GLInt;
begin
  AdvectProgram.Active:=True;

// get the uniform vars
  with AdvectProgram do begin
    InverseSize:=glGetUniformLocation(Handle,'InverseSize');
    TimeStepLoc:=glGetUniformLocation(Handle,'TimeStep');
    DissLoc:=glGetUniformLocation(Handle,'Dissipation');
    SourceTexture:=glGetUniformLocation(Handle,'SourceTexture');
    ObstaclesTexture:=glGetUniformLocation(Handle,'Obstacles');
  end;

// initialize them
  glUniform2F(InverseSize,1.0/GridWidth,1.0/GridHeight);
  glUniform1F(TimeStepLoc,TimeStep);
  glUniform1F(DissLoc,Dissipation);
  glUniform1I(SourceTexture,1);
  glUniform1I(ObstaclesTexture,2);

// we render into the frame buffer
  glBindFrameBuffer(GL_FRAMEBUFFER,Dest.FboHandle);

// source is the velocity texture assigned to texture unit #0
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D,Velocity.TextureHandle);

// the source texture is in texture unit #1
  glActiveTexture(GL_TEXTURE1);
  glBindTexture(GL_TEXTURE_2D,Source.TextureHandle);

// the obstacles are in texture unit #2
  glActiveTexture(GL_TEXTURE2);
  glBindTexture(GL_TEXTURE_2D,Obstacles.TextureHandle);

// process it
  glDrawArrays(GL_TRIANGLE_STRIP,0,4);
  ResetState;
end;

procedure TCloud.Jacobi(Pressure,Divergence,Obstacles,Dest:TSurface);
var
  Alpha       : GLInt;
  InverseBeta : GLInt;
  dSampler    : GLInt;
  oSampler    : GLInt;
begin
  JacobiProgram.Active:=True;

  with JacobiProgram do begin
    Alpha:=glGetUniformLocation(Handle,'Alpha');
    InverseBeta:=glGetUniformLocation(Handle,'InverseBeta');
    dSampler:=glGetUniformLocation(Handle,'Divergence');
    oSampler:=glGetUniformLocation(Handle,'Obstacles');
  end;

  glUniform1f(Alpha,-CellSize*CellSize);
  glUniform1f(InverseBeta, 0.25);
  glUniform1i(dSampler, 1);
  glUniform1i(oSampler, 2);

  glBindFramebuffer(GL_FRAMEBUFFER, dest.FboHandle);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, pressure.TextureHandle);
  glActiveTexture(GL_TEXTURE1);
  glBindTexture(GL_TEXTURE_2D, divergence.TextureHandle);
  glActiveTexture(GL_TEXTURE2);
  glBindTexture(GL_TEXTURE_2D, obstacles.TextureHandle);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  ResetState;
end;

procedure TCloud.SubtractGradient(Velocity,Pressure,Obstacles,Dest:TSurface);
var
  GradientScaleLoc : GLInt;
  HalfCell      : GLInt;
  Sampler       : GLInt;
begin
  SubtractGradientProgram.Active:=True;

  with SubtractGradientProgram do begin
    GradientScaleLoc:=glGetUniformLocation(Handle, 'GradientScale');
    glUniform1f(GradientScaleLoc, GradientScale);

    HalfCell:=glGetUniformLocation(Handle, 'HalfInverseCellSize');
    glUniform1f(HalfCell,0.5/CellSize);
    Sampler:=glGetUniformLocation(Handle, 'Pressure');
    glUniform1i(Sampler, 1);
    sampler:=glGetUniformLocation(Handle, 'Obstacles');
    glUniform1i(Sampler, 2);
  end;

  glBindFramebuffer(GL_FRAMEBUFFER, dest.FboHandle);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, Velocity.TextureHandle);
  glActiveTexture(GL_TEXTURE1);
  glBindTexture(GL_TEXTURE_2D, Pressure.TextureHandle);
  glActiveTexture(GL_TEXTURE2);
  glBindTexture(GL_TEXTURE_2D, Obstacles.TextureHandle);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  ResetState();
end;

procedure TCloud.ComputeDivergence(Velocity,Obstacles,Dest:TSurface);
var
  HalfCell : GLInt;
  Sampler  : GLInt;
begin
  ComputeDivergenceProgram.Active:=True;

  with ComputeDivergenceProgram do begin
    HalfCell:=glGetUniformLocation(Handle, 'HalfInverseCellSize');
    glUniform1f(halfCell, 0.5 / CellSize);
    Sampler:=glGetUniformLocation(Handle, 'Obstacles');
    glUniform1i(sampler, 1);
  end;

  glBindFramebuffer(GL_FRAMEBUFFER, dest.FboHandle);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, Velocity.TextureHandle);
  glActiveTexture(GL_TEXTURE1);
  glBindTexture(GL_TEXTURE_2D, obstacles.TextureHandle);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  ResetState();
end;

procedure TCloud.ApplyImpulse(Dest:TSurface;Position:TVector2;Value,R:Single);
var
  PointLoc     : GLInt;
  RadiusLoc    : GLInt;
  FillColorLoc : GLInt;
begin
  ImpulseProgram.Active:=True;

  with ImpulseProgram do begin
    PointLoc:=glGetUniformLocation(Handle,'Point');
    RadiusLoc:=glGetUniformLocation(Handle,'Radius');
    FillColorLoc:=glGetUniformLocation(Handle,'FillColor');
  end;

  glUniform2f(PointLoc,Position.X,Position.Y);
  glUniform1f(RadiusLoc,R);
  glUniform3f(FillColorLoc,Value,Value,Value);

  glBindFramebuffer(GL_FRAMEBUFFER,Dest.FboHandle);
  glEnable(GL_BLEND);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  ResetState();
end;

procedure TCloud.ApplyOval(Dest:TSurface;Ctr:TPoint2D;W,H,Rz,Value:Single);
var
  X1,X2,Y1,Y2  : Single;
  A,B          : Single;
  CtrPtLoc     : GLInt;
  ALoc,BLoc    : GLInt;
  CosRzLoc     : GLInt;
  SinRzLoc     : GLInt;
  FillColorLoc : GLInt;
begin
  X1:=Ctr.X-W/2;
  X2:=Ctr.X+W/2;
  Y1:=Ctr.Y-H/2;
  Y2:=Ctr.Y+H/2;

  A:=(X2-X1)/2;
  B:=(Y2-Y1)/2;

  OvalProgram.Active:=True;

  with OvalProgram do begin
    CtrPtLoc:=glGetUniformLocation(Handle,'CtrPt');
    ALoc:=glGetUniformLocation(Handle,'A');
    BLoc:=glGetUniformLocation(Handle,'B');
    CosRzLoc:=glGetUniformLocation(Handle,'CosRz');
    SinRzLoc:=glGetUniformLocation(Handle,'SinRz');
    FillColorLoc:=glGetUniformLocation(Handle,'FillColor');
  end;

  glUniform2f(CtrPtLoc,Ctr.X,Ctr.Y);
  glUniform1f(ALoc,A);
  glUniform1f(BLoc,B);
  glUniform1f(CosRzLoc,Cos(Rz));
  glUniform1f(SinRzLoc,Sin(Rz));

  glUniform3f(FillColorLoc,Value,Value,Value);

  glBindFramebuffer(GL_FRAMEBUFFER,Dest.FboHandle);
  glEnable(GL_BLEND);
  glDrawArrays(GL_TRIANGLE_STRIP,0,4);
  ResetState();

  OvalProgram.Active:=False;
end;

procedure TCloud.ApplySubtraction(SubtractedSurface,Dest:TSurface;Value:Single);
var
  SubtractedTextureLoc : GLInt;
  ScaleLoc             : GLInt;
  FillColorLoc         : GLInt;
begin
  SubtractedProgram.Active:=True;

  with SubtractedProgram do begin
    FillColorLoc:=glGetUniformLocation(Handle,'FillColor');
    SubtractedTextureLoc:=glGetUniformLocation(Handle,'SubtractedTexture');
    ScaleLoc:=glGetUniformLocation(Handle,'Scale');
  end;
  glUniform3f(FillColorLoc,Value,Value,Value);
  glUniform1I(SubtractedTextureLoc,0);
  glUniform2f(ScaleLoc,1.0/GridWidth,1.0/GridHeight);

  glBindFramebuffer(GL_FRAMEBUFFER,Dest.FboHandle);
  glEnable(GL_BLEND);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, SubtractedSurface.TextureHandle);

  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  ResetState();
end;

procedure TCloud.ApplySink(Dest:TSurface;Position:TVector2;Value,R:Single);
var
  PointLoc     : GLInt;
  RadiusLoc    : GLInt;
  FillColorLoc : GLInt;
begin
  SinkProgram.Active:=True;

  with SinkProgram do begin
    PointLoc:=glGetUniformLocation(Handle,'Point');
    RadiusLoc:=glGetUniformLocation(Handle,'Radius');
    FillColorLoc:=glGetUniformLocation(Handle,'FillColor');
  end;

  glUniform2f(PointLoc,Position.X,Position.Y);
  glUniform1f(RadiusLoc,R);
  glUniform3f(FillColorLoc,Value,Value,Value);

  glBindFramebuffer(GL_FRAMEBUFFER,Dest.FboHandle);
  glEnable(GL_BLEND);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  ResetState();
end;

procedure TCloud.ApplyBuoyancy(Velocity,Temperature,Density,Dest:TSurface);
var
  TempSampler : GLInt;
  InkSampler  : GLInt;
  AmbTemp     : GLInt;
  TimeStepLoc : GLInt;
  Sigma       : GLInt;
  Kappa       : GLInt;
begin
  BuoyancyProgram.Active:=True;

  with BuoyancyProgram do begin
    TempSampler:=glGetUniformLocation(Handle, 'Temperature');
    InkSampler:=glGetUniformLocation(Handle, 'Density');
    AmbTemp:=glGetUniformLocation(Handle, 'AmbientTemperature');
    TimeStepLoc:=glGetUniformLocation(Handle, 'TimeStep');
    Sigma:=glGetUniformLocation(Handle, 'Sigma');
    Kappa:=glGetUniformLocation(Handle, 'Kappa');
  end;

  glUniform1i(tempSampler, 1);
  glUniform1i(inkSampler, 2);
  glUniform1f(ambTemp, AmbientTemperature);
  glUniform1f(timeStepLoc, TimeStep);
  glUniform1f(sigma, SmokeBuoyancy);
  glUniform1f(kappa, SmokeWeight);

  glBindFramebuffer(GL_FRAMEBUFFER, dest.FboHandle);
  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, velocity.TextureHandle);
  glActiveTexture(GL_TEXTURE1);
  glBindTexture(GL_TEXTURE_2D, temperature.TextureHandle);
  glActiveTexture(GL_TEXTURE2);
  glBindTexture(GL_TEXTURE_2D, density.TextureHandle);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
  ResetState();
end;

function TCloud.SmallCamXToGridX(CamX:Integer):Integer;
begin
  Result:=Round((SmallW-CamX)*(GridWidth/SmallW));
end;

function TCloud.SmallCamYToGridY(CamY:Integer):Integer;
begin
  Result:=Round((SmallH-CamY)*(GridHeight/SmallH));
end;

function TCloud.CamXToGridX(CamX:Integer):Integer;
begin
  Result:=CamX;
//  Result:=GridWidth-1-Round(CamX*(GridWidth/ImageW));
//  Result:=GridWidth-1-Round(CamX*Camera.ImageW/TrackW*(GridWidth/ImageW));

end;

function TCloud.CamYToGridY(CamY:Integer):Integer;
begin
  Result:=CamY;
//  Result:=Round((ImageH-CamY*(MaxImageH/TrackH))*(GridHeight/ImageH));
end;

function TCloud.GridXToCamX(GridX:Integer):Integer;
//var
//  MaxX : Integer;
begin
  Result:=GridX;
{  MaxX:=ImageW-1;

  Result:=Round(MaxX-(GridX*MaxX)/(GridWidth-1));
  if Result<0 then Result:=0
  else if Result>MaxX then Result:=MaxX;}
end;

function TCloud.GridYToCamY(GridY:Integer):Integer;
{var
  MaxY : Integer;}
begin
  Result:=GridY;
{  MaxY:=ImageH-1;

  Result:=Round(MaxY-(GridY*MaxY)/(GridHeight-1));
  if Result<0 then Result:=0
  else if Result>MaxY then Result:=MaxY;}
end;

function TCloud.ViewPortXToGridX(X:Integer):Integer;
begin
  Result:=X shr 1;
end;

function TCloud.ViewPortYToGridY(Y:Integer):Integer;
begin
  Result:=(Projector.Window.Height-Y) shr 1;
end;

procedure TCloud.ApplySmoke(Dest:TSurface;Value:Single);
var
  InverseSize  : GLInt;
  FillColorLoc : GLInt;
begin
  SmokeProgram.Active:=True;

  glColor3F(1,1,1);
  glEnable(GL_TEXTURE_2D);
  glActiveTexture(GL_TEXTURE0);
  SmokeTexture.Apply;

  InverseSize:=glGetUniformLocation(SmokeProgram.Handle,'InverseSize');
  glUniform2F(InverseSize,1.0/GridWidth,1.0/GridHeight);

// set the fill value
  FillColorLoc:=glGetUniformLocation(SmokeProgram.Handle,'FillColor');
  glUniform1f(FillColorLoc,Value);

// bind the surfaces frame buffer
  glBindFramebuffer(GL_FRAMEBUFFER,Dest.FboHandle);

  glEnable(GL_BLEND);
  glBindVertexArray(SmokeVaoHandle);
  glDrawArrays(GL_TRIANGLE_STRIP,0,4);

  SmokeProgram.Active:=False;
  ResetState();
end;

procedure TCloud.SyncWithBlobFinder;
var
  Bmp : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    Bmp.PixelFormat:=pf24Bit;
    Bmp.Width:=Camera.ImageW;
    Bmp.Height:=Camera.ImageH;
    ClearBmp(Bmp,clBlack);
    BlobFinder.DrawBlobStrips(Bmp);
    SmokeTexture.CopyFromBmp(Bmp);
  finally
    Bmp.Free;
  end;

// apply the smoke to the temperature and the density surfaces
  ApplySmoke(Temperature.Ping,ImpulseTemperature);
  ApplySmoke(Density.Ping,ImpulseDensity);
end;

{procedure TCloud.SyncWithBlobFinder;
var
  Bmp : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    Bmp.PixelFormat:=pf24Bit;
    Bmp.Width:=GridWidth;
    Bmp.Height:=GridHeight;
    ClearBmp(Bmp,clBlack);
    BlobFinder.DrawBlobStripsOnProjectorBmp(Bmp);
    SmokeTexture.CopyFromBmp(Bmp);
  finally
    Bmp.Free;
  end;

// apply the smoke to the temperature and the density surfaces
  ApplySmoke(Temperature.Ping,ImpulseTemperature);
  ApplySmoke(Density.Ping,ImpulseDensity);
end;}

procedure TCloud.SyncWithTracker;
var
  Xs,Ys   : Single;
  C,L,I   : Integer;
  DataPtr : PRGBPixel;
begin
  SmokeTexture.Clear;

// draw the chain outlines scaled in the smoke texture
  for C:=1 to Tracker.ShadowCount do begin
    for L:=1 to Tracker.Chain[C].Length do begin
      DataPtr:=PRGBPixel(SmokeTexture.Data);

// find the scaled coordinate of this chain pixel
      with Tracker.Chain[C].Link[L] do begin
        I:=Round((Camera.ImageH-1-Y)*SmokeTexture.W+X);
        Inc(DataPtr,I);
        DataPtr^.R:=255;
        if X>0 then begin
          Dec(DataPtr);
          DataPtr^.R:=255;
        end;
        if X<Camera.ImageW-1 then begin
          Inc(DataPtr,2);
          DataPtr^.R:=255;
        end;
      end;
    end;
  end;

  if SaveSmokeTexture then begin
    SmokeTexture.SaveAsBmp('Smoke.bmp');
    SaveSmokeTexture:=False;
    ImpulseTemperature:=0;
    ImpulseDensity:=0;
  end;

// apply the smoke to the temperature and the density surfaces
  ApplySmoke(Temperature.Ping,ImpulseTemperature);
  ApplySmoke(Density.Ping,ImpulseDensity);
end;

procedure TCloud.Update;
var
  I,F,B,H : Integer;
  Band       : TBand;
  R,R1,R2    : Single;
  BlobPos    : TPoint2D;
  MousePt    : TPoint2D;
  Wd,Ht,Rz   : Single;
  ProjPt     : TPixel;
begin
//  if RedrawObstacles then begin
    DrawObstacles;
//    RedrawObstacles:=False;
//  end;

  glBindVertexArray(SmokeVaoHandle);

// set the viewport to the grid size
  glViewport(0,0,GridWidth,GridHeight);

// advect the velocity
  Advect(Velocity.Ping, Velocity.Ping, Obstacles, Velocity.Pong, VelocityDissipation);
  SwapSurfaces(@Velocity);

// advect the temperature
  Advect(Velocity.Ping, Temperature.Ping, Obstacles, Temperature.Pong, TemperatureDissipation);
  SwapSurfaces(@Temperature);

// advect the density
  Advect(Velocity.Ping, Density.Ping, Obstacles, Density.Pong, DensityDissipation);
  SwapSurfaces(@Density);

// hot pixels rise
  ApplyBuoyancy(Velocity.Ping, Temperature.Ping, Density.Ping, Velocity.Pong);
  SwapSurfaces(@Velocity);

//  SyncWithTracker;
  SyncWithBlobFinder;

  glBindVertexArray(QuadVao);

  ComputeDivergence(Velocity.Ping,Obstacles,Divergence);
  if ClearPressure then ClearSurface(Pressure.Ping,0);

  for I:=1 to JacobiIterations do begin
    Jacobi(Pressure.Ping,Divergence,Obstacles,Pressure.Pong);
    SwapSurfaces(@Pressure);
  end;

  SubtractGradient(Velocity.Ping, Pressure.Ping, Obstacles, Velocity.Pong);
  SwapSurfaces(@Velocity);

//  glBindVertexArray(0);//QuadVao);
end;

procedure TCloud.DrawLine;
begin
  glColor4f(1,1,0,1);
  glBegin(GL_LINES);
    glVertex2f(-100,-100);
    glVertex2f(100,100);
  glEnd;
end;

procedure TCloud.Render;
var
  GLColor     : TGLColor;
  Scale       : GLInt;
  DrawSurface : TSurface;
  R,G,B       : Single;
  FillColor   : GLInt;
begin
// render to the screen
  glViewport(0,0,ViewPortWidth,ViewPortHeight);
  glBindFramebuffer(GL_FRAMEBUFFER,0);

  GLColor:=ColorToGLColor(BackGndColor);
  with GLColor do glClearColor(R,G,B,1);
  glClear(GL_COLOR_BUFFER_BIT);

// bind visualization shader and set up the blend state
  VisualizeProgram.Active:=True;

  with VisualizeProgram do begin
    FillColor:=glGetUniformLocation(Handle,'FillColor');
    Scale:=glGetUniformLocation(Handle,'Scale');
  end;

  R:=(SmokeColor and $0000FF)/255;
  G:=((SmokeColor and $00FF00) shr 8)/255;
  B:=((SmokeColor and $FF0000) shr 16)/255;

  glUniform3F(FillColor,R,G,B);

  glUniform2F(Scale,1.0/ViewportWidth,1.0/ViewportHeight);

  glEnable(GL_BLEND);

  Blend:=True;
  if Blend then glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA)
  else glBlendFunc(GL_SRC_ALPHA,GL_ONE);//_MINUS_SRC_ALPHA);

// Draw ink:
  Case RenderMode of
    rmVelocity    :  DrawSurface:=Velocity.Ping;
    rmPressure    :  DrawSurface:=Pressure.Ping;
    rmTemperature :  DrawSurface:=Temperature.Ping;
    rmDensity     :  DrawSurface:=Density.Ping;
  end;

  glBindTexture(GL_TEXTURE_2D,DrawSurface.TextureHandle);

  glBindVertexArray(QuadVao);
    glDrawArrays(GL_TRIANGLE_STRIP,0,4);

// Draw the obstacles:
    RenderObstacles(FillColor);
  glBindVertexArray(0);

// Disable blending:
  glDisable(GL_BLEND);
  VisualizeProgram.Active:=False;
end;

procedure TCloud.RenderObstacles(FillColor:GLInt);
begin
  glBindTexture(GL_TEXTURE_2D,Obstacles.TextureHandle);
    glUniform3f(FillColor,1,0,0);
    glDrawArrays(GL_TRIANGLE_STRIP,0,4);
  glBindTexture(GL_TEXTURE_2D,0);
end;

procedure TCloud.InvertColors;
begin
//  ColorProgram.Active:=True;
//  RenderTexture;
//  glDrawArrays(GL_TRIANGLE_STRIP,0,4);
//  ColorProgram.Active:=False;
end;

procedure TCloud.RenderTexture;
begin
  glBindTexture(GL_TEXTURE_2D,Texture.Pong.TextureHandle);

  glBegin(GL_QUADS);

// bottom left
    glTexCoord2f(0, 0);
    glVertex2f(0, 0);

// top left
    glTexCoord2f(1, 0);
    glVertex2f(ViewPortWidth, 0);

// top right
    glTexCoord2f(1, 1);
    glVertex2f(ViewPortWidth, ViewPortHeight);

// bottom right
    glTexCoord2f(0, 1);
    glVertex2f(0, ViewPortHeight);
  glEnd();
end;

procedure TCloud.RenderToTexture;
var
  FillColor   : GLInt;
  Scale       : GLInt;
  DrawSurface : TSurface;
  R,G,B       : Single;
begin
// Bind visualization shader and set up blend state
  VisualizeProgram.Active:=True;

  with VisualizeProgram do begin
    FillColor:=glGetUniformLocation(Handle,'FillColor');
    Scale:=glGetUniformLocation(Handle,'Scale');
  end;

  R:= (SmokeColor and $0000FF)/255;
  G:=((SmokeColor and $00FF00) shr 8)/255;
  B:=((SmokeColor and $FF0000) shr 16)/255;

  glUniform3f(FillColor,R,G,B);
  glUniform2f(Scale,1.0/ViewportWidth,1.0/ViewportHeight);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA,GL_ONE);//_MINUS_SRC_ALPHA);

// Set render target to the backbuffer:
  glViewport(0,0,ViewPortWidth,ViewPortHeight);

// render to the texture's frame buffer
  glBindFrameBuffer(GL_FRAMEBUFFER,Texture.Ping.FboHandle);
  SwapSurfaces(@Texture); // the latest will be in pong

{  R:= (BackGndColor and $0000FF)/255;
  G:=((BackGndColor and $00FF00) shr 8)/255;
  B:=((BackGndColor and $FF0000) shr 16)/255;

  glClearColor(R,G,B,1);
  glClear(GL_COLOR_BUFFER_BIT);}

// Draw ink:
  Case RenderMode of
    rmVelocity    :  DrawSurface:=Velocity.Ping;
    rmPressure    :  DrawSurface:=Pressure.Ping;
    rmTemperature :  DrawSurface:=Temperature.Ping;
    rmDensity     :  DrawSurface:=Density.Ping;
  end;

  glBindTexture(GL_TEXTURE_2D,DrawSurface.TextureHandle);
  glDrawArrays(GL_TRIANGLE_STRIP,0,4);

// Disable blending:
  glDisable(GL_BLEND);
  VisualizeProgram.Active:=False;
end;

procedure TCloud.Reset;
begin
  Case RenderMode of
    rmVelocity :
      begin
        ClearSurface(Velocity.Ping,0);
        ClearSurface(Velocity.Pong,0);
      end;
    rmPressure :
      begin
        ClearSurface(Pressure.Ping,0);
        ClearSurface(Pressure.Pong,0);
      end;
    rmDensity :
      begin
        ClearSurface(Density.Ping,0);
        ClearSurface(Density.Pong,0);
      end;
    rmTemperature :
      begin
        ClearSurface(Temperature.Ping,AmbientTemperature);
        ClearSurface(Temperature.Pong,AmbientTemperature);
      end;
  end;
end;

end.




 // ivec2 T = ivec2(gl_FragCoord.xy);

// lookup the subtracted texture at this xy
//  vec4 v = texelFetchOffset(SubtractedTexture, T, 0, ivec2(0, 0));
  float v = texture(SubtractedTexture, gl_FragCoord.xy * Scale).r;
//  if (v.r > 0.5f) {
  if (v > 0.0f) {

    FragColor = vec4(FillColor, 1.0);
  }
  else FragColor = vec4(0);
}

    BorderPositions[0]:=(TopLeftPt.X-HW)/HW;
    BorderPositions[1]:=(HH-TopLeftPt.Y)/HH;

// bottom left
    BorderPositions[2]:=(BottomLeftPt.X-HW)/HW;
    BorderPositions[3:=(HH-BottomLeftPt.Y)/HH;

// bottom right
    BorderPositions[4]:=(BottomRightPt.X-HW)/HW;
    BorderPositions[5]:=(HH-BottomRightPt.Y)/HH;

// top right
    BorderPositions[6]:=(TopRightPt.X-HW)/HW;
    BorderPositions[7]:=(HH-TopRightPt.Y)/HH;
  end;


  {  if Assigned(DestPtr) then begin
    BPR:=GridWidth*3;
    for Y:=0 to GridHeight-1 do begin
      Line:=ObstacleBmp.ScanLine[Y];
      Move(Line^,DestPtr^,BPR);
      Inc(DestPtr,BPR);
    end;
    glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER);
  end;


// we will write to the obstacles texture
  glBindTexture(GL_TEXTURE_2D,Obstacles.TextureHandle);
    glTexImage2D(GL_TEXTURE_2D,0,3,W,H,0,GL_RGB,GL_UNSIGNED_BYTE,Data);

    glTe



// bind the ObstaclePBO
  glBindBuffer(GL_PIXEL_UNPACK_BUFFER_ARB,ObstaclePBO);

  DestPtr:=glMapBuffer(GL_PIXEL_UNPACK_BUFFER_ARB,GL_WRITE_ONLY);
  if Assigned(DestPtr) then begin
    BPR:=GridWidth*3;
    for Y:=0 to GridHeight-1 do begin
      Line:=ObstacleBmp.ScanLine[Y];
      Move(Line^,DestPtr^,BPR);
      Inc(DestPtr,BPR);
    end;
    glUnmapBuffer(GL_PIXEL_UNPACK_BUFFER);
  end;
  glBindTexture(GL_TEXTURE_2D,0);
end;}


