unit Global;

interface

uses
  Windows, Graphics;

const
  VersionStr = 'BlowUp version 1.45';
  MaxImageW  = 1024;
  MaxImageH  = 768;
  TrackW     = 640;
  TrackH     = 480;
  MaxTrackX  = TrackW-1;
  MaxTrackY  = TrackH-1;
  MaxXCells  = 64;
  MaxYCells  = 48;

  CrowdedMaxSpeed       = 5;
  CrowdedUntriggerDelay = 30000;

  QuietMaxSpeed         = 20;
  QuietUntriggerDelay   = 180000;

  SmallW    = 160;
  SmallH    = 120;
  SmallRect : TRect = (Left:0;Top:0;Right:SmallW;Bottom:SmallH);

type
  TPose = record
    X,Y,Z    : Single;
    Rx,Ry,Rz : Single;
  end;

  TFontName = String[64];

  TFontRecord = record
    Name  : TFontName;
    Color : TColor;
    Size  : Integer;
    Style : TFontStyles;
  end;

  TAutoBackGndMode = (amNone,amPixel,amCell);

  TCropWindow = record
    X,Y : Integer;
    W,H : Integer;
  end;

  TFolderName = String[100];

  TPixel = record
    X,Y : Integer;
  end;

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

  TWindow = record
    X1,Y1 : Integer;
    X2,Y2 : Integer;
  end;

  TTrackingShowOption =
    (soCellOutlines,soCoveredCells,soTriggeredCells,soActiveCells,
     soPixelsOverThreshold,soCellGroups);

  TTrackingShowOptionSet = set of TTrackingShowOption;

  TRunMode = (rmNone,rmStarting,rmRunning,rmCalibrating,rmLoading,rmDoingLoad);

  TOutlineMode = (omNone,omPixel,omCell);

  TBlowUpMode = (bmTracking,bmTimed);

  TTrackMethod = (tmNone,tmBlobs,tmSegmenter);

var
  TrackingShowOptions : TTrackingShowOptionSet;
  RunMode             : TRunMode;
  LowRes              : Boolean;
  NativeW,NativeH     : Integer;
  BlowUpMode          : TBlowUpMode;
  MinBlowUpTime       : DWord;
  MaxBlowUpTime       : DWord;
  MinCollapseTime     : DWord;
  MaxCollapseTime     : DWord;
  TrackMethod         : TTrackMethod;

implementation

end.


