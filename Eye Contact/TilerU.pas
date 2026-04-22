unit TilerU;

interface

uses
  Windows, Classes, Jpeg, Graphics, SysUtils, Dialogs, Forms, Global, VCellU;

type
  TCellArray = array[1..MaxXCells,1..MaxYCells] of TVideoCell;

  TTilerInfo = record
    XCells   : Integer;
    YCells   : Integer;
    CellW    : Integer;
    CellH    : Integer;
    DimScale : Single;
    Reserved : array[1..64] of Byte;
  end;

  TPaletteFile = file of TPalette;

  TOnFrameLoaded = procedure(Sender:TObject;Current,Total:Integer) of Object;
  TOnVideoLoaded = procedure(Sender:TObject;Current,Total:Integer) of Object;

  TTiler = class(TObject)
  private
    FOnFrameLoaded : TOnFrameLoaded;
    FOnVideoLoaded : TOnVideoLoaded;
    FOnDoneLoad    : TNotifyEvent;
    LastUpdateTime : DWord;

    function  GetInfo:TTilerInfo;
    procedure SetInfo(NewInfo:TTilerInfo);
    procedure PlaceCells;

    function  EntryFound(NameStr,Line:String;var Frames:Integer):Boolean;
    procedure ParseScrubDataLine(Line:String;V:Integer);
    procedure LoadScrubData(V:Integer);
    
  public
    Video         : TVideoArray;
    Videos        : Integer;
    Cell          : TCellArray;
    XCells        : Integer;
    YCells        : Integer;
    CellW         : Integer;
    CellH         : Integer;
    VideosLoaded  : Boolean;
    DimScale      : Single;
    LoadCancelled : Boolean;

    property Info : TTilerInfo read GetInfo write SetInfo;
    property OnFrameLoaded : TOnFrameLoaded read FOnFrameLoaded write FOnFrameLoaded;
    property OnVideoLoaded : TOnVideoLoaded read FOnVideoLoaded write FOnVideoLoaded;
    property OnDoneLoad    : TNotifyEvent read FOnDoneLoad write FOnDoneLoad;
    constructor Create;
    destructor  Destroy; override;

    function  AbleToLoadVideos:Boolean;
    procedure DrawOnBmp(Bmp:TBitmap);

    procedure InitForTracking;

    function  BmpsLoadedOk:Boolean;
    procedure SyncWithTracker;
    procedure UpdateScrubbing;
    procedure ShowEyeContactCells(Bmp:TBitmap);
    procedure DarkenNonActiveCells(Bmp:TBitmap);
    function  TotalBmpDataSize:Integer;
    function  LongestVideoDuration:Integer;
    function  NumberOfFrames:Integer;
    function  VideoPath:String;
    function  VideoFileName(V:Integer):String;
    procedure MakeDimPalettes;
    procedure ConvertVideoNumberToRowAndColumn(V:Integer;var R,C:Integer);
    function  ConvertRowAndColumnToVideoNumber(R,C:Integer):Integer;
    procedure TestVideos(Lines:TStrings);
    function  VideoWithNumber(Number:Integer):Integer;
  end;

function DefaultTilerInfo:TTilerInfo;

var
  Tiler : TTiler;

implementation

uses
  Routines, BmpUtils, BmpLoadU, TrackerU, CfgFile, VidFile, CameraU;

function DefaultTilerInfo:TTilerInfo;
begin
  Result.XCells:=40;
  Result.YCells:=20;
  Result.CellW:=64;
  Result.CellH:=80;
  Result.DimScale:=0.50;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

constructor TTiler.Create;
var
  V,F : Integer;
  C,R : Integer;
begin
  inherited;
  FOnVideoLoaded:=nil;
  FonFrameLoaded:=nil;
  FOnDoneLoad:=nil;
  for V:=1 to MaxVideos do begin
    Video[V].Number:=0;
    for F:=1 to MaxFrames do Video[V].BmpData[F]:=nil;
  end;
  for C:=1 to MaxXCells do for R:=1 to MaxYCells do Cell[C,R]:=TVideoCell.Create;
  VideosLoaded:=False;
end;

destructor TTiler.Destroy;
var
  V,F : Integer;
  C,R : Integer;
begin
  for V:=1 to Videos do for F:=Video[V].IntroStart to Video[V].ExtroEnd do begin
    if Assigned(Video[V].BmpData[F]) then FreeMem(Video[V].BmpData[F]);
  end;
  for C:=1 to MaxXCells do for R:=1 to MaxYCells do begin
    if Assigned(Cell[C,R]) then Cell[C,R].Free;
  end;
  inherited;
end;

function TTiler.GetInfo:TTilerInfo;
begin
  Result.CellW:=CellW;
  Result.CellH:=CellH;
  Result.XCells:=XCells;
  Result.YCells:=YCells;
  Result.DimScale:=DimScale;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TTiler.SetInfo(NewInfo:TTilerInfo);
begin
  CellW:=NewInfo.CellW;
  CellH:=NewInfo.CellH;
  XCells:=NewInfo.XCells;
  YCells:=NewInfo.YCells;
  DimScale:=NewInfo.DimScale;
  PlaceCells;
end;

procedure TTiler.PlaceCells;
var
  X,Y : Integer;
begin
  for X:=1 to XCells do for Y:=1 to YCells do begin
    Cell[X,Y].X:=(X-1)*CellW;
    Cell[X,Y].Y:=(Y-1)*CellH;
    Cell[X,Y].W:=CellW;
    Cell[X,Y].H:=CellH;
  end;
end;

procedure TTiler.InitForTracking;
var
  X,Y,V : Integer;
begin
  Assert(VideosLoaded,'');
  V:=0;
  for Y:=1 to YCells do for X:=1 to XCells do begin
    Inc(V);
    Cell[X,Y].Video:=@Video[V];
    Cell[X,Y].VideoI:=V;
    Cell[X,Y].InitForTracking;
  end;
  LastUpdateTime:=GetTickCount;
end;

function TTiler.EntryFound(NameStr,Line:String;var Frames:Integer):Boolean;
var
  I        : Integer;
  EntryStr : String;
begin
  I:=Pos(NameStr,Line);
  if I>0 then begin
    Inc(I,Length(NameStr));
    EntryStr:=Copy(Line,I,Length(Line)-I+1);
    Frames:=QuickTimeStringToFrames(EntryStr);
    if Frames<1 then Frames:=1
    else if Frames>MaxFrames then begin
      Frames:=MaxFrames;
    end;
    Result:=True;
  end
  else Result:=False;
end;

procedure TTiler.ParseScrubDataLine(Line:String;V:Integer);
begin
  with Video[V] do begin
    if EntryFound('duration:',Line,Duration) then Exit;
    if EntryFound('intro start:',Line,IntroStart) then Exit;
    if EntryFound('intro end:',Line,IntroEnd) then Exit;
    if EntryFound('eye contact start:',Line,EyeContactStart) then Exit;
    if EntryFound('eye contact end:',Line,EyeContactEnd) then Exit;
    if EntryFound('extro start:',Line,ExtroStart) then Exit;
    if EntryFound('extro end:',Line,ExtroEnd) then Exit;
  end;
end;

procedure TTiler.LoadScrubData(V:Integer);
var
  TxtFile  : TextFile;
  Line     : String;
  N        : Integer;
  FileName : String;
begin
  N:=Video[V].Number;
  FileName:=Path+'ScrubTxt\'+FourDigitIntStr(N)+'.txt';
  if FileExists(FileName) then begin
    Assign(TxtFile,FileName);
    try
      Reset(TxtFile);
      while not EOF(TxtFile) do begin
        Readln(TxtFile,Line);
        ParseScrubDataLine(Line,V);
      end;
    finally
      Close(TxtFile);
    end;
  end
  else begin
    ShowMessage(FileName+' missing');
  end;
end;

function TTiler.VideoPath:String;
begin
  Result:=Path+'Videos'+IntToStr(CellW)+'x'+IntToStr(CellH)+'\';
end;

function TTiler.VideoFileName(V:Integer):String;
begin
  Result:=VideoPath+ThreeDigitIntStr(V)+'.vid';
end;

function TTiler.AbleToLoadVideos:Boolean;
var
  V,F,I        : Integer;
  FileName     : String;
  Bmp          : TBitmap;
  VideoFile    : File;
  VideoHeader  : TVideoFileHeader;
  FrameSize    : Integer;
  VideoList    : TVideoList;
  VideosToLoad : Integer;
begin
  Camera.Stop;
  FrameSize:=CellW*CellH;
  VideosLoaded:=False;
  LoadCancelled:=False;
  VideosToLoad:=XCells*YCells;

// load the list of videos
  GenerateVideoList(VideoList,VideosToLoad);
  for V:=1 to VideosToLoad do Video[V].Number:=0;

// load the videos
  V:=0;
  repeat
    Inc(V);
    if Assigned(FOnVideoLoaded) then FOnVideoLoaded(Self,V,VideosToLoad);
    I:=VideoList[V].Index;
    if (I>0) and (I<=MaxVideos) then begin
      Video[V].Number:=I;
      LoadScrubData(V);
      FileName:=VideoFileName(I);
      LoadVideoFile(FileName,Video[V]);
    end;
  until (V=VideosToLoad) or (V=XCells*YCells) or (I=0) or LoadCancelled;
  Videos:=V;
  VideosLoaded:=True;
  MakeDimPalettes;
  if Assigned(FOnDoneLoad) then FOnDoneLoad(Self);
  Camera.Start;
end;

procedure TTiler.DrawOnBmp(Bmp:TBitmap);
var
  X,Y : Integer;
begin
  for X:=1 to XCells do for Y:=1 to YCells do begin
    Cell[X,Y].DrawOnBmp(Bmp);
  end;
end;

function TTiler.BmpsLoadedOk:Boolean;
begin
  Result:=True;
  if not VideosLoaded then begin
    BmpLoadFrm:=TBmpLoadFrm.Create(Application);
    try
      BmpLoadFrm.Initialize;
      BmpLoadFrm.ShowModal;
    finally
      BmpLoadFrm.Free;
    end;
    VideosLoaded:=True;
  end;
end;

procedure TTiler.SyncWithTracker;
var
  C,R : Integer;
begin
  for C:=1 to XCells do begin
    for R:=1 to YCells do begin
      if Tracker.Cell[C,R].Active then begin
        if Cell[C,R].ScrubMode<>smEyeContact then Cell[C,R].ScrubEyeContact;
      end
      else if Cell[C,R].ScrubMode=smEyeContact then begin
        if Random(100)>50 then Cell[C,R].ScrubIntro
        else Cell[C,R].ScrubExtro;
      end;
    end;
  end;
end;

procedure TTiler.UpdateScrubbing;
var
  C,R  : Integer;
  Time : DWord;
begin
  Time:=GetTickCount;
  for C:=1 to XCells do for R:=1 to YCells do begin
    Cell[C,R].UpdateScrubbing(Time);
  end;
end;

procedure TTiler.ShowEyeContactCells(Bmp:TBitmap);
var
  C,R : Integer;
begin
  Bmp.Canvas.Brush.Color:=clLime;
  Bmp.Canvas.Pen.Color:=clLime;
  for C:=1 to XCells do for R:=1 to YCells do with Cell[C,R] do begin
    if ScrubMode=smEyeContact then DrawCenter(Bmp);
  end;
end;

procedure TTiler.DarkenNonActiveCells(Bmp:TBitmap);
const
  DimValue = 128;
var
  C,R     : Integer;
  Y,Y1,Y2 : Integer;
  X,X1,X2 : Integer;
  Line    : PByteArray;
  SrcPtr  : PByte;
begin
  for R:=1 to YCells do begin
    Y1:=(R-1)*CellH;
    Y2:=Y1+CellH-1;
    for Y:=Y1 to Y2 do begin
      Line:=Bmp.ScanLine[Y];
      for C:=1 to XCells do begin
        if Cell[C,R].ScrubMode<>smEyeContact then begin
          X1:=(C-1)*CellW;
          X2:=X1+CellW-1;
          for X:=X1 to X2 do begin
            if Line^[X]<=DimValue then Line^[X]:=0
            else Line^[X]:=Line^[X]-DimValue;
          end;
        end;
      end;
    end;
  end;
end;

function TTiler.NumberOfFrames:Integer;
var
  V : Integer;
begin
  Result:=0;
  for V:=1 to Videos do begin
    Inc(Result,Video[V].ExtroEnd-Video[V].IntroStart+1);
  end;
end;

function TTiler.TotalBmpDataSize:Integer;
var
  Size : Integer;
begin
  Size:=CellW*CellH;
  Result:=NumberOfFrames*Size;;
end;

function TTiler.LongestVideoDuration:Integer;
var
  V : Integer;
begin
  Result:=0;
  for V:=1 to Videos do begin
    if Video[V].Duration>Result then Result:=Video[V].Duration;
  end;
end;

procedure TTiler.MakeDimPalettes;
var
  V,I : Integer;
begin
  for V:=1 to Videos do with Video[V] do begin
    for I:=0 to 255 do begin
      DimPalette[I].Red:=Round(Palette[I].Red*DimScale);
      DimPalette[I].Green:=Round(Palette[I].Green*DimScale);
      DimPalette[I].Blue:=Round(Palette[I].Blue*DimScale);
    end;
  end;
end;

procedure TTiler.ConvertVideoNumberToRowAndColumn(V:Integer;var R,C:Integer);
begin
  R:=1+(V-1) div XCells;
  C:=V-R*XCells;
end;

function TTiler.ConvertRowAndColumnToVideoNumber(R,C:Integer):Integer;
begin
  if (R<1) or (R>XCells) or (C<1) or (C>YCells) then Result:=0
  else Result:=R*XCells+C;
end;

procedure TTiler.TestVideos(Lines:TStrings);
var
  V,F,N   : Integer;
  VideoOk : Boolean;
begin
  for V:=1 to Videos do with Video[V] do begin
    VideoOk:=True;
    F:=IntroStart;
    while (F<=ExtroEnd) and VideoOk do begin
      if not Assigned(BmpData[F]) then begin
        N:=Video[V].Number;
        Lines.Add('V #'+IntToStr(V)+'Frame = '+IntToStr(F)+' of '+IntToStr(ExtroEnd));
        VideoOk:=False;
      end;
      Inc(F);
    end;
  end;
end;

function TTiler.VideoWithNumber(Number:Integer):Integer;
begin
  Result:=0;
  repeat
    Inc(Result);
  until (Video[Result].Number=Number) or (Result=MaxVideos);
  if Video[Result].Number<>Number then Result:=1;
end;

end.


