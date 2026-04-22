unit Global;

interface

uses
  Graphics, Ipl, OpenCV;

const
  VersionStr = 'Airborne v1.00';

  Debug = True;
  FakeCamera = False;

  MaxFaces = 1;

//  ImageW = 329;
//  ImageH = 246;
  ImageW = 659;
  ImageH = 493;


  TrackW = ImageW;
  TrackH = ImageH;

  MaxTrackY = TrackH-1;

  CamW = ImageW;
  CamH = ImageH;

  FPS = 15;

  MaxImageW = ImageW;
  MaxImageH = ImageH;

  SmallW = ImageW div 2;
  SmallH = ImageH div 2;

  ImageBufferSize  =  MaxImageW*MaxImageH;
  CameraBufferSize = MaxImageW*MaxImageH*3;

  CRLF = #13+#10;

  HighlightedColor = clWhite;
  SelectedColor    = clLime;
  HandleColor      = clRed;

  MaxCalPts = 5;

type
  TCalPt = record
    CamX,CamY   : Single;
    ProjX,ProjY : Single;
    FixedCamX   : Single;
    FixedCamY   : Single;
    Reserved    : array[1..16] of Byte;
  end;
  TCalPtArray = array[1..MaxCalPts] of TCalPt;

  TBand = record
    Found     : Boolean;
    Tracked   : Boolean;
    X,Y,W,H   : Integer;
    Template  : PIplImage;
    TplResult : PIplImage;
  end;

  TBuffer = array[1..MaxImageW*MaxImageH*3] of Byte;

  TMask = array[0..ImageW-1,0..ImageH-1] of Boolean;
  PMask = ^TMask;

  TCameraBuffer = array[1..CameraBufferSize] of Byte;
  PCameraBuffer = ^TCameraBuffer;

  TMatrixData3x3 = array[1..3,1..3] of Single;

  TMatrixData3x4 = array[1..3,1..4] of Single;

  TImageBuffer = array[1..ImageBufferSize] of Byte;
  PImageBuffer = ^TImageBuffer;

  TWindow = record
    Left,Top     : Integer;
    Width,Height : Integer;
  end;

  TPixel = record
    X,Y : Integer;
  end;
  TExtCalPixelArray = array[1..5] of TPixel;

  TProjectorCalPixelArray = array[1..5] of TPixel;

  TFileName = String[127];

  TFolderName = String[100];

  TBackGndMode = (bmNone,bmRaw,bmSubtracted);
  TForeGndMode = (fmStrips,fmBlobs,fmWords);

  TNameStr = String[40];

  DWord = Longword;

  TKInfo = record
    K1,K2 : Single;
    Px,Py : Single;
    Skew  : Single;
    D     : array[1..4] of Single;
  end;

  TPixelPoint = record
    X,Y : Integer;
  end;
  TPixelPtArray = array[1..4] of TPixelPoint;

  TPoint3D = record
    X,Y,Z : Single;
  end;

  TPose = record
    X,Y,Z    : Single;
    Rx,Ry,Rz : Single;
  end;

  TSearchArea = record
    XMin,XMax : Integer;
    YMin,YMax : Integer;
  end;

  TPlane = record
    Point    : array[1..4] of TPoint3D;
    Finite   : Boolean;
    Nx,Ny,Nz : Single;
    A,B,C,D  : Single; // coefficients
  end;

  TPositionAndOrientation = record
    X,Y,Z    : Single;
    Pan      : Single;
    Tilt     : Single;
    Rotation : Single;
  end;

  TPointingLine = record
    StartPoint   : TPoint3D;
    U,V,W        : Double;
    Lambda,Mu,Nu : Double;
  end;

  TPoint2D = record
    X,Y : Single;
  end;

  TCalMeasurements = record
    D12,D23,D34,D14 : Single;
    D1C,D2C,D3C,D4C : Single;
  end;

  TCalPoint = record
      X,Y,Z     : Single;
      Pan,Tilt  : Single;
      PanTicks  : Integer;
      TiltTicks : Integer;
      Reserved  : array[1..8] of Byte;
    end;
  TCalPointArray = array[1..5] of TCalPoint;

  TRay = record
    Base   : TPoint3D;
    Vector : TPoint3D;
  end;

  TPlanePoint = record
    RelativeX : Single;
    RelativeY : Single;
    X,Y,Z     : Single;
    PixelX    : Single;
    PixelY    : Single;
  end;
  TPlanePointArray = array[1..10,1..10] of TPlanePoint;

  TRGBColor = record
    R,G,B : Single;
  end;

  TBGRPixel = record
    B,G,R : Byte;
  end;
  PBGRPixel = ^TBGRPixel;

  TRGBPixel = record
    R,G,B : Byte;
  end;
  PRGBPixel = ^TRGBPixel;

  TRGBAPixel = record
    R,G,B,A : Byte;
  end;
  PRGBAPixel = ^TRGBAPixel;

  TCropWindow = record
    X,Y : Integer;
    W,H : Integer;
  end;

  TDrawMode = (dmNormal,dmSubtracted);

  TCalPixel = record
    X,Y : Integer; // 8
  end;
  TCalPixelArray = array[1..MaxCalPts] of TCalPixel; // 40

  TCalMeasurementType = (mt1C3InLine,mt4C2InLine,mtAllInLine);

  TMetrePt = record
    X,Z : Single;
  end;
  TMetrePtArray = array[1..MaxCalPts] of TMetrePt;

  TMetricCalRecord = record
    Measurements    : TCalMeasurements;       // 32
    MeasurementType : TCalMeasurementType; // 1
    MetrePt         : TMetrePtArray;
    ProjPixel       : TCalPixelArray;      // 40
    HMatrixData     : TMatrixData3x3;
  end;

var
  ShowFrameRate : Boolean = False;
  DrawMode      : TDrawMode = dmNormal;

  ViewPortWidth  : Integer;
  ViewPortHeight : Integer;

  ScreenW : Integer;
  ScreenH : Integer;

implementation

end.

  ImageW : Integer;
  ImageH : Integer;

  CamW : Integer;
  CamH : Integer;

  MaxImageW : Integer;
  MaxImageH : Integer;

  SmallW : Integer;
  SmallH : Integer;


