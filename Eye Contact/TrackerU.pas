unit TrackerU;

interface

uses
  Windows, Global, SysUtils, Graphics;

const
  MaxDilateR = 7;

type
  TTrackerInfo = record
    Threshold     : Integer;
    Fraction      : Single;
    MinCoverAge   : DWord;
    MinUnCoverAge : DWord;
    Dilate        : Boolean;
    DilateR       : Single;
    Reserved      : array[1..59] of Byte;
  end;

  TTrackerCell = record
    X1,Y1     : Integer;
    X2,Y2     : Integer;
    Count     : Integer;
    Fraction  : Single;
    Covered   : Boolean; // instantaneous triggered flag
    CoveredLF : Boolean; // covered last frame flag
    Triggered : Boolean; // triggered = covered/uncovered for a min time
    Active    : Boolean; // active = triggered or next to a triggered cell
    Age       : Integer;
  end;
  TTrackerCellArray = array[1..MaxXCells,1..MaxYCells] of TTrackerCell;

  TTracker = class(TObject)
  private
    function  GetInfo:TTrackerInfo;
    procedure SetInfo(NewInfo:TTrackerInfo);

  public
    Cell          : TTrackerCellArray;
    Threshold     : Integer;
    Fraction      : Single;
    CellArea      : Integer;
    MinCoverAge   : DWord;
    MinUnCoverAge : DWord;
    Dilate        : Boolean;
    DilateR       : Single;
    IntDilateR    : Integer;
    DilateMask    : array[-MaxDilateR..MaxDilateR,-MaxDilateR..MaxDilateR] of Boolean;

    property Info : TTrackerInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure InitForTracking;
    procedure FindActiveCells;
    procedure Update(Bmp:TBitmap);

    procedure DrawCells(Bmp:TBitmap);
    procedure ShowPixelsOverThreshold(Bmp:TBitmap);
    procedure ShowCoveredCells(Bmp:TBitmap);
    procedure ShowTriggeredCells(Bmp:TBitmap);
    procedure ShowActiveCells(Bmp:TBitmap);
    procedure InitDilateMask;
    procedure ShowAverageCellColors(Bmp:TBitmap);
  end;

var
  Tracker : TTracker;

function DefaultTrackerInfo:TTrackerInfo;

implementation

uses
  CameraU, TilerU, BmpUtils;

function DefaultTrackerInfo:TTrackerInfo;
begin
  Result.Threshold:=50;
  Result.Fraction:=0.50;
  Result.MinCoverAge:=4;
  Result.MinUnCoverAge:=4;
  Result.Dilate:=True;
  Result.DilateR:=1.6;
end;

constructor TTracker.Create;
begin
  inherited;
end;

destructor TTracker.Destroy;
begin
  inherited;
end;

function TTracker.GetInfo:TTrackerInfo;
begin
  Result.Threshold:=Threshold;
  Result.Fraction:=Fraction;
  Result.MinCoverAge:=MinCoverAge;
  Result.MinUnCoverAge:=MinUnCoverAge;
  Result.Dilate:=Dilate;
  Result.DilateR:=DilateR;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TTracker.SetInfo(NewInfo:TTrackerInfo);
begin
  Threshold:=NewInfo.Threshold;
  Fraction:=NewInfo.Fraction;
  MinCoverAge:=NewInfo.MinCoverAge;
  MinUnCoverAge:=NewInfo.MinUnCoverAge;
  Dilate:=NewInfo.Dilate;
  DilateR:=NewInfo.DilateR;
  InitDilateMask;
end;

procedure TTracker.InitForTracking;
var
  W,H,X,Y : Integer;
  X1,X2   : Integer;
begin
  W:=SmallRect.Right div Tiler.XCells;
  H:=SmallRect.Bottom div Tiler.YCells;
  for X:=1 to Tiler.XCells do begin
    X1:=(X-1)*W;
    X2:=X1+W-1;
    for Y:=1 to Tiler.YCells do begin
      Cell[X,Y].X1:=X1;
      Cell[X,Y].X2:=X2;
      Cell[X,Y].Y1:=(Y-1)*H;
      Cell[X,Y].Y2:=Cell[X,Y].Y1+H-1;
    end;
  end;
  CellArea:=W*H;
end;

procedure TTracker.Update(Bmp:TBitmap);
var
  C,R,X,Y : Integer;
  Bpp     : Integer;
  Line    : PByteArray;
begin
// count how many are now over the threshold
  Bpp:=BytesPerPixel(Bmp);
  for C:=1 to Tiler.XCells do for R:=1 to Tiler.YCells do begin
    with Cell[C,R] do begin
      Count:=0;
      for Y:=Y1 to Y2 do begin
        Assert((Y>=0) and (Y<Bmp.Height),'');
        Line:=Bmp.ScanLine[Y];
        for X:=X1 to X2 do if Line^[X*Bpp]>Threshold then Inc(Cell[C,R].Count);
      end;
    end;
  end;

// decide which are covered and triggered (triggered = covered long enough
  for C:=1 to Tiler.XCells do for R:=1 to Tiler.YCells do with Cell[C,R] do
  begin
    Cell[C,R].Fraction:=Count/CellArea;
    Covered:=(Cell[C,R].Fraction>Self.Fraction);
    if Triggered then begin
      if Covered then Age:=0
      else begin
        Inc(Age);
        if Age>=MinUnCoverAge then begin
          Triggered:=False;
          Age:=0;
        end;
      end;
    end
    else begin
      if not Covered then Age:=0
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
end;

procedure TTracker.DrawCells(Bmp:TBitmap);
var
  I : Integer;
begin
  with Bmp.Canvas do begin
    Pen.Color:=clNavy;

// horizontal
    for I:=1 to Tiler.YCells do begin
      MoveTo(0,Cell[1,I].Y1);
      LineTo(Bmp.Width,Cell[1,I].Y1);
    end;
    MoveTo(0,Cell[1,Tiler.YCells].Y2);
    LineTo(Bmp.Width,Cell[1,Tiler.YCells].Y2);

// vertical
    for I:=1 to Tiler.XCells do begin
      MoveTo(Cell[I,1].X1,0);
      LineTo(Cell[I,1].X1,Bmp.Height);
    end;
    MoveTo(Cell[Tiler.XCells,1].X2,0);
    LineTo(Cell[Tiler.XCells,1].X2,Bmp.Height);
  end;
end;

procedure TTracker.ShowCoveredCells(Bmp:TBitmap);
var
  C,R,X,Y : Integer;
  Bpp     : Integer;
  Line    : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  for C:=1 to Tiler.XCells do for R:=1 to Tiler.YCells do with Cell[C,R] do
  begin
    for Y:=Y1 to Y2 do begin
      Line:=Bmp.ScanLine[Y];
      if Covered then for X:=X1 to X2 do Line^[X*Bpp+0]:=255;
    end;
  end;
end;

procedure TTracker.ShowTriggeredCells(Bmp:TBitmap);
var
  C,R,X,Y : Integer;
  Bpp     : Integer;
  Line    : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  for C:=1 to Tiler.XCells do for R:=1 to Tiler.YCells do with Cell[C,R] do
  begin
    for Y:=Y1 to Y2 do begin
      Line:=Bmp.ScanLine[Y];
      if Triggered then for X:=X1 to X2 do Line^[X*Bpp+1]:=255;
    end;
  end;
end;

procedure TTracker.ShowActiveCells(Bmp:TBitmap);
var
  C,R,X,Y : Integer;
  Bpp     : Integer;
  Line    : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  for C:=1 to Tiler.XCells do for R:=1 to Tiler.YCells do with Cell[C,R] do
  begin
    for Y:=Y1 to Y2 do begin
      Line:=Bmp.ScanLine[Y];
      if Active then for X:=X1 to X2 do Line^[X*Bpp+2]:=255;
    end;
  end;
end;


procedure TTracker.ShowPixelsOverThreshold(Bmp:TBitmap);
begin
  ThresholdBmpAsm(Bmp,Threshold);
end;

procedure TTracker.FindActiveCells;
var
  C,R,Co,Ro,Ct,Rt : Integer;
begin
  for C:=1 to Tiler.XCells do for R:=1 to Tiler.YCells do with Cell[C,R] do begin
    Active:=Triggered;
    if Triggered then begin
      if Dilate then for Co:=-IntDilateR to +IntDilateR do begin
        Ct:=C+Co;
        if (Ct>0) and (Ct<=Tiler.XCells) then begin
          for Ro:=-IntDilateR to +IntDilateR do if DilateMask[Co,Ro] then begin
            Rt:=R+Ro;
            if (Rt>0) and (Rt<=Tiler.YCells) then Cell[Ct,Rt].Active:=True;
          end;
        end;
      end;
    end;
  end;
end;

procedure TTracker.InitDilateMask;
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

procedure TTracker.ShowAverageCellColors(Bmp:TBitmap);
begin
end;

end.
