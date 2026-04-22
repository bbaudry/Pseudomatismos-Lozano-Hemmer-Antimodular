unit GLDraw;

interface

uses
  OpenGL, Global, Graphics;

type
  TGLColor = record
    R,G,B,A : Single;
  end;

  TGLByteColor = record
    R,G,B : Byte;
  end;

function  GLColorToColor(Color:TGLColor):TColor;
function  ColorToGLColor(Color:TColor):TGLColor;

function  GLByteColorToColor(Color:TGLByteColor):TColor;
function  ColorToGLByteColor(Color:TColor):TGLByteColor;

function  SafeTrunc(Value:Single):Integer;

procedure OutlineCube(XSize,YSize,ZSize:Single);
procedure OutlineRing(Radius,Height:Single;Sides:Integer);

procedure DrawCube(XSize,YSize,ZSize:Single;DrawTop,DrawBtm:Boolean);
procedure DrawRing(Radius,Height:Single;Sides:Integer;Textured:Boolean);

const
  glWhite  : TGLColor = (R:1.0;G:1.0;B:1.0;A:1.0);
  glRed    : TGLColor = (R:1.0;G:0.0;B:0.0;A:1.0);
  glGreen  : TGLColor = (R:0.0;G:1.0;B:0.0;A:1.0);
  glBlue   : TGLColor = (R:0.0;G:0.0;B:1.0;A:1.0);
  glGray   : TGLColor = (R:0.3;G:0.3;B:0.3;A:1.0);
  glYellow : TGLColor = (R:1.0;G:1.0;B:0.0;A:1.0);
  glPurple : TGLColor = (R:1.0;G:0.0;B:1.0;A:1.0);
  glOrange : TGLColor = (R:1.0;G:0.7;B:0.5;A:1.0);

  UpVector   : TPoint3D = (X:0;Y:0;Z:+1);
  DownVector : TPoint3D = (X:0;Y:0;Z:-1);

implementation

function GLColorToColor(Color:TGLColor):TColor;
begin
  Result:=(Round(Color.B*255) shl 16)+(Round(Color.G*255) shl 8)+
           Round(Color.R*255);
end;

function ColorToGLColor(Color:TColor):TGLColor;
begin
  Result.R:=(Color and $FF)/255;
  Result.G:=((Color and $00FF00) shr 8)/255;
  Result.B:=(Color shr 16)/255;
  Result.A:=1;
end;

function GLByteColorToColor(Color:TGLByteColor):TColor;
begin
  Result:=(Color.B shl 16)+(Color.G shl 8)+Color.R;
end;

function ColorToGLByteColor(Color:TColor):TGLByteColor;
begin
  Result.R:=(Color and $FF);
  Result.G:=((Color and $00FF00) shr 8);
  Result.B:=(Color shr 16);
end;

function SafeTrunc(Value:Single):Integer;
begin
  Result:=Round(Value);
  if Value>=0 then begin
    if Result>Value then Dec(Result);
  end
  else begin
    if Result<Value then Inc(Result);
  end;
end;

procedure DrawCube(XSize,YSize,ZSize:Single;DrawTop,DrawBtm:Boolean);
var
  X,Y,Z : Single;
begin
  X:=XSize/2; Y:=YSize/2; Z:=ZSize/2;
  glBegin(GL_QUADS);

    if DrawTop then begin
      glNormal3F(0,0,+1);
      glVertex3F(-X,+Y,+Z);
      glVertex3F(-X,-Y,+Z);
      glVertex3F(+X,-Y,+Z);
      glVertex3F(+X,+Y,+Z);
    end;

    glNormal3F(0,-1,0);
    glVertex3F(-X,-Y,+Z);
    glVertex3F(-X,-Y,-Z);
    glVertex3F(+X,-Y,-Z);
    glVertex3F(+X,-Y,+Z);

    glNormal3F(-1,0,0);
    glVertex3F(-X,+Y,+Z);
    glVertex3F(-X,+Y,-Z);
    glVertex3F(-X,-Y,-Z);
    glVertex3F(-X,-Y,+Z);

    glNormal3F(0,+1,0);
    glVertex3F(+X,+Y,+Z);
    glVertex3F(+X,+Y,-Z);
    glVertex3F(-X,+Y,-Z);
    glVertex3F(-X,+Y,+Z);

    glNormal3F(+1,0,0);
    glVertex3F(+X,-Y,+Z);
    glVertex3F(+X,-Y,-Z);
    glVertex3F(+X,+Y,-Z);
    glVertex3F(+X,+Y,+Z);

    if DrawBtm then begin
      glNormal3F(0,0,-1);
      glVertex3F(+X,+Y,-Z);
      glVertex3F(+X,-Y,-Z);
      glVertex3F(-X,-Y,-Z);
      glVertex3F(-X,+Y,-Z);
    end;
  glEnd;
end;

function CrossProduct(V1,V2:TPoint3D):TPoint3D;
begin
  Result.X:=(V1.Z*V2.Y)-(V1.Y*V2.Z);
  Result.Y:=(V1.X*V2.Z)-(V1.Z*V2.X);
  Result.Z:=(V1.Y*V2.X)-(V1.X*V2.Y);
end;

procedure DrawRing(Radius,Height:Single;Sides:Integer;Textured:Boolean);
var
  X1,X2,Y1,Y2   : Single;
  Angle,Z,S1,S2 : Single;
  I             : Integer;
  V1,V2,Norm    : TPoint3D;
begin
  X1:=Radius; Y1:=0;
  Z:=Height/2;
  glDisable(GL_CULL_FACE);
  glBegin(GL_QUADS);
  V1.X:=0; V1.Y:=0; V1.Z:=1;
  V2.Z:=0;
  for I:=1 to Sides do begin
    Angle:=(I/Sides)*(2*Pi);
    X2:=Radius*Cos(Angle);
    Y2:=Radius*Sin(Angle);
    V2.X:=(X2-X1);
    V2.Y:=(Y2-Y1);
    Norm:=CrossProduct(V2,V1);
    glNormal3F(-Norm.X,-Norm.Y,-Norm.Z);
    if Textured then begin
      S1:=(I-1)/Sides;
      S2:=I/Sides;
      glTexCoord2F(S1,1);
    end;
    glVertex3F(X1,Y1,+Z);
    if Textured then glTexCoord2F(S1,0);
    glVertex3F(X1,Y1,-Z);
    if Textured then glTexCoord2F(S2,0);
    glVertex3F(X2,Y2,-Z);
    if Textured then glTexCoord2F(S2,1);
    glVertex3F(X2,Y2,+Z);
    X1:=X2; Y1:=Y2;
  end;
  glEnd;
  glEnable(GL_CULL_FACE);
end;

procedure OutlineCube(XSize,YSize,ZSize:Single);
var
  X,Y,Z : Single;
begin
  X:=XSize/2; Y:=YSize/2; Z:=ZSize/2;

  glBegin(GL_LINE_STRIP);
    glVertex3F(-X,+Y,+Z);
    glVertex3F(-X,-Y,+Z);
    glVertex3F(+X,-Y,+Z);
    glVertex3F(+X,+Y,+Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3F(-X,-Y,+Z);
    glVertex3F(-X,-Y,-Z);
    glVertex3F(+X,-Y,-Z);
    glVertex3F(+X,-Y,+Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3F(-X,+Y,+Z);
    glVertex3F(-X,+Y,-Z);
    glVertex3F(-X,-Y,-Z);
    glVertex3F(-X,-Y,+Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3F(+X,+Y,+Z);
    glVertex3F(+X,+Y,-Z);
    glVertex3F(-X,+Y,-Z);
    glVertex3F(-X,+Y,+Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3F(+X,-Y,+Z);
    glVertex3F(+X,-Y,-Z);
    glVertex3F(+X,+Y,-Z);
    glVertex3F(+X,+Y,+Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3F(+X,+Y,-Z);
    glVertex3F(+X,-Y,-Z);
    glVertex3F(-X,-Y,-Z);
    glVertex3F(-X,+Y,-Z);
  glEnd;
end;

procedure OutlineRing(Radius,Height:Single;Sides:Integer);
var
  X1,X2,Y1,Y2   : Single;
  Angle,Z,S1,S2 : Single;
  I             : Integer;
  V1,V2,Norm    : TPoint3D;
begin
  X1:=Radius; Y1:=0;
  Z:=Height/2;
  V1.X:=0; V1.Y:=0; V1.Z:=1;
  V2.Z:=0;
  for I:=1 to Sides do begin
    Angle:=(I/Sides)*(2*Pi);
    X2:=Radius*Cos(Angle);
    Y2:=Radius*Sin(Angle);
    V2.X:=(X2-X1);
    V2.Y:=(Y2-Y1);
    glBegin(GL_LINE_LOOP);
      glVertex3F(X1,Y1,+Z);
      glVertex3F(X1,Y1,-Z);
      glVertex3F(X2,Y2,-Z);
      glVertex3F(X2,Y2,+Z);
    glEnd;
    X1:=X2; Y1:=Y2;
  end;
end;

end.


