 unit JpgMakerU;

interface

uses
  Windows, Dialogs, QT_Movies, QT_MacTypes, QT_QuickDraw, QT_Files, C_Types,
  QT_QuickTimeVR, QT_QTML, QT_QDOffScreen, QT_Events, QTime, QTUtils, Graphics,
  Jpeg, SysUtils;

type
  TOnLoadVideo = procedure(Sender:TObject;Count,Total:Integer) of Object;
  TOnLoadFrame = procedure(Sender:TObject;Count,Total:Integer;var Cancelled:Bool) of Object;
  TOnDoneMake = procedure(Sender:TObject) of Object;

  TJpgMaker = class(TObject)
  private
    FOnLoadFrame : TOnLoadFrame;
    FOnLoadVideo : TOnLoadVideo;
    FOnDoneMake  : TOnDoneMake;

    GWorld : GWorldPtr;

    function  AbleToInitGWorld(W,H:Integer):Bool;
    function  AbleToLoadQTMovie(var QTMovie:Movie;FileName:String):Bool;

    procedure MakeJpgsFromMovie(QTMovie:Movie;V,W,H:Integer;var Cancelled:Bool);

    procedure MakeJpgsFromMovieFile(SourceFileName,DestFolder:String;V,W,H:Integer;var Cancelled:Bool);

  public
    property OnLoadFrame : TOnLoadFrame read FOnLoadFrame write FOnLoadFrame;
    property OnLoadVideo : TOnLoadVideo read FOnLoadVideo write FOnLoadVideo;
    property OnDoneMake  : TOnDoneMake read FOnDoneMake write FOnDoneMake;

    constructor Create;
    destructor  Destroy; override;

    procedure MakeJpgsFromAllMoviesInFolder(Folder:String;W,H:Integer);
  end;

var
  JpgMaker : TJpgMaker;

implementation

uses
  Routines, Global;

constructor TJpgMaker.Create;
begin
  FOnLoadFrame:=nil;
  FOnLoadVideo:=nil;
  FOnDoneMake:=nil;
  GWorld:=nil;
  InitializeQTML(0); //Initialize QTML
  EnterMovies;       //Initialize QuickTime
end;

destructor TJpgMaker.Destroy;
begin
  ExitMovies;    //Terminate QuickTime
  TerminateQTML; //Terminate QTML
end;

function TJpgMaker.AbleToInitGWorld(W,H:Integer):Bool;
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

function TJpgMaker.AbleToLoadQTMovie(var QTMovie:Movie;FileName:String):Bool;
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

procedure TJpgMaker.MakeJpgsFromMovie(QTMovie:Movie;V,W,H:Integer;var Cancelled:Bool);
var
  Error            : OSErr;
  Time             : Longint;
  PicH             : PicHandle;
  MovieBox         : Rect;
  BasePtr          : PByte;
  X,Y,I,Frame      : Integer;
  Frames           : Integer;
  SrcLine,DestLine : PByteArray;
  Duration         : LongInt;
  Bmp,SmallBmp     : TBitmap;
  RotatedBmp       : TBitmap;
  Jpg              : TJpegImage;
  JpgPath,FileName : String;
  SmallRect        : TRect;
begin
  GetMovieBox(QTMovie,MovieBox);
  Bmp:=TBitmap.Create;
  SmallBmp:=TBitmap.Create;
  RotatedBmp:=TBitmap.Create;
  Jpg:=TJpegImage.Create;
  try
    Bmp.Width:=MovieBox.Right-MovieBox.Left;
    Bmp.Height:=MovieBox.Bottom-MovieBox.Top;
    Bmp.PixelFormat:=pf32Bit;
    SmallBmp.Width:=H;  // the image will be rotated
    SmallBmp.Height:=W;
    SmallBmp.PixelFormat:=pf32Bit;
    SmallRect.Left:=0;
    SmallRect.Top:=0;
    SmallRect.Right:=H;
    SmallRect.Bottom:=W;
    RotatedBmp.Width:=W; // this one will be oriented the way we want
    RotatedBmp.Height:=H;
    RotatedBmp.PixelFormat:=pf32Bit;

// grab the frames one by one
    Duration:=GetMovieDuration(QTMovie);
    Frames:=Duration div 100;
    JpgPath:=Path+'Jpgs'+IntToStr(W)+'x'+IntToStr(H)+'\V'+ThreeDigitIntStr(V);
    if not DirectoryExists(JpgPath) then CreateDir(JpgPath);
    Frame:=0;
    Time:=0;
    Cancelled:=False;
    while (Time <= Duration) and (not Cancelled) do begin
      Inc(Frame);
      if Assigned(FOnLoadFrame) then FOnLoadFrame(Self,Frame,Frames,Cancelled);

// get this frame
      PicH:=GetMoviePict(QTMovie,Time);
      Time:=Time+100;

// draw it in the GWorld
      if Assigned(PicH) then begin
        DrawPicture(PicH,@MovieBox);

// get access to the pixels
        LockPixels(GWorld.PortPixMap);
        BasePtr:=PByte(GWorld.PortPixMap^.BaseAddr);

// copy them over to the bitmap
        for Y:=0 to Bmp.Height-1 do begin
          DestLine:=Bmp.ScanLine[Y];
          Move(BasePtr^,DestLine^,Bmp.Width*4);
          Inc(BasePtr,Bmp.Width*4);
        end;
        UnlockPixels(GWorld.PortPixMap);
        KillPicture(PicH);

// draw it over to the small bmp
        SmallBmp.Canvas.StretchDraw(SmallRect,Bmp);

// draw the rotated bmp
        for Y:=0 to H-1 do begin
          DestLine:=RotatedBmp.ScanLine[H-1-Y];
          for X:=0 to W-1 do begin
            SrcLine:=SmallBmp.ScanLine[X];
            for I:=0 to 3 do DestLine^[X*4+I]:=SrcLine^[Y*4+I];
          end;
        end;

// save it
        Jpg.Assign(RotatedBmp);
        FileName:=JpgPath+'\'+FourDigitIntStr(Frame)+'.jpg';
        Jpg.SaveToFile(FileName);
      end;
    end;
  finally
    if Assigned(Bmp) then Bmp.Free;
    if Assigned(SmallBmp) then SmallBmp.Free;
    if Assigned(RotatedBmp) then RotatedBmp.Free;
    if Assigned(Jpg) then Jpg.Free;
  end;
end;


procedure TJpgMaker.MakeJpgsFromMovieFile(SourceFileName,DestFolder:String;
                                          V,W,H:Integer;var Cancelled:Bool);
var
  QTMovie : Movie;
begin
  if AbleToLoadQTMovie(QTMovie,SourceFileName) then begin
    MakeJpgsFromMovie(QTMovie,V,W,H,Cancelled);
    DisposeMovie(QTMovie);
  end;
end;

procedure TJpgMaker.MakeJpgsFromAllMoviesInFolder(Folder:String;W,H:Integer);
var
  DestFolder : String;
  FileName   : String;
  I,Count    : Integer;
  Found      : Integer;
  SR         : TSearchRec;
  Cancelled  : Bool;
begin
  DestFolder:=Path+'Jpgs'+IntToStr(W)+'x'+IntToStr(H);
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
      MakeJpgsFromMovieFile(FileName,DestFolder,I,W,H,Cancelled);
      Found:=FindNext(SR);
    end;
    DisposeGWorld(GWorld);
  end;
  if Assigned(FOnDoneMake) then FOnDoneMake(Self);
end;

end.





