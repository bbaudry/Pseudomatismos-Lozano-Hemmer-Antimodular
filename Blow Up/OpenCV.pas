unit OpenCV;

interface

uses
  Windows, CvTypes, IPL;

procedure cvGetLibraryInfo(Version:PChar;var Loaded:Integer;DllName:PChar); cdecl;
function  cvCreateImage(Size:TCvSize;Depth:Integer;Channels:Integer):PIplImage; cdecl;
procedure cvReleaseImage(var Image:PIplImage); cdecl;

function  cvFindChessBoardCornerGuesses(Image:PIplImage;ThresholdImage:PIplImage;
            Storage:PCvMemStorage;EtalonSize:TCvSize;Corners:PCvPoint2D32FArray;
            var CornerCount:Integer):Integer; cdecl;

procedure cvFindCornerSubPix(Image:PIplImage;Corners:PCvPoint2D32FArray;
            Count:Integer;Win,ZeroZone:TCvSize;Criteria:TCvTermCriteria); cdecl;

procedure cvCalibrateCamera(NumImages:Integer;NumPoints:PCvIntArray;
            ImageSize:TCvSize;ImagePoints:PCvPoint2D32FArray;
            ObjectPoints:PCvPoint3D32FArray;Distortion:TCvVect32F;
            CameraMatrix:TCvMatr32F;TransVects:TCvVect32F;RotMatrix:TCvMatr32F;
            UseIntrinsicGuess:Integer); cdecl;

procedure cvFindExtrinsicCameraParams(NumPoints:Integer;ImageSize:TCvSize;
            ImagePts:PCvPoint2D32FArray;ObjectPoints:PCvPoint3D32FArray;
            FocalLength:TCvVect32F;PrincipalPoint:TCvPoint2D32F;
            Distortion:TCvVect32F;RotVect:TCvVect32F;TransVect:TCvVect32F); cdecl;

procedure cvCanny(Img:PIplImage;Edges:PIplImage;LowThresh:Double;
                  HighThresh:Double;AperatureSize:Integer=3); cdecl;

procedure cvPreCornerDetect(Img:PIplImage;Corners:PIplImage;
                            AperatureSize:Integer); cdecl;

procedure cvCornerEigenValsAndVecs(Img:PIplImage;EigenVV:PIplImage;
            BlockSize:Integer;AperatureSize:Integer=3); cdecl;

procedure cvCornerMinEigenVal(Img:PIplImage;EigenVV:PIplImage;BlockSize:Integer;
            AperatureSize:Integer=3); cdecl;

procedure cvGoodFeaturesToTrack(Image:PIplImage;EigImage:PIplImage;
            TempImage:PIplImage;Corners:PCvPoint2D32FArray;var CornerCount:Integer;
            QualityLevel:Double;MinDistance:Double); cdecl;

procedure cvFindFundamentalMatrix(Points1:PCvIntArray;Points2:PCvIntArray;
            NumPoints:Integer;Method:Integer;Matrix:PCvMatrix3); cdecl;

procedure cvUnDistortInit(SrcImage:PIplImage;Data:PIplImage;IntrMatrix:TCvMatr32F;
            DistCoeffs:TCvVect32F;Interpolate:Integer=1); cdecl;

procedure cvUnDistort(SrcImage:PIplImage;DstImage:PIplImage;Data:PIplImage;
            Interpolate:Integer=1); cdecl;

procedure cvUnDistortOnce(SrcImage:PIplImage;DstImage:PIplImage;
            IntrMatrix:TCvMatr32F;DistCoeffs:TCvVect32F;Interpolate:Integer=1); cdecl;

procedure cvRodrigues(RotMatr:PCvMat;RotVect:PCvMat;Jacobian:PCvMat;
            ConvType:Integer); cdecl;

// Allocates and initializes CvMat header and allocates data
function  cvCreateMat(Rows:Integer;Cols:Integer;dType:Integer):PCvMat; cdecl;
function  cvCreateMatHeader(Rows:Integer;Cols:Integer;dType:Integer):PCvMat; cdecl;
procedure cvCreateData(var Arr:PCvArr); cdecl;

// Releases CvMat header and deallocates matrix data
procedure cvReleaseMat(var Mat:PCvMat); cdecl;
procedure cvReleaseData(var Arr:PCvArr); cdecl;

implementation

// tested
procedure cvCalibrateCamera; external 'cv.dll';
function  cvCreateMat; external 'cv.dll';
function  cvCreateMatHeader; external 'cv.dll';
function  cvCreateImage; external 'cv.dll';
function  cvFindChessBoardCornerGuesses; external 'cv.dll';
procedure cvFindCornerSubPix; external 'cv.dll';
procedure cvFindExtrinsicCameraParams; external 'cv.dll';
procedure cvGetLibraryInfo; external 'cv.dll';
procedure cvReleaseMat; external 'cv.dll';
procedure cvUnDistortOnce; external 'cv.dll';
procedure cvUnDistortInit; external 'cv.dll';
procedure cvUnDistort; external 'cv.dll';

// not tested
procedure cvCanny; external 'cv.dll';
procedure cvCornerEigenValsAndVecs; external 'cv.dll';
procedure cvCornerMinEigenVal; external 'cv.dll';
procedure cvCreateData; external 'cv.dll';
procedure cvFindFundamentalMatrix; external 'cv.dll';
procedure cvGoodFeaturesToTrack; external 'cv.dll';
procedure cvPreCornerDetect; external 'cv.dll';
procedure cvReleaseData; external 'cv.dll';
procedure cvReleaseImage; external 'cv.dll';
procedure cvRodrigues; external 'cv.dll';

end.

