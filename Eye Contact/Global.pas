unit Global;

interface

uses
  Windows, Graphics;

const
  MaxImageW = 640;
  MaxImageH = 480;
  VideoFPS  = 25;
  MaxVideos = 865;
  MaxFrames = 3000;
  MaxXCells = 80;
  MaxYCells = 40;
  VideoW    = 720;
  VideoH    = 576;
  SmallRect : TRect = (Left:0;Top:0;Right:160;Bottom:120);

type
  TAutoBackGndMode = (amNone,amPixel,amCell);

  TCropWindow = record
    X,Y : Integer;
    W,H : Integer;
  end;

  TBitmapData = array[0..VideoW*VideoH-1] of Byte;
  PBitmapData = ^TBitmapData;

  TRGBRecord = record
    Red   : Byte;
    Green : Byte;
    Blue  : Byte;
  end;
  TPalette = array[0..255] of TRGBRecord;

  TVideo = record
    IntroStart      : Integer;
    IntroEnd        : Integer;
    EyeContactStart : Integer;
    EyeContactEnd   : Integer;
    ExtroStart      : Integer;
    ExtroEnd        : Integer;
    Duration        : Integer;
    BmpData         : array[1..MaxFrames] of PBitmapData;
    Palette         : TPalette;
    DimPalette      : TPalette;
    Number          : Integer;
  end;
  PVideo = ^TVideo;
  TVideoArray = array[1..MaxVideos] of TVideo;

  TVideoFileHeader = record
    Frames  : Integer;
    W,H     : Integer;
    Palette : TPalette;
  end;

  TAutoBackGndRecord = record
    Enabled : Boolean;
    Period  : DWord;
    Armed   : Boolean;
    ArmTime : DWord;
  end;

  TFolderName = String[100];

  TPoint2D = record
    X,Y : Single;
  end;

  TPoint3D = record
    X,Y,Z : Single;
  end;

  TRay = record
    Base   : TPoint3D;
    Vector : TPoint3D;
  end;

  TPlane = record
    Point    : array[1..4] of TPoint3D;
    Finite   : Boolean;
    Nx,Ny,Nz : Single;
    A,B,C,D  : Single; // coefficients
  end;

  TTrackingShowOption = (soCellOutlines,soCoveredCells,soTriggeredCells,
                         soActiveCells,soPixelsOverThreshold);

  TTrackingShowOptionSet = set of TTrackingShowOption;

var
  TrackingShowOptions : TTrackingShowOptionSet;
  AutoBackGndMode     : TAutoBackGndMode;

implementation

end.


