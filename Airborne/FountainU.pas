unit FountainU;

interface

uses
  VectorGeometry, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, GLScene, GLObjects,  GLTexture, OpenGL1x, StdCtrls,
  Jpeg, ComCtrls, ExtCtrls, VectorTypes, GLRenderContextInfo, BaseClasses,
  OpenGLTokens, Routines, Global, TextureU, GLDraw, GLSceneU, Math, ProgramU;

const
  MaxParticles = 1000000;

  MaxLines = 40;
  MaxCols  = 48;

  HOME_MODE    = 0;  // sitting at home
  MOVE_MODE    = 1;  // moving about
  WAIT_MODE    = 2;  // waiting for home to become calm
  FADE_IN_MODE = 3;  // fading in

type
  TParticleMode = (pmIdle,pmRising,pmRisen,pmFalling);

  TParticle = record
    CharI : Integer;
  end;
  PParticle = ^TParticle;

  TParticleArray = array[1..MaxParticles] of TParticle;

  TStaticInfo = record
    Position : TPoint2D;
    Spacing  : TPoint2D;
  end;

  TTextChar = record
    Char      : Char;
    StaticPos : TPoint2D;
  end;

  TTextLine = String[MaxCols];
  TTextLines = array[1..MaxLines] of TTextLine;

  TTextPosition = array[1..MaxLines,1..255] of TPoint2D;

  TFountainInfo = record
    Color         : TColor;
    Static        : TStaticInfo;
    MoveThreshold : Single;
    HomeThreshold : Single;
    FadeInTime    : Single;
    SpriteSize    : Integer;
    WaitAlpha     : Single;
    Reserved      : array[1..1020-16-16-4] of Byte;
  end;

  TFountain = class(TObject)
  private
    Particle  : TParticleArray;

    StartTime : DWord;
    LastTime  : DWord;

    ParticleProgram : TProgram;

// buffer objects
    FeedBackBuffer : array[0..1] of GLUInt;
    PositionBuffer : array[0..1] of GLUInt;
    HomePosBuffer  : array[0..1] of GLUInt;
    MSTABuffer     : array[0..1] of GLUInt;
    TextureIBuffer : array[0..1] of GLUInt;

// vertex array
    Vertex : array[0..1] of GLUInt;

    UpdateSub : GLUInt;
    RenderSub : GLUInt;

    Texture : TTexture;

    procedure LoadProgram;
    procedure CreateBuffers;

    procedure LoadText;
    procedure ArrangeText;

    procedure FakeText;    

    function  GetInfo:TFountainInfo;
    procedure SetInfo(NewInfo:TFountainInfo);
    procedure AllocateBuffers;
    procedure InitializeBuffers;


  public
    Particles : Integer;
    DrawIndex : Integer;

    Speed : Single;

    Lines   : Integer;
    Text    : TTextLines;
    TextPos : TTextPosition;
    Static  : TStaticInfo;

    Reset : Boolean;

    MoveThreshold : Single;
    HomeThreshold : Single;
    Color         : TColor;
    FadeInTime    : Single;
    SpriteSize    : Integer;
    WaitAlpha     : Single;

    property Info : TFountainInfo read GetInfo write SetInfo;

    constructor Create;
    destructor Destroy; override;

    procedure PrepareForShow;

    procedure Update;
    procedure Render;
  end;

var
  Fountain : TFountain;

function DefaultFountainInfo:TFountainInfo;

implementation

uses
  Main, CloudU, AlphabetU;

function DefaultFountainInfo:TFountainInfo;
begin
  with Result do begin
    Static.Position.X:=-0.95;
    Static.Position.Y:=+0.20;
    Static.Spacing.X:=0.04;
    Static.Spacing.Y:=0.03;
    Color:=clBlack;
    MoveThreshold:=50000;
    HomeThreshold:=50000;
    FadeInTime:=2.0;
    SpriteSize:=20;
    WaitAlpha:=0.01;
    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

constructor TFountain.Create;
begin
  inherited;

  ParticleProgram:=TProgram.Create;
  Texture:=TTexture.Create;
  HomeThreshold:=50000;

  Randomize;
end;

destructor TFountain.Destroy;
begin
  if Assigned(ParticleProgram) then ParticleProgram.Free;
  if Assigned(Texture) then Texture.Free;

  glDeleteBuffers(2,@PositionBuffer[0]);
  glDeleteBuffers(2,@HomePosBuffer[0]);
  glDeleteBuffers(2,@TextureIBuffer[0]);

  inherited;
end;

function TFountain.GetInfo:TFountainInfo;
begin
  Result.Static:=Static;
  Result.Color:=Color;
  Result.MoveThreshold:=MoveThreshold;
  Result.HomeThreshold:=HomeThreshold;
  Result.FadeInTime:=FadeInTime;
  Result.SpriteSize:=SpriteSize;
  Result.WaitAlpha:=WaitAlpha;

  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TFountain.SetInfo(NewInfo:TFountainInfo);
begin
  Static:=NewInfo.Static;
  Color:=NewInfo.Color;
  MoveThreshold:=NewInfo.MoveThreshold;
  HomeThreshold:=NewInfo.HomeThreshold;
  FadeInTime:=NewInfo.FadeInTime;
  SpriteSize:=NewInfo.SpriteSize;
  WaitAlpha:=NewInfo.WaitAlpha;
end;

procedure TFountain.LoadText;
var
  FileName : String;
  Line     : AnsiString;
  TxtFile  : TextFile;
  I        : Integer;
begin
  Lines:=0;
  FileName:=Path+'Words.txt';
  AssignFile(TxtFile,FileName);
  try
    System.Reset(TxtFile);
    while not EOF(TxtFile) do begin
      Inc(Lines);
      ReadLn(TxtFile,Text[Lines]);
    end;
  finally
    CloseFile(TxtFile);
  end;
end;

procedure TFountain.ArrangeText;
var
  L,C : Integer;
  X,Y : Single;
begin
  Particles:=0;
  Y:=Static.Position.Y;
  for L:=1 to Lines do begin
    X:=Static.Position.X;
    for C:=1 to Length(Text[L]) do begin
      if Text[L,C]<>#32 then begin
        Inc(Particles);
        TextPos[L,C].X:=X;
        TextPos[L,C].Y:=Y;
      end;
      X:=X+Static.Spacing.X;
    end;
    Y:=Y-Static.Spacing.Y;
  end;
end;

procedure TFountain.FakeText;
var
  L,C,I : Integer;
  X,Y   : Single;
begin
  Particles:=0;
  Y:=Static.Position.Y;

  Lines:=MaxLines;
  I:=LoChar;
  for L:=1 to Lines do begin
    X:=Static.Position.X;
    for C:=1 to MaxCols do begin
      Inc(Particles);

      Text[Lines,C]:=Char(I);
      if I<HiChar then Inc(I)
      else I:=LoChar;

      TextPos[L,C].X:=X;
      TextPos[L,C].Y:=Y;

      X:=X+Static.Spacing.X;
    end;
    Y:=Y-Static.Spacing.Y;
  end;
end;

procedure TFountain.PrepareForShow;
var
  P : Integer;
begin
  LoadText;
  ArrangeText;
//  FakeText;

  Speed:=0.1;
  glEnable(GL_TEXTURE_2D_ARRAY);

  LoadProgram;

// get the subroutine indexes inside the shader
  RenderSub:=glGetSubroutineIndex(ParticleProgram.Handle,GL_VERTEX_SHADER,'render');
  UpdateSub:=glGetSubroutineIndex(ParticleProgram.Handle,GL_VERTEX_SHADER,'update');

  CreateBuffers;
  AllocateBuffers;
  InitializeBuffers;

  for P:=1 to MaxParticles do Particle[P].CharI:=LoChar+Random(HiChar-LoChar+1);
end;

procedure TFountain.LoadProgram;
const
  Names = 4;
  OutputName : array[1..Names] of PGLChar =
   ('Position','HomePos','MSTA','TextureI');
begin
// load the particle program - don't link it yet
  ParticleProgram.LoadVertexAndFragmentFiles('Particle.vert','Particle.frag',False);

// set up the varying feedback output names
  glTransformFeedbackVaryings(ParticleProgram.Handle,4,@OutputName[1],
                              GL_SEPARATE_ATTRIBS);
// link the program
  ParticleProgram.Link;
end;

procedure TFountain.CreateBuffers;
begin
// Generate the buffers
  glGenBuffers(2,@PositionBuffer[0]);
  glGenBuffers(2,@HomePosBuffer[0]);
  glGenBuffers(2,@MSTABuffer[0]);
  glGenBuffers(2,@TextureIBuffer[0]);
end;

procedure TFountain.AllocateBuffers;
var
  I,Size : Integer;
begin
// Position, HomePos, and MSTA have 3 components
  Size:=Particles*3*SizeOf(Single);
  for I:=0 to 1 do begin
    glBindBuffer(GL_ARRAY_BUFFER,PositionBuffer[I]);
    glBufferData(GL_ARRAY_BUFFER,Size,nil,GL_DYNAMIC_COPY);

    glBindBuffer(GL_ARRAY_BUFFER,HomePosBuffer[I]);
    glBufferData(GL_ARRAY_BUFFER,Size,nil,GL_DYNAMIC_COPY);

    glBindBuffer(GL_ARRAY_BUFFER,MSTABuffer[I]);
    glBufferData(GL_ARRAY_BUFFER,Size,nil,GL_DYNAMIC_COPY);
  end;

// TextureI has 1 float component
  Size:=Particles*SizeOf(Single);
  for I:=0 to 1 do begin
    glBindBuffer(GL_ARRAY_BUFFER,TextureIBuffer[I]);
    glBufferData(GL_ARRAY_BUFFER,Size,nil,GL_DYNAMIC_COPY);
  end;
  glBindBuffer(GL_ARRAY_BUFFER,0);
end;

procedure TFountain.InitializeBuffers;
var
  I,L,P,C,LL : Integer;
  Size,V     : Integer;
  SingleSize : Integer;
  Time       : Single;
  Data       : array of GLFloat;
  Normalized : ByteBool;
begin
  Size:=Particles*3*SizeOf(Single);

// initialize the position and the home position
  SetLength(Data,Particles*3); // X,Y,Z
  I:=0;
  for L:=1 to Lines do begin
    LL:=Length(Text[L]);
    for C:=1 to LL do if Text[L,C]<>#32 then begin
      Data[I]:=TextPos[L,C].X; Inc(I);
      Data[I]:=TextPos[L,C].Y; Inc(I);
      Data[I]:=0;              Inc(I);
    end;
  end;

  for I:=0 to 1 do begin
    glBindBuffer(GL_ARRAY_BUFFER,PositionBuffer[I]);
    glBufferSubData(GL_ARRAY_BUFFER,0,Size,@Data[0]);
    glBindBuffer(GL_ARRAY_BUFFER,HomePosBuffer[I]);
    glBufferSubData(GL_ARRAY_BUFFER,0,Size,@Data[0]);
  end;

// fill the Mode/StartTime/Alpha buffers
  I:=0;
  for P:=1 to Particles do begin
    Data[I]:=HOME_MODE; Inc(I); // Mode
    Data[I]:=0.0;       Inc(I); // StartTime
    Data[I]:=1.0;       Inc(I); // Alpha
  end;
  for I:=0 to 1 do begin
    glBindBuffer(GL_ARRAY_BUFFER,MSTABuffer[I]);
    glBufferSubData(GL_ARRAY_BUFFER,0,Size,@Data[0]);
  end;

// fill the TextureI buffers
  I:=0;
  for L:=1 to Lines do begin
    LL:=Length(Text[L]);
    for C:=1 to LL do begin
      V:=Ord(AnsiChar(Text[L,C]));
      if V<>32 then begin
        Data[I]:=Ord(Text[L,C])-LoChar;
        Inc(I);
      end;
    end;
  end;

  Size:=Particles*SizeOf(Single);
  for I:=0 to 1 do begin
    glBindBuffer(GL_ARRAY_BUFFER,TextureIBuffer[I]);
    glBufferSubData(GL_ARRAY_BUFFER,0,Size,@Data[0]);
    glBindBuffer(GL_ARRAY_BUFFER,0);
  end;

// create vertex arrays for each set of buffers
  glGenVertexArrays(2,@Vertex[0]);
  Normalized:=False;

  for I:=0 to 1 do begin
    glBindVertexArray(Vertex[I]);
    glBindBuffer(GL_ARRAY_BUFFER,PositionBuffer[I]);
    glVertexAttribPointer(0,3,GL_FLOAT,Normalized,0,nil);
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER,HomePosBuffer[I]);
    glVertexAttribPointer(1,3,GL_FLOAT,Normalized,0,nil);
    glEnableVertexAttribArray(1);

    glBindBuffer(GL_ARRAY_BUFFER,MSTABuffer[I]);
    glVertexAttribPointer(2,3,GL_FLOAT,Normalized,0,nil);
    glEnableVertexAttribArray(2);

    glBindBuffer(GL_ARRAY_BUFFER,TextureIBuffer[I]);
    glVertexAttribPointer(3,1,GL_FLOAT,Normalized,0,nil);
    glEnableVertexAttribArray(3);
  end;

  glBindVertexArray(0);

// generate the feedback buffer objects
  glGenTransformFeedbacks(2,@FeedBackBuffer[0]);

// initialize them
  for I:=0 to 1 do begin
    glBindTransformFeedback(GL_TRANSFORM_FEEDBACK,FeedBackBuffer[I]);

    glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER,0,PositionBuffer[I]);
    glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER,1,HomePosBuffer[I]);
    glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER,2,MSTABuffer[I]);
    glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER,3,TextureIBuffer[I]);
  end;
  glBindTransformFeedback(GL_TRANSFORM_FEEDBACK,0);

  StartTime:=GetTickCount;
  LastTime:=StartTime;

  DrawIndex:=0;
end;

procedure TFountain.Update;
var
  Time      : DWord;
  TimeStep  : Single;
  FrameTime : Single;
  Elapsed   : Single;
  Max       : GLInt;
begin
  glGetIntegerv(GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS,@Max);

  glBindTexture(GL_TEXTURE_2D,0);
  glBindFramebuffer(GL_FRAMEBUFFER,0);

// find the elapsed time
  Time:=GetTickCount;
  Elapsed:=(Time-StartTime)/1000;

//TimeStep:=(Time-LastTime)/1000;
//LastTime:=Time;

  ParticleProgram.Active:=True;

  glUniformSubRoutinesUIV(GL_VERTEX_SHADER,1,@UpdateSub);

// set the render scale
  ParticleProgram.SetUniformF('RenderW',ViewPortWidth);
  ParticleProgram.SetUniformF('RenderH',ViewPortHeight);

// set the time
  ParticleProgram.SetUniformF('Time',Elapsed);

// set the FadeTime
  ParticleProgram.SetUniformF('FadeTime',FadeInTime);

// reset flag
  if Reset then begin
    ParticleProgram.SetUniformI('Reset',1);
    Reset:=False;
  end
  else ParticleProgram.SetUniformI('Reset',0);

// thresholds
  ParticleProgram.SetUniformF('HomeThreshold',HomeThreshold);
  ParticleProgram.SetUniformF('MoveThreshold',MoveThreshold);

// wait alpha
  ParticleProgram.SetUniformF('WaitAlpha',WaitAlpha);

// use texture unit #0 for the velocity texture
  ParticleProgram.SetUniformI('VelocityTexture',0);

// use texture unit #1 for the density texture
  ParticleProgram.SetUniformI('DensityTexture',1);

// Disable rendering
  glEnable(GL_RASTERIZER_DISCARD);

// Bind the feedback object for the buffers
  glBindTransformFeedback(GL_TRANSFORM_FEEDBACK,FeedBackBuffer[DrawIndex]);

// set up the velocity texture
  glActiveTexture(GL_TEXTURE0);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D,Cloud.Velocity.Ping.TextureHandle);

// set up the density texture
  glActiveTexture(GL_TEXTURE1);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D,Cloud.Density.Ping.TextureHandle);

// draw points from input buffer with transform
  glBeginTransformFeedBack(GL_POINTS);
    glBindVertexArray(Vertex[1-DrawIndex]);
      glDrawArrays(GL_POINTS,0,Particles);
    glBindVertexArray(0);
  glEndTransformFeedBack();

  glBindTexture(GL_TEXTURE_2D,0);

// enable rendering again}
  glDisable(GL_RASTERIZER_DISCARD);

  glBindTransformFeedback(GL_TRANSFORM_FEEDBACK,0);

  ParticleProgram.Active:=False;

  glBindTexture(GL_TEXTURE_2D,0);

  glActiveTexture(GL_TEXTURE0);
  glEnable(GL_TEXTURE_2D);
end;

procedure TFountain.Render;
var
  R,G,B : Single;
begin
  ParticleProgram.Active:=True;

  glDisable(GL_LIGHTING);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  glEnable(GL_POINT_SPRITE);
  glEnable(GL_TEXTURE_2D_ARRAY);
  glActiveTexture(GL_TEXTURE0);

  Alphabet.AssertTextureArray;

  ParticleProgram.SetUniformI('ParticleTex',0);

  R:=(Color and  $0000FF)/255;
  G:=((Color and $00FF00) shr 8)/255;
  B:=((Color and $FF0000) shr 16)/255;
  ParticleProgram.SetUniform3F('FillColor',R,G,B);

  glUniformSubroutinesUIV(GL_VERTEX_SHADER,1,@RenderSub);

// draw the sprites from the feedback buffer
  glPointSize(SpriteSize);
  glBindVertexArray(Vertex[DrawIndex]);
    glDrawArrays(GL_POINTS,0,Particles);
  glBindVertexArray(0);

// swap the buffers
  DrawIndex:=(1-DrawIndex);

  ParticleProgram.Active:=False;
end;

initialization

end.






Once data has been placed into a buffer using transform feedback, it can be read back using a function like glGetBufferSubData or by mapping it into the application’s address space using glMapBuffer and reading from it directly. It can also be used as the source of data for subsequent drawing commands.
