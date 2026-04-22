unit CellTrackerU;

interface

uses
  Windows, Global, SysUtils, Graphics, Classes;

const
  MaxDilateR = 7;
  MaxBlobs   = 254;
  XCells     = MaxXCells;
  YCells     = MaxYCells;

type
  TCellTrackerInfo = record     // 8*4 + 4*1 + 59 =
    Fraction          : Single;
    MinCoverAge       : Integer;
    MinUnCoverAge     : Integer;
    Dilate            : Boolean;
    DilateR           : Single;
    FillInside        : Boolean;
    MinFillCoverAge   : Integer;
    MinFillUnCoverAge : Integer;
    MinCellI          : Integer;
    SuppressLoneCells : Boolean;
    SuppressIslands   : Boolean;
    MinBlobArea       : Integer;
    Reserved          : array[1..59] of Byte;
  end;

  TCell = record
    X1,Y1     : Integer;
    X2,Y2     : Integer;
    Count     : Integer;
    Area      : Integer;
    Fraction  : Single;
    Covered   : Boolean; // instantaneous triggered flag
    CoveredLF : Boolean; // covered last frame flag
    Triggered : Boolean; // triggered = covered/uncovered for a min time
    Active    : Boolean; // active = triggered or next to a triggered cell
    Age       : Integer;
    AvgI      : Integer;
    Surrounded : Boolean;
    Filled     : Boolean;
    FillAge    : Integer;
    Lone       : Boolean;
    BlobI      : Integer;
    PartOfBigBlob : Boolean;
  end;
  TCellArray = array[1..MaxXCells,1..MaxYCells] of TCell;

  TDilateMask = array[-MaxDilateR..MaxDilateR,-MaxDilateR..MaxDilateR] of Boolean;

  TCellTracker = class(TObject)
  private
    function  GetInfo:TCellTrackerInfo;
    procedure SetInfo(NewInfo:TCellTrackerInfo);

  public
    Cell              : TCellArray;
    Fraction          : Single;
    CellArea          : Integer;
    MinCoverAge       : DWord;
    MinUnCoverAge     : DWord;
    Dilate            : Boolean;
    DilateR           : Single;
    IntDilateR        : Integer;
    DilateMask        : TDilateMask;
    FillInside        : Boolean;
//    MinCellI          : Integer;
    SuppressLoneCells : Boolean;
    FloodBmp          : TBitmap;
    MinFillCoverAge   : Integer;
    MinFillUnCoverAge : Integer;
    SuppressIslands   : Boolean;
    MinBlobArea       : Integer;
    BlobCount         : Integer;
    BlobArea          : array[1..MaxBlobs] of Integer;
    CoverFraction     : Single;

    property Info : TCellTrackerInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure InitForTracking;
    procedure FindActiveCells;
    procedure Update;
    procedure FindBlobs;

    procedure DrawCells(Bmp:TBitmap);
    procedure ShowCoveredCells(Bmp:TBitmap);
    procedure ShowTriggeredCells(Bmp:TBitmap);
    procedure ShowActiveCells(Bmp:TBitmap);
    procedure ShowActiveCellsOnTrackBmp(Bmp:TBitmap);
    procedure InitDilateMask;
    procedure ShowCellIntensities(Bmp:TBitmap);
    procedure ActivateSurroundedCells;
    procedure FindCRFromXY(var C,R:Integer;X,Y:Integer);
    procedure DeActivateLoneCells;
    procedure FindLoneCells;
    procedure MarkCellsInLatestBlob;
    procedure SegmentCells;
    procedure DrawSegmentedBmp(Bmp:TBitmap);
    procedure FindIslandCells;
    procedure DrawBigBlobsBmp(Bmp:TBitmap);

    function CellAtPixelXYCovered(X,Y:Integer):Boolean;
    function CamWindowToCellWindow(var CamWindow:TWindow):TWindow;
    function CamXToColumn(CamX:Integer):Integer;
    function CamYToRow(CamY:Integer):Integer;
    function CoverageInCellWindow(var Window:TWindow):Single;
    function CellWindowToCamWindow(CellWindow:TWindow):TWindow;

    procedure FindCoverFraction;
    function  BiggestBlob:Integer;
    procedure FindBlobCenterAndArea(B:Integer;var Xc,Yc,Area:Integer);
  end;

var
  CellTracker : TCellTracker;

function DefaultCellTrackerInfo:TCellTrackerInfo;

implementation

uses
  CameraU, BmpUtils, SegmenterU, Routines, Main, TilerU;

function DefaultCellTrackerInfo:TCellTrackerInfo;
begin
  Result.Fraction:=0.20;
  Result.MinCoverAge:=2;
  Result.MinUnCoverAge:=4;
  Result.Dilate:=True;
  Result.DilateR:=1.0;
  Result.FillInside:=True;
  Result.MinFillCoverAge:=2;
  Result.MinFillUnCoverAge:=2;
  Result.MinCellI:=30;
  Result.SuppressLoneCells:=True;
  Result.SuppressIslands:=True;
  Result.MinBlobArea:=30;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

constructor TCellTracker.Create;
begin
  inherited Create;
  FloodBmp:=TBitmap.Create;
  FloodBmp.PixelFormat:=pf24Bit;
end;

destructor TCellTracker.Destroy;
begin
  if Assigned(FloodBmp) then FloodBmp.Free;
  inherited;
end;

function TCellTracker.GetInfo:TCellTrackerInfo;
begin
  Result.Fraction:=Fraction;
  Result.MinCoverAge:=MinCoverAge;
  Result.MinUnCoverAge:=MinUnCoverAge;
  Result.Dilate:=Dilate;
  Result.DilateR:=DilateR;
  Result.FillInside:=FillInside;
  Result.MinFillCoverAge:=MinFillCoverAge;
  Result.MinFillUnCoverAge:=MinFillUnCoverAge;
  Result.MinCellI:=30;///MinCellI;
  Result.SuppressLoneCells:=SuppressLoneCells;
  Result.SuppressIslands:=SuppressIslands;
  Result.MinBlobArea:=MinBlobArea;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TCellTracker.SetInfo(NewInfo:TCellTrackerInfo);
begin
  Fraction:=NewInfo.Fraction;
  MinCoverAge:=NewInfo.MinCoverAge;
  MinUnCoverAge:=NewInfo.MinUnCoverAge;
  Dilate:=NewInfo.Dilate;
  DilateR:=NewInfo.DilateR;
  InitDilateMask;
  FillInside:=NewInfo.FillInside;
  MinFillCoverAge:=NewInfo.MinFillCoverAge;
  MinFillUnCoverAge:=NewInfo.MinFillUnCoverAge;
//  MinCellI:=NewInfo.MinCellI;
  SuppressLoneCells:=NewInfo.SuppressLoneCells;
  SuppressIslands:=NewInfo.SuppressIslands;
  MinBlobArea:=NewInfo.MinBlobArea;
  if MinBlobArea<1 then MinBlobArea:=1;
end;

procedure TCellTracker.InitForTracking;
var
  W,H   : Single;
  X1,X2 : Single;
  Y1,Y2 : Single;
  X,Y   : Integer;
begin
  W:=(SmallRect.Right-1)/XCells;
  H:=(SmallRect.Bottom-1)/YCells;
  Y1:=0;
  for Y:=1 to YCells do begin
    Y2:=Y1+H;
    X1:=0;
    for X:=1 to XCells do begin
      X2:=X1+W;
      Cell[X,Y].X1:=Round(X1);
      Cell[X,Y].X2:=Round(X2);
      Cell[X,Y].Y1:=Round(Y1);
      Cell[X,Y].Y2:=Round(Y2);
      Cell[X,Y].Area:=(1+(Cell[X,Y].X2-Cell[X,Y].X1))*(1+Cell[X,Y].Y2-Cell[X,Y].Y1);
      Cell[X,Y].Age:=0;
      Cell[X,Y].FillAge:=0;
      Cell[X,Y].Filled:=False;
      X1:=X2;
    end;
    Y1:=Y2;
  end;
  CellArea:=Round(W*H);
  FloodBmp.Width:=XCells;
  FloodBmp.Height:=YCells;
end;

procedure TCellTracker.Update;
var
  C,R,X,Y : Integer;
begin
// loop through the cells
  for C:=1 to XCells do for R:=1 to YCells do begin

// count how many pixels are in the foreground and accumulate the intensities
    with Cell[C,R] do begin
      Count:=0;
      for Y:=Y1 to Y2 do begin
        for X:=X1 to X2 do begin
          if Segmenter.Pixel[X,Y].State<>psBackGnd then Inc(Cell[C,R].Count);
        end;
      end;
       if AvgI>255 then AvgI:=255;
      Fraction:=Count/Area;   // fraction of pixels in the foreground
    end;
    Cell[C,R].Covered:=(Cell[C,R].Fraction>Self.Fraction);
    Cell[C,R].PartOfBigBlob:=Cell[C,R].Covered;
  end;

  if SuppressIslands then FindIslandCells;

// decide which are covered and triggered (triggered = covered long enough)
  for C:=1 to XCells do for R:=1 to YCells do with Cell[C,R] do
  begin
    if Triggered then begin
      if PartOfBigBlob then Age:=0
      else begin
        Inc(Age);
        if Age>=MinUnCoverAge then begin
          Triggered:=False;
          Age:=0;
        end;
      end;
    end
    else begin
      if not PartOfBigBlob then Age:=0
      else begin
        Inc(Age);
        if Age>=MinCoverAge then begin
          Triggered:=True;
          Age:=0;
        end;
      end;
    end;
  end;
  FindActiveCells;
  if FillInside then ActivateSurroundedCells;
  FindCoverFraction;
  FindBlobs;
end;

procedure TCellTracker.DrawCells(Bmp:TBitmap);
var
  I : Integer;
begin
  with Bmp.Canvas do begin
    Pen.Color:=clNavy;

// horizontal
    for I:=1 to YCells do begin
      MoveTo(0,Cell[1,I].Y1);
      LineTo(Bmp.Width,Cell[1,I].Y1);
    end;
    MoveTo(0,Cell[1,YCells].Y2);
    LineTo(Bmp.Width,Cell[1,YCells].Y2);

// vertical
    for I:=1 to XCells do begin
      MoveTo(Cell[I,1].X1,0);
      LineTo(Cell[I,1].X1,Bmp.Height);
    end;
    MoveTo(Cell[XCells,1].X2,0);
    LineTo(Cell[XCells,1].X2,Bmp.Height);
  end;
end;

procedure TCellTracker.ShowCoveredCells(Bmp:TBitmap);
var
  C,R,X,Y : Integer;
  Bpp     : Integer;
  Line    : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  for C:=1 to XCells do for R:=1 to YCells do with Cell[C,R] do
  begin
    for Y:=Y1 to Y2 do begin
      Line:=Bmp.ScanLine[Y];
      if Covered then for X:=X1 to X2 do Line^[X*Bpp+0]:=255;
    end;
  end;
end;

procedure TCellTracker.ShowTriggeredCells(Bmp:TBitmap);
var
  C,R,X,Y : Integer;
  Bpp     : Integer;
  Line    : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  for C:=1 to XCells do for R:=1 to YCells do with Cell[C,R] do
  begin
    for Y:=Y1 to Y2 do begin
      Line:=Bmp.ScanLine[Y];
      if Triggered then for X:=X1 to X2 do Line^[X*Bpp+1]:=255;
    end;
  end;
end;

procedure TCellTracker.ShowActiveCells(Bmp:TBitmap);
var
  C,R,X,Y : Integer;
  Bpp     : Integer;
  Line    : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  for C:=1 to XCells do for R:=1 to YCells do begin
    with Cell[C,R] do if Active then begin
      for Y:=Y1 to Y2 do begin
        Line:=Bmp.ScanLine[Y];
        for X:=X1 to X2 do Line^[X*Bpp+2]:=255;
      end;
    end;
  end;
end;

procedure TCellTracker.FindActiveCells;
var
  C,R,Co,Ro,Ct,Rt : Integer;
begin
  if SuppressLoneCells then FindLoneCells;
  for C:=1 to XCells do for R:=1 to YCells do with Cell[C,R] do begin
    if SuppressLoneCells then begin
      Active:=Triggered and (not Lone);
    end
    else Active:=Triggered;
    if Triggered then begin
      if Dilate then for Co:=-IntDilateR to +IntDilateR do begin
        Ct:=C+Co;
        if (Ct>0) and (Ct<=XCells) then begin
          for Ro:=-IntDilateR to +IntDilateR do if DilateMask[Co,Ro] then begin
            Rt:=R+Ro;
            if (Rt>0) and (Rt<=YCells) then Cell[Ct,Rt].Active:=True;
          end;
        end;
      end;
    end;
  end;
end;

procedure TCellTracker.InitDilateMask;
var
  Co,Ro : Integer;
  R     : Single;
begin
  IntDilateR:=Round(DilateR);
  if IntDilateR<DilateR then Inc(IntDilateR);
  for Co:=-IntDilateR to +IntDilateR do for Ro:=-IntDilateR to +IntDilateR do begin
    R:=Sqrt(Sqr(Co)+Sqr(Ro));
    DilateMask[Co,Ro]:=(R<=DilateR);
  end;
end;

procedure TCellTracker.ShowCellIntensities(Bmp:TBitmap);
var
  R,C : Integer;
begin
  for R:=1 to YCells do for C:=1 to XCells do with Cell[C,R] do begin
    Bmp.Canvas.Brush.Color:=(AvgI shl 16)+(AvgI shl 8)+AvgI;
    Bmp.Canvas.FillRect(Rect(X1,Y1,X2+1,Y2+1));
  end;
end;

procedure TCellTracker.ActivateSurroundedCells;
var
  X,Y      : Integer;
  Line     : PByteArray;
begin
// clear the bmp
  ClearBmp(FloodBmp,clBlack);

// color in the active cells
  for Y:=0 to FloodBmp.Height-1 do begin
    Line:=FloodBmp.ScanLine[Y];
    for X:=0 to FloodBmp.Width-1 do begin
      if Cell[X+1,Y+1].Active then Line^[X*3]:=255;
    end;
  end;

// flood around the border
// top
  FloodBmp.Canvas.Brush.Style:=bsSolid;
  FloodBmp.Canvas.Brush.Color:=$FF0000;
  Line:=FloodBmp.ScanLine[0];
  for X:=0 to FloodBmp.Width-1 do begin
    if Line^[X*3]=0 then FloodBmp.Canvas.FloodFill(X,0,clBlack,fsSurface);
  end;

// bottom
  Line:=FloodBmp.ScanLine[FloodBmp.Height-1];
  for X:=0 to FloodBmp.Width-1 do begin
    if Line^[X*3]=0 then FloodBmp.Canvas.FloodFill(X,FloodBmp.Height-1,clBlack,fsSurface);
  end;

// left
  for Y:=0 to FloodBmp.Height-1 do begin
    Line:=FloodBmp.ScanLine[Y];
    if Line^[0]=0 then FloodBmp.Canvas.FloodFill(0,Y,clBlack,fsSurface);
  end;

// right
  for Y:=0 to FloodBmp.Height-1 do begin
    Line:=FloodBmp.ScanLine[Y];
    if Line^[(FloodBmp.Width-1)*3]=0 then begin
      FloodBmp.Canvas.FloodFill(FloodBmp.Width-1,Y,clBlack,fsSurface);
    end;
  end;

// force surrounded cells to activate
// any cells that aren't colored by now are isolated inside active cells
  for Y:=0 to FloodBmp.Height-1 do begin
    Line:=FloodBmp.ScanLine[Y];
    for X:=0 to FloodBmp.Width-1 do with Cell[X+1,Y+1] do begin

// determine if it's surrounded - if so we'll want to fill it once its been
// surrounded for long enough
//      if Line^[X*3]=0 then Active:=True;
      Surrounded:=(Line^[X*3]=0);

// it's considered filled (surrounded for long enough)...
      if Filled then begin

// if its still surrounded reset the age
        if Surrounded then FillAge:=0

// otherwise increment the age
        else begin
          Inc(FillAge);

// if its old enough unfill it
          if FillAge>=MinFillUnCoverAge then begin
            Filled:=False;
            FillAge:=0;
          end;
        end;
      end

// it's considered not filled
      else begin

// if its not surrounded reset the fill age - needs to be continuous
        if not Surrounded then FillAge:=0

// if its surrounded inc the age and call it filled if its been surrounded long
// enough
        else begin
          Inc(FillAge);
          if FillAge>=MinFillCoverAge then begin
            Filled:=True;
            FillAge:=0;
          end;
        end;
      end;

// its active if its filled
      if Filled then Active:=True;
    end;
  end;
end;

procedure TCellTracker.FindCRFromXY(var C,R:Integer;X,Y:Integer);
var
  W,H : Single;
begin
  W:=(SmallRect.Right-1)/XCells;
  H:=(SmallRect.Bottom-1)/YCells;
  C:=1+Trunc(X/W);
  R:=1+Trunc(Y/H);
end;

function TCellTracker.CellAtPixelXYCovered(X,Y:Integer):Boolean;
var
  R,C : Integer;
begin
  FindCRFromXY(C,R,X,Y);
  Result:=(R<YCells) and Cell[C,R].Covered;
end;

procedure TCellTracker.FindLoneCells;
var
  X,Y,Xo,Yo : Integer;
  C,R,Count : Integer;
begin
  for Y:=1 to YCells do for X:=1 to XCells do if Cell[X,Y].Triggered
  then begin
    Count:=0;
    Yo:=-1;
    repeat
      R:=Y+Yo;
      if (R>0) and (R<=YCells) then begin
        Xo:=-1;
        repeat
          C:=X+Xo;
          if (C>0) and (C<=XCells) and ((Xo<>0) or (Yo<>0)) then begin
            if Cell[C,R].Triggered then Inc(Count);
          end;
          Inc(Xo);
        until (Count>0) or (Xo>1);
      end;
      Inc(Yo);
    until (Count>0) or (Yo>1);
    Cell[X,Y].Lone:=(Count=0);
  end;
end;

procedure TCellTracker.DeActivateLoneCells;
var
  X,Y,Xo,Yo : Integer;
  C,R,Count : Integer;
begin
  for Y:=1 to YCells do for X:=1 to XCells do if Cell[X,Y].Active
  then begin
    Count:=0;
    Yo:=-1;
    repeat
      R:=Y+Yo;
      if (R>0) and (R<=YCells) then begin
        Xo:=-1;
        repeat
          C:=X+Xo;
          if (C>0) and (C<=XCells) and ((Xo<>0) or (Yo<>0)) then begin
            if Cell[C,R].Active then Inc(Count);
          end;
          Inc(Xo);
        until (Count>0) or (Xo>1);
      end;
      Inc(Yo);
    until (Count>0) or (Yo>1);
    if Count=0 then Cell[X,Y].Active:=False;
  end;
end;

procedure TCellTracker.MarkCellsInLatestBlob;
var
  X,Y,I : Integer;
  Line  : PByteArray;
begin
  for Y:=1 to YCells do begin
    Line:=FloodBmp.ScanLine[Y-1];
    for X:=1 to XCells do if Cell[X,Y].Covered and (Cell[X,Y].BlobI=0) then
    begin
      I:=(X-1)*3;
      if Line^[I]=BlobCount then begin
        Cell[X,Y].BlobI:=BlobCount;
      end;
    end;
  end;
end;

procedure TCellTracker.SegmentCells;
var
  I,X,Y : Integer;
  Line  : PByteArray;
begin
// copy the cell data to the bmp
  ClearBmp(FloodBmp,clBlack);
  for Y:=1 to YCells do begin
    Line:=FloodBmp.ScanLine[Y-1];
    for X:=1 to XCells do if Cell[X,Y].Covered then begin
      I:=(X-1)*3;
      Line^[I]:=255;
      Cell[X,Y].BlobI:=0;
    end;
  end;

// flood fill region by region
  BlobCount:=0;
  for Y:=1 to YCells do begin
    for X:=1 to XCells do begin
      if Cell[X,Y].Covered and (Cell[X,Y].BlobI=0) and (BlobCount<MaxBlobs) then
      begin
        Inc(BlobCount);
        Cell[X,Y].BlobI:=BlobCount;
        FloodBmp.Canvas.Brush.Color:=(BlobCount shl 16);
        FloodBmp.Canvas.FloodFill(X-1,Y-1,$FF0000,fsSurface);
        MarkCellsInLatestBlob;
      end;
    end;
  end;
end;

procedure TCellTracker.DrawSegmentedBmp(Bmp:TBitmap);
const
  MaxColors = 15;
  Color : array[1..MaxColors] of TColor =
    (clRed,clBlue,clGreen,clYellow,clPurple,clMaroon,clOlive,clNavy,clPurple,
     clTeal,clSilver,clLime,clFuchsia,clAqua,clWhite);
var
  X,Y,I : Integer;
begin
  ClearBmp(Bmp,clBlack);
  for Y:=1 to YCells do for X:=1 to XCells do begin
    with Cell[X,Y] do if Active and (BlobI>0) then begin
      I:=1+((Cell[X,Y].BlobI-1) mod MaxColors);
      Bmp.Canvas.Brush.Color:=Color[I];
      Bmp.Canvas.FillRect(Rect(X1,Y1,X2,Y2));
    end;
  end;
end;

procedure TCellTracker.FindIslandCells;
var
  I,X,Y : Integer;
begin
  SegmentCells;

// find the blob areas
  for I:=1 to BlobCount do BlobArea[I]:=0;
  for Y:=1 to YCells do for X:=1 to XCells do begin
    if Cell[X,Y].Covered then begin
      Inc(BlobArea[Cell[X,Y].BlobI]);
    end;
  end;

// mark the ones that belong to big enough blobs
  for  Y:=1 to YCells do for X:=1 to XCells do begin
    with Cell[X,Y] do if Covered then begin
      PartOfBigBlob:=(BlobArea[BlobI]>=MinBlobArea);
    end;
  end;
end;

procedure TCellTracker.DrawBigBlobsBmp(Bmp:TBitmap);
var
  X,Y : Integer;
begin
  ClearBmp(Bmp,clBlack);
  Bmp.Canvas.Brush.Color:=clWhite;//Color[I];
  for Y:=1 to YCells do for X:=1 to XCells do begin
    with Cell[X,Y] do if PartOfBigBlob then begin
      Bmp.Canvas.FillRect(Rect(X1,Y1,X2,Y2));
    end;
  end;
end;

function TCellTracker.CamXToColumn(CamX:Integer):Integer;
var
  Fraction : Single;
begin
  Fraction:=CamX/TrackW;
  Result:=1+SafeTrunc(Fraction*XCells);
  if Result>XCells then Result:=XCells;
end;

function TCellTracker.CamYToRow(CamY:Integer):Integer;
var
  Fraction : Single;
begin
  Fraction:=CamY/TrackH;
  Result:=1+SafeTrunc(Fraction*YCells);
  if Result>YCells then Result:=YCells;
end;

function TCellTracker.CamWindowToCellWindow(var CamWindow:TWindow):TWindow;
begin
  with Result do begin
    X1:=CamXToColumn(CamWindow.X1);
    X2:=CamXToColumn(CamWindow.X2);
    Y1:=CamYToRow(CamWindow.Y1);
    Y2:=CamYToRow(CamWindow.Y2);
  end;
end;

function TCellTracker.CoverageInCellWindow(var Window:TWindow):Single;
var
  Count : Integer;
  Total : Integer;
  C,R   : Integer;
begin
  Count:=0;
  with Window do begin
    Total:=((X2-X2)+1)*((Y2-Y1)+1);
    for R:=Y1 to Y2 do for C:=X1 to X2 do begin
      if Cell[C,R].Active then Inc(Count);
    end;
  end;
  Result:=Count/Total;
end;

function TCellTracker.CellWindowToCamWindow(CellWindow:TWindow):TWindow;
var
  XScale : Single;
  YScale : Single;
begin
  XScale:=TrackW/SmallW;
  YScale:=TrackH/SmallH;
  with CellWindow do begin
    Result.X1:=Round(Cell[X1,Y1].X1*XScale);
    Result.Y1:=Round(Cell[X1,Y1].Y1*YScale);
    Result.X2:=Round(Cell[X2,Y2].X2*XScale);
    Result.Y2:=Round(Cell[X2,Y2].Y2*YScale);
  end;
end;

procedure TCellTracker.FindCoverFraction;
var
  Count : Integer;
  Total : Integer;
  C,R   : Integer;
begin
  Count:=0;
  Total:=XCells*YCells;
  for R:=1 to YCells do for C:=1 to XCells do begin
    if Cell[C,R].Active then Inc(Count);
  end;
  CoverFraction:=Count/Total;
end;

procedure TCellTracker.ShowActiveCellsOnTrackBmp(Bmp:TBitmap);
var
  X,Y,C,R,Bpp    : Integer;
  X1,X2,Y1,Y2    : Integer;
  XPixelsPerCell : Single;
  YPixelsPerCell : Single;
  Line           : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  XPixelsPerCell:=TrackW/XCells;
  YPixelsPerCell:=TrackH/YCells;
  for R:=1 to YCells do begin
    Y1:=Round((R-1)*YPixelsPerCell);
    Y2:=Round(R*+YPixelsPerCell);
    if Y2>=Bmp.Height then Y2:=Bmp.Height-1;
    for C:=1 to XCells do if Cell[C,R].Active then begin
      X1:=Round((C-1)*XPixelsPerCell);
      X2:=X1+Round(XPixelsPerCell);
      if X2>=Bmp.Width then X2:=Bmp.Width-1;
      for Y:=Y1 to Y2 do begin
        Line:=Bmp.ScanLine[Y];
        for X:=X1 to X2 do begin
          Line^[X*Bpp+2]:=255;
        end;
      end;
    end;
  end;
end;

function TCellTracker.BiggestBlob:Integer;
var
  Count    : array[1..MaxBlobs] of Integer;
  MaxCount : Integer;
  R,C,B    : Integer;
begin
  MaxCount:=0;
  Result:=0;
  FillChar(Count,SizeOf(Count),0);
  for R:=1 to YCells do for C:=1 to XCells do if Cell[C,R].Active then begin
    B:=Cell[C,R].BlobI;
    if B>0 then begin
      Inc(Count[B]);
      if Count[B]>MaxCount then begin
        MaxCount:=Count[B];
        Result:=B;
      end;
    end;
  end;
end;

procedure TCellTracker.FindBlobCenterAndArea(B:Integer;var Xc,Yc,Area:Integer);
var
  X1,X2,Y1,Y2    : Single;
  X,XMin,XMax    : Integer;
  Y,YMin,YMax    : Integer;
  XPixelsPerCell : Single;
  YPixelsPerCell : Single;
begin
  Area:=0;
  for Y:=1 to YCells do for X:=1 to XCells do begin
    if Cell[X,Y].Active and (Cell[X,Y].BlobI=B) then begin
      if Area=0 then begin
        XMin:=X; XMax:=X;
        YMin:=Y; YMax:=Y;
      end
      else begin
        if X<XMin then XMin:=X;
        if X>XMax then XMax:=X;
        if Y<YMin then YMin:=Y;
        if Y>YMax then YMax:=Y;
      end;
      Inc(Area);
    end;
  end;
  if Area>=MinBlobArea then begin
    XPixelsPerCell:=TrackW/XCells;
    YPixelsPerCell:=TrackH/YCells;
    X1:=(XMin-1)*XPixelsPerCell;
    X2:=XMax*XPixelsPerCell;
    Y1:=(YMin-1)*YPixelsPerCell;
    Y2:=YMax*YPixelsPerCell;
    Xc:=Round((X1+X2)/2);
    Yc:=Round((Y1+Y2)/2);
  end
  else begin
    Xc:=0;
    Yc:=0;
  end;
end;

procedure TCellTracker.FindBlobs;
var
  I,X,Y : Integer;
  Line  : PByteArray;
begin
// copy the cell data to the bmp
  ClearBmp(FloodBmp,clBlack);
  for Y:=1 to YCells do begin
    Line:=FloodBmp.ScanLine[Y-1];
    for X:=1 to XCells do if Cell[X,Y].Active then begin
      I:=(X-1)*3;
      Line^[I]:=255;
      Cell[X,Y].BlobI:=0;
    end;
  end;

// flood fill region by region
  BlobCount:=0;
  for Y:=1 to YCells do begin
    for X:=1 to XCells do begin
      if Cell[X,Y].Active and (Cell[X,Y].BlobI=0) and (BlobCount<MaxBlobs) then
      begin
        Inc(BlobCount);
        Cell[X,Y].BlobI:=BlobCount;
        FloodBmp.Canvas.Brush.Color:=(BlobCount shl 16);
        FloodBmp.Canvas.FloodFill(X-1,Y-1,$FF0000,fsSurface);
        MarkCellsInLatestBlob;
      end;
    end;
  end;
end;

end.

procedure TCellTracker.ShowActiveCellsOnTrackBmp(Bmp:TBitmap);
var
  C,R,X,Y : Integer;
  Bpp     : Integer;
  Line    : PByteArray;
  XScale  : Single;
  YScale  : Single;
  XC,YC   : Integer;
  XC1,XC2 : Integer;
  YC1,YC2 : Integer;
begin
  Bpp:=BytesPerPixel(Bmp);
  XScale:=TrackW/SmallW;
  YScale:=TrackH/SmallH;
  for C:=1 to XCells do for R:=1 to YCells do begin
    with Cell[C,R] do if Active then for Y:=Y1 to Y2 do begin
      YC1:=Round(Y*YScale);
      YC2:=Round((Y+1)*YScale-1);
      if YC2>=Bmp.Height then YC2:=Bmp.Height-1;
      for YC:=YC1 to YC2 do begin
        Line:=Bmp.ScanLine[YC];
        XC1:=Round(X*XScale);
        XC2:=Round((X+1)*XScale-1);
        if XC2>=Bmp.Width then XC2:=Bmp.Width-1;
        for XC:=XC1 to XC2 do Line^[XC*Bpp+2]:=255;
      end;
    end;
  end;
end;


end.








