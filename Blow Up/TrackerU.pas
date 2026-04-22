unit TrackerU;

interface

uses
  Windows, Global, SysUtils, Graphics, Classes, BlobFind;

const
  MaxTrackerAverages = 64;

type
  TTrackerHistory = array[1..MaxTrackerAverages] of Integer;

  TTrackMode = (tmSearching,tmTracking);

  TTrackerInfo = record
    Enabled   : Boolean;
    XAverages : Integer;
    YAverages : Integer;
    MaxSpeed  : Single;
    Reserved  : array[1..248] of Byte;
  end;

  TTarget = record
    Found : Boolean;
    Xc,Yc : Integer; // center
  end;

  TTracker = class(TObject)
  private
    function  GetInfo:TTrackerInfo;
    procedure SetInfo(NewInfo:TTrackerInfo);

  public
    TrackMode : TTrackMode;
    Target    : TPixel;
    Enabled   : Boolean;
    XAverages : Integer;
    YAverages : Integer;
    XHistory  : TTrackerHistory;
    YHistory  : TTrackerHistory;
    XHistoryI : Integer;
    YHistoryI : Integer;
    MaxSpeed  : Single;
    Speed     : Single;
    LastTarget : TPixel;

    property Info : TTrackerInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure InitForTracking;
    procedure UpdateWithTarget(X,Y:Integer);
    procedure Update;
    procedure DrawTarget(Bmp:TBitmap);
  end;

var
  Tracker : TTracker;

function DefaultTrackerInfo:TTrackerInfo;

implementation

uses
  CameraU, BmpUtils, Routines, Main, TilerU, CellTrackerU;

function DefaultTrackerInfo:TTrackerInfo;
begin
  Result.Enabled:=True;//False;
  Result.XAverages:=6;
  Result.YAverages:=64;
  Result.MaxSpeed:=CrowdedMaxSpeed;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

constructor TTracker.Create;
begin
  inherited Create;
end;

destructor TTracker.Destroy;
begin
  inherited;
end;

function TTracker.GetInfo:TTrackerInfo;
begin
  Result.Enabled:=Enabled;
  Result.XAverages:=XAverages;
  Result.YAverages:=YAverages;
  Result.MaxSpeed:=MaxSpeed;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TTracker.SetInfo(NewInfo:TTrackerInfo);
begin
  Enabled:=NewInfo.Enabled;
  XAverages:=NewInfo.XAverages;
  YAverages:=NewInfo.YAverages;
  MaxSpeed:=NewInfo.MaxSpeed;
  if MaxSpeed=0 then MaxSpeed:=10;
end;

procedure TTracker.InitForTracking;
begin
  FillChar(XHistory,SizeOf(XHistory),0);
  FillChar(YHistory,SizeOf(YHistory),0);
  XHistoryI:=0;
  YHistoryI:=0;
  Speed:=0;
  FillChar(Target,SizeOf(Target),0);
  LastTarget:=Target;
end;

procedure TTracker.UpdateWithTarget(X,Y:Integer);
var
  Dx,Dy,I : Integer;
begin
// X
  if XHistoryI<XAverages then Inc(XHistoryI)
  else XHistoryI:=1;
  XHistory[XHistoryI]:=X;

// Y
  if YHistoryI<YAverages then Inc(YHistoryI)
  else YHistoryI:=1;
  YHistory[YHistoryI]:=Y;

// remember the last position
  LastTarget:=Target;

// update the averaging
  Target.X:=0;
  for I:=1 to XAverages do Target.X:=Target.X+XHistory[I];
  Target.X:=Round(Target.X/XAverages);

  Target.Y:=0;
  for I:=1 to YAverages do Target.Y:=Target.Y+YHistory[I];
  Target.Y:=Round(Target.Y/YAverages);

  Dx:=Target.X-LastTarget.X;
  Dy:=Target.Y-LastTarget.Y;

  Speed:=Sqrt(Sqr(Dx)+Sqr(Dy));
  if Speed>MaxSpeed then begin
    Dx:=Round(Dx*MaxSpeed/Speed);
    Dy:=Round(Dy*MaxSpeed/Speed);
    Target.X:=LastTarget.X+Dx;
    Target.Y:=LastTarget.Y+Dy;
  end;
  Tiler.ShiftCells(Dx,Dy);
end;

procedure TTracker.Update;
var
  B,X,Y,Area : Integer;
begin
  Speed:=0;
  if Enabled then begin
    Case TrackMethod of
      tmBlobs :
        begin
          B:=BlobFinder.BestBlobForTracker;
          if B>0 then with BlobFinder.Blob[B] do UpdateWithTarget(Xc,Yc);
        end;
      tmSegmenter :
        begin
          B:=CellTracker.BiggestBlob;
          if B>0 then begin
            CellTracker.FindBlobCenterAndArea(B,X,Y,Area);
            if (X>=TrackW) or (Y>=TrackH) then begin
              CellTracker.FindBlobCenterAndArea(B,X,Y,Area);
            end;
            if Area>=CellTracker.MinBlobArea then UpdateWithTarget(X,Y);
          end;
        end;
    end;
  end;
end;

procedure TTracker.DrawTarget(Bmp:TBitmap);
begin
  Bmp.Canvas.Pen.Color:=clBlue;
  Bmp.Canvas.Pen.Width:=3;
  DrawXHairs(Bmp,Target.X,Target.Y,7);
  Bmp.Canvas.Pen.Width:=1;
end;

end.


