unit BlobFindU;

interface

uses
  Global, Windows, Graphics, SysUtils, Math, Classes;

const
  MaxBlobs        = 10;
  MaxStripsPerRow = MaxImageW div 2;

type
  TBlobFinderInfo = packed record
    JumpD     : Integer;
    MergeD    : Integer;
    MinArea   : Integer;
    LoT,HiT   : Integer;
    UseITable : Boolean;
    YOffset   : Integer;
    Reserved  : array[1..59] of Byte;
  end;

  TStrip = record
    XMin,XMax : Integer;
    BlobI     : Integer;
  end;
  TStripArray = array[1..MaxStripsPerRow,0..MaxImageH-1] of TStrip;

  TStripCountArray = array[0..TrackH-1] of Integer;

  TBlob = record
    XMin,XMax : Integer;
    YMin,YMax : Integer;
    Area      : Integer;
    Xc,Yc     : Integer;
    Xm,Ym     : Single;
    BigEnough : Boolean;
    Used      : Boolean;
  end;
  TBlobArray = array[1..MaxBlobs] of TBlob;

  TBlobFinder = class(TObject)
  private
    Strip      : TStripArray;
    StripCount : TStripCountArray;

    function  StripsOverLap(Strip1,Strip2:TStrip):Boolean;
    function  XYInBlob(X,Y,I:Integer):Boolean;
    function  BlobsOverlap(I1,I2:Integer):Boolean;
    procedure MergeBlob(I1,I2:Integer);
    procedure FindBlobCenters;

    function  GetInfo:TBlobFinderInfo;
    procedure SetInfo(NewInfo:TBlobFinderInfo);
    function  HLineInsideBlob(X1, X2, Y, I: Integer): Boolean;
    function  VLineInsideBlob(Y1, Y2, X, I: Integer): Boolean;

  public
    Blob          : TBlobArray;
    BlobCount     : Integer;
    MinArea       : Integer;
    JumpD         : Integer;
    MergeD        : Integer;
    LoT,HiT       : Integer;
    MouseW        : Integer;
    UseITable     : Boolean;
    XYInTrackArea : TMask;
    YOffset       : Integer;

    property Info:TBlobFinderInfo read GetInfo write SetInfo;

    constructor Create;
    destructor Destroy; override;

    procedure Update(Bmp:TBitmap);
    procedure MergeBlobs;

    procedure FindStrips(Bmp:TBitmap);
    procedure FindBlobs;

    procedure DrawBlobStrips(Bmp:TBitmap);

    procedure DrawStrips(Bmp:TBitmap);
    procedure DrawBlobs(Bmp:TBitmap);
    procedure DrawThresholds(SrcBmp,DestBmp:TBitmap);

    procedure InitForTracking;
    procedure UpdateMouseTest(X,Y:Integer);
    procedure ShowBlobsInLines(Lines:TStrings);

    function  AnyValidBlobs:Boolean;

    procedure LoadTrackAreaMask;
    procedure SaveTrackAreaMask;
    procedure DrawTrackArea(Bmp:TBitmap);
    function  TrackAreaMaskFileName:String;

    function BiggestBlob:Integer;
    function NextBiggestBlob:Integer;

    procedure MarkAllBlobsUsed(Setting:Boolean);
    function BlobInsideTrackArea(B: Integer): Boolean;
  end;

var
  BlobFinder : TBlobFinder;

function DefaultBlobFinderInfo:TBlobFinderInfo;

implementation

uses
  BmpUtils, CameraU, Routines, MaskU;

function DefaultBlobFinderInfo:TBlobFinderInfo;
begin
  with Result do begin
    JumpD:=12;
    MergeD:=12;
    MinArea:=500;
    LoT:=15;
    HiT:=30;
    UseITable:=False;
    YOffset:=0;
    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

constructor TBlobFinder.Create;
begin
  inherited Create;
  MouseW:=100;
end;

destructor TBlobFinder.Destroy;
begin
  inherited;
end;

function TBlobFinder.GetInfo:TBlobFinderInfo;
begin
  Result.MinArea:=MinArea;
  Result.JumpD:=JumpD;
  Result.MergeD:=MergeD;
  Result.LoT:=LoT;
  Result.HiT:=HiT;
  Result.UseITable:=UseITable;
  Result.YOffset:=YOffset;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TBlobFinder.SetInfo(NewInfo:TBlobFinderInfo);
begin
  MinArea:=NewInfo.MinArea;
  JumpD:=NewInfo.JumpD;
  MergeD:=NewInfo.MergeD;
  LoT:=NewInfo.LoT;
  HiT:=NewInfo.HiT;
  UseITable:=NewInfo.UseITable;
  YOffset:=NewInfo.YOffset;
end;

procedure TBlobFinder.FindStrips(Bmp:TBitmap);
type
  TScanMode = (smLooking,smTracing,smJumping);
var
  X,Y,V,I,TY : Integer;
  JumpCount  : Integer;
  ScanMode   : TScanMode;
  Line       : PByteArray;
begin
// clear the strip count array
  FillChar(StripCount,SizeOf(StripCount),0);

// loop through the scanlines looking for strips
  for Y:=0 to TrackH-2 do begin
    TY:=Y;
    ScanMode:=smLooking;
    Line:=Bmp.ScanLine[Y];
    for X:=0 to MaxImageW-1 do if XYInTrackArea[X,Y] then begin
      I:=X*3;
      V:=Line^[I+0];

      Case ScanMode of

// if we're looking and the intensity>=HiT, make a new strip
        smLooking :
          if V>=HiT then begin
            Inc(StripCount[Y]);
            Strip[StripCount[Y],Y].XMin:=X;
            Strip[StripCount[Y],Y].XMax:=X;
            ScanMode:=smTracing;
          end;

// tracing - tracking with a lower threshold
        smTracing :
          if V<LoT then begin
            ScanMode:=smJumping;
            JumpCount:=1;
          end
          else Strip[StripCount[Y],Y].XMax:=X;

// jumping across dim pixels
        smJumping :
          if V>=LoT then begin
            ScanMode:=smTracing;
            Strip[StripCount[Y],Y].XMax:=X;
          end
          else if JumpCount<JumpD then Inc(JumpCount)
          else ScanMode:=smLooking;
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

procedure TBlobFinder.Update(Bmp:TBitmap);
var
  B : Integer;
begin
  FindStrips(Bmp);
  FindBlobs;
  MergeBlobs;
  FindBlobCenters;
  for B:=1 to MaxBlobs do with Blob[B] do begin
    YMin:=YMin+YOffset;
    YMax:=YMax+YOffset;
    Yc:=Yc+YOffset;
  end;
end;

procedure TBlobFinder.FindBlobCenters;
var
  B : Integer;
begin
  for B:=1 to BlobCount do with Blob[B] do begin
    BigEnough:=(Area>=MinArea);
    if BigEnough then begin

// find the pixel center
      Xc:=(XMin+XMax) div 2;
      Yc:=(YMin+YMax) div 2;
    end;  
  end;
end;

// Blob[I2] is merged into Blob[I1] - I2 will be deleted
procedure TBlobFinder.MergeBlob(I1,I2:Integer);
var
  I,Y : Integer;
begin
  with Blob[I1] do begin
    if Blob[I2].XMin<XMin then XMin:=Blob[I2].XMin;
    if Blob[I2].XMax>XMax then XMax:=Blob[I2].XMax;
    if Blob[I2].YMin<YMin then YMin:=Blob[I2].YMin;
    if Blob[I2].YMax>YMax then YMax:=Blob[I2].YMax;
    Area:=Area+Blob[I2].Area;
    for Y:=YMin to YMax do for I:=1 to StripCount[Y] do begin
      if Strip[I,Y].BlobI=I2 then Strip[I,Y].BlobI:=I1;
    end;
  end;

// sort the array so it's continuous
  for I:=I2 to BlobCount-1 do begin
    Blob[I]:=Blob[I+1];
  end;
  Dec(BlobCount);
end;

function TBlobFinder.XYInBlob(X,Y:Integer;I:Integer):Boolean;
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

{function TBlobFinder.BlobsOverlap(I1,I2:Integer):Boolean;
begin
  with Blob[I2] do begin
    Result:=HLineInsideBlob(XMin,XMax,YMin-MergeD,I1) or
            HLineInsideBlob(XMin,XMax,YMax+MergeD,I1) or
            VLineInsideBlob(YMin,YMax,XMin-MergeD,I1) or
            VLineInsideBlob(YMin,YMax,XMax+MergeD,I1) or
            XYInsideBlob(Xc,Yc,I1);
  end;
end;}

function TBlobFinder.BlobsOverlap(I1,I2:Integer):Boolean;
begin
  with Blob[I1] do begin
    Result:=XYInBlob(XMin,YMin,I2) or XYInBlob(XMax,YMin,I2) or
            XYInBlob(XMax,YMax,I2) or XYInBlob(XMin,YMax,I2);
  end;
  if not Result then with Blob[I2] do begin
    Result:=XYInBlob(XMin,YMin,I1) or XYInBlob(XMax,YMin,I1) or
            XYInBlob(XMax,YMax,I1) or XYInBlob(XMin,YMax,I1);
  end;
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

{procedure TBlobFinder.MergeBlobs;
var
  Count : Integer;
  I,I2  : Integer;
begin
  if BlobCount=0 then Exit;
  repeat
    Count:=BlobCount;
    I:=0;
    repeat
      Inc(I);
      I2:=I+1;
      while (I2<=BlobCount) do begin
        if BlobsOverlap(I,I2) then MergeBlob(I,I2)
        else Inc(I2);
      end;
    until (I>=(BlobCount-1));
  until (Count=BlobCount);
end;}

procedure TBlobFinder.DrawBlobStrips(Bmp:TBitmap);
var
  Y,I,C : Integer;
begin
  Bmp.Canvas.Pen.Color:=clWhite;
  for Y:=0 to TrackH-1 do for I:=1 to StripCount[Y] do with Strip[I,Y] do begin
    if BlobI>0 then begin
      Bmp.Canvas.MoveTo(XMin,Y);
      Bmp.Canvas.LineTo(XMax+1,Y);
    end;
  end;
end;

{procedure TBlobFinder.DrawBlobStripsOnTexture(Texture:TTexture);
var
  Y,I,C : Integer;
  Xs,Ys   : Single;
  C,L,I   : Integer;
  DataPtr : PRGBPixel;
begin
  SmokeTexture.Clear;

  for Y:=0 to TrackH-1 do for I:=1 to StripCount[Y] do with Strip[I,Y] do begin
    if BlobI>0 then begin
      Bmp.Canvas.MoveTo(XMin,Y);
      Bmp.Canvas.LineTo(XMax+1,Y);
    end;
  end;
end;}

procedure TBlobFinder.DrawStrips(Bmp:TBitmap);
var
  Y,I,C : Integer;
begin
  Bmp.Canvas.Pen.Color:=clRed;
  for Y:=0 to TrackH-1 do for I:=1 to StripCount[Y] do with Strip[I,Y] do begin
    Bmp.Canvas.MoveTo(XMin,Y);
    Bmp.Canvas.LineTo(XMax+1,Y);
  end;
end;

procedure TBlobFinder.DrawBlobs(Bmp:TBitmap);
const
  Size = 3;
var
  I : Integer;
begin
// frame it and show the peak
  Bmp.Canvas.Brush.Color:=clBlue;
  Bmp.Canvas.Font.Color:=clWhite;
  for I:=1 to BlobCount do with Blob[I] do if Area>=MinArea then begin
    Bmp.Canvas.FrameRect(Rect(XMin,YMin,XMax,YMax));
    DrawXHairs(Bmp,clBlue,Xc,Yc,3);
  end;
end;

procedure TBlobFinder.DrawThresholds(SrcBmp,DestBmp:TBitmap);
var
  X,Y,I,V  : Integer;
  Line     : PByteArray;
  DestLine : PByteArray;
  SrcPtr   : PByte;
  DestPtr  : PByte;
  DestBpp  : Integer;
begin
  DestBpp:=BytesPerPixel(DestBmp);
  for Y:=0 to TrackH-1 do begin
    Line:=SrcBmp.ScanLine[Y];
    DestLine:=DestBmp.ScanLine[Y];
    for X:=0 to SrcBmp.Width-1 do begin
      I:=X*DestBpp;
      V:=Line^[I+0];
      if V>HiT then begin
        DestLine^[I+0]:=0;   // B
        DestLine^[I+1]:=255; // G
        DestLine^[I+2]:=0;   // R
      end
      else if V>LoT then begin
        DestLine^[I+0]:=0;   // B
        DestLine^[I+1]:=255; // G
        DestLine^[I+2]:=255; // R
      end;
    end;
  end;
end;

procedure TBlobFinder.InitForTracking;
begin
  LoadTrackAreaMask;
end;

procedure TBlobFinder.FindBlobs;
var
  I,Y,Y2   : Integer;
  Ym,StartY  : Integer;
  I2,MaxY    : Integer;
  SkipD      : Integer;
  StripFound : Boolean;
begin
  Ym:=TrackH-1;

// reset the count and BlobI vars
  BlobCount:=0;
  for Y:=0 to Ym do begin
    for I:=1 to StripCount[Y] do Strip[I,Y].BlobI:=0;
  end;

// look through the strip array in Y
  for Y:=0 to Ym-1 do for I:=1 to StripCount[Y] do begin
    with Strip[I,Y] do if BlobI=0 then begin
      Inc(BlobCount);
      BlobI:=BlobCount;

// bounding box and area
      Blob[BlobI].XMin:=XMin;
      Blob[BlobI].XMax:=XMax;
      Blob[BlobI].YMin:=Y;
      Blob[BlobI].YMax:=Y;
      Blob[BlobI].Area:=XMax-XMin+1;
    end;

// check all the strips below this one for overlaps
    Y2:=Y;
    StartY:=Y+1;
    SkipD:=0;
    MaxY:=Min(Ym,Y+MergeD);
    while (SkipD<MergeD) and (Y2<MaxY) do begin
      Inc(Y2);
      StripFound:=False;

// look for an overlapping strip at this Y
      for I2:=1 to StripCount[Y2] do if StripsOverLap(Strip[I,Y],Strip[I2,Y2])
      then begin

// if we found an unassigned strip add it to the blob
        if Strip[I2,Y2].BlobI=0 then begin
          StripFound:=True;
          with Strip[I2,Y2] do begin
            BlobI:=Strip[I,Y].BlobI;
            Blob[BlobI].Area:=Blob[BlobI].Area+(XMax-XMin-1)*(1+Y2-StartY);;

// update the bounding box
            if XMin<Blob[BlobI].XMin then Blob[BlobI].XMin:=XMin;
            if XMax>Blob[BlobI].XMax then Blob[BlobI].XMax:=XMax;
            if Y2>Blob[BlobI].YMax then Blob[BlobI].YMax:=Y2;
          end;
        end;
      end;

// if we found a strip, start looking again from here
      if StripFound then begin
        SkipD:=0;
        StartY:=Y2+1;
        MaxY:=Min(Ym,Y+MergeD);
      end
      else Inc(SkipD);
    end;
    if BlobCount=MaxBlobs then Exit;
  end;
end;

procedure TBlobFinder.UpdateMouseTest(X,Y:Integer);
const
  MouseH = 100;
begin
  BlobCount:=1;
  with Blob[1] do begin

// set XMin and XMax
    XMin:=X-(MouseW div 2);
    if XMin<0 then XMin:=0;
    XMax:=XMin+MouseW;
    if XMax>=MaxImageW then begin
      XMax:=MaxImageW-1;
      XMin:=XMax-MouseW;
    end;

// set YMin and YMax
    YMin:=Y-(MouseH div 2);
    if YMin<0 then YMin:=0;
    YMax:=YMin+MouseH;
    if YMax>=TrackH then begin
      YMax:=TrackH-1;
      YMin:=YMax-MouseH;
    end;
    Area:=MouseW*MouseH;
  end;

// clear the strips
  for Y:=0 to TrackH-1 do begin
    StripCount[Y]:=0;
  end;
end;

procedure TBlobFinder.ShowBlobsInLines(Lines:TStrings);
var
  I : Integer;
begin
  for I:=1 to BlobCount do with Blob[I] do begin
    Lines.Add('#'+IntToStr(I)+' XMin:'+IntToStr(XMin)+' XMax:'+IntToStr(XMax)+
             ' YMin:'+IntToStr(YMin)+' YMax:'+IntToStr(YMax));
  end;
end;

function TBlobFinder.AnyValidBlobs:Boolean;
var
  B : Integer;
begin
  B:=0;
  Result:=False;
  while (not Result) and (B<BlobCount) do begin
    Inc(B);
    if Blob[B].Area>MinArea then Result:=True;
  end;
end;

procedure TBlobFinder.DrawTrackArea(Bmp:TBitmap);
begin
  ApplyMaskToBmp(@XYInTrackArea,Bmp);
end;

function TBlobFinder.TrackAreaMaskFileName:String;
begin
  Result:=Path+'Mask.dat';
end;

procedure TBlobFinder.LoadTrackAreaMask;
begin
  LoadMask(TrackAreaMaskFileName,@XYInTrackArea);
end;

procedure TBlobFinder.SaveTrackAreaMask;
begin
  SaveMask(TrackAreaMaskFileName,@XYInTrackArea);
end;

function TBlobFinder.BiggestBlob:Integer;
var
  BiggestArea,I : Integer;
begin
  Result:=0;
  BiggestArea:=0;
  for I:=1 to BlobCount do with Blob[I] do begin
    if (Area>=MinArea) and (Area>BiggestArea) then begin
      Result:=I;
      BiggestArea:=Area;
    end;
  end;
end;

function TBlobFinder.NextBiggestBlob:Integer;
var
  BiggestArea,I : Integer;
begin
  Result:=0;
  BiggestArea:=0;
  for I:=1 to BlobCount do with Blob[I] do if not Used then begin
    if (Area>=MinArea) and (Area>BiggestArea) then begin //and BlobInsideTrackArea(I) then
      Result:=I;
      BiggestArea:=Area;
    end;
  end;
  if Result>0 then Blob[Result].Used:=True;
end;

procedure TBlobFinder.MarkAllBlobsUsed(Setting:Boolean);
var
  B : Integer;
begin
  for B:=1 to MaxBlobs do Blob[B].Used:=Setting;
end;

function TBlobFinder.BlobInsideTrackArea(B:Integer):Boolean;
var
  X,Y : Integer;
begin
  with Blob[B] do begin

    if (XMin<0) or (XMax>=ImageW) or (YMin<0) or (YMax>=ImageH) then begin
      Result:=False;
      Exit;
    end

    else begin
      Result:=True;
      Y:=YMin;
      repeat
        X:=XMin;
        repeat
          if not XYInTrackArea[X,Y] then Result:=False
          else Inc(X);
        until (X>XMax) or not Result;
        Inc(Y);
      until (Y>YMax) or not Result;
    end;
  end;
end;

end.

procedure TBlobFinder.

// find the height of the target in pixels - the camera is sideways so use X
      H:=XMax-XMin;

// find how far up from their feet we need to go in pixels
      Yo:=Round(H*YOffsetFraction);
      ProjPt:=Projector.PixelFromCamXY(XMax-Yo,Yc);

// the OpenGL Y is inverted relative to th pixel point
      ProjPt.Y:=Projector.Window.Height-ProjPt.Y;
      BlobPos.X:=ViewPortXToGridX(ProjPt.X);
      BlobPos.Y:=ViewPortYToGridY(ProjPt.Y);
      Wd:=(YMax-YMin);// shr 2;
 //     Ht:=(XMax-XMin) shr 2;
      Ht:=Wd;

      Rz:=0;



