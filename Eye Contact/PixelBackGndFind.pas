unit PixelBackGndFind;

interface

uses
  Global, Routines, SysUtils, Windows, Graphics;

type
  TPixelBackGndFinderInfo = packed record
    CoverThreshold : Integer;
    MaxCount       : Integer;
    Enabled        : Boolean;
    MinTime        : DWord;
    Reserved       : array[1..51] of Byte;
  end;

// background means the pixel is < threshold and is considered part of the backgnd
// trigger means the pixel was > threhold last frame and is being monitored to
// see if it remains > threshold for a long enough period of time
// if it does it will be considered changed
// the pixel will go back to being part of the background if it remains within
// it's changed value for long enough
  TPixelState = (psBackGnd,psTriggered,psChanged);

  TPixel = record
    State       : TPixelState;
    TriggerTime : DWord;
    ChangeTime  : DWord;
    ChangeValue : Integer;
  end;

  TPixelArray = array[0..MaxImageW-1,0..MaxImageH-1] of TPixel;

  TOnCellUpdate = procedure(Sender:TObject;CellRect:TRect) of Object;

  TPixelBackGndFinder = class(TObject)
  private
    function  GetInfo : TPixelBackGndFinderInfo;
    procedure SetInfo(NewInfo:TPixelBackGndFinderInfo);

  public
    Tag : Integer;

    AutoBackGnd : TAutoBackGndRecord;

    BackGndChanged : Boolean;

    Enabled     : Boolean;
    Threshold   : Integer;
    MaxCount    : Integer;
    MinTime     : DWord;

    Pixel : TPixelArray;

    property Info : TPixelBackGndFinderInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure SetBackGndBmp(Bmp:TBitmap);

    procedure InitPixels;
    procedure InitForTracking;


    procedure ShowAutoBackGndChangingPixels(Bmp:TBitmap);
    procedure ShowPixelsAboveAutoBackGndThreshold(Bmp:TBitmap);

    procedure ShowPixelStates(Bmp:TBitmap);

    procedure Update(Bmp:TBitmap);
  end;

var
  PixelBackGndFinder : TPixelBackGndFinder;

function DefaultPixelBackGndFinderInfo:TPixelBackGndFinderInfo;

implementation

uses
  BmpUtils, CameraU;

function DefaultPixelBackGndFinderInfo:TPixelBackGndFinderInfo;
begin
  with Result do begin
    Enabled:=True;
    CoverThreshold:=50;
    MaxCount:=30;
    MinTime:=60000;
    FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
  end;
end;

constructor TPixelBackGndFinder.Create;
begin
  inherited Create;
  BackGndChanged:=False;
end;

destructor TPixelBackGndFinder.Destroy;
begin
  inherited;
end;

function TPixelBackGndFinder.GetInfo:TPixelBackGndFinderInfo;
begin
  Result.Enabled:=Enabled;
  Result.CoverThreshold:=Threshold;
  Result.MaxCount:=MaxCount;
  Result.MinTime:=MinTime;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TPixelBackGndFinder.SetInfo(NewInfo:TPixelBackGndFinderInfo);
begin
  Enabled:=NewInfo.Enabled;
  Threshold:=NewInfo.CoverThreshold;
  MaxCount:=NewInfo.MaxCount;
  MinTime:=NewInfo.MinTime;
  if MinTime<1000 then MinTime:=1000;
end;

procedure TPixelBackGndFinder.InitPixels;
var
  X,Y : Integer;
begin
  for X:=0 to MaxImageW-1 do for Y:=0 to MaxImageH-1 do begin
    Pixel[X,Y].State:=psBackGnd;
  end;
end;

procedure TPixelBackGndFinder.InitForTracking;
begin
  InitPixels;
end;

procedure TPixelBackGndFinder.SetBackGndBmp(Bmp:TBitmap);
begin
  Camera.BackGndBmp.Canvas.Draw(0,0,Bmp);
  InitPixels;
  BackGndChanged:=True;
end;

procedure TPixelBackGndFinder.ShowPixelsAboveAutoBackGndThreshold(Bmp:TBitmap);
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

procedure TPixelBackGndFinder.ShowAutoBackGndChangingPixels(Bmp:TBitmap);
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

procedure TPixelBackGndFinder.ShowPixelStates(Bmp:TBitmap);
var
  X,Y,I,D          : Integer;
  Time,ElapsedTime : DWord;
  Line,BackGndLine : PByteArray;
begin
  Time:=GetTickCount;
  for Y:=0 to Camera.SubtractedBmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    BackGndLine:=Camera.BackGndBmp.ScanLine[Y];
    for X:=0 to Camera.SubtractedBmp.Width-1 do with Pixel[X,Y] do begin
      I:=X*3;
      Case State of
        psBackGnd : Move(BackGndLine^[I],Line^[I],3);

// red means triggered
        psTriggered :
          begin
            ElapsedTime:=Time-TriggerTime;
            D:=Round(255*ElapsedTime/MinTime);
            Line^[I+0]:=0;
            Line^[I+1]:=0;
            Line^[I+2]:=D;
          end;

// green means changed
        psChanged :
          begin
            ElapsedTime:=Time-ChangeTime;
            D:=Round(255*ElapsedTime/MinTime);
            Line^[I+0]:=D;
            Line^[I+1]:=0;
            Line^[I+2]:=0;
          end;
      end;
    end;
  end;
end;

procedure TPixelBackGndFinder.Update(Bmp:TBitmap);
var
  Time           : DWord;
  X,Y,I          : Integer;
  CurrentLine    : PByteArray;
  SubtractedLine : PByteArray;
  BackGndLine    : PByteArray;
begin
  Time:=GetTickCount;
  for Y:=0 to Bmp.Height-1 do begin
    CurrentLine:=Bmp.ScanLine[Y];
    SubtractedLine:=Camera.SubtractedBmp.ScanLine[Y];
    BackGndLine:=Camera.BackGndBmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do with Pixel[X,Y] do begin
      I:=X*3;
      Case State of

// if this pixel is considered part of the background, see if it's now above
// the threshold
        psBackGnd :
          if SubtractedLine^[I]>=Threshold then begin
            State:=psTriggered;
            TriggerTime:=Time;
          end;

// if this pixel is triggered, mark it as background if it's fallen below the
// threshold - if it's still above see if enough time has passed
        psTriggered :
          if SubtractedLine^[I]<Threshold then State:=psBackGnd
          else if (Time-TriggerTime)>=MinTime then begin
            State:=psChanged;
            ChangeValue:=CurrentLine^[I];
            ChangeTime:=Time;
          end;

// if this pixe
        psChanged :
          if (CurrentLine^[I]-ChangeValue)>Threshold then begin
            ChangeValue:=CurrentLine^[I];
            ChangeTime:=Time;
          end
          else if (Time-ChangeTime)>=MinTime then begin
            State:=psBackGnd;
            Move(CurrentLine^[I],BackGndLine^[I],3);
          end;
      end;
    end;
  end;
end;

end.
