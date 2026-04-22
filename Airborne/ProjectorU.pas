unit ProjectorU;

interface

uses
  CameraU, Graphics, MatrixU, Global, Forms, MemoFrmU, CalU, SysUtils;

const
  MaxCalPts = 5;

type
  TProjectorInfo = record
    HData       : TMatrixData3x3;
    CalPt       : TCalPtArray;
    CfgFileName : Global.TFileName;
    Window      : TWindow;
    MetricCal   : TMetricCalRecord;
    Enabled     : Boolean;
    Reserved    : array[1..255] of Byte;
  end;

  TProjector = class(TObject)
  private
    HInvMatrix    : TMatrix;
    ProjPtMatrix  : TMatrix;
    CamPtMatrix   : TMatrix;
    MetrePtMatrix : TMatrix;

    MetricMatrix    : TMatrix;
    MetricInvMatrix : TMatrix;

    function  GetInfo:TProjectorInfo;
    procedure SetInfo(NewInfo:TProjectorInfo);

    procedure FindMetricCalMetrePts;

  public
    Enabled     : Boolean;
    HMatrix     : TMatrix;
    CfgFileName : TFileName;
    CalPt       : TCalPtArray;
    Window      : TWindow;
    MetricCal   : TMetricCalRecord;
    MaskBmp     : TBitmap;

    property Info:TProjectorInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    function PixelFromCamXY(X,Y:Integer):TPixel;
    function ClipXPixelToWindow(Pixel:Single):Integer;
    function ClipYPixelToWindow(Pixel:Single):Integer;

    procedure FindMetricMatrices(Normalize:Boolean);
    procedure FindMetricMatrices2;
    function  MetreXZToPixelXY(X,Z:Single):TPixelPoint;
    function  MetreXZToPixelXYNoClip(X,Z:Single):TPixelPoint;

    function  PixelXYToMetrePt(X,Y:Integer):TMetrePt;

    procedure ShowMetricCalDetails;
    procedure InitFromCalibrator(Calibrator:TCalibrator);
    procedure CopyMetricCalPtsFromCalPts;

    procedure DrawCalPts(Bmp:TBitmap);
    procedure DrawFixedCalPts(Bmp:TBitmap);
    procedure DrawMetricCalPts(Bmp:TBitmap);

    function  MaskBmpFileName:String;
    procedure CreateAndLoadMaskBmp;
    procedure SaveMaskBmp;
    procedure FreeMaskBmp;
  end;

var
  Projector : TProjector;

function DefaultProjectorInfo:TProjectorInfo;

implementation

uses
  Math2D, Routines, BmpUtils;

function DefaultProjectorInfo:TProjectorInfo;
begin
  with Result do begin
    Enabled:=True;
    FillChar(HData,SizeOf(HData),0);
    CfgFileName:='c:\Default.cfg';
    FillChar(CalPt,SizeOf(CalPt),0);
    Window.Left:=Screen.Width div 2;
    Window.Top:=0;
    Window.Width:=Screen.Width div 2;
    Window.Height:=Screen.Height;

    FillChar(MetricCal,SizeOf(MetricCal),0);
    MetricCal.MeasurementType:=mt4C2InLine;

    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

constructor TProjector.Create;
begin
// between the projector and the camera
  HMatrix:=TMatrix.Create(3,3);

// between the projector and the real world - ie metres
  MetricMatrix:=TMatrix.Create(3,3);
  MetricInvMatrix:=TMatrix.Create(3,3);

// matrices used in homography computations
  CamPtMatrix:=TMatrix.Create(3,1);
  ProjPtMatrix:=TMatrix.Create(3,1);
  MetrePtMatrix:=TMatrix.Create(3,1);

  MaskBmp:=nil;
end;

destructor TProjector.Destroy;
begin
  if Assigned(HMatrix) then HMatrix.Free;
  if Assigned(MetricMatrix) then MetricMatrix.Free;
  if Assigned(MetricInvMatrix) then MetricInvMatrix.Free;

  if Assigned(CamPtMatrix) then CamPtMatrix.Free;
  if Assigned(ProjPtMatrix) then ProjPtMatrix.Free;
  if Assigned(MetrePtMatrix) then MetrePtMatrix.Free;

  FreeMaskBmp;
end;

function TProjector.GetInfo:TProjectorInfo;
var
  R,C : Integer;
begin
  Result.Enabled:=Enabled;
  for R:=1 to 3 do for C:=1 to 3 do Result.HData[R,C]:=HMatrix.Cell[R,C];
  Result.CfgFileName:=CfgFileName;
  Result.CalPt:=CalPt;
  Result.Window:=Window;

  MetricCal.HMatrixData:=MetricMatrix.GetData3x3;
  Result.MetricCal:=MetricCal;

  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TProjector.SetInfo(NewInfo:TProjectorInfo);
var
  R,C : Integer;
begin
  Enabled:=NewInfo.Enabled;
  for R:=1 to 3 do for C:=1 to 3 do HMatrix.Cell[R,C]:=NewInfo.HData[R,C];
  CfgFileName:=NewInfo.CfgFileName;
  CalPt:=NewInfo.CalPt;

  Window:=NewInfo.Window;
  MetricCal:=NewInfo.MetricCal;
  MetricMatrix.InitFromData3x3(MetricCal.HMatrixData);
  MetricInvMatrix.Equals(MetricMatrix);
  MetricInvMatrix.PseudoInvert;
end;

function TProjector.MaskBmpFileName:String;
begin
  Result:=Path+'Mask.bmp';
end;

procedure TProjector.CreateAndLoadMaskBmp;
begin
  MaskBmp:=TBitmap.Create;
  if FileExists(MaskBmpFileName) then MaskBmp.LoadFromFile(MaskBmpFileName)
  else ClearBmp(MaskBmp,clWhite);
  MaskBmp.Width:=Window.Width;
  MaskBmp.Height:=Window.Height;
  MaskBmp.PixelFormat:=pf24Bit;
end;

procedure TProjector.SaveMaskBmp;
begin
  MaskBmp.SaveToFile(MaskBmpFileName);
end;

procedure TProjector.FreeMaskBmp;
begin
  if Assigned(MaskBmp) then begin
    MaskBmp.Free;
    MaskBmp:=nil;
  end;
end;

function TProjector.ClipXPixelToWindow(Pixel:Single):Integer;
begin
  with Window do begin
    if Pixel<0 then Result:=0
    else if Pixel>=(Width-1) then Result:=Width-1
    else Result:=Round(Pixel);
  end;
end;

function TProjector.ClipYPixelToWindow(Pixel:Single):Integer;
begin
  with Window do begin
    if Pixel<0 then Result:=0
    else if Pixel>=(Height-1) then Result:=Height-1
    else Result:=Round(Pixel);
  end;
end;

function TProjector.PixelFromCamXY(X,Y:Integer):TPixel;
var
  Den           : Single;
  FixedX,FixedY : Single;
begin
  if not Camera.AbleToUndistortPixel(X,Y,FixedX,FixedY) then begin
    FixedX:=X;
    FixedY:=Y;
  end;
  CamPtMatrix.Cell[1,1]:=FixedX;
  CamPtMatrix.Cell[2,1]:=FixedY;
  CamPtMatrix.Cell[3,1]:=1;
  ProjPtMatrix.InitFromProduct(HMatrix,CamPtMatrix);
  Den:=ProjPtMatrix.Cell[3,1];

  if Abs(Den)>0.00001 then begin
    Result.X:=ClipXPixelToWindow(ProjPtMatrix.Cell[1,1]/Den);
    Result.Y:=ClipYPixelToWindow(ProjPtMatrix.Cell[2,1]/Den);
  end
  else FillChar(Result,SizeOf(Result),0);

{  if Result.X<0 then Result.X:=0
  else if Result.X>=ViewPortWidth then Result.X:=ViewPortWidth-1;

  if Result.Y<0 then Result.Y:=0
  else if Result.Y>=ViewPortHeight then Result.Y:=ViewPortHeight-1;}
end;

procedure TProjector.InitFromCalibrator(Calibrator:TCalibrator);
begin
  CalPt:=Calibrator.CalPt;
  HMatrix.Equals(Calibrator.HMatrix);
end;

procedure TProjector.CopyMetricCalPtsFromCalPts;
var
  I : Integer;
begin
  for I:=1 to MaxCalPts do begin
    MetricCal.ProjPixel[I].X:=Round(CalPt[I].ProjX);
    MetricCal.ProjPixel[I].Y:=Round(CalPt[I].ProjY);
  end;
end;

procedure TProjector.FindMetricCalMetrePts;
begin
  with MetricCal do begin
    AbleToFindMetrePtsFromMeasurements(MetrePt,Measurements,MeasurementType);
  end;
end;

procedure TProjector.FindMetricMatrices(Normalize:Boolean);
var
  Calibrator : TCalibrator;
begin
  Calibrator:=TCalibrator.Create;
  try
    FindMetricCalMetrePts;
    Calibrator.CopyCalPtsFromMetricCal(MetricCal);
    Calibrator.CalculateMatrices(nil,Normalize);
    MetricMatrix.Equals(Calibrator.HMatrix);
    MetricInvMatrix.Equals(Calibrator.HInvMatrix);
  finally
    Calibrator.Free;
  end;
end;

procedure TProjector.FindMetricMatrices2;
var
  A     : TMatrix;
  I,R   : Integer;
  Xm,Zm : Single;
  Xp,Yp : Single;
begin
// find the calibration X,Zs from the measurements
  FindMetricCalMetrePts;

// solve the matrix
  A:=TMatrix.Create(8,9);
  try
    R:=0;
    for I:=1 to 4 do begin
      Xm:=MetricCal.MetrePt[I].X;
      Zm:=MetricCal.MetrePt[I].Z;
      Xp:=MetricCal.ProjPixel[I].X;
      Yp:=MetricCal.ProjPixel[I].Y;

      Inc(R);
      A.Cell[R,1]:=Xm;
      A.Cell[R,2]:=Zm;
      A.Cell[R,3]:=1;
      A.Cell[R,4]:=0;
      A.Cell[R,5]:=0;
      A.Cell[R,6]:=0;
      A.Cell[R,7]:=-Xp*Xm;
      A.Cell[R,8]:=-Xp*Zm;
      A.Cell[R,9]:=Xp;

      Inc(R);
      A.Cell[R,1]:=0;
      A.Cell[R,2]:=0;
      A.Cell[R,3]:=0;
      A.Cell[R,4]:=Xm;
      A.Cell[R,5]:=Zm;
      A.Cell[R,6]:=1;
      A.Cell[R,7]:=-Yp*Xm;
      A.Cell[R,8]:=-Yp*Zm;
      A.Cell[R,9]:=Yp;
    end;

 // solve it
    if A.AbleToSolveWithGaussJordanReduction then begin
      with MetricMatrix do begin
        Cell[1,1]:=A.Cell[1,9]; Cell[1,2]:=A.Cell[2,9]; Cell[1,3]:=A.Cell[3,9];
        Cell[2,1]:=A.Cell[4,9]; Cell[2,2]:=A.Cell[5,9]; Cell[2,3]:=A.Cell[6,9];
        Cell[3,1]:=A.Cell[7,9]; Cell[3,2]:=A.Cell[8,9]; Cell[3,3]:=1;
      end;
    end
    else MetricMatrix.SetAsIdentity(3); 
  finally
    A.Free;
  end;
  MetricInvMatrix.Equals(MetricMatrix);
  MetricInvMatrix.PseudoInvert;
end;

function TProjector.MetreXZToPixelXY(X,Z:Single):TPixelPoint;
var
  Den : Single;
begin
  MetrePtMatrix.Cell[1,1]:=X;
  MetrePtMatrix.Cell[2,1]:=Z;
  MetrePtMatrix.Cell[3,1]:=1;
  ProjPtMatrix.InitFromProduct(MetricMatrix,MetrePtMatrix);
  Den:=ProjPtMatrix.Cell[3,1];
  if Abs(Den)>0.00001 then begin
    Result.X:=ClipXPixelToWindow(ProjPtMatrix.Cell[1,1]/Den);
    Result.Y:=ClipYPixelToWindow(ProjPtMatrix.Cell[2,1]/Den);
  end
  else FillChar(Result,SizeOf(Result),0);
end;

function TProjector.MetreXZToPixelXYNoClip(X,Z:Single):TPixelPoint;
var
  Den : Single;
begin
  MetrePtMatrix.Cell[1,1]:=X;
  MetrePtMatrix.Cell[2,1]:=Z;
  MetrePtMatrix.Cell[3,1]:=1;
  ProjPtMatrix.InitFromProduct(MetricMatrix,MetrePtMatrix);
  Den:=ProjPtMatrix.Cell[3,1];
  if Abs(Den)>0.00001 then begin
    Result.X:=Round(ProjPtMatrix.Cell[1,1]/Den);
    Result.Y:=Round(ProjPtMatrix.Cell[2,1]/Den);
  end
  else FillChar(Result,SizeOf(Result),0);
end;

function TProjector.PixelXYToMetrePt(X,Y:Integer):TMetrePt;
var
  Den : Single;
begin
  ProjPtMatrix.Cell[1,1]:=X;
  ProjPtMatrix.Cell[2,1]:=Y;
  ProjPtMatrix.Cell[3,1]:=1;
  MetrePtMatrix.InitFromProduct(MetricInvMatrix,ProjPtMatrix);
  Den:=MetrePtMatrix.Cell[3,1];
  if Abs(Den)>0.00001 then begin
    Result.X:=MetrePtMatrix.Cell[1,1]/Den;
    Result.Z:=MetrePtMatrix.Cell[2,1]/Den;
  end
  else FillChar(Result,SizeOf(Result),0);
end;

procedure TProjector.ShowMetricCalDetails;
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    MetricMatrix.DisplayInLinesWithPunctuation(MemoFrm.Memo.Lines,'Metric matrix');
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

procedure TProjector.DrawMetricCalPts(Bmp:TBitmap);
const
  Size = 4;
var
  I,X,Y  : Integer;
  CalcPt : TPixelPoint;
begin
  with Bmp.Canvas,MetricCal do begin
    Font.Color:=clYellow;
    Brush.Style:=bsClear;

    for I:=1 to MaxCalPts do begin
      Pen.Color:=clYellow;
      X:=Round(ProjPixel[I].X);
      Y:=Round(ProjPixel[I].Y);
      MoveTo(X-Size,Round(Y));
      LineTo(X+Size+1,Y);
      MoveTo(X,Y-Size);
      LineTo(X,Y+Size+1);

      CalcPt:=MetreXZToPixelXY(MetrePt[I].X,MetrePt[I].Z);
      Pen.Color:=clLime;
      Ellipse(CalcPt.X-Size,CalcPt.Y-Size,CalcPt.X+Size,CalcPt.Y+Size);

      X:=X+Size+3;
      Y:=Y-7;
      TextOut(X,Y,'#'+IntToStr(I));
    end;
  end;
end;


procedure TProjector.DrawCalPts(Bmp:TBitmap);
const
  Size = 4;
var
  I,X,Y : Integer;
begin
  with Bmp.Canvas do begin
    Font.Color:=clYellow;
    Brush.Style:=bsClear;
    Pen.Color:=clYellow;
    for I:=1 to MaxCalPts do with CalPt[I] do begin
      X:=Round(CamX);
      Y:=Round(CamY);
      MoveTo(X-Size,Round(Y));
      LineTo(X+Size+1,Y);
      MoveTo(X,Y-Size);
      LineTo(X,Y+Size+1);
      X:=X+Size+3;
      Y:=Y-7;
      TextOut(X,Y,'#'+IntToStr(I));
    end;
  end;
end;

procedure TProjector.DrawFixedCalPts(Bmp:TBitmap);
const
  Size = 4;
var
  I,X,Y : Integer;
begin
  with Bmp.Canvas do begin
    Font.Color:=clYellow;
    Brush.Style:=bsClear;
    Pen.Color:=clYellow;
    for I:=1 to MaxCalPts do with CalPt[I] do begin
      X:=Round(FixedCamX);
      Y:=Round(FixedCamY);
      MoveTo(X-Size,Round(Y));
      LineTo(X+Size+1,Y);
      MoveTo(X,Y-Size);
      LineTo(X,Y+Size+1);
      X:=X+Size+3;
      Y:=Y-7;
      TextOut(X,Y,'#'+IntToStr(I));
    end;
  end;
end;



end.

procedure TProjector.LoadCalFile(FileName:String);
var
  R,C       : Integer;
  CalRecord : TProjectorCalRecord;
begin
  if AbleToLoadProjectorCalRecord(FileName,CalRecord) then begin
    CfgFileName:=FileName;
    CalPt:=CalRecord.CalInfo.CalPt;
    for R:=1 to 3 do for C:=1 to 3 do begin
      HMatrix.Cell[R,C]:=CalRecord.CalInfo.HData[R,C];
    end;
  end;
end;

end.


