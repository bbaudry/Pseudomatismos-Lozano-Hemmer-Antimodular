unit BlobFind;

interface

uses
  Global, Windows, Graphics, SysUtils, Math, Classes, OpenGL, CameraU;

const
  MaxBlobs        = 64;
  MaxStripsPerRow = TrackW div 2;

type
  TSmearMode = (smClassic,smSoftEdge,smHardEdge);

  TBlobFinderInfo = record
    LoT,HiT           : Integer;
    JumpD             : Integer;
    MinArea           : Integer;
    KalmanTime        : Single;
    KalmanSensitivity : Integer;
    MaxLostTime       : DWord;
    MergeD            : Integer;
    UseColor          : Boolean;
    AntiMerge         : Boolean;
    SmearMode         : TSmearMode;
    CullArea          : Integer;
    Reserved          : array[1..249] of Byte;
  end;

  TStrip = record
    XMin,XMax : Integer;
    BlobI     : Integer;
  end;
  TStripArray = array[1..MaxStripsPerRow,0..TrackH-1] of TStrip;

  TStripCountArray = array[0..TrackH-1] of Integer;

  TXAtYArray = array[0..TrackH-1] of Integer;
  TYAtXArray = array[0..TrackW-1] of Integer;

  TBlob = record
    XMin,XMax : Integer;
    YMin,YMax : Integer;
    Width     : Integer;
    Height    : Integer;
    Xc,Yc     : Integer;
    Area      : Integer;
    MinXAtY   : TXAtYArray;
    MaxXAtY   : TXAtYArray;
    MinYAtX   : TYAtXArray;
    MaxYAtX   : TYAtXArray;
  end;
  TBlobArray = array[1..MaxBlobs] of TBlob;

  TBlobFinder = class(TObject)
  private
    Strip      : TStripArray;
    StripCount : TStripCountArray;

    function  StripsOverLap(Strip1,Strip2:TStrip):Boolean;

    function XYInsideBlob(X,Y:Integer;I:Integer):Boolean;
    function  XYInBlob2(X,Y,I:Integer):Boolean;

    function HLineInsideBlob(X1,X2,Y,I:Integer):Boolean;
    function VLineInsideBlob(Y1,Y2,X,I:Integer):Boolean;

    function  BlobsOverlap(I1,I2:Integer):Boolean;
    function  BlobsOverlap2(I1,I2:Integer):Boolean;

    procedure FindBlobCenters;

    procedure MergeBlob(I1,I2:Integer);
    procedure MergeBlobs;
    procedure MergeBlobs2;


    function  GetInfo:TBlobFinderInfo;
    procedure SetInfo(NewInfo:TBlobFinderInfo);

    procedure SetBlobXLimits;
    procedure MergeBlobStrips(I1,I2:Integer);

  public
    Tag       : Integer;
    Blob      : TBlobArray;
    BlobCount : Integer;

    LoT,HiT,JumpD,MergeD : Integer;
    MinArea,Averages     : Integer;

    MaxLostTime : DWord;

    CoverFraction : Single;
    UseColor      : Boolean;
    AntiMerge     : Boolean;
    SmearMode     : TSmearMode;
    CullArea      : Integer;

    property Info:TBlobFinderInfo read GetInfo write SetInfo;

    constructor Create;
    destructor Destroy; override;

    procedure Update;
    procedure FindStrips(Bmp:TBitmap);
    procedure FindBlobs;

    procedure DrawStrips(Bmp:TBitmap);
    procedure DrawStripsInColor(Bmp:TBitmap);

    procedure DrawBlobs(Bmp:TBitmap;HiLit:Integer);

    procedure OutlinePixel(Bmp:TBitmap;X,Y:Integer);
    procedure OutlineBlob(Bmp:TBitmap;B:Integer);
    procedure OutlineBlobs(Bmp:TBitmap);

    procedure InitForTracking;

    function  SceneStatic:Boolean;
    function  BlobRect(B:Integer):TRect;
    procedure CopyBlobAreas(SrcBmp,DestBmp:TBitmap);
    function  BestBlobForTracker:Integer;
    procedure ShowPixelsAboveThreshold(Bmp:TBitmap);

    procedure FindCoverFraction;

    function RandomBlobWithMinArea:Integer;
    function BlobsWithMinArea:Integer;
    function CoverageInWindow(var Window:TWindow):Single;
  end;

var
  BlobFinder : TBlobFinder;

function  DefaultBlobFinderInfo:TBlobFinderInfo;
procedure CreateBlobFinder;
procedure FreeBlobFinder;

implementation

uses
  BmpUtils, TrackerU, BackGndFind, TilerU, Routines;

procedure CreateBlobFinder;
begin
  BlobFinder:=TBlobFinder.Create;
end;

procedure FreeBlobFinder;
begin
  if Assigned(BlobFinder) then BlobFinder.Free;
end;

function DefaultBlobFinderInfo:TBlobFinderInfo;
begin
  with Result do begin
    LoT:=20;
    HiT:=40;
    JumpD:=5;
    MergeD:=100;
    MinArea:=1000;
    KalmanTime:=0.50;
    KalmanSensitivity:=20;
    MaxLostTime:=800;  // milliseconds
    UseColor:=True;
    AntiMerge:=True;
    SmearMode:=smHardEdge;
    CullArea:=500;
    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

constructor TBlobFinder.Create;
begin
  inherited Create;
  CoverFraction:=0;
end;

destructor TBlobFinder.Destroy;
begin
  inherited;
end;

function TBlobFinder.GetInfo:TBlobFinderInfo;
begin
  Result.LoT:=LoT;
  Result.HiT:=HiT;
  Result.JumpD:=JumpD;
  Result.MinArea:=MinArea;
  Result.KalmanTime:=0;//KalmanTime;
  Result.KalmanSensitivity:=0;//KalmanSensitivity;
  Result.MaxLostTime:=MaxLostTime;
  Result.MergeD:=MergeD;
  Result.UseColor:=UseColor;
  Result.AntiMerge:=AntiMerge;
  Result.SmearMode:=SmearMode;
  Result.CullArea:=CullArea;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TBlobFinder.SetInfo(NewInfo:TBlobFinderInfo);
begin
  LoT:=NewInfo.LoT;
  HiT:=NewInfo.HiT;
  JumpD:=NewInfo.JumpD;
  MinArea:=NewInfo.MinArea;
//KalmanTime:=NewInfo.KalmanTime;
//KalmanSensitivity:=NewInfo.KalmanSensitivity;
  MaxLostTime:=NewInfo.MaxLostTime;
  MergeD:=NewInfo.MergeD;
//UseColor:=NewInfo.UseColor;
  UseColor:=True;
  AntiMerge:=NewInfo.AntiMerge;
  SmearMode:=NewInfo.SmearMode;
  CullArea:=NewInfo.CullArea;
end;

procedure TBlobFinder.FindStrips(Bmp:TBitmap);
type
  TScanMode = (smLooking,smTracing,smJumping);
var
  X,Y,I,V   : Integer;
  JumpCount : Integer;
  Line      : PByteArray;
  ScanMode  : TScanMode;
  LoThresh  : Integer;
  HiThresh  : Integer;
  LastLoX   : Integer;
  LastHiX   : Integer;
begin
// clear the strip count array
  FillChar(StripCount,SizeOf(StripCount),0);
  if UseColor then begin
    LoThresh:=LoT*3;
    HiThresh:=HiT*3
  end
  else begin
    LoThresh:=LoT;
    HiThresh:=HiT;
  end;

// loop through the scanlines looking for strips
  for Y:=0 to Bmp.Height-1 do begin
    ScanMode:=smLooking;
    Line:=Bmp.ScanLine[Y];
    LastLoX:=-1;
    for X:=0 to Bmp.Width-1 do begin
      I:=X*3;
      if UseColor then V:=Line^[I+0]+Line^[I+1]+Line^[I+2]
      else V:=Line^[I+0];
      Case ScanMode of

// if we're looking and the intensity>=HiT, make a new strip
        smLooking :
          if V>=HiThresh then begin
            Inc(StripCount[Y]);
            if SmearMode=smSoftEdge then begin
              if LastLoX>=0 then Strip[StripCount[Y],Y].XMin:=LastLoX
              else Strip[StripCount[Y],Y].XMin:=X;
            end
            else Strip[StripCount[Y],Y].XMin:=X;
            Strip[StripCount[Y],Y].XMax:=X;
            ScanMode:=smTracing;
            LastLoX:=X;
            LastHiX:=X;
          end
          else if V>=LoThresh then LastLoX:=X;

// tracing
        smTracing :
          if V<LoThresh then begin
            ScanMode:=smJumping;
            JumpCount:=1;
          end
          else begin
            LastLoX:=X;
            if V>=HiThresh then LastHiX:=X;
          end;

// jumping across dim pixels
        smJumping :
          if V>=LoThresh then begin
            ScanMode:=smTracing;
            LastLoX:=X;
          end
          else begin
            if JumpCount<JumpD then Inc(JumpCount)

// lost it - finish this strip off and look for the next
            else begin
              ScanMode:=smLooking;
              Case SmearMode of
                smClassic  : Strip[StripCount[Y],Y].XMax:=X;
                smSoftEdge : Strip[StripCount[Y],Y].XMax:=LastLoX;
                smHardEdge : Strip[StripCount[Y],Y].XMax:=LastHiX;
              end;
              LastLoX:=-1;
            end;
          end;
      end;
    end;

// finish off this row
    Case ScanMode of
      smLooking : ;
      smTracing : Strip[StripCount[Y],Y].XMax:=Bmp.Width-1;
      smJumping :
        Case SmearMode of
          smClassic :  Strip[StripCount[Y],Y].XMax:=Bmp.Width-1;
          smSoftEdge : Strip[StripCount[Y],Y].XMax:=LastLoX;
          smHardEdge : Strip[StripCount[Y],Y].XMax:=LastHiX;
        end;
    end;
  end;
end;

function TBlobFinder.StripsOverLap(Strip1,Strip2:TStrip):Boolean;
begin
  with Strip1 do begin
    Result:=not ((XMin>Strip2.XMax) or (XMax<Strip2.XMin));
  end;
end;

procedure TBlobFinder.FindBlobCenters;
var
  I : Integer;
begin
  for I:=1 to BlobCount do with Blob[I] do begin
    Xc:=(XMin+XMax) div 2;
    Yc:=(YMin+YMax) div 2;
    Width:=(XMax-XMin)+1;
    Height:=(YMax-YMin)+1;
  end;
end;

procedure TBlobFinder.FindBlobs;
var
  I3,Y,Y2,SkipD  : Integer;
  I2,X,MaxY,Y3,I : Integer;
  PrevY,PrevI    : Integer;
  Found,MetBlob  : Boolean;
begin
// reset the count and BlobI vars
  BlobCount:=0;
  for Y:=0 to TrackH-1 do begin
    for I:=1 to StripCount[Y] do Strip[I,Y].BlobI:=0;
  end;

// look through the strip array
  for Y:=0 to TrackH-2 do for I:=1 to StripCount[Y] do begin
    with Strip[I,Y] do if BlobI=0 then begin
      Inc(BlobCount);
      BlobI:=BlobCount;

// bounding box and area
      Blob[BlobI].XMin:=XMin;
      Blob[BlobI].XMax:=XMax;
      Blob[BlobI].YMin:=Y;
      Blob[BlobI].YMax:=Y;
      Blob[BlobI].Area:=XMax-XMin+1;

// clear the limits
      for I2:=0 to TrackW-1 do begin
        Blob[BlobI].MinYAtX[I2]:=TrackH-1;
        Blob[BlobI].MaxYAtX[I2]:=0;
      end;
      for I2:=0 to TrackH-1 do begin
        Blob[BlobI].MinXAtY[I2]:=TrackW-1;
        Blob[BlobI].MaxXAtY[I2]:=0;
      end;

// init the limits
      Blob[BlobI].MinXAtY[Y]:=XMin;
      Blob[BlobI].MaxXAtY[Y]:=XMax;
      for X:=XMin to XMax do begin
        Blob[BlobI].MinYAtX[X]:=Y;
        Blob[BlobI].MaxYAtX[X]:=Y;
        Blob[BlobI].MinYAtX[X]:=Y;
        Blob[BlobI].MaxYAtX[X]:=Y;
      end;

// check all the strips below this one for overlaps
      Y2:=Y+1;
      SkipD:=0;
      PrevY:=Y;
      PrevI:=I;
      MetBlob:=False;
      while (Y2<TrackH) and (SkipD<MergeD) and (not MetBlob) do begin
        Inc(SkipD);
        I2:=0;
        Found:=False;
        while (I2<StripCount[Y2]) and (not MetBlob) do begin
          Inc(I2);
          if StripsOverLap(Strip[PrevI,PrevY],Strip[I2,Y2]) then begin
            if Strip[I2,Y2].BlobI=0 then with Strip[I2,Y2] do begin
              PrevI:=I2;
              PrevY:=Y2;
              SkipD:=0;
              BlobI:=Strip[I,Y].BlobI;
              Blob[BlobI].Area:=Blob[BlobI].Area+(XMax-XMin-1);

// update the bounding box
              if XMin<Blob[BlobI].XMin then Blob[BlobI].XMin:=XMin;
              if XMax>Blob[BlobI].XMax then Blob[BlobI].XMax:=XMax;
              if Y2>Blob[BlobI].YMax then Blob[BlobI].YMax:=Y2;

// update the limits
              if XMin<Blob[BlobI].MinXAtY[Y2] then Blob[BlobI].MinXAtY[Y2]:=XMin;
              if XMax>Blob[BlobI].MaxXAtY[Y2] then Blob[BlobI].MaxXAtY[Y2]:=XMax;
              for X:=XMin to XMax do begin
                if Y2<Blob[BlobI].MinYAtX[X] then Blob[BlobI].MinYAtX[X]:=Y2;
                if Y2>Blob[BlobI].MaxYAtX[X] then Blob[BlobI].MaxYAtX[X]:=Y2;
              end;
            end

// we've met another blob - merge with it
            else if Strip[I2,Y2].BlobI>0 then begin
              Blob[BlobCount].YMax:=Y2-1;
              MergeBlobStrips(BlobCount,Strip[I2,Y2].BlobI);
              MetBlob:=True;
              Dec(BlobCount);
            end;
          end;
        end;

// check the next row
        Inc(Y2);
      end;
      if BlobCount=MaxBlobs then Exit;
    end;
  end;
end;

// check all the strips below this one for overlaps
function TBlobFinder.MergeLowerStrips(Y,I:Integer);

// check all the strips below this one for overlaps
function TBlobFinder.MetBlobWhileMergingLowerStrips(Y,I:Integer):Boolean;
begin
  Y2:=Y+1;
  SkipD:=0;
  PrevY:=Y;
  PrevI:=I;
  Result:=False;
  while (Y2<TrackH) and (SkipD<MergeD) and (not Result) do begin
    Inc(SkipD);
    I2:=0;
    while (I2<StripCount[Y2]) and (not Result) do begin
      Inc(I2);

// see if these strips overlap in X
      if StripsOverLap(Strip[PrevI,PrevY],Strip[I2,Y2]) then begin

// see if this strip is free - if it is then merge it
        with Strip[I2,Y2] do if BlobI=0 then begin

// this is the new strip to check for overlaps
          PrevI:=I2;
          PrevY:=Y2;

// since we found a strip reset the skip counter
          SkipD:=0;

// merge it
          BlobI:=Strip[I,Y].BlobI;
          Blob[BlobI].Area:=Blob[BlobI].Area+(XMax-XMin-1);

// update the bounding box
          if XMin<Blob[BlobI].XMin then Blob[BlobI].XMin:=XMin;
          if XMax>Blob[BlobI].XMax then Blob[BlobI].XMax:=XMax;
          if Y2>Blob[BlobI].YMax then Blob[BlobI].YMax:=Y2;

// update the limits
          if XMin<Blob[BlobI].MinXAtY[Y2] then Blob[BlobI].MinXAtY[Y2]:=XMin;
          if XMax>Blob[BlobI].MaxXAtY[Y2] then Blob[BlobI].MaxXAtY[Y2]:=XMax;
          for X:=XMin to XMax do begin
            if Y2<Blob[BlobI].MinYAtX[X] then Blob[BlobI].MinYAtX[X]:=Y2;
            if Y2>Blob[BlobI].MaxYAtX[X] then Blob[BlobI].MaxYAtX[X]:=Y2;
          end;

// add all the strips below           
        end

// we've met another blob - merge with it
        else if Strip[I2,Y2].BlobI>0 then begin
          Result:=True;
          Blob[BlobCount].YMax:=Y2-1;
          MergeBlobStrips(BlobCount,Strip[I2,Y2].BlobI);
        end;


// check the next row
        Inc(Y2);
      end;
      if BlobCount=MaxBlobs then Exit;
    end;
  end;


// Blob[I1] will be merged into Blob[I2] -> Blob[I1] will be deleted
procedure TBlobFinder.MergeBlobStrips(I1,I2:Integer);
var
  Y,I,X : Integer;
begin
// mark the strips as belonging to Blob[I2]
  for Y:=Blob[I1].YMin to Blob[I1].YMax do begin
    for I:=1 to StripCount[Y] do begin
      if Strip[I,Y].BlobI=I1 then Strip[I,Y].BlobI:=I2;
    end;
  end;

// copy the limits
  with Blob[I2] do begin
    if Blob[I1].XMin<XMin then XMin:=Blob[I1].XMin;
    if Blob[I1].XMax>XMax then XMax:=Blob[I1].XMax;
    if Blob[I1].YMin<YMin then YMin:=Blob[I1].YMin;
    if Blob[I1].YMax>YMax then YMax:=Blob[I1].YMax;

// copy the boundary pixels
    for X:=Blob[I1].XMin to Blob[I1].XMax do begin
      if Blob[I1].MinYAtX[X]<MinYAtX[X] then MinYAtX[X]:=Blob[I1].MinYAtX[X];
      if Blob[I1].MaxYAtX[X]>MaxYAtX[X] then MaxYAtX[X]:=Blob[I1].MaxYAtX[X];
    end;
    for Y:=Blob[I1].YMin to Blob[I1].YMax do begin
      if Blob[I1].MinXAtY[Y]<MinXAtY[Y] then MinXAtY[Y]:=Blob[I1].MinXAtY[Y];
      if Blob[I1].MaxXAtY[Y]>MaxXAtY[Y] then MaxXAtY[Y]:=Blob[I1].MaxXAtY[Y];
    end;

// add the area
    Area:=Area+Blob[I1].Area;
  end;
end;

function TBlobFinder.XYInsideBlob(X,Y:Integer;I:Integer):Boolean;
begin
  with Blob[I] do begin
    Result:=(X>=XMin) and (X<=XMax) and (Y>=YMin) and (Y<=YMax);
  end;
end;

function TBlobFinder.HLineInsideBlob(X1,X2,Y,I:Integer):Boolean;
begin
  with Blob[I] do begin
    Result:=(Y>=YMin) and (Y<=YMax) and
            (((X1>=XMin) and (X1<=XMax)) or
             ((X2>=XMin) and (X2<=XMax)) or
             ((X1<=XMin) and (X2>=XMax)));
  end;
end;

function TBlobFinder.VLineInsideBlob(Y1,Y2,X,I:Integer):Boolean;
begin
  with Blob[I] do begin
    Result:=(X>=XMin) and (X<=XMax) and
            (((Y1>=YMin) and (Y1<=YMax)) or
             ((Y2>=YMin) and (Y2<=YMax)) or
             ((Y1<=YMin) and (Y2>=YMax)));
  end;
end;

function TBlobFinder.BlobsOverlap(I1,I2:Integer):Boolean;
begin
  with Blob[I2] do begin
    Result:=HLineInsideBlob(XMin,XMax,YMin-MergeD,I1) or
            HLineInsideBlob(XMin,XMax,YMax+MergeD,I1) or
            VLineInsideBlob(YMin,YMax,XMin-MergeD,I1) or
            VLineInsideBlob(YMin,YMax,XMax+MergeD,I1) or
            XYInsideBlob(Xc,Yc,I1);
  end;
end;

// Blob[I2] is absorbed into Blob[I1]
procedure TBlobFinder.MergeBlob(I1,I2:Integer);
var
  I,X,Y : Integer;
begin
  with Blob[I1] do begin
    if Blob[I2].XMin<XMin then XMin:=Blob[I2].XMin;
    if Blob[I2].XMax>XMax then XMax:=Blob[I2].XMax;
    if Blob[I2].YMin<YMin then YMin:=Blob[I2].YMin;
    if Blob[I2].YMax>YMax then YMax:=Blob[I2].YMax;
    for X:=Blob[I2].XMin to Blob[I2].XMax do begin
      if Blob[I2].MinYAtX[X]<MinYAtX[X] then MinYAtX[X]:=Blob[I2].MinYAtX[X];
      if Blob[I2].MaxYAtX[X]>MaxYAtX[X] then MaxYAtX[X]:=Blob[I2].MaxYAtX[X];
    end;
    for Y:=Blob[I2].YMin to Blob[I2].YMax do begin
      if Blob[I2].MinXAtY[Y]<MinXAtY[Y] then MinXAtY[Y]:=Blob[I2].MinXAtY[Y];
      if Blob[I2].MaxXAtY[Y]>MaxXAtY[Y] then MaxXAtY[Y]:=Blob[I2].MaxXAtY[Y];
    end;
    Area:=Area+Blob[I2].Area;
  end;

// sort the array so it's continuous
  for I:=I2 to BlobCount-1 do begin
    Blob[I]:=Blob[I+1];
  end;
  Dec(BlobCount);
end;

procedure TBlobFinder.MergeBlobs;
var
  I,I2       : Integer;
  BlobMerged : Boolean;
begin
  repeat
    BlobMerged:=False;
    I:=0;
    repeat
      Inc(I);
      I2:=I+1;
      while (I2<=BlobCount) do begin
        if BlobsOverlap(I,I2) or BlobsOverlap(I2,I) then begin
          MergeBlob(I,I2);
          BlobMerged:=True;
        end
        else Inc(I2);
      end;
    until (I>=(BlobCount-1));
  until not BlobMerged;
end;

procedure TBlobFinder.DrawStrips(Bmp:TBitmap);
var
  Y,I : Integer;
begin
  Bmp.Canvas.Pen.Color:=clRed;
  for Y:=0 to TrackH-1 do for I:=1 to StripCount[Y] do begin
    with Strip[I,Y] do begin//if (BlobI>0) and (Blob[BlobI].Area>MinArea) then begin
      Bmp.Canvas.MoveTo(XMin,Y);
      Bmp.Canvas.LineTo(XMax+1,Y);
    end;
  end;
end;

procedure TBlobFinder.DrawBlobs(Bmp:TBitmap;HiLit:Integer);
var
  I : Integer;
begin
  Bmp.Canvas.Brush.Style:=bsClear;
  for I:=1 to BlobCount do with Blob[I] do if Area>=MinArea then begin
    if I=HiLit then Bmp.Canvas.Pen.Color:=clYellow
    else Bmp.Canvas.Pen.Color:=clBlue;
    Bmp.Canvas.Rectangle(XMin,YMin,XMax+1,YMax+1);
  end;
end;


function TBlobFinder.SceneStatic:Boolean;
begin
  Result:=(BlobCount=0);
end;

procedure TBlobFinder.OutlinePixel(Bmp:TBitmap;X,Y:Integer);
const
  Red   = 128;//255;
  Green = 128;//255;
  Blue  = 128;//255;
var
  X2,Y2,I : Integer;
  Line    : PByteArray;
begin
  for Y2:=Y-1 to Y do if (Y2>=0) and (Y2<Bmp.Height) then begin
    Line:=Bmp.ScanLine[Y2];
    for X2:=X-1 to X do if (X2>0) and (X2<(Bmp.Width-1)) then begin
      I:=X2*3;
      Line^[I+0]:=Blue;
      Line^[I+1]:=Green;
      Line^[I+2]:=Red;
    end;
  end;
end;

procedure TBlobFinder.OutlineBlob(Bmp:TBitmap;B:Integer);
var
  X,Y : Integer;
begin
  with Blob[B] do begin
    for X:=XMin to XMax do begin
      Y:=MinYAtX[X];
      OutlinePixel(Bmp,X,Y);
      Y:=MaxYAtX[X];
      OutlinePixel(Bmp,X,Y);
    end;
    for Y:=YMin to YMax do begin
      X:=MinXAtY[Y];
      OutlinePixel(Bmp,X,Y);
      X:=MaxXAtY[Y];
      OutlinePixel(Bmp,X,Y);
    end;
  end;
end;

procedure TBlobFinder.OutlineBlobs(Bmp:TBitmap);
var
  B : Integer;
begin
  for B:=1 to BlobCount do OutlineBlob(Bmp,B);
end;

procedure TBlobFinder.Update;
begin
  FindStrips(BackGndFinder.SubtractedBmp);
  FindCoverFraction;
  FindBlobs;
  if BlobCount>0 then begin
    FindBlobCenters;
    if not AntiMerge then begin
      MergeBlobs;
      FindBlobCenters;
    end;
  end;
end;

function TBlobFinder.BlobRect(B:Integer):TRect;
begin
  with Blob[B] do begin
    Result.Left:=XMin;
    Result.Right:=XMax;
    Result.Top:=YMin;
    Result.Bottom:=YMax;
  end;
end;

procedure TBlobFinder.CopyBlobAreas(SrcBmp,DestBmp:TBitmap);
var
  B     : Integer;
  BRect : TRect;
begin
  for B:=1 to BlobCount do if Blob[B].Area>=MinArea then begin
    BRect:=BlobRect(B);
    DestBmp.Canvas.CopyRect(BRect,SrcBmp.Canvas,BRect);
  end;
end;

procedure TBlobFinder.InitForTracking;
begin
//
end;

function TBlobFinder.BestBlobForTracker:Integer;
const
  Border = 50;
var
  B           : Integer;
  BiggestArea : Integer;
begin
  Result:=0;
  for B:=1 to BlobCount do with Blob[B] do if Area>=MinArea then begin

// make sure it's in the camera view
//    if (XMin>Border) and (XMax<(Camera.ImageW-Border)) then begin
      if (Result=0) or (Area>BiggestArea) then begin
        BiggestArea:=Area;
        Result:=B;
      end;
//    end;
  end;
end;

procedure TBlobFinder.ShowPixelsAboveThreshold(Bmp:TBitmap);
var
  X,Y,I,Bpp : Integer;
  TestLine  : PByteArray;
  DrawLine  : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  ClearBmp(Bmp,clBlack);
  for Y:=0 to Bmp.Height-1 do begin
    TestLine:=BackGndFinder.SubtractedBmp.ScanLine[Y];
    DrawLine:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*Bpp;
      if TestLine^[I]>HiT then DrawLine^[I+1]:=255
      else if TestLine^[I]>LoT then DrawLine^[I+0]:=255;
    end;
  end;
end;

procedure TBlobFinder.FindCoverFraction;
var
  Count : Integer;
  Total : Integer;
  Y,I   : Integer;
begin
  Count:=0;
  Total:=TrackW*TrackH;
  for Y:=0 to TrackH-1 do for I:=1 to StripCount[Y] do begin
    Count:=Count+Strip[I,Y].XMax-Strip[I,Y].XMin+1;
  end;
  CoverFraction:=Count/Total;
end;

function TBlobFinder.RandomBlobWithMinArea:Integer;
var
  Count : Integer;
begin
  Count:=0;
  Result:=1+Random(BlobCount);
  while (Blob[Result].Area<MinArea) and (Count<BlobCount) do begin
    if Result<BlobCount then Inc(Result)
    else Result:=1;
    Inc(Count);
  end;
  if Blob[Result].Area<MinArea then Result:=0;
end;

function TBlobFinder.BlobsWithMinArea:Integer;
var
  B : Integer;
begin
  Result:=0;
  for B:=1 to BlobCount do begin
    if Blob[B].Area>=MinArea then Inc(Result);
  end;
end;

function TBlobFinder.CoverageInWindow(var Window:TWindow):Single;
var
  Area    : Integer;
  Y,I,L,R : Integer;
begin
  with Window do begin
    Area:=(X2-X1+1)*(Y2-Y1+1);
    Result:=0;
    for Y:=Y1 to Y2 do for I:=1 to StripCount[Y] do with Strip[I,Y] do begin
      if (XMax>X1) and (XMin<X2) then begin
        L:=Max(X1,XMin);
        R:=Min(X2,XMax);
        Result:=Result+(R-L)+1;
      end;
    end;
  end;
  Result:=Result/Area;
end;

procedure TBlobFinder.SetBlobXLimits;
var
  B,Y      : Integer;
  LastXMin : Integer;
  LastXMax : Integer;
begin
  for B:=1 to BlobCount do with Blob[B] do begin
    LastXMin:=XMin;
    LastXMax:=XMax;
    for Y:=YMin to YMax do begin
      if MinXAtY[Y]=MaxImageW-1 then MinXAtY[Y]:=LastXMin
      else LastXMin:=MinXAtY[Y];
      if MaxXAtY[Y]=0 then MaxXAtY[Y]:=LastXMax
      else LastXMax:=MaxXAtY[Y];
    end;
  end;
end;

function TBlobFinder.BlobsOverlap2(I1,I2:Integer):Boolean;
var
  X,Y : Integer;
begin
// see if any part of the trace is inside the other blob
  with Blob[I1] do begin
    X:=XMin;
    repeat
      Y:=MinYAtX[X];
      Result:=XYInBlob2(X,Y,I2);
      if not Result then begin
        Y:=MaxYAtX[X];
        Result:=XYInBlob2(X,Y,I2);
      end;
      Inc(X);
    until Result or (X>XMax);
    if not Result then begin
      Y:=YMin;
      repeat
        X:=MinXAtY[Y];
        Result:=XYInBlob2(X,Y,I2);
        if not Result then begin
          X:=MaxXAtY[Y];
          Result:=XYInBlob2(X,Y,I2);
        end;
        Inc(Y);
      until Result or (Y>YMax);
    end;
  end;
end;

procedure TBlobFinder.MergeBlobs2;
var
  I,I2       : Integer;
  BlobMerged : Boolean;
begin
  repeat
    BlobMerged:=False;
    I:=0;
    repeat
      Inc(I);
      I2:=I+1;
      while (I2<=BlobCount) do begin
        if BlobsOverlap2(I,I2) or BlobsOverlap2(I2,I) then begin
          MergeBlob(I,I2);
          BlobMerged:=True;
        end
        else Inc(I2);
      end;
    until (I>=(BlobCount-1));
  until not BlobMerged;
end;

function TBlobFinder.XYInBlob2(X,Y,I:Integer):Boolean;
var
  X1,Y1,X2,Y2 : Integer;
begin
  Result:=False;
  with Blob[I] do begin
    X1:=MinXAtY[Y];
    X2:=MaxXAtY[Y];
    if (X>=X1) and (X<=X2) then begin
      Y1:=MinYAtX[X]-MergeD;
      Y2:=MaxYAtX[X]+MergeD;
      if (Y>=Y1) and (Y<=Y2) then Result:=True;
    end;
  end;
end;

procedure TBlobFinder.DrawStripsInColor(Bmp:TBitmap);
var
  Y,I : Integer;
begin
  for Y:=0 to TrackH-1 do for I:=1 to StripCount[Y] do begin
    with Strip[I,Y] do begin
      Case BlobI of
        0 : Bmp.Canvas.Pen.Color:=clRed;
        1 : Bmp.Canvas.Pen.Color:=clGreen;
        2 : Bmp.Canvas.Pen.Color:=clBlue;
        3 : Bmp.Canvas.Pen.Color:=clPurple;
        else Bmp.Canvas.Pen.Color:=clOlive;
      end;
      Bmp.Canvas.MoveTo(XMin,Y);
      Bmp.Canvas.LineTo(XMax+1,Y);
    end;
  end;
end;


end.

// cull it if it's too small
     { if Blob[BlobCount].Area<=CullArea then begin
        for Y2:=Y to MaxY do for I2:=1 to StripCount[Y2] do begin
          if Strip[I2,Y2].BlobI=BlobCount then Strip[I2,Y2].BlobI:=-1;
        end;
        Dec(BlobCount);
      end
      else}

      //  if BlobCount>0 then begin
//    if not AntiMerge then MergeBlobs;
{    if AntiMerge then begin
      SetBlobXLimits;
      MergeBlobs2;
    end
    else MergeBlobs;}
//  end;
//  FindBlobCenters;

