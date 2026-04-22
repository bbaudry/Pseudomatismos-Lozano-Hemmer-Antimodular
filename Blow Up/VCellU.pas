unit VCellU;

interface

uses
  Windows, Classes, Global, Jpeg, Graphics, SysUtils, BlobFind, Bitmap, OpenGL;

type
  TClipMode = (cmNone,cmLeft,cmRight);

  TZoomMode = (zmNone,zmZoomIn,zmZoomOut);

  TVideoCell = class(TObject)
  private

  public
// destination rectangle on the screen - OpenGL coordinates
    X1,Y1,X2,Y2  : Integer;
    Width,Height : Integer;

// texture coordinates
    TX1,TX2 : Single;
    TY1,TY2 : Single;

// cell center mapped to tracking coordinates
    PixelXc : Integer;
    PixelYc : Integer;

// current camera source rectangle
    CamX1,CamY1 : Integer;
    CamX2,CamY2 : Integer;
    CamW,CamH   : Integer;

    FullCamX1,FullCamY1 : Integer;
    FullCamX2,FullCamY2 : Integer;
    FullCamW,FullCamH   : Integer;

// start of zoom camera source rectangle
    StartX1,StartY1 : Integer;
    StartX2,StartY2 : Integer;
    StartW,StartH   : Integer;

// target camera source rectangle
    TgtX1,TgtY1 : Integer;
    TgtX2,TgtY2 : Integer;
    TgtW,TgtH   : Integer;

    IdleX1,IdleY1 : Integer;
    IdleX2,IdleY2 : Integer;
    IdleW,IdleH   : Integer;

    ZoomWindow : TWindow;

// super cell vars
    PartOfSuperCell : Boolean;
    X,Y,W,H         : Integer;
    Placed          : Boolean;

    constructor Create;
    destructor Destroy; override;

    procedure Update;

    procedure InitForTracking;
    procedure ZoomToBlob(var Blob:TBlob);

    procedure DrawOnBmp(Bmp:TBitmap);
    procedure DrawOnCanvas(Canvas:TCanvas);

    procedure OutlineOnBmp(Bmp:TBitmap);
    procedure OutlineOnCanvas(Canvas:TCanvas);

    procedure DrawOnCamBmp(Bmp:TBitmap);
    procedure DrawOnCamBmpAsSuperCell(Bmp:TBitmap);
    procedure HighlightOnCamBmp(Bmp:TBitmap);

    procedure ZoomToIdle;
    procedure JumpToIdle;

    procedure StartZoom;
    procedure UpdateZoom(F:Single);

    procedure JumpToTarget;
    procedure ShiftCam(Dx,Dy:Integer);
    procedure ShiftTgt(Dx,Dy:Integer);
    procedure ZoomToStrips(MidY,Jitter:Integer);
    procedure ZoomToNonStrips(MidY,Jitter:Integer);
    procedure ZoomToWindow(var Window:TWindow);
    procedure ZoomToStripsInBlob(var Blob:TBlob;MidY,Jitter:Integer);
    procedure Zoom;
    procedure Render;
    procedure ZoomToAnything(MidY,Jitter:Integer);
    procedure FindFullCamVars;
    procedure FindZoomWindow(XSize,YSize:Integer);
    procedure FindTextureCoords;
    procedure ZoomToForeGround(MidY,Jitter:Integer);
    procedure ZoomToBackGround(MidY,Jitter:Integer);
  end;

implementation

uses
  BmpUtils, Routines, TilerU, CameraU, CellTrackerU;

constructor TVideoCell.Create;
begin
  inherited;
  CamW:=80;
  CamH:=60;
  CamX1:=0;
  CamX2:=CamX1+CamW-1;
  CamY1:=0;
  CamY2:=CamY1+CamH-1;
end;

destructor TVideoCell.Destroy;
begin
  inherited;
end;

procedure TVideoCell.InitForTracking;
begin
end;

procedure TVideoCell.Update;
begin
end;

procedure TVideoCell.DrawOnBmp(Bmp:TBitmap);
var
  SrcRect  : TRect;
  DestRect : TRect;
begin
  SrcRect:=Rect(CamX1,CamY1,CamX2,CamY2);
  DestRect:=Rect(X1,Y1,X2,Y2);
  Bmp.Canvas.CopyRect(DestRect,Camera.Bmp.Canvas,SrcRect);
//  StretchBlt(Bmp.Canvas.Handle,X1,Y1,Width,Height,Camera.Bmp.Canvas.Handle,
//             CamX1,CamY1,CamW,CamH,SRCCOPY);
end;

procedure TVideoCell.DrawOnCanvas(Canvas:TCanvas);
begin
  StretchBlt(Canvas.Handle,X1,Y1,Width,Height,Camera.Bmp.Canvas.Handle,
             CamX1,CamY1,CamW,CamH,SRCCOPY);
end;

procedure TVideoCell.OutlineOnBmp(Bmp:TBitmap);
begin
  with Bmp.Canvas do begin
    Brush.Style:=bsClear;
    Pen.Color:=clLime;
    Pen.Width:=5;
    Rectangle(X1,Y1,X2,Y2);
  end;
end;

procedure TVideoCell.OutlineOnCanvas(Canvas:TCanvas);
begin
  with Canvas do begin
    Brush.Style:=bsClear;
    Pen.Color:=clLime;
    Pen.Width:=5;
    Rectangle(CamX1,CamY1,CamX2,CamY2);
  end;
end;

procedure TVideoCell.DrawOnCamBmp(Bmp:TBitmap);
begin
  with Bmp.Canvas do begin
    Brush.Style:=bsClear;
    Pen.Color:=clLime;
    Pen.Style:=psDash;
    Rectangle(CamX1,CamY1,CamX2+1,CamY2+1);
    if not (Tiler.Mode in [tmIdle,tmForcedIdle]) then begin
      Pen.Color:=clGreen;
      Pen.Style:=psSolid;
      Rectangle(TgtX1,TgtY1,TgtX2+1,TgtY2+1);
    end;
  end;
end;

procedure TVideoCell.HighlightOnCamBmp(Bmp:TBitmap);
begin
  with Bmp.Canvas do begin
    Brush.Style:=bsClear;
    Pen.Color:=clYellow;
    Pen.Style:=psDash;
    Rectangle(CamX1,CamY1,CamX2+1,CamY2+1);
    if not (Tiler.Mode in [tmIdle,tmForcedIdle]) then begin
      Pen.Style:=psSolid;
      Rectangle(TgtX1,TgtY1,TgtX2+1,TgtY2+1);
    end;
  end;
end;

procedure TVideoCell.DrawOnCamBmpAsSuperCell(Bmp:TBitmap);
begin
  with Bmp.Canvas do begin
    Brush.Style:=bsClear;
    Pen.Color:=clRed;
    Pen.Style:=psDash;
    Rectangle(CamX1,CamY1,CamX2+1,CamY2+1);
    Pen.Color:=clMaroon;
    Pen.Style:=psSolid;
    Rectangle(TgtX1,TgtY1,TgtX2+1,TgtY2+1);
  end;
end;

procedure TVideoCell.StartZoom;
begin
  StartX1:=CamX1;
  StartX2:=CamX2;
  StartY1:=CamY1;
  StartY2:=CamY2;
end;

procedure TVideoCell.ZoomToBlob(var Blob:TBlob);
const
  MinW = 40;
  MaxW = 160;
  MinH = 30;
  MaxH = 120;
var
  W,H : Integer;
  Scale : Single;
begin
// pick a width and height at random
  TgtW:=MinW+Random(MaxW-MinW);
  if TgtW>Blob.Width then TgtW:=Blob.Width;
  if Tiler.KeepAspect then begin
    TgtH:=Round(TgtW*Height/Width);
  end
  else TgtH:=MinH+Random(MaxH-MinH);
  if TgtH>Blob.Height then begin
    TgtH:=Blob.Height;
    if Tiler.KeepAspect then TgtW:=Round(TgtH*Width/Height);
  end;

// find where we want to be
  W:=Blob.XMax-Blob.XMin-TgtW;
  if W<=1 then TgtX1:=Blob.XMin
  else TgtX1:=Blob.XMin+Random(W);
  TgtX2:=TgtX1+TgtW-1;

  if TgtX1<0 then begin
    TgtX1:=0;
    TgtX2:=TgtW-1;
  end;
  if TgtX2>=TrackW then begin
    TgtX2:=TrackW-1;
    TgtX1:=TgtX2-TgtW+1;
  end;

  H:=Blob.YMax-Blob.YMin-TgtH;
  if H<=1 then TgtY1:=Blob.YMin
  else TgtY1:=Blob.YMin+Random(H);
  TgtY2:=TgtY1+TgtH-1;

  if TgtY1<0 then begin
    TgtY1:=0;
    TgtY2:=TgtY1+TgtH;
  end;
  if TgtY2>=TrackH then begin
    TgtY2:=TrackH-1;
    TgtY1:=TgtY2-TgtH;
  end;
  StartZoom;
end;

procedure TVideoCell.UpdateZoom(F:Single);
begin
  CamX1:=StartX1+Round((TgtX1-StartX1)*F);
  CamX2:=StartX2+Round((TgtX2-StartX2)*F);
  CamY1:=StartY1+Round((TgtY1-StartY1)*F);
  CamY2:=StartY2+Round((TgtY2-StartY2)*F);
  CamW:=1+CamX2-CamX1;
  CamH:=1+CamY2-CamY1;
end;

procedure TVideoCell.JumpToTarget;
begin
  CamX1:=TgtX1;
  CamX2:=TgtX2;
  CamY1:=TgtY1;
  CamY2:=TgtY2;
  CamW:=TgtW;
  CamH:=TgtH;
end;

procedure TVideoCell.JumpToIdle;
begin
  CamX1:=IdleX1;
  CamX2:=IdleX2;
  CamY1:=IdleY1;
  CamY2:=IdleY2;
  CamW:=IdleW;
  CamH:=IdleH;
end;

procedure TVideoCell.ZoomToIdle;
begin
  TgtX1:=IdleX1;
  TgtX2:=IdleX2;
  TgtW:=TgtX2-TgtX1+1;

  TgtY1:=IdleY1;
  TgtY2:=IdleY2;
  TgtH:=TgtY2-TgtY1+1;

  StartZoom;
end;

procedure TVideoCell.ShiftCam(Dx,Dy:Integer);
begin
  if (CamX1+Dx)<0 then Dx:=-CamX1;
  if (CamX2+Dx)>=TrackW then Dx:=TrackW-1-CamX2;

  if (CamY1+Dy)<0 then Dy:=-CamY1;
  if (CamY2+Dy)>=TrackH then Dy:=TrackH-1-CamY2;

  CamX1:=CamX1+Dx;
  CamX2:=CamX2+Dx;

  CamY1:=CamY1+Dy;
  CamY2:=CamY2+Dy;
Assert((CamX1>=0) and (CamX2<TrackW) and (CamY1>=0) and (CamY2<TrackH),'');
end;

procedure TVideoCell.ShiftTgt(Dx,Dy:Integer);
begin
  if (TgtX1+Dx)<0 then Dx:=-TgtX1;
  if (TgtX2+Dx)>=TrackW then Dx:=TrackW-1-TgtX2;

  if (TgtY1+Dy)<0 then Dy:=-TgtY1;
  if (TgtY2+Dy)>=TrackH then Dy:=TrackH-1-TgtY2;

  TgtX1:=TgtX1+Dx;
  TgtX2:=TgtX2+Dx;

  TgtY1:=TgtY1+Dy;
  TgtY2:=TgtY2+Dy;
end;

procedure TVideoCell.ZoomToWindow(var Window:TWindow);
begin
  TgtX1:=Window.X1;
  TgtX2:=Window.X2;
  TgtY1:=Window.Y1;
  TgtY2:=Window.Y2;
  TgtW:=TgtX2-TgtX1+1;
  TgtH:=TgtY2-TgtY1+1;
  StartZoom;
end;

procedure TVideoCell.ZoomToStripsInBlob(var Blob:TBlob;MidY,Jitter:Integer);
var
  Count      : Integer;
  Window     : TWindow;
  BestWindow : TWindow;
  F,BestF    : Single;
begin
  Count:=0;
  BestF:=-1;
  repeat
// pick a source window inside the blob
    Window:=Tiler.RandomWindowInBlob(Blob,MidY,Jitter,Width,Height);

// check the coverage
    F:=BlobFinder.CoverageInWindow(Window);
    if F>BestF then begin
      BestWindow:=Window;
      BestF:=F;
    end;
    Inc(Count);
  until (Count>=Tiler.Tenacity) or (BestF>Tiler.MinLevel);
  ZoomToWindow(BestWindow);
end;

procedure TVideoCell.FindTextureCoords;
var
  MaxCamX : Integer;
  MaxCamY : Integer;
begin
  FindFullCamVars;
  MaxCamX:=Camera.ImageW-1;
  MaxCamY:=Camera.ImageH-1;

// find the texture coordinates
// too expensive to flip and mirror the big bmp with the cpu - do it on the gpu
  if (not Camera.LoRes) and Camera.FlipImage then begin
    TY1:=1-FullCamY1/MaxCamY;
    TY2:=1-FullCamY2/MaxCamY;
  end
  else begin
    TY1:=FullCamY1/MaxCamY;
    TY2:=FullCamY2/MaxCamY;
  end;
  if (not Camera.LoRes) and Camera.MirrorImage then begin
    TX1:=1-FullCamX1/MaxCamX;
    TX2:=1-FullCamX2/MaxCamX;
  end
  else begin
    TX1:=FullCamX1/MaxCamX;
    TX2:=FullCamX2/MaxCamX;
  end;
end;

procedure TVideoCell.Render;
begin
  glBegin(GL_QUADS);
    glTexCoord2F(TX1,TY2);
    glVertex2I(X1,Y2);

    glTexCoord2F(TX2,TY2);
    glVertex2I(X2,Y2);

    glTexCoord2F(TX2,TY1);
    glVertex2I(X2,Y1);

    glTexCoord2F(TX1,TY1);
    glVertex2I(X1,Y1);
  glEnd;
end;

procedure TVideoCell.ZoomToStrips(MidY,Jitter:Integer);
var
  Count      : Integer;
  Window     : TWindow;
  BestWindow : TWindow;
  F,BestF    : Single;
begin
  Count:=0;
  repeat
    Window:=Tiler.RandomWindow(MidY,Jitter,Width,Height);

// check the coverage
    F:=BlobFinder.CoverageInWindow(Window);
    if (Count=0) or (F>BestF) then begin
      BestWindow:=Window;
      BestF:=F;
    end;
    Inc(Count);
  until (Count>=Tiler.Tenacity) or (BestF>Tiler.MinLevel);
  ZoomToWindow(BestWindow);
end;

procedure TVideoCell.ZoomToNonStrips(MidY,Jitter:Integer);
var
  Count      : Integer;
  Window     : TWindow;
  BestWindow : TWindow;
  F,BestF    : Single;
begin
  Count:=0;
  repeat
    Window:=Tiler.RandomWindow(MidY,Jitter,Width,Height);

// check the coverage
    F:=BlobFinder.CoverageInWindow(Window);
    if (Count=0) or (F<BestF) then begin
      BestWindow:=Window;
      BestF:=F;
    end;
    Inc(Count);
  until (Count>=Tiler.Tenacity) or (BestF<Tiler.MinLevel);
  ZoomToWindow(BestWindow);
end;

procedure TVideoCell.ZoomToAnything(MidY,Jitter:Integer);
var
  Window     : TWindow;
begin
  Window:=Tiler.RandomWindow(MidY,Jitter,Width,Height);
  ZoomToWindow(Window);
end;

// converts from the tracking plane (640x480) to the video plane (1024x768)
procedure TVideoCell.FindFullCamVars;
begin
  FullCamX1:=Round(CamX1*Camera.ImageW/TrackW);
  FullCamX2:=Round(CamX2*Camera.ImageW/TrackW);
  FullCamY1:=Round(CamY1*Camera.ImageH/TrackH);
  FullCamY2:=Round(CamY2*Camera.ImageH/TrackH);
end;

procedure TVideoCell.Zoom;
begin
  ZoomToWindow(ZoomWindow);
end;

procedure TVideoCell.FindZoomWindow(XSize,YSize:Integer);
begin
  ZoomWindow.X1:=PixelXc-XSize;
  ZoomWindow.X2:=PixelXc+XSize;
  ZoomWindow.Y1:=PixelYc-YSize;
  ZoomWindow.Y2:=PixelYc+YSize;
end;

procedure TVideoCell.ZoomToForeGround(MidY,Jitter:Integer);
var
  Count      : Integer;
  Window     : TWindow;
  CellWindow : TWindow;
  BestWindow : TWindow;
  F,BestF    : Single;
begin
  Count:=0;
  repeat
    Window:=Tiler.RandomWindow(MidY,Jitter,Width,Height);
    CellWindow:=CellTracker.CamWindowToCellWindow(Window);

// check the coverage
    F:=CellTracker.CoverageInCellWindow(CellWindow);
    if (Count=0) or (F>BestF) then begin
      BestWindow:=CellWindow;
      BestF:=F;
    end;
    Inc(Count);
  until (Count>=Tiler.Tenacity) or (BestF>Tiler.MinLevel);
  Window:=CellTracker.CellWindowToCamWindow(BestWindow);
  ZoomToWindow(Window);
end;

procedure TVideoCell.ZoomToBackGround(MidY,Jitter:Integer);
var
  Count      : Integer;
  Window     : TWindow;
  CellWindow : TWindow;
  BestWindow : TWindow;
  F,BestF    : Single;
begin
  Count:=0;
  repeat
    Window:=Tiler.RandomWindow(MidY,Jitter,Width,Height);
    CellWindow:=CellTracker.CamWindowToCellWindow(Window);

// check the coverage
    F:=CellTracker.CoverageInCellWindow(CellWindow);
    if (Count=0) or (F<BestF) then begin
      BestWindow:=CellWindow;
      BestF:=F;
    end;
    Inc(Count);
  until (Count>=Tiler.Tenacity) or (BestF>Tiler.MinLevel);
  Window:=CellTracker.CellWindowToCamWindow(BestWindow);
  ZoomToWindow(Window);
end;

end.


var
  Count      : Integer;
  Window     : TWindow;
  BestWindow : TWindow;
  F,BestF    : Single;
begin
  Count:=0;
  repeat
    Window:=Tiler.RandomWindow(MidY,Jitter,Width,Height);

// check the coverage
    F:=BlobFinder.CoverageInWindow(Window);
    if (Count=0) or (F>BestF) then begin
      BestWindow:=Window;
      BestF:=F;
    end;
    Inc(Count);
  until (Count>=Tiler.Tenacity) or (BestF>Tiler.MinLevel);
  ZoomToWindow(BestWindow);

