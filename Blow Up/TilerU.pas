unit TilerU;

interface

uses
  Windows, Classes, Jpeg, Graphics, SysUtils, Dialogs, Forms, Global, VCellU,
  BlobFind, OpenGL, GLDraw;

const
  MaxSuperCells = 10;

type
  TCellArray = array[1..MaxXCells,1..MaxYCells] of TVideoCell;

  TTilerMode =
   (tmIdle,tmZoomingIn,tmZoomedIn,tmZoomingOut,tmForcedZoomingOut,tmForcedIdle,
    tmDelayBeforeZoomOut);

  TBlowUpTarget = (btBestBlob,btBackGnd,btForeGnd,btAnything,btZoom);

  TSuperCell = TVideoCell;
  TSuperCellArray = array[1..MaxSuperCells] of TSuperCell;

  TTilerInfo = record
    XCells1             : Integer;
    YCells1             : Integer;
    GridColor           : TGLByteColor;
    GridSize            : Integer;
    ZoomTime            : DWord;
    TriggerLevel        : Single;
    UntriggerLevel      : Single;
    MinLevel            : Single;
    MinCamSize          : Integer;
    MaxCamSize          : Integer;
    KeepAspect          : Boolean;
    BlowUpTarget        : TBlowUpTarget;
    KeepBlowUpY         : Boolean;
    BlowUpYFraction     : Single;
    Tenacity            : Integer;
    ZoomScale           : Single;
    DynamicGrid         : Boolean;
    GridPeriod          : DWord;
    XCells2,YCells2     : Integer;
    ForceUntrigger      : Boolean;
    ForceUnTriggerDelay : DWord;
    SuperCell1x2Count   : Integer;
    SuperCell2x1Count   : Integer;
    SuperCell2x2Count   : Integer;
    SuperCellScale      : Single;
    UntriggerDelay      : DWord;
    CamIdleY            : Integer;
    Reserved            : array[1..14] of Byte;
  end;

  TTiler = class(TObject)
  private
    function  GetInfo:TTilerInfo;
    procedure SetInfo(NewInfo:TTilerInfo);

    function  RandomColumn:Integer;
    function  RandomRow:Integer;

    procedure FindNextChangeTime;
    procedure CheckForTriggers;
    function  AspectScaledWindowWidth(H,CellW,CellH:Integer):Integer;
    function  AspectScaledWindowHeight(W,CellW,CellH:Integer):Integer;

  public
    Width      : Integer;
    Height     : Integer;
    Cell       : TCellArray;
    XCells     : Integer;
    YCells     : Integer;
    XCells1    : Integer;
    YCells1    : Integer;
    XCells2    : Integer;
    YCells2    : Integer;
    GridColor  : TGLByteColor;
    GridSize   : Integer;
    ZoomTime   : DWord;
    MinCamSize : Integer;
    MaxCamSize : Integer;
    KeepAspect : Boolean;
    Mode       : TTilerMode;
    TestBmp    : TBitmap;

    NextChangeTime  : DWord;
    TriggerLevel    : Single;
    UntriggerLevel  : Single;
    UnTriggerDelay  : DWord;
    MinLevel        : Single;
    TriggerDelay    : DWord;
    ZoomStartTime   : DWord;
    BlowUpTarget    : TBlowUpTarget;
    KeepBlowUpY     : Boolean;
    BlowUpYFraction : Single;
    Tenacity        : Integer;
    ZoomScale       : Single;

    DynamicGrid : Boolean;
    GridPeriod  : DWord;
    TextureData : array[1..MaxImageW*MaxImageH*3] of Byte;

    ForceUntrigger      : Boolean;
    ForceUnTriggerDelay : DWord;

    SuperCell1x2Count : Integer;
    SuperCell2x1Count : Integer;
    SuperCell2x2Count : Integer;

    SuperCell1x2 : TSuperCellArray;
    SuperCell2x1 : TSuperCellArray;
    SuperCell2x2 : TSuperCellArray;

    ShowSuperCells : Boolean;
    SuperCellScale : Single;

    ShowTestPattern : Boolean;
    ShowFullCamera  : Boolean;

    CamIdleY  : Integer;
    CamIdleY1 : Integer;
    CamIdleY2 : Integer;

    property Info : TTilerInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure DrawOnBmp(Bmp:TBitmap);
    procedure DrawGridOnBmp(Bmp:TBitmap);

    procedure DrawOnCanvas(Canvas:TCanvas);
    procedure DrawGridOnCanvas(Canvas:TCanvas);

    procedure InitForTracking;
    procedure PlaceCells;

    procedure Update;
    procedure UpdateZoom;
    procedure FindColAndRowFromPixelXY(var C,R:Integer;X,Y:Integer);

    function CellStr(C,R:Integer):String;
    function CellCount:Integer;

    procedure ZoomToBlob(var Blob:TBlob);
    procedure ZoomToBestBlob;
    procedure ZoomToStrips;
    procedure ZoomToNonStrips;
    procedure ZoomToAnything;
    procedure ZoomOut;
    procedure ShiftCells(Dx,Dy:Integer);
    procedure DrawCellsOnCamBmp(Bmp:TBitmap);
    procedure DrawSuperCellsOnCamBmp(Bmp:TBitmap);
    function  RandomWindowInBlob(var Blob:TBlob;Yc,Jitter,CellW,CellH:Integer):TWindow;
    procedure Render;
    procedure RenderFullCamera;
    procedure RenderGrid;
    procedure ShowCellVars(Lines:TStrings);
    procedure ShowCamera;
    function  RandomWindow(MidY,Jitter,CellW,CellH:Integer):TWindow;
    function  RandomCellWindow(MidY,Jitter,CellW,CellH:Integer):TWindow;
    procedure CopyCameraImageToTextureData;
    procedure Zoom;
    procedure FindZoomWindows;
    procedure InitSuperCells;
    procedure PlaceSuperCells;
    procedure ZoomToForeGround;
    procedure ZoomToBackGround;

    function  SuperCellOk(var SuperCell:TSuperCell):Boolean;
    procedure ClearSuperCells;
    function  AbleToPlaceSuperCell(var SuperCell:TSuperCell):Boolean;
    function  AbleToPlaceSuperCells(var SuperCell:TSuperCellArray;Count:Integer):Boolean;
    procedure RenderSuperCells(var SuperCell:TSuperCellArray;Count:Integer);
    procedure RenderAllSuperCells;
    procedure PlaceSuperCell(var SuperCell:TSuperCell);
    procedure FixSuperCellGrid;
    procedure OutlineSuperCell(var SuperCell:TSuperCell);
    procedure ScaleSuperCells;
    procedure TestCells(Lines:TStrings);
    procedure FindCamIdleVars;
    function  CameraXToTextureX(CamX:Integer):Single;
    function  CameraYToTextureY(CamY:Integer):Single;
    function  Coverage:Single;
end;

function DefaultTilerInfo:TTilerInfo;

var
  Tiler : TTiler;

implementation

uses
  Routines, BmpUtils, TrackerU, CfgFile, CameraU, MemoFrmU, StopWatchU,
  CellTrackerU;

function DefaultTilerInfo:TTilerInfo;
begin
  Result.XCells1:=60;
  Result.YCells1:=40;
  Result.GridColor.R:=0;//255;
  Result.GridColor.G:=0;//255;
  Result.GridColor.B:=0;
  Result.GridSize:=1;//3;
  Result.ZoomTime:=3000;
  Result.TriggerLevel:=0.10;
  Result.UntriggerLevel:=0.02;
  Result.MinLevel:=0.50;
  Result.MinCamSize:=40;
  Result.MaxCamSize:=200;
  Result.KeepAspect:=True;//False;
  Result.BlowUpTarget:=btBestBlob;
  Result.KeepBlowUpY:=True;
  Result.BlowUpYFraction:=0.10;
  Result.Tenacity:=20;
  Result.ZoomScale:=5;
  Result.DynamicGrid:=True;
  Result.GridPeriod:=3000;
  Result.XCells2:=3;
  Result.YCells2:=2;

  Result.ForceUntrigger:=True;
  Result.ForceUnTriggerDelay:=CrowdedUnTriggerDelay;

  Result.SuperCell1x2Count:=1;
  Result.SuperCell2x1Count:=2;
  Result.SuperCell2x2Count:=1;
  Result.SuperCellScale:=3;
  Result.UnTriggerDelay:=3000;
  Result.CamIdleY:=100;

  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

constructor TTiler.Create;
var
  C,R,I : Integer;
begin
  inherited;
  for C:=1 to MaxXCells do begin
    for R:=1 to MaxYCells do Cell[C,R]:=TVideoCell.Create;
  end;
  for I:=1 to MaxSuperCells do SuperCell1x2[I]:=TVideoCell.Create;
  for I:=1 to MaxSuperCells do SuperCell2x1[I]:=TVideoCell.Create;
  for I:=1 to MaxSuperCells do SuperCell2x2[I]:=TVideoCell.Create;
  ShowSuperCells:=False;//True;                     
  TestBmp:=TBitmap.Create;
  TestBmp.PixelFormat:=pf24Bit;
  TestBmp.Width:=MaxImageW;
  TestBmp.Height:=MaxImageH; 
  DrawTestPatternOnBmp(TestBmp,clGray,clYellow,50);
  TestBmp.SaveToFile('c:\Test.bmp');
  ShowTestPattern:=False;                              
  ShowFullCamera:=False;
end;

destructor TTiler.Destroy;
var
  C,R,I : Integer;
begin
  for C:=1 to MaxXCells do for R:=1 to MaxYCells do begin
    if Assigned(Cell[C,R]) then Cell[C,R].Free;
  end;
  for I:=1 to MaxSuperCells do begin
    if Assigned(SuperCell1x2[I]) then SuperCell1x2[I].Free;
    if Assigned(SuperCell2x1[I]) then SuperCell2x1[I].Free;
    if Assigned(SuperCell2x2[I]) then SuperCell2x2[I].Free;
  end;
  if Assigned(TestBmp) then TestBmp.Free;
  inherited;
end;

function TTiler.GetInfo:TTilerInfo;
begin
  Result.XCells1:=XCells1;
  Result.YCells1:=YCells1;
  Result.GridColor:=GridColor;
  Result.GridSize:=GridSize;
  Result.KeepAspect:=KeepAspect;
  Result.ZoomTime:=ZoomTime;
  Result.TriggerLevel:=TriggerLevel;
  Result.UntriggerLevel:=UntriggerLevel;
  Result.MinLevel:=MinLevel;
  Result.MinCamSize:=MinCamSize;
  Result.MaxCamSize:=MaxCamSize;
  Result.KeepAspect:=KeepAspect;
  Result.BlowUpTarget:=BlowUpTarget;
  Result.KeepBlowUpY:=KeepBlowUpY;
  Result.BlowUpYFraction:=BlowUpYFraction;
  Result.Tenacity:=Tenacity;
  Result.ZoomScale:=ZoomScale;
  Result.DynamicGrid:=DynamicGrid;
  Result.GridPeriod:=GridPeriod;
  Result.XCells2:=XCells2;
  Result.YCells2:=YCells2;
  Result.ForceUntrigger:=ForceUntrigger;
  Result.ForceUnTriggerDelay:=ForceUnTriggerDelay;
  Result.SuperCell2x1Count:=SuperCell2x1Count;
  Result.SuperCell1x2Count:=SuperCell1x2Count;
  Result.SuperCell2x2Count:=SuperCell2x2Count;
  Result.SuperCellScale:=SuperCellScale;
  Result.UnTriggerDelay:=UnTriggerDelay;
  Result.CamIdleY:=CamIdleY;

  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TTiler.SetInfo(NewInfo:TTilerInfo);
begin
  XCells1:=NewInfo.XCells1;
  YCells1:=NewInfo.YCells1;
  GridColor:=NewInfo.GridColor;
  GridSize:=NewInfo.GridSize;
  ZoomTime:=NewInfo.ZoomTime;
  TriggerLevel:=NewInfo.TriggerLevel;
  UntriggerLevel:=NewInfo.UntriggerLevel;
  MinLevel:=NewInfo.MinLevel;
  MinCamSize:=NewInfo.MinCamSize;
  MaxCamSize:=NewInfo.MaxCamSize;
  KeepAspect:=NewInfo.KeepAspect;
  BlowUpTarget:=NewInfo.BlowUpTarget;
  KeepBlowUpY:=NewInfo.KeepBlowUpY;
  BlowUpYFraction:=NewInfo.BlowUpYFraction;
  Tenacity:=NewInfo.Tenacity;
  ZoomScale:=NewInfo.ZoomScale;
  DynamicGrid:=NewInfo.DynamicGrid;
  GridPeriod:=NewInfo.GridPeriod;
  XCells2:=NewInfo.XCells2;
  YCells2:=NewInfo.YCells2;

  ForceUntrigger:=NewInfo.ForceUntrigger;
  ForceUnTriggerDelay:=NewInfo.ForceUnTriggerDelay;
  SuperCell2x1Count:=NewInfo.SuperCell2x1Count;
  SuperCell1x2Count:=NewInfo.SuperCell1x2Count;
  SuperCell2x2Count:=NewInfo.SuperCell2x2Count;
  SuperCellScale:=NewInfo.SuperCellScale;
  if SuperCellScale<1 then SuperCellScale:=1;
  UnTriggerDelay:=NewInfo.UnTriggerDelay;
  CamIdleY:=NewInfo.CamIdleY;
end;

procedure TTiler.PlaceCells;
var
  X,X1,X2,Y,Y1,Y2 : Integer;
  IdleX1,IdleX2   : Integer;
  IdleY1,IdleY2   : Integer;
  CellW,CellH     : Single;
  CamW,CamH       : Single;
  PixelXc,PixelYc : Integer;
  ScaledH         : Integer;
begin
  CellW:=Width/XCells;
  CellH:=Height/YCells;
  CamW:=TrackW/XCells;
  ScaledH:=Round(TrackW*Screen.Height/Screen.Width);
  CamH:=ScaledH/YCells;

  for X:=1 to XCells do begin
    if X=1 then X1:=0
    else X1:=X2+1;
    if X=XCells then X2:=Width-1
    else X2:=Round(X*CellW)-1;

    if X=1 then IdleX1:=0
    else IdleX1:=IdleX2+1;
    if X=XCells then IdleX2:=TrackW-1
    else IdleX2:=Round(X*CamW)-1;

    PixelXc:=Round((X-0.5)*CamW);

    for Y:=1 to YCells do begin
      Cell[X,Y].X1:=X1;         // X1,Y1,X2,Y2,Width,Height = screen coords
      Cell[X,Y].X2:=X2+1;
      Cell[X,Y].IdleX1:=IdleX1; // IdleX1,IdleY1,IdleX2,IdleY2 = zoomed in idle coords
      Cell[X,Y].IdleX2:=IdleX2;
      Cell[X,Y].PixelXc:=PixelXc;
    end;
  end;

  for Y:=1 to YCells do begin
    if Y=1 then Y1:=Height-1
    else Y1:=Y2-1;
    if Y=YCells then Y2:=0
    else Y2:=Height-Round(Y*CellH);

    if Y=1 then IdleY1:=CamIdleY1
    else IdleY1:=IdleY2+1;
    if Y=YCells then IdleY2:=CamIdleY2
    else IdleY2:=CamIdleY1+Round(Y*CamH)-1;

    PixelYc:=CamIdleY1+Round((Y-0.5)*CamH);

    for X:=1 to XCells do begin
      Cell[X,Y].Y1:=Y1;
      Cell[X,Y].Y2:=Y2-1;
      Cell[X,Y].IdleY1:=IdleY1;
      Cell[X,Y].IdleY2:=IdleY2;
      Cell[X,Y].PixelYc:=PixelYc;
    end;
  end;

  for Y:=1 to YCells do for X:=1 to XCells do begin
    Cell[X,Y].PartOfSuperCell:=False;
    Cell[X,Y].Width:=(Cell[X,Y].X2-Cell[X,Y].X1)+1;
    Cell[X,Y].Height:=(Cell[X,Y].Y1-Cell[X,Y].Y2)+1;

    Cell[X,Y].IdleX1:=(Cell[X,Y].IdleX1+Cell[X,Y].IdleX2) div 2;
    Cell[X,Y].IdleX2:=Cell[X,Y].IdleX1+1;
    Cell[X,Y].IdleY1:=(Cell[X,Y].IdleY1+Cell[X,Y].IdleY2) div 2;
    Cell[X,Y].IdleY2:=Cell[X,Y].IdleY1;


    Cell[X,Y].IdleW:=(Cell[X,Y].IdleX2-Cell[X,Y].IdleX1)+1;
    Cell[X,Y].IdleH:=(Cell[X,Y].IdleY2-Cell[X,Y].IdleY1)+1;
    Cell[X,Y].JumpToIdle;
  end;
  FindZoomWindows;
end;

// since the camera is 1024x768 and the screen is 1920x1080, if we want no
// distortion we need a window into the camera that cuts some of the Y pixels
// off - the part of the camera we see is X=0..ImageW-1, CamIdleY1..CamIdleY2
procedure TTiler.FindCamIdleVars;
var
  CamIdleH : Integer;
  ScaledY  : Integer;
begin
  CamIdleH:=Round(TrackW*Height/Width);
  ScaledY:=Round(CamIdleY*TrackH/Camera.ImageH);
  if (ScaledY+CamIdleH)>TrackH then begin
    CamIdleY1:=TrackH-CamIdleH;
    CamIdleY2:=TrackH-1;
  end
  else begin
    CamIdleY1:=ScaledY;
    CamIdleY2:=ScaledY+CamIdleH-1;
  end;
end;

procedure TTiler.InitForTracking;
begin
  Mode:=tmIdle;
  FindCamIdleVars;
  XCells:=XCells1;
  YCells:=YCells1;
  PlaceCells;
  InitSuperCells;
  FindNextChangeTime;
  ZoomStartTime:=GetTickCount;
end;

procedure TTiler.DrawGridOnBmp(Bmp:TBitmap);
var
  I : Integer;
begin
  with Bmp.Canvas do begin
    Pen.Width:=GridSize;
    Pen.Color:=GLByteColorToColor(GridColor);
    for I:=2 to YCells do begin
      MoveTo(0,Cell[1,I].Y1);
      LineTo(Bmp.Width,Cell[1,I].Y1);
    end;
    for I:=2 to XCells do begin
      MoveTo(Cell[I,1].X1,0);
      LineTo(Cell[I,1].X1,Bmp.Height);
    end;
  end;
end;

procedure TTiler.DrawOnBmp(Bmp:TBitmap);
var
  X,Y : Integer;
begin
  if Mode=tmIdle then begin
    Bmp.Canvas.StretchDraw(Rect(0,0,Bmp.Width,Bmp.Height),Camera.Bmp);
  end
  else begin
    for X:=1 to XCells do for Y:=1 to YCells do Cell[X,Y].DrawOnBmp(Bmp);
    if GridSize>0 then DrawGridOnBmp(Bmp);
  end;
end;

procedure TTiler.DrawGridOnCanvas(Canvas:TCanvas);
var
  I : Integer;
begin
  with Canvas do begin
    Pen.Width:=GridSize;
    Pen.Color:=GLByteColorToColor(GridColor);
    for I:=2 to YCells do begin
      MoveTo(0,Cell[1,I].Y1);
      LineTo(Width,Cell[1,I].Y1);
    end;
    for I:=2 to XCells do begin
      MoveTo(Cell[I,1].X1,0);
      LineTo(Cell[I,1].X1,Height);
    end;
  end;
end;

procedure TTiler.DrawOnCanvas(Canvas:TCanvas);
var
  X,Y : Integer;
begin
  for X:=1 to XCells do for Y:=1 to YCells do Cell[X,Y].DrawOnCanvas(Canvas);
  if GridSize>0 then DrawGridOnCanvas(Canvas);
end;

procedure TTiler.UpdateZoom;
var
  C,R,I : Integer;
  Time : DWord;
  F    : Single;
begin
  if Mode in [tmZoomingIn,tmZoomingOut,tmForcedZoomingOut] then begin
    Time:=GetTickCount;
    F:=(Time-ZoomStartTime)/Tiler.ZoomTime;
    if F>=1 then begin
      Case Mode of
        tmZoomingIn : Mode:=tmZoomedIn;
        tmZoomingOut :
          begin
            Mode:=tmIdle;
            ClearSuperCells;
          end;
        tmForcedZoomingOut :
          begin
            Mode:=tmForcedIdle;
            ClearSuperCells;
          end;
      end;
      ZoomStartTime:=GetTickCount;
      F:=1;
    end;

// update the zoom on the cells
    for C:=1 to XCells do for R:=1 to YCells do begin
      if not Cell[C,R].PartOfSuperCell then Cell[C,R].UpdateZoom(F);
    end;

// do the super cells too
    for I:=1 to SuperCell1x2Count do begin
      with SuperCell1x2[I] do if Placed then UpdateZoom(F);
    end;
    for I:=1 to SuperCell2x1Count do begin
      with SuperCell2x1[I] do if Placed then UpdateZoom(F);
    end;
    for I:=1 to SuperCell2x2Count do begin
      with SuperCell2x2[I] do if Placed then UpdateZoom(F);
    end;
  end;
end;

procedure TTiler.FindNextChangeTime;
begin
  Case Mode of
    tmZoomingIn : NextChangeTime:=GetTickCount+MinCollapseTime+Random(MaxCollapseTime-MinCollapseTime);
    else NextChangeTime:=GetTickCount+MinBlowUpTime+Random(MaxBlowUpTime-MinBlowUpTime);
  end;
end;

function TTiler.Coverage:Single;
begin
  Case TrackMethod of
    tmBlobs     : Result:=BlobFinder.CoverFraction;
    tmSegmenter : Result:=CellTracker.CoverFraction;
  end;
end;

procedure TTiler.CheckForTriggers;
var
  WasIdle : Boolean;
  Fraction : Single;
begin
  Case Mode of
    tmIdle,tmZoomingOut :
      if Coverage>=TriggerLevel then begin
        WasIdle:=(Mode=tmIdle);
        Case BlowUpTarget of
          btBestBlob :
            if TrackMethod=tmBlobs then ZoomToBestBlob
            else ZoomToForeGround;
          btForeGnd  :
            if TrackMethod=tmBlobs then ZoomToStrips
            else ZoomToForeGround;
          btBackGnd  :
            if TrackMethod=tmBlobs then ZoomToNonStrips
            else ZoomToBackGround;
          btAnything : ZoomToAnything;
          btZoom     : Zoom;
        end;
        if WasIdle then begin
          ScaleSuperCells;
          PlaceSuperCells;
        end;
      end;

    tmZoomingIn :if Coverage<=UnTriggerLevel then ZoomOut;

    tmZoomedIn :
      if Coverage<UnTriggerLevel then begin
        if UnTriggerDelay=0 then ZoomOut
        else begin
          ZoomStartTime:=GetTickCount;
          Mode:=tmDelayBeforeZoomOut;
        end;
      end
      else if ForceUnTrigger and ((GetTickCount-ZoomStartTime)>=ForceUnTriggerDelay)
      then begin
        ZoomOut;
        Mode:=tmForcedZoomingOut;
      end;

    tmDelayBeforeZoomOut :
      if Coverage>=TriggerLevel then begin
        Mode:=tmZoomedIn;
      end
      else if (GetTickCount-ZoomStartTime)>=UnTriggerDelay then ZoomOut;
  end;
end;

procedure TTiler.Update;
var
  Time : DWord;
begin
// check for BlowUp / Collapse triggers
  CheckForTriggers;
  UpdateZoom;

  if Mode=tmForcedIdle then begin
    if (GetTickCount-ZoomStartTime)>=3000 then Mode:=tmIdle;
  end;

  if DynamicGrid and (Mode=tmIdle) then begin
    Time:=GetTickCount;
    if (Time>=ZoomStartTime) and ((Time-ZoomStartTime)>=GridPeriod) then begin
      XCells:=RandomInteger(XCells1,XCells2);
      YCells:=RandomInteger(YCells1,YCells2);
      ZoomStartTime:=Time+GridPeriod;
      PlaceCells;
    end;
  end;
end;

procedure TTiler.FindColAndRowFromPixelXY(var C,R:Integer;X,Y:Integer);
begin
{  C:=1+(X div CellW);
  if C>XCells then C:=XCells;

  R:=1+(Y div CellH);
  if R>YCells then R:=YCells;}
end;

function TTiler.RandomColumn:Integer;
begin
  Result:=1+Random(XCells);
end;

function TTiler.RandomRow:Integer;
begin
  Result:=1+Random(YCells);
end;

function TTiler.CellCount:Integer;
begin
  Result:=XCells*YCells;
end;

function TTiler.CellStr(C,R:Integer):String;
begin
  Result:='Cell['+IntToStr(C)+','+IntToStr(R)+']';
end;

procedure TTiler.ZoomOut;
var
  C,R,I : Integer;
begin
  for R:=1 to YCells do for C:=1 to XCells do begin
    Cell[C,R].ZoomToIdle;
  end;
  for I:=1 to SuperCell1x2Count do SuperCell1x2[I].ZoomToIdle;
  for I:=1 to SuperCell2x1Count do SuperCell2x1[I].ZoomToIdle;
  for I:=1 to SuperCell2x2Count do SuperCell2x2[I].ZoomToIdle;
  Mode:=tmZoomingOut;
  ZoomStartTime:=GetTickCount;
end;

procedure TTiler.ShiftCells(Dx,Dy:Integer);
var
  C,R,I : Integer;
begin
  for R:=1 to YCells do for C:=1 to XCells do begin
    Case Mode of
      tmIdle               : ;
      tmZoomingIn          : Cell[C,R].ShiftTgt(Dx,Dy);
      tmZoomedIn           : Cell[C,R].ShiftCam(Dx,Dy);
      tmZoomingOut         : ;
      tmDelayBeforeZoomOut : Cell[C,R].ShiftCam(Dx,Dy);
    end;
  end;
  for I:=1 to SuperCell1x2Count do begin
    if Mode=tmZoomingIn then SuperCell1x2[I].ShiftTgt(Dx,Dy)
    else if Mode in [tmZoomedIn,tmDelayBeforeZoomOut] then SuperCell1x2[I].ShiftCam(Dx,Dy);
  end;
  for I:=1 to SuperCell2x1Count do begin
    if Mode=tmZoomingIn then SuperCell2x1[I].ShiftTgt(Dx,Dy)
    else if Mode in [tmZoomedIn,tmDelayBeforeZoomOut] then SuperCell2x1[I].ShiftCam(Dx,Dy);
  end;
  for I:=1 to SuperCell2x2Count do begin
    if Mode=tmZoomingIn then SuperCell2x2[I].ShiftTgt(Dx,Dy)
    else if Mode in [tmZoomedIn,tmDelayBeforeZoomOut] then SuperCell2x2[I].ShiftCam(Dx,Dy);
  end;
end;

procedure TTiler.ZoomToBlob(var Blob:TBlob);
var
  C,R : Integer;
begin
  for R:=1 to YCells do for C:=1 to XCells do begin
    Cell[C,R].ZoomToBlob(Blob);
  end;
  Mode:=tmZoomingIn;
  ZoomStartTime:=GetTickCount;
end;

procedure TTiler.ZoomToAnything;
var
  C,R,MidY : Integer;
  Jitter   : Integer;
begin
  Jitter:=Round(TrackH*BlowUpYFraction);
  for R:=1 to YCells do begin
    MidY:=Cell[1,R].PixelYc;
    for C:=1 to XCells do begin
      Cell[C,R].ZoomToAnything(MidY,Jitter);
    end;
    Mode:=tmZoomingIn;
    ZoomStartTime:=GetTickCount;
  end;
end;

procedure TTiler.ZoomToBestBlob;
var
  C,R,B,MidY : Integer;
  Jitter     : Integer;
begin
  B:=BlobFinder.BestBlobForTracker;
  if B>0 then begin
    Jitter:=Round(BlobFinder.Blob[B].Height*BlowUpYFraction);
    for R:=1 to YCells do begin
      if KeepBlowUpY then begin

// find the BlobY corresponding to this row
        with BlobFinder do begin
          MidY:=Round(Blob[B].YMin+Blob[B].Height*Cell[1,R].PixelYc/TrackH);
        end;
      end;
      for C:=1 to XCells do begin
        Cell[C,R].ZoomToStripsInBlob(BlobFinder.Blob[B],MidY,Jitter);
      end;
    end;
    Mode:=tmZoomingIn;
    ZoomStartTime:=GetTickCount;
  end;
end;

procedure TTiler.ZoomToStrips;
var
  C,R,MidY : Integer;
  Jitter   : Integer;
begin
  Jitter:=Round(TrackH*BlowUpYFraction);
  for R:=1 to YCells do begin
    MidY:=Cell[1,R].PixelYc;
    for C:=1 to XCells do begin
      Cell[C,R].ZoomToStrips(MidY,Jitter);
    end;
  end;
  Mode:=tmZoomingIn;
  ZoomStartTime:=GetTickCount;
end;

procedure TTiler.ZoomToNonStrips;
var
  C,R,MidY : Integer;
  Jitter   : Integer;
begin
  Jitter:=Round(TrackH*BlowUpYFraction);
  for R:=1 to YCells do begin
    MidY:=Cell[1,R].PixelYc;
    for C:=1 to XCells do begin
      Cell[C,R].ZoomToNonStrips(MidY,Jitter);
    end;
  end;
  Mode:=tmZoomingIn;
  ZoomStartTime:=GetTickCount;
end;

procedure TTiler.DrawCellsOnCamBmp(Bmp:TBitmap);
var
  C,R : Integer;
begin
  for R:=1 to YCells do for C:=1 to XCells do begin
    if (Mode in [tmIdle,tmForcedIdle]) or (not Cell[C,R].PartOfSuperCell) then
    begin
      Cell[C,R].DrawOnCamBmp(Bmp);
    end;
  end;
end;

procedure TTiler.DrawSuperCellsOnCamBmp(Bmp:TBitmap);
var
  I : Integer;
begin
  if Mode in [tmIdle,tmForcedIdle] then Exit;
  for I:=1 to SuperCell1x2Count do SuperCell1x2[I].DrawOnCamBmpAsSuperCell(Bmp);
  for I:=1 to SuperCell2x1Count do SuperCell2x1[I].DrawOnCamBmpAsSuperCell(Bmp);
  for I:=1 to SuperCell2x2Count do SuperCell2x2[I].DrawOnCamBmpAsSuperCell(Bmp);
end;

function TTiler.RandomWindowInBlob(var Blob:TBlob;Yc,Jitter,CellW,CellH:Integer):TWindow;
var
  W,H,Gap : Integer;
begin
// blob is too small for even the smallest
  if Blob.Width<MinCamSize then W:=MinCamSize

// blob can fit some
  else if Blob.Width<MaxCamSize then begin
    Gap:=Blob.Width-MinCamSize;
    W:=MinCamSize+Random(Gap);
  end

// blob cam fit all
  else begin
    W:=MinCamSize+Random(MaxCamSize-MinCamSize);
  end;
  if W>TrackW then W:=TrackW;

// height
  if KeepAspect then begin
    H:=AspectScaledWindowHeight(W,CellW,CellH)
  end
  else begin

// blob is too small for even the smallest
    if Blob.Height<MinCamSize then H:=MinCamSize

// blob can fit some
    else if Blob.Height<MaxCamSize then begin
      Gap:=Blob.Height-MinCamSize;
      H:=MinCamSize+Random(Gap);
    end

// blob cam fit all
    else begin
      H:=MinCamSize+Random(MaxCamSize-MinCamSize);
    end;
  end;
  if H>TrackH then begin
    H:=TrackH;
    if KeepAspect then begin
      W:=AspectScaledWindowWidth(H,CellW,CellH);
    end;
  end;

// find X1
  Gap:=Blob.Width-W;
  Result.X1:=RandomInteger(Blob.XMin,Blob.XMin+Gap);
  if Result.X1<0 then Result.X1:=0;

// find X2
  Result.X2:=Result.X1+W-1;
  if Result.X2>=TrackW then Result.X2:=TrackW-1;

// find Y1
  if KeepBlowUpY then begin
    Result.Y1:=Round(Yc-H/2-Jitter/2+Random(Jitter));
  end
  else begin
    Gap:=Blob.Height-H;
    Result.Y1:=RandomInteger(Blob.YMin,Blob.YMin+Gap);
  end;

// clip it
  if Result.Y1<0 then Result.Y1:=0;

// find Y2
  Result.Y2:=Result.Y1+H-1;
  if Result.Y2>=TrackH then begin
    Result.Y2:=TrackH-1;
    Result.Y1:=Result.Y2-(H-1);
  end;
end;

function TTiler.AspectScaledWindowWidth(H,CellW,CellH:Integer):Integer;
begin
  Result:=Round(H*CellW/CellH);
end;

function TTiler.AspectScaledWindowHeight(W,CellW,CellH:Integer):Integer;
begin
  Result:=Round(W*CellH/CellW);
end;

function TTiler.RandomWindow(MidY,Jitter,CellW,CellH:Integer):TWindow;
var
  W,H : Integer;
begin
  W:=MinCamSize+Random(MaxCamSize-MinCamSize);

// height
  if KeepAspect then begin
    H:=AspectScaledWindowHeight(W,CellW,CellH);
//    H:=WindowHeightFromWidth(W);
  end
  else H:=MinCamSize+Random(MaxCamSize-MinCamSize);

  if H>TrackH then begin
    H:=TrackH;
    if KeepAspect then W:=AspectScaledWindowWidth(H,CellW,CellH);
  end;

// find X1,X2
  Result.X1:=Random(TrackW-(W-1));
  Result.X2:=Result.X1+W-1;

// find Y1,Y2
  if KeepBlowUpY then begin
    Result.Y1:=Round(MidY-H/2-Jitter/2+Random(Jitter));
  end
  else Result.Y1:=Random(TrackH-(H-1));

  if Result.Y1<0 then Result.Y1:=0;
  Result.Y2:=Result.Y1+H-1;
  if Result.Y2>=TrackH then begin
    Result.Y2:=TrackH-1;
    Result.Y1:=Result.Y2-(H-1);
    if Result.Y1<0 then begin
      Result.Y1:=0;
    end;
  end;
end;

function TTiler.CameraXToTextureX(CamX:Integer):Single;
begin
  Result:=CamX/(Camera.ImageW-1);
end;

function TTiler.CameraYToTextureY(CamY:Integer):Single;
begin
  Result:=CamY/(Camera.ImageH-1);
end;

procedure TTiler.RenderFullCamera;
var
  X1,X2   : Integer;
  Y1,Y2   : Integer;
  TY1,TY2 : Single;
begin
  if (not Camera.LoRes) and Camera.MirrorImage then begin
    X1:=Width-1;
    X2:=0;
  end
  else begin
    X1:=0;
    X2:=Width-1;
  end;
  if (not Camera.LoRes) and Camera.FlipImage then begin
    Y1:=0;
    Y2:=Height-1;
  end
  else begin
    Y1:=Height-1;
    Y2:=0;
  end;
  TY1:=CameraYToTextureY(CamIdleY1);
  TY2:=CameraYToTextureY(CamIdleY2);

  glBegin(GL_QUADS);
    glTexCoord2F(0,TY2);
    glVertex2I(X1,Y2);

    glTexCoord2F(1,TY2);
    glVertex2I(X2,Y2);

    glTexCoord2F(1,TY1);
    glVertex2I(X2,Y1);

    glTexCoord2F(0,TY1);
    glVertex2I(X1,Y1);
  glEnd;
end;

procedure TTiler.CopyCameraImageToTextureData;
begin
  if Camera.LoRes then begin
    InitBmpDataFromBmp(PByte(@TextureData),Camera.Bmp,0,0,Camera.ImageW-1,Camera.ImageH-1);
  end
  else begin
    if ShowTestPattern then begin
      InitBmpDataFromBmp(PByte(@TextureData),TestBmp,0,0,MaxImageW-1,Camera.ImageH-1);
    end
    else begin
      InitBmpDataFromBmp(PByte(@TextureData),Camera.FullBmp,0,0,Camera.ImageW-1,Camera.ImageH-1);
    end;
  end;
end;

procedure TTiler.ShowCamera;
begin
// move the bmp data into a continouous array
  CopyCameraImageToTextureData;
  glTexImage2D(GL_TEXTURE_2D,0,3,Camera.ImageW,Camera.ImageH,0,GL_BGR,GL_UNSIGNED_BYTE,@TextureData);
  glColor3UB(255,255,255);
  glEnable(GL_TEXTURE_2D);
  RenderFullCamera;
  glDisable(GL_TEXTURE_2D);
end;

procedure TTiler.Render;
var
  C,R : Integer;
begin
  if ShowFullCamera then begin
    ShowCamera;
    Exit;
  end;

// move the bmp data into a continouous array
  CopyCameraImageToTextureData;
  glTexImage2D(GL_TEXTURE_2D,0,3,Camera.ImageW,Camera.ImageH,0,GL_BGR,GL_UNSIGNED_BYTE,@TextureData);

  glColor3UB(255,255,255);
  glEnable(GL_TEXTURE_2D);
  for R:=1 to YCells do for C:=1 to XCells do if not Cell[C,R].PartOfSuperCell then begin
    Cell[C,R].FindTextureCoords;
    Cell[C,R].Render;
  end;

  if GridSize>0 then begin
    glDisable(GL_TEXTURE_2D);
    RenderGrid;
    glColor3UB(255,255,255);
    glEnable(GL_TEXTURE_2D);
  end;
  if Mode<>tmIdle then begin
    RenderAllSuperCells;
    glDisable(GL_TEXTURE_2D);
    FixSuperCellGrid;
  end;
end;

procedure TTiler.OutlineSuperCell(var SuperCell:TSuperCell);
begin
  with SuperCell do begin

// top
    if Y>1 then begin
      glVertex2I(X1,Y1);
      glVertex2I(X2,Y1);
    end;

// right
    if (X+W-1)<XCells then begin
      glVertex2I(X2,Y1);
      glVertex2I(X2,Y2);
    end;

// bottom
    if (Y+H-1)<YCells then begin
      glVertex2I(X1,Y2);
      glVertex2I(X2,Y2);
    end;

// left
    if X>1 then begin
      glVertex2I(X1,Y1);
      glVertex2I(X1,Y2);
    end;
  end;
end;

procedure TTiler.FixSuperCellGrid;
var
  I : Integer;
begin
  glLineWidth(GridSize);
  if ShowSuperCells then glColor3UB(255,0,0)
  else with GridColor do glColor3UB(R,G,B);

  glBegin(GL_LINES);
    for I:=1 to SuperCell1x2Count do with SuperCell1x2[I] do if Placed then begin
      OutlineSuperCell(SuperCell1x2[I]);
    end;
    for I:=1 to SuperCell2x1Count do with SuperCell2x1[I] do if Placed then begin
      OutlineSuperCell(SuperCell2x1[I]);
    end;
    for I:=1 to SuperCell2x2Count do with SuperCell2x2[I] do if Placed then begin
      OutlineSuperCell(SuperCell2x2[I]);
    end;
  glEnd;
end;

procedure TTiler.RenderGrid;
var
  I : Integer;
begin
  glLineWidth(GridSize);
  with GridColor do glColor3UB(R,G,B);
  glBegin(GL_LINES);
  for I:=2 to YCells do begin
    glVertex2I(0,Cell[1,I].Y1);
    glVertex2I(Width,Cell[1,I].Y1);
  end;
//  glVertex2I(0,Cell[1,YCells].Y2);
//  glVertex2I(Width,Cell[1,YCells].Y2);

  for I:=2 to XCells do begin
    glVertex2I(Cell[I,1].X1,0);
    glVertex2I(Cell[I,1].X1,Height-1);
  end;
//  glVertex2I(Cell[XCells,1].X2,0);
//  glVertex2I(Cell[XCells,1].X2,Height);

  glEnd;
end;

procedure TTiler.ShowCellVars(Lines:TStrings);
var
  C,R : Integer;
begin
  for R:=1 to YCells do for C:=1 to XCells do with Cell[C,R] do begin
    Lines.Add('Cell['+IntToStr(C)+','+IntToStr(R)+']: X1 = '+IntToStr(CamX1)+
              ', Y1 = '+IntToStr(CamY1)+', X2 = '+IntToStr(CamX2)+
              ', Y2 = '+IntToStr(CamY2));
  end;
end;

procedure TTiler.Zoom;
var
  C,R : Integer;
begin
  for R:=1 to YCells do for C:=1 to XCells do begin
    Cell[C,R].Zoom;
  end;
  Mode:=tmZoomingIn;
  ZoomStartTime:=GetTickCount;
end;

procedure TTiler.FindZoomWindows;
var
  C,R   : Integer;
  XSize : Integer;
  YSize : Integer;
begin
  XSize:=Round((TrackW/XCells)/(2*Tiler.ZoomScale));
  YSize:=Round((TrackH/YCells)/(2*Tiler.ZoomScale));
  for R:=1 to YCells do for C:=1 to XCells do begin
    Cell[C,R].FindZoomWindow(XSize,YSize);
  end;
end;

procedure TTiler.InitSuperCells;
var
  S : Integer;
begin
  for S:=1 to MaxSuperCells do begin
    SuperCell1x2[S].W:=1;
    SuperCell1x2[S].H:=2;
    SuperCell1x2[S].Placed:=False;

    SuperCell2x1[S].W:=2;
    SuperCell2x1[S].H:=1;
    SuperCell2x1[S].Placed:=False;

    SuperCell2x2[S].W:=2;
    SuperCell2x2[S].H:=2;
    SuperCell2x2[S].Placed:=False;
  end;
end;

function TTiler.SuperCellOk(var SuperCell:TSuperCell):Boolean;
var
  C,R : Integer;
begin
  with SuperCell do begin
    R:=Y;
    Result:=True;
    repeat
      C:=X;
      repeat
        if Cell[C,R].PartOfSuperCell then Result:=False
        else Inc(C);
      until (C=(X+W)) or (not Result);
      Inc(R);
    until (R=(Y+H)) or (not Result);
  end;
end;

procedure TTiler.ClearSuperCells;
var
  C,R,I : Integer;
begin
// mark all the cells as untaken
  for R:=1 to YCells do for C:=1 to XCells do begin
    Cell[C,R].PartOfSuperCell:=False;
  end;
  for I:=1 to SuperCell1x2Count do SuperCell1x2[I].Placed:=False;
  for I:=1 to SuperCell2x1Count do SuperCell2x1[I].Placed:=False;
  for I:=1 to SuperCell2x2Count do SuperCell2x2[I].Placed:=False;
end;

procedure TTiler.PlaceSuperCell(var SuperCell:TSuperCell);
var
  C,R : Integer;
begin
  with SuperCell do begin
    for R:=Y to Y+H-1 do for C:=X to X+W-1 do begin
      Cell[C,R].PartOfSuperCell:=True;
    end;
    X1:=Cell[X,Y].X1;
    X2:=Cell[X+W-1,Y].X2;
    SuperCell.Width:=X2-X1+1;

    Y1:=Cell[X,Y].Y1;
    Y2:=Cell[X,Y+H-1].Y2;
    SuperCell.Height:=Y2-Y1+1;
    Placed:=True;

// target is zoomed in cam coordinates
    TgtX1:=Cell[X,Y].TgtX1;
    TgtX2:=Cell[X,Y].TgtX2;
    TgtW:=TgtX2-TgtX1+1;

    TgtY1:=Cell[X,Y].TgtY1;
    TgtY2:=Cell[X,Y].TgtY2;
    TgtH:=TgtY2-TgtY1+1;

// idle is the zoomed out cam coordinates (2x1 pixels)
    IdleX1:=Cell[X,Y].IdleX1;
    IdleX2:=Cell[X+W-1,Y].IdleX2;
    IdleW:=IdleX2-IdleX1+1;

    IdleY1:=Cell[X,Y].IdleY1;
    IdleY2:=Cell[X,Y+H-1].IdleY2;
    IdleH:=IdleY2-IdleY1+1;

// set the cam vars to the idle vars
    JumpToIdle;
    StartZoom;
  end;
end;

procedure TTiler.RenderSuperCells(var SuperCell:TSuperCellArray;Count:Integer);
var
  I : Integer;
begin
  for I:=1 to Count do begin
    with SuperCell[I] do if Placed then begin
      FindTextureCoords;

// enfore the aspect ratio
      if W>H then TX2:=TX1+(TX2-TX1)*W/H
      else TY2:=TY1-(TY1-TY2)*H/W;

// make sure we're not clipping anywhere
      if TX1<0 then begin
        TX2:=TX2+TX1;
        TX1:=0;
      end;

      if TX2>1 then begin
        TX1:=TX1-(TX2-1);
        TX2:=1;
      end;

      if TY1<0 then begin
        TY2:=TY2+TY1;
        TY1:=0;
      end;

      if TY2>1 then begin
        TY1:=TY1-(TY2-1);
        TY2:=1;
      end;

      Render;
    end;
  end;
end;

procedure TTiler.RenderAllSuperCells;
begin
  RenderSuperCells(SuperCell1x2,SuperCell1x2Count);
  RenderSuperCells(SuperCell2x1,SuperCell2x1Count);
  RenderSuperCells(SuperCell2x2,SuperCell2x2Count);
end;

procedure TTiler.ScaleSuperCells;
var
  I         : Integer;
  MinXCells : Integer;
  MaxXCells : Integer;
  MinYCells : Integer;
  MaxYCells : Integer;
  WScale    : Single;
  HScale    : Single;
begin
  if XCells1<XCells2 then begin
    MinXCells:=XCells1;
    MaxXCells:=XCells2;
  end
  else begin
    MinXCells:=XCells2;
    MaxXCells:=XCells1;
  end;
  if YCells1<YCells2 then begin
    MinYCells:=YCells1;
    MaxYCells:=YCells2;
  end
  else begin
    MinYCells:=YCells2;
    MaxYCells:=YCells1;
  end;
  WScale:=1+(SuperCellScale-1)*(XCells-MinXCells)/(MaxXCells-MinXCells);
  HScale:=1+(SuperCellScale-1)*(YCells-MinYCells)/(MaxYCells-MinYCells);

  for I:=1 to SuperCell1x2Count do with SuperCell1x2[I] do begin
    W:=Round(1*WScale);
    H:=Round(2*HScale);
  end;
  for I:=1 to SuperCell2x1Count do with SuperCell2x1[I] do begin
    W:=Round(2*WScale);
    H:=Round(1*HScale);
  end;
  for I:=1 to SuperCell2x2Count do with SuperCell2x2[I] do begin
    W:=Round(2*WScale);
    H:=Round(2*HScale);
  end;
end;

function TTiler.AbleToPlaceSuperCell(var SuperCell:TSuperCell):Boolean;
var
  I,Tries  : Integer;
  MaxCount : Integer;
  MaxV     : Integer;
  Ok       : Boolean;
begin
  Result:=True;
  with SuperCell do begin

// pick a spot at random
    MaxV:=XCells-(W-1);
    X:=1+Random(MaxV);

    MaxV:=YCells-(H-1);
    Y:=1+Random(MaxV);

    MaxCount:=XCells*YCells;
    Tries:=0;
    repeat
      Ok:=SuperCellOk(SuperCell);

// if this cell's not ok, check the next one
      if not Ok then begin
        Inc(Tries);
        if (X+W-1)<XCells then Inc(X)
        else begin
          X:=1;
          if (Y+H-1)<YCells then Inc(Y)
          else Y:=1;
        end;
      end;
    until Ok or (Tries=MaxCount);
    if Ok then PlaceSuperCell(SuperCell)
    else Result:=False;
  end;
end;


function TTiler.AbleToPlaceSuperCells(var SuperCell:TSuperCellArray;Count:Integer):Boolean;
var
  I : Integer;
begin
  Result:=True;
  I:=0;
  while (I<Count) and Result do begin
    Inc(I);
    if not AbleToPlaceSuperCell(SuperCell[I]) then Result:=False;
  end;
end;

procedure TTiler.PlaceSuperCells;
var
  GridFull : Boolean;
begin
  ClearSuperCells;

// place the hardest to place ones first
  AbleToPlaceSuperCells(SuperCell2x2,SuperCell2x2Count);

// place the next hardest
  if XCells>YCells then begin
    AbleToPlaceSuperCells(SuperCell2x1,SuperCell2x1Count);
    AbleToPlaceSuperCells(SuperCell1x2,SuperCell1x2Count);
  end
  else begin
    AbleToPlaceSuperCells(SuperCell1x2,SuperCell1x2Count);
    AbleToPlaceSuperCells(SuperCell2x1,SuperCell2x1Count);
  end;
end;

procedure TTiler.TestCells(Lines:TStrings);
var
  C,R          : Integer;
  TextureRatio : Single;
  PixelRatio   : Single;
  Txt          : String;
  TXW,TXH      : Single;
begin
  for R:=1 to YCells do for C:=1 to XCells do begin
    Txt:='Cell['+IntToStr(C)+','+IntToStr(R)+']: ';
    if (Mode in [tmIdle,tmForcedIdle]) or (not Cell[C,R].PartOfSuperCell) then
    begin
      TXW:=(Cell[C,R].TX2-Cell[C,R].TX1)+1;
      TXH:=(Cell[C,R].TY2-Cell[C,R].TY1)+1;
      TextureRatio:=TXW/TXH;
      PixelRatio:=(1600/2560)*(Cell[C,R].Width/Cell[C,R].Height);
      Txt:=Txt+'Texture: '+FloatToStrF(TextureRatio,ffFixed,9,3)+
              ' Pixel: '+FloatToStrF(PixelRatio,ffFixed,9,3);
    end
    else Txt:=Txt+'part of SuperCell';
    Lines.Add(Txt);
  end;
  TextureRatio:=1;
  PixelRatio:=(1600/2560)*(Width/Height);
  Txt:='Full screen: Texture: '+FloatToStrF(TextureRatio,ffFixed,9,3)+
                   ' Pixel: '+FloatToStrF(PixelRatio,ffFixed,9,3);
  Lines.Add(Txt);
end;

procedure TTiler.ZoomToForeGround;
var
  C,R,MidY : Integer;
  Jitter   : Integer;
begin
  Jitter:=Round(TrackH*BlowUpYFraction);
  for R:=1 to YCells do begin
    MidY:=Cell[1,R].PixelYc;
    for C:=1 to XCells do begin
      Cell[C,R].ZoomToForeGround(MidY,Jitter);
    end;
  end;
  Mode:=tmZoomingIn;
  ZoomStartTime:=GetTickCount;
end;

procedure TTiler.ZoomToBackGround;
var
  C,R,MidY : Integer;
  Jitter   : Integer;
begin
  Jitter:=Round(TrackH*BlowUpYFraction);
  for R:=1 to YCells do begin
    MidY:=Cell[1,R].PixelYc;
    for C:=1 to XCells do begin
      Cell[C,R].ZoomToBackGround(MidY,Jitter);
    end;
  end;
  Mode:=tmZoomingIn;
  ZoomStartTime:=GetTickCount;
end;

function TTiler.RandomCellWindow(MidY,Jitter,CellW,CellH:Integer):TWindow;
begin
  Result:=RandomWindow(MidY,Jitter,CellW,CellH);
  Result:=CellTracker.CamWindowToCellWindow(Result);
end;

end.


