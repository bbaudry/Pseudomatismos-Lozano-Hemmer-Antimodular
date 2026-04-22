unit CellBackGndFind;

interface

uses
  Global, Routines, SysUtils, Windows, Graphics;

const
  MaxXCells = 32;
  MaxYCells = 32;

type
  TCellBackGndFinderInfo = record
    CoverThreshold : Integer;
    MaxCount       : Integer;
    Enabled        : Boolean;
    XCells,YCells  : Integer;
    MinTime        : DWord;
    Reserved       : array[1..51] of Byte;
  end;

  TOnCellUpdate = procedure(Sender:TObject;CellRect:TRect) of Object;

  TCellBackGndFinder = class(TObject)
  private
    FOnCellUpdate : TOnCellUpdate;

    function  GetInfo : TCellBackGndFinderInfo;
    procedure SetInfo(NewInfo:TCellBackGndFinderInfo);

  public
    TestBackGndBmp    : TBitmap;
    TestSubtractedBmp : TBitmap;

    AutoBackGnd    : TAutoBackGndRecord;
    ChangeCount    : array[1..MaxXCells,1..MaxYCells] of Integer;
    ChangeTime     : array[1..MaxXCells,1..MaxYCells] of DWord;
    CellTriggered  : array[1..MaxXCells,1..MaxYCells] of Boolean;
    BackGndChanged : Boolean;

    Enabled     : Boolean;
    XCells      : Integer;
    YCells      : Integer;
    Threshold   : Integer;
    MaxCount    : Integer;
    MinTime     : DWord;

    property Info : TCellBackGndFinderInfo read GetInfo write SetInfo;
    property OnCellUpdate : TOnCellUpdate read FOnCellUpdate write FOnCellUpdate;

    constructor Create;
    destructor  Destroy; override;

    procedure SetBackGndBmp(Bmp:TBitmap);

    procedure ClearChangeTimes;
    procedure InitForTracking;

    procedure DrawAutoBackGndCells(Bmp:TBitmap);
    procedure ShowAutoBackGndChangingPixels(Bmp:TBitmap);
    procedure ShowAutoBackGndChangeCounts(Bmp:TBitmap);
    procedure ShowPixelsAboveAutoBackGndThreshold(Bmp:TBitmap);
    procedure ShowCellAges(Bmp:TBitmap);

    procedure Update(Bmp:TBitmap);
  end;

var
  CellBackGndFinder : TCellBackGndFinder;

function DefaultCellBackGndFinderInfo:TCellBackGndFinderInfo;

implementation

uses
  BmpUtils, CameraU;//, Math2D;

function DefaultCellBackGndFinderInfo:TCellBackGndFinderInfo;
begin
  with Result do begin
    Enabled:=True;
    CoverThreshold:=50;
    MaxCount:=30;
    XCells:=16;
    YCells:=12;
    MinTime:=60000;
    FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
  end;
end;

constructor TCellBackGndFinder.Create;
begin
  inherited Create;

  TestBackGndBmp:=CreateImageBmp;
  ClearBmp(TestBackGndBmp,clBlack);

  TestSubtractedBmp:=CreateImageBmp;
  ClearBmp(TestSubtractedBmp,clBlack);

  BackGndChanged:=False;
  FOnCellUpdate:=nil;
end;

destructor TCellBackGndFinder.Destroy;
begin
  if Assigned(TestBackGndBmp) then TestBackGndBmp.Free;
  if Assigned(TestSubtractedBmp) then TestSubtractedBmp.Free;
  inherited;
end;

function TCellBackGndFinder.GetInfo:TCellBackGndFinderInfo;
begin
  Result.Enabled:=Enabled;
  Result.CoverThreshold:=Threshold;
  Result.MaxCount:=MaxCount;
  Result.MinTime:=MinTime;
  Result.XCells:=XCells;
  Result.YCells:=YCells;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TCellBackGndFinder.SetInfo(NewInfo:TCellBackGndFinderInfo);
begin
  Enabled:=NewInfo.Enabled;
  Threshold:=NewInfo.CoverThreshold;
  MaxCount:=NewInfo.MaxCount;
  MinTime:=NewInfo.MinTime;
  if MinTime<1000 then MinTime:=1000;
  XCells:=NewInfo.XCells;
  if XCells<1 then XCells:=1;
  YCells:=NewInfo.YCells;
  if YCells<1 then YCells:=1;
end;

procedure TCellBackGndFinder.ClearChangeTimes;
var
  X,Y  : Integer;
  Time : DWord;
begin
  Time:=GetTickCount;
  for X:=1 to XCells do for Y:=1 to YCells do begin
    ChangeTime[X,Y]:=Time;
    CellTriggered[X,Y]:=False;
  end;
end;

procedure TCellBackGndFinder.InitForTracking;
begin
  ClearChangeTimes;
  Camera.InitBmp(TestBackGndBmp);
  Camera.InitBmp(TestSubtractedBmp);
end;

procedure TCellBackGndFinder.SetBackGndBmp(Bmp:TBitmap);
begin
  Camera.BackGndBmp.Canvas.Draw(0,0,Bmp);
  TestBackGndBmp.Canvas.Draw(0,0,Bmp);
  ClearChangeTimes;
  BackGndChanged:=True;
end;

procedure TCellBackGndFinder.DrawAutoBackGndCells(Bmp:TBitmap);
var
  X,Xp,Y,Yp : Integer;
  Spacing   : Integer;
begin
  with Bmp.Canvas do begin
    Pen.Color:=clRed;
    Spacing:=Round(Bmp.Width/XCells);
    for X:=1 to XCells-1 do begin
      Xp:=X*Spacing;
      MoveTo(Xp,0);
      LineTo(Xp,Bmp.Height);
    end;
    Spacing:=Round(Bmp.Height/YCells);
    for Y:=1 to YCells-1 do begin
      Yp:=Y*Spacing;
      MoveTo(0,Yp);
      LineTo(Bmp.Width,Yp);
    end;
  end;
end;

procedure TCellBackGndFinder.ShowPixelsAboveAutoBackGndThreshold(Bmp:TBitmap);
var
  X,Y,I,Bpp : Integer;
  TestLine  : PByteArray;
  DrawLine  : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  ClearBmp(Bmp,clBlack);
  for Y:=0 to Bmp.Height-1 do begin
    TestLine:=Camera.SubtractedBmp.ScanLine[Y];
    DrawLine:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*Bpp;
      if TestLine^[I]>Threshold then DrawLine^[I]:=255;
    end;
  end;
end;

procedure TCellBackGndFinder.ShowAutoBackGndChangingPixels(Bmp:TBitmap);
var
  X,Y,I,Bpp     : Integer;
  Line,DrawLine : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Camera.SubtractedBmp.ScanLine[Y];
    DrawLine:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*Bpp;
      if Line^[I]>Threshold then begin
        DrawLine^[I+0]:=255;
        DrawLine^[I+1]:=0;
        DrawLine^[I+2]:=0;
      end;
    end;
  end;
end;

procedure TCellBackGndFinder.ShowAutoBackGndChangeCounts(Bmp:TBitmap);
var
  XSpacing,YSpacing     : Integer;
  TxtX,TxtY,XCell,YCell : Integer;
  Txt                   : String;
  CellRect              : TRect;
begin
  XSpacing:=Round(Bmp.Width/XCells);
  YSpacing:=Round(Bmp.Height/YCells);
  Bmp.Canvas.Font.Color:=clWhite;
  Bmp.Canvas.Font.Size:=8;
  for XCell:=1 to XCells do begin
    for YCell:=1 to YCells do begin
      CellRect.Left:=(XCell-1)*XSpacing;
      CellRect.Right:=CellRect.Left+XSpacing;
      CellRect.Top:=(YCell-1)*YSpacing;
      CellRect.Bottom:=CellRect.Top+YSpacing;
      Txt:=IntToStr(ChangeCount[XCell,YCell]);
      TxtX:=CellRect.Left+(XSpacing-Bmp.Canvas.TextWidth(Txt)) div 2;
      TxtY:=CellRect.Top+(YSpacing-Bmp.Canvas.TextHeight(Txt)) div 2;
      Bmp.Canvas.TextOut(TxtX,TxtY,Txt);
    end;
  end;
end;

procedure TCellBackGndFinder.Update(Bmp:TBitmap);
var
  XSpacing,YSpacing : Integer;
  X,Y,XCell,YCell,I : Integer;
  Line,TestLine     : PByteArray;
  CellRect          : TRect;
  Time,ElapsedTime  : DWord;
  Bpp               : Integer;
begin
// draw the test subtracted bmp
  SubtractBmpAsmAbs(Bmp,TestBackGndBmp,TestSubtractedBmp);

// clear the change counts
  FillChar(ChangeCount,SizeOf(ChangeCount),0);
  XSpacing:=Round(Bmp.Width/XCells);
  YSpacing:=Round(Bmp.Height/YCells);
  Bpp:=BytesPerPixel(Bmp);

// count how many pixels have changed by more than the required threshold in
// each of the cells
  for Y:=0 to Camera.SubtractedBmp.Height-1 do begin
    YCell:=1+(Y div YSpacing);
    Line:=Camera.SubtractedBmp.ScanLine[Y];
    TestLine:=TestSubtractedBmp.ScanLine[Y];
    for X:=0 to Camera.SubtractedBmp.Width-1 do begin
      XCell:=1+(X div XSpacing);
      I:=X*Bpp;
      if CellTriggered[XCell,YCell] then begin
        if TestLine^[I]>Threshold then Inc(ChangeCount[XCell,YCell]);
      end
      else if Line^[I]>Threshold then Inc(ChangeCount[XCell,YCell]);
    end;
  end;

  Time:=GetTickCount;
  for XCell:=1 to XCells do begin
    for YCell:=1 to YCells do begin
      CellRect.Left:=(XCell-1)*XSpacing;
      CellRect.Right:=CellRect.Left+XSpacing;
      CellRect.Top:=(YCell-1)*YSpacing;
      CellRect.Bottom:=CellRect.Top+YSpacing;
      if CellTriggered[XCell,YCell] then begin
        if ChangeCount[XCell,YCell]<MaxCount then begin
          ElapsedTime:=Time-ChangeTime[XCell,YCell];
          if ElapsedTime>=MinTime then begin
            CellTriggered[XCell,YCell]:=False;
            ChangeTime[XCell,YCell]:=Time;
            Camera.BackGndBmp.Canvas.CopyRect(CellRect,Bmp.Canvas,CellRect);
            if Assigned(FOnCellUpdate) then FOnCellUpdate(Self,CellRect);
          end
        end
        else begin
          ChangeTime[XCell,YCell]:=Time;
          Camera.BackGndBmp.Canvas.CopyRect(CellRect,Bmp.Canvas,CellRect);
          TestBackGndBmp.Canvas.CopyRect(CellRect,Bmp.Canvas,CellRect);
        end;
      end

// any cells that have enough changed pixels could need refreshing
      else if ChangeCount[XCell,YCell]>=MaxCount then begin

// if this cell has had enough pixels changed by the required amount for enough
// time, refresh the back ground with the current bmp
        ElapsedTime:=Time-ChangeTime[XCell,YCell];
        if ElapsedTime>=MinTime then begin
          CellTriggered[XCell,YCell]:=True;
          ChangeTime[XCell,YCell]:=Time;
          TestBackGndBmp.Canvas.CopyRect(CellRect,Bmp.Canvas,CellRect);
        end;
      end

// reset the timer - the values must change continuously
      else begin
        ChangeTime[XCell,YCell]:=Time;
      end;
    end;
  end;
end;

procedure TCellBackGndFinder.ShowCellAges(Bmp:TBitmap);
var
  XSpacing,YSpacing : Integer;
  XCell,YCell       : Integer;
  X,Y,W             : Integer;
  Txt               : String;
  CellRect          : TRect;
  Time,ElapsedTime  : DWord;
begin
  XSpacing:=Round(Bmp.Width/XCells);
  YSpacing:=Round(Bmp.Height/YCells);
  Time:=GetTickCount;
  for XCell:=1 to XCells do begin
    for YCell:=1 to YCells do begin
      if CellTriggered[XCell,YCell] then Bmp.Canvas.Pen.Color:=clLime
      else Bmp.Canvas.Pen.Color:=clYellow;
      CellRect.Left:=(XCell-1)*XSpacing;
      CellRect.Right:=CellRect.Left+XSpacing;
      CellRect.Top:=(YCell-1)*YSpacing;
      CellRect.Bottom:=CellRect.Top+YSpacing;
      ElapsedTime:=Time-ChangeTime[XCell,YCell];
      W:=Round(XSpacing*(ElapsedTime/MinTime));
      X:=CellRect.Left+1;
      Y:=CellRect.Top+(YSpacing div 2);
      Bmp.Canvas.MoveTo(X,Y);
      Bmp.Canvas.LineTo(X+W,Y);
    end;
  end;
end;

end.


