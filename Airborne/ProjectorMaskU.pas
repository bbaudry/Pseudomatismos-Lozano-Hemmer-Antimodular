unit ProjectorMaskU;

interface

uses
  OpenGL1x, OpenGLTokens, FileUtils, Math, Global, TextureU, Graphics, SysUtils;

const
  ProjectorMaskW = 1052;
  ProjectorMaskH = 1400;

type
  TProjectorMaskInfo = record
    Enabled       : Boolean;
    TopLeftPt     : TPixel;
    TopRightPt    : TPixel;
    BottomLeftPt  : TPixel;
    BottomRightPt : TPixel;
    CenterPt      : TPixel;
    CenterRadius  : Integer;
    Reserved      : array[1..32] of Byte;
  end;

  TProjectorMask = class(TObject)
  private
    Texture : TTexture;

    function  BmpFileName:String;
    procedure InitBmp;

    function  GetInfo:TProjectorMaskInfo;
    procedure SetInfo(NewInfo:TProjectorMaskInfo);

  public
    Bmp : TBitmap;
    Enabled : Boolean;

    TopLeftPt     : TPixel;
    TopRightPt    : TPixel;
    BottomLeftPt  : TPixel;
    BottomRightPt : TPixel;
    CenterPt      : TPixel;
    CenterRadius  : Integer;

    TextureUpdated : Boolean;
//    TrackMask : array[0..MaxImageW-1,0..MaxImageH-1] of Boolean;

    constructor Create;
    destructor Destroy; override;

    property Info:TProjectorMaskInfo read GetInfo write SetInfo;

    procedure LoadBmp;
    procedure SaveBmp;
    procedure DrawBmp;
    procedure FillBmp;
    procedure UpdateTexture;
    procedure Render;
  end;

var
  ProjectorMask : TProjectorMask;

function DefaultProjectorMaskInfo:TProjectorMaskInfo;

implementation

uses
  Routines, BmpUtils, GLDraw, CloudU;

function DefaultProjectorMaskInfo:TProjectorMaskInfo;
const
  Border = 50;
begin
  with Result do begin
    Enabled:=False;

    TopLeftPt.X:=Border;
    TopLeftPt.Y:=Border;

    TopRightPt.X:=MaxImageW-Border;
    TopRightPt.Y:=Border;

    BottomLeftPt.X:=Border;
    BottomLeftPt.Y:=MaxImageH-Border;

    BottomRightPt.X:=MaxImageW-Border;
    BottomRightPt.Y:=MaxImageH-Border;

    CenterPt.X:=MaxImageW div 2;
    CenterPt.Y:=MaxImageH div 2;

    CenterRadius:=CenterPt.X-Border;

    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

constructor TProjectorMask.Create;
begin
  inherited;
  Bmp:=TBitmap.Create;
  InitBmp;
  Texture:=TTexture.Create;
  TextureUpdated:=True;
end;

destructor TProjectorMask.Destroy;
begin
  if Assigned(Bmp) then Bmp.Free;
  if Assigned(Texture) then Texture.Free;
  inherited;
end;

function TProjectorMask.GetInfo: TProjectorMaskInfo;
begin
  Result.Enabled:=Enabled;
  Result.TopLeftPt:=TopLeftPt;
  Result.TopRightPt:=TopRightPt;
  Result.BottomLeftPt:=BottomLeftPt;
  Result.BottomRightPt:=BottomRightPt;
  Result.CenterPt:=CenterPt;
  Result.CenterRadius:=CenterRadius;

  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TProjectorMask.SetInfo(NewInfo: TProjectorMaskInfo);
begin
  Enabled:=NewInfo.Enabled;
  TopLeftPt:=NewInfo.TopLeftPt;
  TopRightPt:=NewInfo.TopRightPt;
  BottomLeftPt:=NewInfo.BottomLeftPt;
  BottomRightPt:=NewInfo.BottomRightPt;
  CenterPt:=NewInfo.CenterPt;
  CenterRadius:=NewInfo.CenterRadius;
  DrawBmp;
  FillBmp;
  SaveBmp;
  Texture.CopyFromBmp(Bmp);
end;

function TProjectorMask.BmpFileName:String;
begin
  Result:=Path+'ProjectorMask.bmp';
end;

procedure TProjectorMask.InitBmp;
begin
  Bmp.Width:=ProjectorMaskW;
  Bmp.Height:=ProjectorMaskH;
  Bmp.PixelFormat:=pf24Bit;
  Bmp.Canvas.Brush.Color:=clBlack;
  Bmp.Canvas.Brush.Style:=bsSolid;
end;

procedure TProjectorMask.LoadBmp;
begin
  if FileExists(BmpFileName) then begin
    Bmp.LoadFromFile(BmpFileName);
    InitBmp;
  end
  else begin
    InitBmp;
    ClearBmp(Bmp,clWhite);
  end;
end;

procedure TProjectorMask.SaveBmp;
begin
  Bmp.SaveToFile(BmpFileName);
end;

procedure TProjectorMask.DrawBmp;
var
  D,X,Y : Integer;
  Rads  : Single;
begin
  ClearBmp(Bmp,Cloud.BackGndColor);
  with Bmp.Canvas do begin
    Pen.Color:=clBlack;
    with TopLeftPt do MoveTo(X,Y);
    with BottomLeftPt do LineTo(X,Y);
    with BottomRightPt do LineTo(X,Y);
    with TopRightPt do LineTo(X,Y);

    for D:=0 to 180 do begin
      Rads:=DegToRad(D);
      X:=CenterPt.X+Round(CenterRadius*Cos(Rads));
      Y:=CenterPt.Y-Round(CenterRadius*Sin(Rads));
      if D=0 then Bmp.Canvas.MoveTo(X,Y)
      else Bmp.Canvas.LineTo(X,Y);
    end;
  end;
end;

procedure TProjectorMask.FillBmp;
const
  FillStyle = fsBorder;
  Border    = 5;
begin
  Bmp.Canvas.Brush.Color:=clBlack;
  Bmp.Canvas.Brush.Style:=bsSolid;

// fill the corners
  Bmp.Canvas.FloodFill(Border,Border,clBlack,FillStyle);
  Bmp.Canvas.FloodFill(Bmp.Width-Border,Border,clBlack,FillStyle);
  Bmp.Canvas.FloodFill(Bmp.Width-Border,Bmp.Height-Border,clBlack,FillStyle);
  Bmp.Canvas.FloodFill(Border,Bmp.Height-Border,clBlack,FillStyle);
end;

procedure TProjectorMask.UpdateTexture;
begin
  Texture.CopyFromBmp(Bmp);
  TextureUpdated:=True;
end;

procedure TProjectorMask.Render;
var
  X,Y : Integer;
begin
  glPushMatrix;
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_LIGHTING);

    if TextureUpdated then begin
      Texture.Store;
      TextureUpdated:=False;
    end
    else Texture.Bind;
    glColor3F(1,1,1);
    gluOrtho2D(0,ViewPortWidth-1,0,ViewPortHeight-1);
    X:=ViewPortWidth shr 1;
    Y:=ViewPortHeight shr 1;
    RenderTexturedRectangleMirrored(X,Y,ViewPortWidth,ViewPortHeight,1);
    glBindTexture(GL_TEXTURE_2D,0);
  glPopMatrix;
end;

end.

-redraw mask with edge          5
-copy track mask                 5
-in cloud - check all 4 oval edges for being inside before applying 5

- merge working code from museum 15
