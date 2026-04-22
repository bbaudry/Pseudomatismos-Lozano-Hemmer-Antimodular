unit BackGndFind;

interface

uses
  Global, Routines, SysUtils, Windows, Graphics, CameraU;

type
  TSubtractMethod = (smBrighter,smDarker,smAbsolute);

  TBackGndFinderInfo = record
    Threshold          : Integer;
    MaxCount           : Integer;
    Enabled            : Boolean;
    MinTime            : DWord;
    UpdateFullImage    : Boolean;
    MaxStaticTime      : DWord;
    FullImageThreshold : Integer;
    SubtractMethod     : TSubtractMethod;
    Reserved           : array[1..9] of Byte;
  end;

// background means the pixel is < threshold and is considered part of the backgnd
// trigger means the pixel was > threhold last frame and is being monitored to
// see if it remains > threshold for a long enough period of time
// if it does it will be considered changed
// the pixel will go back to being part of the background if it remains within
// it's changed value for long enough
  TPixelState = (psBackGnd,psTriggered,psChanged);

  TColorChangeValue = record
    R,G,B : Byte;
  end;

  TBgfPixel = record
    State       : TPixelState;
    TriggerTime : DWord;
    ChangeTime  : DWord;
    ChangeValue : TColorChangeValue;
  end;

  TBgfPixelArray = array[0..TrackW-1,0..TrackH-1] of TBgfPixel;

  TBackGndFinder = class(TObject)
  private
    function  GetInfo : TBackGndFinderInfo;
    procedure SetInfo(NewInfo:TBackGndFinderInfo);

  public
    Tag : Integer;

    BackGndBmp    : TBitmap;
    SubtractedBmp : TBitmap;

    BackGndChanged : Boolean;

    Enabled   : Boolean;
    Threshold : Integer;
    MaxCount  : Integer;
    MinTime   : DWord;

    Pixel : TBgfPixelArray;

    LastStaticTime : DWord;

    UpdateFullImage     : Boolean;
    MaxStaticTime       : DWord;
    FullImageThreshold  : Integer;
    FullImageBackGndAvg : Single;

    SubtractMethod : TSubtractMethod;

    property Info : TBackGndFinderInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure SetBackGndBmp(Bmp:TBitmap);

    procedure InitPixels;
    procedure InitForTracking;

    procedure DrawSubtractedBmp(Bmp:TBitmap);

    procedure ShowPixelsAboveThreshold(Bmp:TBitmap);
    procedure ShowPixelStates(Bmp:TBitmap);

    procedure LoadBackGndBmp;
    procedure SaveBackGndBmp;
    procedure Update(Bmp:TBitmap);
    procedure UpdateFullImageBackGndCheck;
    procedure SizeBmps;
  end;

var
  BackGndFinder : TBackGndFinder;

function DefaultBackGndFinderInfo:TBackGndFinderInfo;

implementation

uses
  BmpUtils, Math2D, BlobFind;

function DefaultBackGndFinderInfo:TBackGndFinderInfo;
begin
  with Result do begin
    Enabled:=True;
    Threshold:=30;
    MaxCount:=30;  // not used
    MinTime:=120000;
    UpdateFullImage:=True;
    MaxStaticTime:=90000;
    FullImageThreshold:=5;
    SubtractMethod:=smBrighter;
    FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
  end;
end;

constructor TBackGndFinder.Create;
begin
  inherited Create;
  BackGndBmp:=CreateImageBmp;
  ClearBmp(BackGndBmp,clBlack);
  SubtractedBmp:=CreateImageBmp;
  ClearBmp(SubtractedBmp,clBlack);
  BackGndChanged:=False;
  LoadBackGndBmp;
end;

destructor TBackGndFinder.Destroy;
begin
  SaveBackGndBmp;
  if Assigned(BackGndBmp) then BackGndBmp.Free;
  if Assigned(SubtractedBmp) then SubtractedBmp.Free;
  inherited;
end;

function TBackGndFinder.GetInfo:TBackGndFinderInfo;
begin
  Result.Enabled:=Enabled;
  Result.Threshold:=Threshold;
  Result.MaxCount:=MaxCount;
  Result.MinTime:=MinTime;
  Result.UpdateFullImage:=UpdateFullImage;
  Result.MaxStaticTime:=MaxStaticTime;
  Result.FullImageThreshold:=FullImageThreshold;
  Result.SubtractMethod:=SubtractMethod;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TBackGndFinder.SetInfo(NewInfo:TBackGndFinderInfo);
begin
  Enabled:=NewInfo.Enabled;
  Threshold:=NewInfo.Threshold;
  MaxCount:=NewInfo.MaxCount;
  MinTime:=NewInfo.MinTime;
  UpdateFullImage:=NewInfo.UpdateFullImage;
  MaxStaticTime:=NewInfo.MaxStaticTime;
  FullImageThreshold:=NewInfo.FullImageThreshold;
  SubtractMethod:=NewInfo.SubtractMethod;
end;

procedure TBackGndFinder.LoadBackGndBmp;
var
  FileName : String;
begin
  FileName:=Path+'Camera.bmp';
  if FileExists(FileName) then BackGndBmp.LoadFromFile(Path+'Camera.bmp')
  else ClearBmp(BackGndBmp,clBlack);
  BackGndBmp.PixelFormat:=pf24Bit;
end;

procedure TBackGndFinder.SaveBackGndBmp;
begin
  BackGndBmp.SaveToFile(Path+'Camera.bmp');
end;

procedure TBackGndFinder.InitPixels;
var
  X,Y : Integer;
begin
  for X:=0 to TrackW-1 do for Y:=0 to TrackH-1 do begin
    Pixel[X,Y].State:=psBackGnd;
  end;
end;

procedure TBackGndFinder.InitForTracking;
begin
  InitPixels;
  LastStaticTime:=GetTickCount;
end;

procedure TBackGndFinder.SetBackGndBmp(Bmp:TBitmap);
begin
  BackGndBmp.Canvas.Draw(0,0,Bmp);
  InitPixels;
  BackGndChanged:=True;
end;

procedure TBackGndFinder.DrawSubtractedBmp(Bmp:TBitmap);
begin
  if BlobFinder.UseColor then begin
    SubtractColorBmpAsmAbs(Bmp,BackGndBmp,SubtractedBmp);
  end
  else SubtractBmpAsmAbs(Bmp,BackGndBmp,SubtractedBmp);
end;

procedure TBackGndFinder.SizeBmps;
begin
  BackGndBmp.Width:=TrackW;
  BackGndBmp.Height:=TrackH;
  SubtractedBmp.Width:=TrackW;
  SubtractedBmp.Height:=TrackH;
end;

procedure TBackGndFinder.ShowPixelsAboveThreshold(Bmp:TBitmap);
var
  X,Y,I,Bpp   : Integer;
  ColorThresh : Integer;
  TestLine    : PByteArray;
  DrawLine    : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  ColorThresh:=Threshold*3;
  for Y:=0 to Bmp.Height-1 do begin
    TestLine:=SubtractedBmp.ScanLine[Y];
    DrawLine:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*Bpp;
      if (TestLine^[I]+TestLine^[I+1]+TestLine^[I+2])>ColorThresh then begin
        DrawLine^[I]:=255;
      end;
    end;
  end;
end;

procedure TBackGndFinder.ShowPixelStates(Bmp:TBitmap);
var
  X,Y,I,D          : Integer;
  Time,ElapsedTime : DWord;
  Line,BackGndLine : PByteArray;
begin
  Time:=GetTickCount;
  for Y:=0 to SubtractedBmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    BackGndLine:=BackGndBmp.ScanLine[Y];
    for X:=0 to SubtractedBmp.Width-1 do with Pixel[X,Y] do begin
      I:=X*3;
      Case State of
        psBackGnd : ;

// red means triggered
        psTriggered :
          begin
            ElapsedTime:=Time-TriggerTime;
            D:=Round(255*ElapsedTime/MinTime);
            if D>255 then D:=255;
            Line^[I+0]:=0;
            Line^[I+1]:=0;
            Line^[I+2]:=D;
          end;

// green means changed
        psChanged :
          begin
            ElapsedTime:=Time-ChangeTime;
            D:=Round(255*ElapsedTime/MinTime);
            if D>255 then D:=255;
            Line^[I+0]:=D;
            Line^[I+1]:=0;
            Line^[I+2]:=0;
          end;
      end;
    end;
  end;
end;

procedure TBackGndFinder.Update(Bmp:TBitmap);
var
  Time           : DWord;
  X,Y,I,V        : Integer;
  CurrentLine    : PByteArray;
  SubtractedLine : PByteArray;
  BackGndLine    : PByteArray;
  ColorThresh    : Integer;
begin
  DrawSubtractedBmp(Bmp);
  if not Enabled then Exit;
  ColorThresh:=Threshold*3;

  Time:=GetTickCount;
  for Y:=0 to Bmp.Height-1 do begin
    CurrentLine:=Bmp.ScanLine[Y];
    SubtractedLine:=SubtractedBmp.ScanLine[Y];
    BackGndLine:=BackGndBmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do with Pixel[X,Y] do begin
      I:=X*3;
      Case State of

// if this pixel is considered part of the background, see if it's now above
// the threshold
        psBackGnd :
          begin
            V:=SubtractedLine^[I]+SubtractedLine^[I+1]+SubtractedLine^[I+2];
            if V>=ColorThresh then begin
              State:=psTriggered;
              TriggerTime:=Time;
            end;
          end;

// if this pixel is triggered, mark it as background if it's fallen below the
// threshold - if it's still above see if enough time has passed
        psTriggered :
          begin
            V:=SubtractedLine^[I]+SubtractedLine^[I+1]+SubtractedLine^[I+2];
            if V<ColorThresh then State:=psBackGnd
            else if (Time-TriggerTime)>=MinTime then begin
              State:=psChanged;
              ChangeValue.R:=CurrentLine^[I+2];
              ChangeValue.G:=CurrentLine^[I+1];
              ChangeValue.B:=CurrentLine^[I+0];
              ChangeTime:=Time;
            end;
          end;

// if this pixel is changed, see if it's still changing
        psChanged :
          begin
            V:=(CurrentLine^[I]-ChangeValue.B)+
               (CurrentLine^[I+1]-ChangeValue.G)+
               (CurrentLine^[I+2]-ChangeValue.R);
            if V>=ColorThresh then begin
              ChangeValue.R:=CurrentLine^[I+2];
              ChangeValue.G:=CurrentLine^[I+1];
              ChangeValue.B:=CurrentLine^[I+0];
              ChangeTime:=Time;
            end

// if needs to be stable for at least min time before we update the reference
            else if (Time-ChangeTime)>=MinTime then begin
              State:=psBackGnd;
              BackGndLine^[I+0]:=CurrentLine^[I+0];
              BackGndLine^[I+1]:=CurrentLine^[I+1];
              BackGndLine^[I+2]:=CurrentLine^[I+2];
            end;
          end;
      end;
    end;
  end;
end;

procedure TBackGndFinder.UpdateFullImageBackGndCheck;
var
  Time : DWord;
begin
  Time:=GetTickCount;

// if there's too much action, reset the clock
  if FullImageBackGndAvg>=FullImageThreshold then LastStaticTime:=Time

// if enough time has past, take the backgnd
  else if (Time-LastStaticTime)>MaxStaticTime then begin
    SetBackGndBmp(Camera.Bmp);
    LastStaticTime:=Time;
  end;
end;

end.

