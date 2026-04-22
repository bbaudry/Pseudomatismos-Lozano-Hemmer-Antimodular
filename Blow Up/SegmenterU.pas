unit SegmenterU;

interface

uses
  Global, Routines, SysUtils, Windows, Graphics, CameraU;

const
  MaxFGTime   = 120000;
  MaxAverages = 16;
  MaxSamples  = 1800;// Integer(FPS*MaxFGTime/1000);

type
  TSegmenterInfo = packed record
    Threshold      : Integer;
    MaxFGTime      : DWord;
    DriftThreshold : Integer;
    Reserved       : array[1..60] of Byte;
  end;

// background means the pixel is < threshold and is considered part of the backgnd
// trigger means the pixel was > threhold last frame and is being monitored to
// see if it remains > threshold for a long enough period of time
// if it does it will be considered changed
// the pixel will go back to being part of the background if it remains within
// it's changed value for long enough
  TPixelState = (psBackGnd,psForeGnd,psSampling);

  TPixel = record
    State         : TPixelState;
    Sample        : array[1..MaxSamples] of Single;
    SteadySamples : Integer;
    Mean          : Single;
    BackGndMean   : Single;
    Intensity     : Integer;
    ApparentI     : Integer;
    Dif           : Single;
    Drifting      : Boolean;
    OverThreshold : Boolean;
    FGTime        : DWord;
    LastI         : Integer;
    ChangeCount   : Integer;
  end;

  TPixelArray = array[0..159,0..119] of TPixel;

  TOnCellUpdate = procedure(Sender:TObject;CellRect:TRect) of Object;

  TSegmenter = class(TObject)
  private
    function  GetInfo : TSegmenterInfo;
    procedure SetInfo(NewInfo:TSegmenterInfo);

  public
    Pixel    : TPixelArray;
    SampleI  : Integer;
    Samples  : Integer;

    Threshold      : Integer;
    DriftThreshold : Integer;
    MaxFGTime      : DWord;

    property Info : TSegmenterInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure InitForTracking;

    procedure DrawIntensityBmp(Bmp:TBitmap);
    procedure DrawApparentIntensityBmp(Bmp:TBitmap);
    procedure DrawMeanBmp(Bmp:TBitmap);
    procedure DrawBackGndMeanBmp(Bmp:TBitmap);
    procedure DrawDeviatedBmp(Bmp:TBitmap);
    procedure DrawThresholdedBmp(Bmp:TBitmap);
    procedure DrawAgesBmp(Bmp:TBitmap);
    procedure DrawPixelStatesBmp(Bmp:TBitmap);
    procedure DrawDriftingBmp(Bmp:TBitmap);

    procedure ForceAllToBackGnd(Bmp:TBitmap);
    procedure Update(Bmp:TBitmap);
    procedure SetMaxFGTime(NewTime:DWord);
  end;

var
  Segmenter : TSegmenter;

function DefaultSegmenterInfo:TSegmenterInfo;

implementation

uses
  BmpUtils;

function DefaultSegmenterInfo:TSegmenterInfo;
begin
  with Result do begin
    Threshold:=35;
    MaxFGTime:=90000;
    DriftThreshold:=45;
    FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
  end;
end;

constructor TSegmenter.Create;
begin
  inherited Create;
  FillChar(Pixel,SizeOf(Pixel),0);
  SampleI:=1;
end;

destructor TSegmenter.Destroy;
begin
  inherited;
end;

function TSegmenter.GetInfo:TSegmenterInfo;
begin
  Result.Threshold:=Threshold;
  Result.MaxFGTime:=MaxFGTime;
  Result.DriftThreshold:=DriftThreshold;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TSegmenter.SetInfo(NewInfo:TSegmenterInfo);
begin
  Threshold:=NewInfo.Threshold;
  MaxFGTime:=NewInfo.MaxFGTime;
  DriftThreshold:=NewInfo.DriftThreshold;
end;

procedure TSegmenter.InitForTracking;
var
  X,Y : Integer;
begin
  Samples:=Round(FPS*MaxFGTime/1000);
  if Samples>MaxSamples then Samples:=MaxSamples;
  for Y:=0 to SmallRect.Bottom-1 do for X:=0 to SmallRect.Right-1 do begin
    Pixel[X,Y].SteadySamples:=0;
  end;
end;

procedure TSegmenter.SetMaxFGTime(NewTime:DWord);
begin
  MaxFGTime:=NewTime;
  Samples:=Round(FPS*MaxFGTime/1000);
  ForceAllToBackGnd(Camera.SmallBmp);
end;

procedure TSegmenter.DrawIntensityBmp(Bmp:TBitmap);
const
  MaxI = 255*3;
var
  X,Y,I,D : Integer;
  Line    : PByteArray;
begin
  for Y:=0 to SmallRect.Bottom-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to SmallRect.Right-1 do begin
      I:=X*3;
      D:=Round(255*Pixel[X,Y].Intensity/MaxI);
      Line^[I+0]:=D;
      Line^[I+1]:=D;
      Line^[I+2]:=D;
    end;
  end;
end;

procedure TSegmenter.DrawApparentIntensityBmp(Bmp:TBitmap);
var
  X,Y,I,D : Integer;
  Line    : PByteArray;
begin
  ClearBmp(Bmp,clBlack);
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*3;
      if Pixel[X,Y].ApparentI>255 then D:=255
      else D:=Pixel[X,Y].ApparentI;
      Line^[I+0]:=D;
      Line^[I+1]:=D;
      Line^[I+2]:=D;
    end;
  end;
end;

procedure TSegmenter.DrawMeanBmp(Bmp:TBitmap);
const
  MaxI = 255*3;
var
  X,Y,I,D : Integer;
  Line    : PByteArray;
begin
  ClearBmp(Bmp,clBlack);
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      D:=Round(255*Pixel[X,Y].Mean/MaxI);
      if D<0 then D:=0
      else if D>255 then D:=255;
      I:=X*3;
      Line^[I+0]:=D;
      Line^[I+1]:=D;
      Line^[I+2]:=D;
    end;
  end;
end;

procedure TSegmenter.DrawBackGndMeanBmp(Bmp:TBitmap);
var
  X,Y,D : Integer;
  Line  : PByteArray;
begin
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      D:=Round(Pixel[X,Y].BackGndMean/3);
      if D>255 then D:=255;
      Line[X*3+0]:=D;
      Line[X*3+1]:=D;
      Line[X*3+2]:=D;
    end;
  end;
end;

procedure TSegmenter.DrawDeviatedBmp(Bmp:TBitmap);
var
  X,Y,I,D : Integer;
  Line    : PByteArray;
begin
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*3;
      D:=Round(Abs(Pixel[X,Y].Intensity-Pixel[X,Y].Mean));
      if D>255 then D:=255;
      Line^[I+0]:=D;
      Line^[I+1]:=D;
      Line^[I+2]:=D;
    end;
  end;
end;

procedure TSegmenter.DrawThresholdedBmp(Bmp:TBitmap);
var
  X,Y,I : Integer;
  Line  : PByteArray;
begin
  ClearBmp(Bmp,clBlack);
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*3;
      if Pixel[X,Y].OverThreshold then Line^[I+2]:=255;
    end;
  end;
end;

procedure TSegmenter.DrawDriftingBmp(Bmp:TBitmap);
var
  X,Y,D,I : Integer;
  Line    : PByteArray;
begin
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      if Pixel[X,Y].Drifting then D:=255
      else D:=0;
      I:=X*3;
      Line^[I+0]:=D;
      Line^[I+1]:=D;
      Line^[I+2]:=D;
    end;
  end;
end;

procedure TSegmenter.DrawAgesBmp(Bmp:TBitmap);
var
  X,Y,D : Integer;
  Line  : PByteArray;
begin
  ClearBmp(Bmp,clBlack);
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      if Pixel[X,Y].State=psForeGnd then begin
        D:=Round(255*Pixel[X,Y].SteadySamples/Samples);
        if D>255 then D:=255;
      end
      else D:=0;
      Line[X*3+2]:=D;
    end;
  end;
end;

procedure TSegmenter.DrawPixelStatesBmp(Bmp:TBitmap);
var
  X,Y,I : Integer;
  Line  : PByteArray;
begin
  ClearBmp(Bmp,clBlack);
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do with Pixel[X,Y] do begin
      I:=X*3;
      Case State of
        psBackGnd  : ;
        psForeGnd  : Line^[I+0]:=255; // blue
        psSampling : Line^[I+2]:=255; // red
      end;
    end;
  end;
end;

procedure TSegmenter.ForceAllToBackGnd(Bmp:TBitmap);
var
  X,Y,I : Integer;
  V     : Single;
  Line  : PByteArray;
begin
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do with Pixel[X,Y] do begin
      State:=psBackGnd;
      I:=X*3;
      Intensity:=Line^[I]+Line^[I+1]+Line^[I+2];
      Mean:=Intensity;
      BackGndMean:=Mean;
      V:=Mean/Samples;
      for I:=1 to Samples do begin
        Sample[I]:=V;
      end;
      ChangeCount:=0;
      LastI:=Intensity;
    end;
  end;
end;

procedure TSegmenter.Update(Bmp:TBitmap);
var
  Time  : DWord;
  X,Y,I : Integer;
  Bpp   : Integer;
  V     : Single;
  Line  : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  Time:=GetTickCount;

  if SampleI<Samples then Inc(SampleI)
  else SampleI:=1;

  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do with Pixel[X,Y] do begin
      I:=X*Bpp;

      Intensity:=Line^[I]+Line^[I+1]+Line^[I+2];
      if Abs(LastI-Intensity)>DriftThreshold then Inc(ChangeCount);
      LastI:=Intensity;

      ApparentI:=Round(Intensity/3);
      Dif:=Abs(Intensity-BackGndMean);
      OverThreshold:=(Dif>=Threshold);
      if OverThreshold then begin
        if State=psBackGnd then begin
          FGTime:=Time;
          State:=psForeGnd;
        end;
      end
      else State:=psBackGnd;

// update the mean
      Mean:=Mean-Sample[SampleI];
      Sample[SampleI]:=Intensity/Samples;
      Mean:=Mean+Sample[SampleI];

// see if this pixel is stable
      Drifting:=Abs(Intensity-Mean)>DriftThreshold;
      if Drifting then SteadySamples:=0
      else begin
        Inc(SteadySamples);
        if SteadySamples>=Samples then begin
          BackGndMean:=Mean;
          State:=psBackGnd;
          SteadySamples:=0;
          V:=Mean/Samples;
          for I:=1 to Samples do begin
            Sample[I]:=V;
          end;
        end;
      end;
      if (State=psForeGnd) and ((Time-FGTime)>MaxFGTime) then begin
        BackGndMean:=Mean;
        State:=psBackGnd;
        SteadySamples:=0;
        V:=Mean/Samples;
        for I:=1 to Samples do begin
          Sample[I]:=V;
        end;
      end;
      if SampleI=1 then begin
        if ChangeCount>(Samples div 5) then begin
          BackGndMean:=Mean;
          State:=psBackGnd;
          SteadySamples:=0;
          V:=Mean/Samples;
          for I:=1 to Samples do begin
            Sample[I]:=V;
          end;
        end;
        ChangeCount:=0;
      end;
    end;
  end;
end;

end.

