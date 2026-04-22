 unit BmpMakerU;

interface

uses
  Windows, Dialogs, QT_Movies, QT_MacTypes, QT_QuickDraw, QT_Files, C_Types,
  QT_QuickTimeVR, QT_QTML, QT_QDOffScreen, QT_Events, QTime, QTUtils, Graphics,
  Jpeg, SysUtils;

type
  TOnLoadVideo = procedure(Sender:TObject;Count,Total:Integer) of Object;
  TOnLoadFrame = procedure(Sender:TObject;Count,Total:Integer) of Object;
  TOnDoneMake = procedure(Sender:TObject) of Object;

  TBmpMaker = class(TObject)
  private
    FOnLoadFrame : TOnLoadFrame;
    FOnLoadVideo : TOnLoadVideo;
    FOnDoneMake  : TOnDoneMake;

    GWorld : GWorldPtr;

    function  AbleToInitGWorld(W,H:Integer):Bool;
    function  AbleToLoadQTMovie(var QTMovie:Movie;FileName:String):Bool;

    procedure MakeBmpsFromMovie(QTMovie:Movie;V,W,H:Integer);

    procedure MakeBmpsFromMovieFile(SourceFileName,DestFolder:String;V,W,H:Integer);

  public
    Cancelled : Bool;
    Overwrite : Bool;

    property OnLoadFrame : TOnLoadFrame read FOnLoadFrame write FOnLoadFrame;
    property OnLoadVideo : TOnLoadVideo read FOnLoadVideo write FOnLoadVideo;
    property OnDoneMake  : TOnDoneMake read FOnDoneMake write FOnDoneMake;

    constructor Create;
    destructor  Destroy; override;

    procedure MakeBmpsFromAllMoviesInFolder(Folder:String;W,H:Integer);
  end;

var
  BmpMaker : TBmpMaker;

implementation

uses
  Routines, Global, TilerU, BmpUtils, FreeImage, VidFile;

constructor TBmpMaker.Create;
begin
  FOnLoadFrame:=nil;
  FOnLoadVideo:=nil;
  FOnDoneMake:=nil;
  GWorld:=nil;
  InitializeQTML(0); //Initialize QTML
  EnterMovies;       //Initialize QuickTime
end;

destructor TBmpMaker.Destroy;
begin
  ExitMovies;    //Terminate QuickTime
  TerminateQTML; //Terminate QTML
end;

function TBmpMaker.AbleToInitGWorld(W,H:Integer):Bool;
var
  MovieBox : Rect;
  Error    : OSErr;
begin
  Assert(not Assigned(GWorld),'');
  MovieBox.Left:=0;
  MovieBox.Top:=0;
  MovieBox.Right:=W;
  MovieBox.Bottom:=H;
  Error:=NewGWorld(@GWorld,0,MovieBox,nil,nil,0);
  if Error=0 then begin
    SetGWorld(GWorld,nil);
    Result:=True;
  end
  else Result:=False;
end;

function TBmpMaker.AbleToLoadQTMovie(var QTMovie:Movie;FileName:String):Bool;
var
  FS      : FSSpec;
  Error   : OSErr;
  ResID   : Short;
  Changed : Boolean;
  ResFile : Short;
begin
// open the movie file
  FS.Name:=FileName;
  FSMakeFSSpec(0,0,@FS.Name,@FS);
  try
    Error:=OpenMovieFile(FS,ResFile, fsRdPerm);
    if Error = noErr then begin
      ResID:=0; // 1st movie in file
      Error:=NewMovieFromFile(QTMovie,ResFile,@ResID,@FileName,NewMovieActive,
                              @Changed);
    end;
  finally
    CloseMovieFile(ResFile);
  end;
  Result:=(Error=noErr);
end;

procedure TBmpMaker.MakeBmpsFromMovie(QTMovie:Movie;V,W,H:Integer);
const
  MaxFramesForWU = 450;
type
  TBuffer = array[0..$FFFFFFF] of Byte;
  PBuffer = ^TBuffer;
var
  Error             : OSErr;
  Time              : Longint;
  PicH              : PicHandle;
  MovieBox          : Rect;
  X,Y,I,Frame,C,R   : Integer;
  Frames,BigY       : Integer;
  SrcPtr,DestPtr    : PBuffer; //yteArray;
  Duration          : LongInt;
  FilePath,FileName : String;
  SrcI,DestI        : Integer;
  BigImage24        : PFiBitmap;
  BigImage8         : PFiBitmap;
  Image24           : PFiBitmap;
  SmallImage24      : PFiBitmap;
  MovieW,MovieH     : Integer;
  Cols,Rows,Xo,Yo   : Integer;
begin
  GetMovieBox(QTMovie,MovieBox);
  MovieW:=MovieBox.Right-MovieBox.Left;
  MovieH:=MovieBox.Bottom-MovieBox.Top;
  MovieBox.Top:=0;
  MovieBox.Bottom:=MovieH;
  SetMovieBox(QTMovie,MovieBox);

  Duration:=GetMovieDuration(QTMovie);
  Frames:=(Duration div 100)+1;

  if Frames>MaxFramesForWu then begin
    Rows:=MaxFramesForWu;
    Cols:=1+((Frames-1) div Rows);
  end
  else begin
    Cols:=1;
    Rows:=Frames;
  end;
  Image24:=FreeImage_Allocate(MovieW,MovieH,24);    // image of 1 frame full size
  BigImage24:=FreeImage_Allocate(W*Cols,H*Rows,24); // image of all the small frames
  try

// grab the frames one by one
    Frame:=0;
    Time:=0;
    Cancelled:=False;
    BigY:=0;
    C:=1;
    R:=0;
    while (Time<=Duration) and (not Cancelled) do begin
      Inc(Frame);
      if Assigned(FOnLoadFrame) then FOnLoadFrame(Self,Frame,Frames);

      if R<Rows then Inc(R)
      else begin
        R:=1;
        Inc(C);
      end;

// get this frame
      PicH:=GetMoviePict(QTMovie,Time);
      Time:=Time+100;

// draw it in the GWorld
      if Assigned(PicH) then begin
        DrawPicture(PicH,@MovieBox);

// get access to the pixels
        LockPixels(GWorld.PortPixMap);
        SrcPtr:=PBuffer(GWorld.PortPixMap^.BaseAddr);

// copy them over to the Image24
        for Y:=0 to MovieH-1 do begin
          DestPtr:=PBuffer(FreeImage_GetScanLine(Image24,Y));
          for X:=0 to MovieW-1 do begin
            SrcI:=(Y*MovieW+X)*4;
            DestI:=X*3;
            for I:=0 to 2 do DestPtr^[DestI+I]:=SrcPtr^[SrcI+I];
          end;
        end;
        UnlockPixels(GWorld.PortPixMap);
        KillPicture(PicH);

// draw it over to the small bmp
        SmallImage24:=FreeImage_Rescale(Image24,80,64,FILTER_BICUBIC);//LANCZOS3);

// rotate it onto the big image
        Xo:=(C-1)*W;
        Yo:=(R-1)*H;
        for Y:=0 to H-1 do begin
          DestPtr:=PBuffer(FreeImage_GetScanLine(BigImage24,Y+Yo));
          for X:=0 to W-1 do begin
            SrcPtr:=PBuffer(FreeImage_GetScanLine(SmallImage24,X));
            for I:=0 to 2 do DestPtr^[(X+Xo)*3+I]:=SrcPtr^[(H-1-Y)*3+I];
          end;
        end;
        FreeImage_Unload(SmallImage24);
      end;
    end;

// convert it to 8 bit
    BigImage8:=FreeImage_ColorQuantize(BigImage24,FIQ_WUQUANT); // Xiaolin Wu

// create the video file
    FilePath:=Path+'Videos'+IntToStr(W)+'x'+IntToStr(H)+'\';
    if not DirectoryExists(FilePath) then CreateDir(FilePath);
    FileName:=FilePath+ThreeDigitIntStr(V)+'.vid';
    SaveVideoFile(BigImage8,FileName,Frames);//,Cols,Rows);
  finally
    FreeImage_Unload(Image24);
    FreeImage_Unload(BigImage24);
    FreeImage_Unload(BigImage8);
  end;
end;

procedure TBmpMaker.MakeBmpsFromMovieFile(SourceFileName,DestFolder:String;
                                          V,W,H:Integer);
var
  QTMovie  : Movie;
  FilePath : String;
  FileName : String;
begin
  if not Overwrite then begin
    FilePath:=Path+'Videos'+IntToStr(W)+'x'+IntToStr(H)+'\';
    FileName:=FilePath+ThreeDigitIntStr(V)+'.vid';
    if FileExists(FileName) then Exit;
  end;
  if AbleToLoadQTMovie(QTMovie,SourceFileName) then begin
    MakeBmpsFromMovie(QTMovie,V,W,H);
    DisposeMovie(QTMovie);
  end;
end;

procedure TBmpMaker.MakeBmpsFromAllMoviesInFolder(Folder:String;W,H:Integer);
var
  DestFolder : String;
  FileName   : String;
  I,Count    : Integer;
  Found      : Integer;
  SR         : TSearchRec;
begin
  DestFolder:=Tiler.VideoPath;
  if not DirectoryExists(DestFolder) then CreateDir(DestFolder);

// init the GWorld
  if AbleToInitGWorld(VideoW,VideoH) then begin

// count all the videos in the folder
    Count:=0;
    Found:=FindFirst(Folder+'\????.mov',faAnyFile,SR);
    while (Found=0) and (Count<MaxVideos) do begin
      Inc(Count);
      Found:=FindNext(SR);
    end;

// load the movies
    I:=0;
    Found:=FindFirst(Folder+'\????.mov',faAnyFile,SR);
    Cancelled:=False;
    while (Found=0) and (I<Count) and (not Cancelled) do begin
      Inc(I);
      if Assigned(FOnLoadVideo) then FOnLoadVideo(Self,I,Count);
      FileName:=Folder+'\'+SR.Name;
      MakeBmpsFromMovieFile(FileName,DestFolder,I,W,H);
      Found:=FindNext(SR);
    end;
    DisposeGWorld(GWorld);
  end;
  Tiler.MakeDimPalettes;
  if Assigned(FOnDoneMake) then FOnDoneMake(Self);
end;

end.



