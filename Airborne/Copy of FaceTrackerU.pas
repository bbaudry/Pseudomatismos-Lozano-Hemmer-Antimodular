unit FaceTrackerU;

interface

uses
  Ipl, Windows, SysUtils, Classes, Messages, Dialogs, Global, OpenCV_CV,
  OpenCV_CVAUX, OpenCV_CXCORE, Graphics, Forms, OpenCV, OpenCV_HighGUI, Math;

const
  ThreadMsg     = WM_USER+1;
  FacesFoundMsg = WM_USER+2;
  MaxFaces      = 10;

type
// linked list of images
  PListElement = ^TListElement;
  TListElement = record
    Image : TIplImage;
    pNext : PListElement;
  end;

  TImageList = record
    CS    : TRtlCriticalSection;
    pHead : PListElement;
    pLast : PListElement;
  end;

  TEye = record
    Found     : Boolean;
    Tracked   : Boolean;
    Rect      : CvRect;
    Template  : PIplImage;
    TplResult : PIplImage;
  end;
  TEyeArray = array[1..2] of TEye;

  TFace = record
    Found       : Boolean;
    X,Y,W,H     : Integer;
    Eye         : TEyeArray;
    EyesFound   : Boolean;
    EyesTracked : Boolean;
  end;
  TFaceArray = array[1..MaxFaces] of TFace;

  TOnFacesFound = procedure(Sender:TObject;Faces:PCvSeq) of Object;

  TFaceTrackerInfo = record
    Scaling      : Single;
    Consensus    : Integer;
    MinSize      : Integer;
    SearchWindow : TCropWindow;
    UseBlobs     : Boolean;
    WindowScale  : Single;
    Threshold    : Single;
    Reserved     : array[1..64] of Byte;
  end;

  TFaceTracker = class(TObject)
  private
    Handle        : THandle;
    ThreadHandle  : THandle;
    FOnUpdate     : TNotifyEvent;
    ThreadID      : DWord;
    FaceCascade   : PCvHaarClassifierCascade;
    EyeCascade    : PCvHaarClassifierCascade;
    Storage       : PCvMemStorage;
    FOnFacesFound : TNotifyEvent;
    CS            : TRtlCriticalSection;

    procedure WndProc(var Msg:TMessage);
    procedure ThreadLoop;

    function MinOfU8Image(Image:PIplImage;MinLoc:PCvPoint):Integer;
    function MinOf32FImage(Image:PIplImage;var MinLoc:CvPoint):Single;

    function GetInfo : TFaceTrackerInfo;
    procedure SetInfo(NewInfo:TFaceTrackerInfo);

  public
    Scaling      : Single;
    Consensus    : Integer;
    MinSize      : Integer;
    SearchWindow : TCropWindow;
    UseBlobs     : Boolean;
    Searching    : Boolean;
    Face         : TFaceArray;
    WindowScale  : Single;
    Threshold    : Single;

    MinValue : Double;

    property OnUpdate : TNotifyEvent read FOnUpdate write FOnUpdate;
    property OnFacesFound : TNotifyEvent read FOnFacesFound write FOnFacesFound;

    property Info : TFaceTrackerInfo read GetInfo write SetInfo;

    constructor Create;
    destructor Destroy; override;

    function  FirstAvailableImage:Integer;

    procedure UpdateWithBmp(Bmp:TBitmap);
    procedure UpdateInWindow;
    procedure UpdateWithTracker;

    procedure TrackEyesInBmp(Bmp:TBitmap);

    procedure StopThread;

    procedure InitForTracking;

    procedure DrawFacesScaled(Bmp:TBitmap;Scale:Single);
    procedure DrawFaces(Bmp:TBitmap);
    procedure DrawEyes(Bmp:TBitmap);

    procedure DrawTrackedEyes(Bmp:TBitmap);


    function  FindFaces(Image:PIplImage):PCvSeq;
    procedure TrackFaces(CvFaces:PCvSeq);

    procedure FindEyes(Image:PIplImage);
    procedure TrackEyes(Image:PIplImage);

    function  FaceCount:Integer;
    function  FacesWithEyes:Integer;
    procedure UpdateEyeTemplate(Image:PIplImage;F,I:Integer);
    procedure SaveEyes(F:Integer);
  end;

var
  FaceTracker : TFaceTracker;

function DefaultFaceTrackerInfo:TFaceTrackerInfo;

implementation

uses
  IplUtils, ImageU, Main;

function DefaultSearchWindow:TCropWindow;
begin
  Result.X:=100;
  Result.Y:=100;
  Result.W:=100;
  Result.H:=100;
end;

function DefaultFaceTrackerInfo:TFaceTrackerInfo;
begin
  with Result do begin
    Scaling:=1.1;
    Consensus:=8;
    MinSize:=10;
    SearchWindow:=DefaultSearchWindow;
    UseBlobs:=False;

    WindowScale:=1.0;
    Threshold:=0.15;

    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

function ThreadEntryRoutine(Info:Pointer):Integer; stdcall;
begin
  FaceTracker.ThreadLoop;
end;

constructor TFaceTracker.Create;
begin
  inherited;

  WindowScale:=2.0;
  Threshold:=0.30;

  InitializeCriticalSection(CS);
  Searching:=False;
  FOnUpdate:=nil;
  FOnFacesFound:=nil;
end;

destructor TFaceTracker.Destroy;
begin
  StopThread;
  DeAllocateHWnd(Handle);

  CvReleaseMemStorage(@Storage);
  DeleteCriticalSection(CS);

  inherited;
end;

function TFaceTracker.GetInfo:TFaceTrackerInfo;
begin
  Result.Scaling:=Scaling;
  Result.Consensus:=Consensus;
  Result.MinSize:=MinSize;
  Result.SearchWindow:=SearchWindow;
  Result.UseBlobs:=UseBlobs;
  Result.WindowScale:=WindowScale;
  Result.Threshold:=Threshold;

  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TFaceTracker.SetInfo(NewInfo:TFaceTrackerInfo);
begin
  Scaling:=NewInfo.Scaling;
  Consensus:=NewInfo.Consensus;
  MinSize:=NewInfo.MinSize;
  SearchWindow:=NewInfo.SearchWindow;
  UseBlobs:=NewInfo.UseBlobs;
  WindowScale:=NewInfo.WindowScale;
  Threshold:=NewInfo.Threshold;
end;

procedure TFaceTracker.InitForTracking;
const
  FaceCascadeFile = 'c:\OpenCV2.0\data\haarcascades\haarcascade_frontalface_alt2.xml';
  EyeCascadeFile = 'c:\OpenCV2.0\data\haarcascades\haarcascade_eye.xml';
begin
  Searching:=False;

// load the face classifier
  if FileExists(FaceCascadeFile) then FaceCascade:=CvLoad(FaceCascadeFile,nil,nil,nil)
  else begin
    ShowMessage('Unable to open ' + FaceCascadeFile);
    Halt;
  end;

// load the eye classifier
  if FileExists(EyeCascadeFile) then EyeCascade:=CvLoad(EyeCascadeFile,nil,nil,nil)
  else begin
    ShowMessage('Unable to open ' + EyeCascadeFile);
    Halt;
  end;

  Storage:=CvCreateMemStorage(0);
  Handle:=AllocateHWnd(WndProc);

// the thread itself
  ThreadHandle:=CreateThread(nil,0,@ThreadEntryRoutine,nil,CREATE_SUSPENDED,ThreadID);

  if ThreadHandle=0 then begin
    ShowMessage('Failed to create Face Tracker thread.');
  end
  else begin

// THREAD_PRIORITY_TIMECRITICAL   - causes other threads to starve
// THREAD_PRIORITY_HIGHEST        - +2
// THREAD_PRIORITY_ABOVE_NORMAL   - +1
// THREAD_PRIORITY_NORMAL         -  0
// THREAD_PRIORITY_BELOW_NORMAL   - -1
// THREAD_PRIORITY_LOWEST         - -2
 //   SetThreadPriority(ThreadHandle,THREAD_PRIORITY_NORMAL);

// start it up
  ResumeThread(ThreadHandle);

// force feed it messages until we succeed - see Win32.Hlp
    repeat
      Application.ProcessMessages;
    until PostThreadMessage(ThreadID,ThreadMsg,0,0);
  end;
end;

function TFaceTracker.FirstAvailableImage:Integer;
begin
end;

procedure TFaceTracker.StopThread;
begin
  if ThreadHandle=0 then Exit;

// signal the thread there is some work to to
  PostThreadMessage(ThreadID,ThreadMsg,0,0); // the 2nd 0 tells it to terminate

  WaitForSingleObject(ThreadHandle,INFINITE); //wait for the thread to finish

// close the handle
  CloseHandle(ThreadHandle);
  ThreadHandle:=0;
end;

procedure TFaceTracker.TrackFaces(CvFaces:PCvSeq);
var
  I    : Integer;
  MaxI : Integer;
  Rect : PCvRect;
begin
  for I:=1 to MaxFaces do Face[I].Found:=False;
  MaxI:=Min(MaxFaces,CvFaces^.Total);

  for I:=1 to MaxI do begin
    Rect:=PCvRect(CvGetSeqElem(CvFaces,I-1));

    Face[I].Found:=True;
    Face[I].X:=Rect^.X; // Round(Rect.X+Rect.Width/2);
    Face[I].Y:=Rect^.Y; //Round(Rect.Y+Rect.Height/2);
    Face[I].W:=Rect^.Width;
    Face[I].H:=Rect^.Height;
  end;
end;

procedure TFaceTracker.FindEyes(Image:PIplImage);
var
  F,I        : Integer;
  SearchRect : CvRect;
  CvEyes     : PCvSeq;
  Size       : TCvSize;
//  Rect       : PCvRect;
begin
  Size.Width:=MinSize div 2;
  Size.Height:=Size.Width;

  for F:=1 to MaxFaces do with Face[F] do if Found then begin

// place the search rect around the top 1/3 of the face
    SearchRect.X:=X;
    SearchRect.Y:=Y+Round(H/5.5);
    SearchRect.Width:=W;
    SearchRect.Height:=Round(H/3.0);

    cvSetImageROI(Image,SearchRect);

    CvEyes:=CvHaarDetectObjects(Image,EyeCascade,Storage,Scaling,Consensus-1,
                                CV_HAAR_DO_CANNY_PRUNING,Size);
    cvClearMemStorage(Storage);
    if CvEyes.Total=2 then begin
      EyesFound:=True;
      for I:=1 to 2 do begin
        Eye[I].Rect:=PCvRect(CvGetSeqElem(CvEyes,I-1))^;
        Eye[I].Rect.X:=Eye[I].Rect.X+SearchRect.X;
        Eye[I].Rect.Y:=Eye[I].Rect.Y+SearchRect.Y;

        UpdateEyeTemplate(Image,F,I);
      end;
    end;
  end
  else Face[F].EyesFound:=False;
end;

procedure TFaceTracker.WndProc(var Msg:TMessage);
var
  Faces : PCvSeq;
  Image : PIplImage;
begin
  Case Msg.Msg of
    FacesFoundMsg :
      begin
        Image:=PIplImage(Msg.WParam);
    //    if Assigned(Image) then cvReleaseImage(Image);
  //      MainFrm.Caption:=IntToStr(Msg.WParam);
        Searching:=False;
        if Assigned(FOnFacesFound) then FOnFacesFound(Self);//,Faces);
      end;
    else with Msg do begin
      Result:=DefWindowProc(Handle,Msg,wParam,lParam);
    end;
  end;
end;

procedure TFaceTracker.UpdateWithTracker;
begin
//  EnterCriticalSection(CritSec);

//  LeaveCriticalSection(CritSec);
end;

procedure TFaceTracker.UpdateWithBmp(Bmp:TBitmap);
var
  Image : TImageIpl;
begin
// leave if we're busy looking
  if Searching then Exit;
  Searching:=True;

  Image:=TImageIpl.Create;
  Image.CopyFromBmp(Bmp);

// give it to the thread
  PostThreadMessage(ThreadID,ThreadMsg,Integer(Image.IplImage),1);
end;

procedure TFaceTracker.UpdateInWindow;
var
  SubImage : PIplImage;
begin
// leave if we're busy looking
  if Searching then Exit;

// create a copy of the window
  with SearchWindow do begin
//    SubImage:=CopySubImage(Camera.Image,X,Y,W,H);
  end;

// give it to the thread
  PostThreadMessage(ThreadID,ThreadMsg,Integer(SubImage),1);
end;

procedure TFaceTracker.ThreadLoop;
var
  Msg   : TMsg;
  Faces : PCvSeq;
  Image : PIplImage;
begin
// create the message queue
  GetMessage(Msg,0,0,0);

// we'll sit in this loop until the thread is terminated
  repeat

// wait until the main thread signals to us that it's ready
//    while not PeekMessage(Msg,0,StartMsg,StopMsg,PM_REMOVE) do begin
    while not PeekMessage(Msg,0,ThreadMsg,ThreadMsg,PM_REMOVE) do begin
      Sleep(1);
    end;

    if Msg.LParam>0 then begin
      Image:=PIplImage(Msg.WParam);

      EnterCriticalSection(CS);
        Faces:=FindFaces(Image);
        TrackFaces(Faces);
        FindEyes(Image);
      LeaveCriticalSection(CS);

// release the image
//    cvReleaseImage(Image);

// tell the main thread we processed this image
      PostMessage(Handle,FacesFoundMsg,Msg.wParam,0);
    end;
  until (Msg.LParam=0);
end;

function TFaceTracker.FindFaces(Image:PIplImage):PCvSeq;
var
  Size       : TCvSize;
  SearchRect : CvRect;
begin
  Size.Width:=MinSize;
  Size.Height:=MinSize;

  SearchRect.X:=0;
  SearchRect.Y:=0;
  SearchRect.Width:=MaxImageW;
  SearchRect.Height:=MaxImageH;

  cvSetImageROI(Image,SearchRect);

// look for the faces
  Result:=CvHaarDetectObjects(Image,FaceCascade,Storage,Scaling,Consensus-1,
                              CV_HAAR_DO_CANNY_PRUNING,Size);
  cvClearMemStorage(Storage);
end;

procedure TFaceTracker.DrawFacesScaled(Bmp:TBitmap;Scale:Single);
var
  I     : Integer;
  X1,X2 : Integer;
  Y1,Y2 : Integer;
  Rect  : PCvRect;
begin
  Bmp.Canvas.Pen.Color:=clRed;
  Bmp.Canvas.Brush.Style:=bsClear;
  for I:=1 to MaxFaces do with Face[I] do if Found then begin
    X1:=Round(X*Scale);
    X2:=Round((X+W-1)*Scale); //1+Round(W*Scale)-1;
    Y1:=Round(Y*Scale);
    Y2:=Round((Y+H-1)*Scale); //1+Round(W*Scale)-1;
    Bmp.Canvas.Ellipse(X1,Y1,X2,Y2);
  end;
end;

procedure TFaceTracker.DrawFaces(Bmp:TBitmap);
var
  I     : Integer;
  X1,X2 : Integer;
  Y1,Y2 : Integer;
  Rect  : PCvRect;
begin
  Bmp.Canvas.Pen.Color:=clRed;
  Bmp.Canvas.Brush.Style:=bsClear;
  for I:=1 to MaxFaces do with Face[I] do if Found then begin
    X2:=X+W-1;
    Y2:=Y+H-1;
    Bmp.Canvas.Ellipse(X,Y,X2,Y2);
  end;
end;

procedure TFaceTracker.DrawEyes(Bmp:TBitmap);
var
  F,I   : Integer;
  X1,X2 : Integer;
  Y1,Y2 : Integer;
  Rect  : PCvRect;
begin
  Bmp.Canvas.Brush.Style:=bsClear;
  for F:=1 to MaxFaces do if Face[F].Found and Face[F].EyesFound then begin
    for I:=1 to 2 do with Face[F].Eye[I] do begin
      Bmp.Canvas.Pen.Color:=clYellow;
      X1:=Rect.X;
      Y1:=Rect.Y;
      X2:=X1+Rect.Width-1;
      Y2:=Y1+Rect.Height-1;
      Bmp.Canvas.Ellipse(X1,Y1,X2,Y2);
    end;
  end;
end;

procedure TFaceTracker.DrawTrackedEyes(Bmp:TBitmap);
var
  F,I   : Integer;
  X1,X2 : Integer;
  Y1,Y2 : Integer;
  Rect  : PCvRect;
begin
  Bmp.Canvas.Brush.Style:=bsClear;
  for F:=1 to MaxFaces do if Face[F].EyesTracked then begin
    for I:=1 to 2 do with Face[F].Eye[I] do begin
      Bmp.Canvas.Pen.Color:=clGreen;
      X1:=Rect.X;
      Y1:=Rect.Y;
      X2:=X1+Rect.Width-1;
      Y2:=Y1+Rect.Height-1;
      Bmp.Canvas.Ellipse(X1,Y1,X2,Y2);
    end;
  end;
end;

procedure TFaceTracker.UpdateEyeTemplate(Image:PIplImage;F,I:Integer);
var
  Size : CvSize;
begin
  with Face[F].Eye[I] do begin

// create a template of the eye
    if Assigned(Template) then cvReleaseImage(@Template);
    Size.Width:=Rect.Width;
    Size.Height:=Rect.Height;
    Template:=cvCreateImage(Size,IPL_DEPTH_8U,1);

// copy the sub-image over
    cvSetImageROI(Image,Rect);
    cvCopy(Image,Template,nil);
    cvResetImageROI(Image);
  end;
end;

procedure TFaceTracker.TrackEyesInBmp(Bmp:TBitmap);
var
  Image : TImageIpl;
begin
// convert to an IPL image
  Image:=TImageIpl.Create;
  Image.CopyFromBmp(Bmp);

  TrackEyes(Image.IplImage);
end;

function TFaceTracker.MinOfU8Image(Image:PIplImage;MinLoc:PCvPoint):Integer;
var
  X,Y : Integer;
  SrcPtr : PByte;
begin
  Result:=256;
  for Y:=0 to Image^.Height-1 do begin
    SrcPtr:=Image^.ImageData;
    Inc(SrcPtr,Image^.WidthStep*Y);
    for X:=0 to Image^.Width-1 do begin
      if SrcPtr^<Result then begin
        Result:=SrcPtr^;
        MinLoc.X:=X;
        MinLoc.Y:=Y;
      end;
    end;
  end;
end;

function TFaceTracker.MinOf32FImage(Image:PIplImage;var MinLoc:CvPoint):Single;
var
  X,X1,X2 : Integer;
  Y,Y1,Y2 : Integer;
  BytePtr : PByte;
  SrcPtr  : PSingle;
begin
  Result:=(PSingle(Image^.ImageData))^;
  MinLoc.X:=0; MinLoc.Y:=0;

  for Y:=0 to Image^.Height-1 do begin
    BytePtr:=Image^.ImageData;
    Inc(BytePtr,Image^.WidthStep*Y);
    SrcPtr:=PSingle(BytePtr);
    for X:=0 to Image^.Width-1 do begin
      if SrcPtr^<Result then begin
        Result:=SrcPtr^;
        MinLoc.X:=X;
        MinLoc.Y:=Y;
      end;
      Inc(SrcPtr);
    end;
  end;
end;

procedure TFaceTracker.TrackEyes(Image:PIplImage);
const
  Threshold = 0.3;
var
  SearchRect : CvRect;
  F,I        : Integer;
  MinLoc     : CvPoint;
  MaxLoc     : CvPoint;
  Size       : CvSize;
  W,H        : Integer;
begin
  for F:=1 to MaxFaces do if Face[F].Found and Face[F].EyesFound then begin
    for I:=1 to 2 do with Face[F].Eye[I] do begin

// scale the search region
      SearchRect.Width:=Round(Rect.Width*WindowScale);
      SearchRect.Height:=Round(Rect.Height*WindowScale);

// keep it centered on the last eye location
      SearchRect.X:=Rect.X-(SearchRect.Width-Rect.Width) shr 1;
      SearchRect.Y:=Rect.Y-(SearchRect.Height-Rect.Height) shr 1;

      cvSetImageROI(Image,SearchRect);

// we need the result image - an image big enough for our window which is 2x the
// size of the template
      if Assigned(TplResult) then cvReleaseImage(@TplResult);
      Size.Width:=SearchRect.Width-Rect.Width+1;
      Size.Height:=SearchRect.Height-Rect.Height+1;
      TplResult:=cvCreateImage(Size,IPL_DEPTH_32F,1);

// get a resulting image of the normalized sum of squared differences of the template
      cvMatchTemplate(Image,Template,TplResult,CV_TM_SQDIFF_NORMED);

// look for the min
      MinValue:=MinOf32FImage(TplResult,MinLoc);

//    cvMinMaxLoc(TplResult,@MinValue,@MaxValue,@MinLoc,@MaxLoc,nil);
 //     cvSaveImage('c:\Result.bmp',TplResult);

// consider it found if it's below the threshold
      Tracked:=(MinValue<=Threshold);

// update the bounding rectangle
      if Tracked then begin
//        Rect.X:=Rect.X-(Rect.Width shr 1)+MinLoc.X;
//        Rect.Y:=Rect.Y-(Rect.Height shr 1)+MinLoc.Y;
        Rect.X:=SearchRect.X+MinLoc.X;
        Rect.Y:=SearchRect.Y+MinLoc.Y;
      end;
    end;
    with Face[F] do EyesTracked:=Eye[1].Tracked and Eye[2].Tracked;
  end;
end;

function TFaceTracker.FaceCount:Integer;
var
  I : Integer;
begin
  Result:=0;
  for I:=1 to MaxFaces do if Face[I].Found then Inc(Result);
end;

function TFaceTracker.FacesWithEyes:Integer;
var
  I : Integer;
begin
  Result:=0;

  for I:=1 to MaxFaces do if Face[I].Found and Face[I].EyesFound then Inc(Result);
end;

procedure TFaceTracker.SaveEyes(F:Integer);
begin
  cvSaveImage('c:\Eye1.bmp',Face[F].Eye[1].Template);
  cvSaveImage('c:\Eye2.bmp',Face[F].Eye[2].Template);
end;

end.


OpenCV Eye Tracking
Nov 2, 2008 | Tags: OpenCV |  del.icio.us |  Digg
This is a simple program that displays live video from a webcam and tracks user's eye. The system tracks user's eye with a given template, which was manually selected using mouse.




When the user initially clicks the eye feature, a box is drawn around the square and the subimage within this square is cropped out of the image frame. The cropped image is used as a template to find the position of the feature in subsequent frames. The system determines the position of the feature using Sum of Square Differences (SQD) method. To reduce extensive computation, the system tracks the feature in a "search window", a small area around the position of the feature in previous frame.
Listing 1: OpenCV Eye Tracking
/**
 * Display video from webcam and track user's eye with
 * manually selected template.
 *
 * Author    Nash <me [at] nashruddin.com>
 * License   GPL
 * Website   http://nashruddin.com
 */

#include <stdio.h>
#include "cv.h"
#include "highgui.h"

#define  TPL_WIDTH       12      /* template width       */
#define  TPL_HEIGHT      12      /* template height      */
#define  WINDOW_WIDTH    24      /* search window width  */
#define  WINDOW_HEIGHT   24      /* search window height */
#define  THRESHOLD       0.3

IplImage *frame, *tpl, *tm;
int      object_x0, object_y0, is_tracking = 0;

void mouseHandler( int event, int x, int y, int flags, void *param );
void trackObject();

/* main code */
int main( int argc, char** argv )
{
    CvCapture   *capture;
    int         key;

    /* initialize camera */
    capture = cvCaptureFromCAM( 0 );

    /* always check */
    if( !capture ) return 1;

    /* get video properties, needed by template image */
    frame = cvQueryFrame( capture );
    if ( !frame ) return 1;

    /* create template image */
    tpl = cvCreateImage( cvSize( TPL_WIDTH, TPL_HEIGHT ),
                         frame->depth, frame->nChannels );

    /* create image for template matching result */
    tm = cvCreateImage( cvSize( WINDOW_WIDTH  - TPL_WIDTH  + 1,
                                WINDOW_HEIGHT - TPL_HEIGHT + 1 ),
                        IPL_DEPTH_32F, 1 );

    /* create a window and install mouse handler */
    cvNamedWindow( "video", CV_WINDOW_AUTOSIZE );
    cvSetMouseCallback( "video", mouseHandler, NULL );

    while( key != 'q' ) {
        /* get a frame */
        frame = cvQueryFrame( capture );

        /* always check */
        if( !frame ) break;

        /* 'fix' frame */
        cvFlip( frame, frame, -1 );
        frame->origin = 0;

        /* perform tracking if template is available */
        if( is_tracking ) trackObject();

        /* display frame */
        cvShowImage( "video", frame );

        /* exit if user press 'q' */
        key = cvWaitKey( 1 );
    }

    /* free memory */
    cvDestroyWindow( "video" );
    cvReleaseCapture( &capture );
    cvReleaseImage( &tpl );
    cvReleaseImage( &tm );

    return 0;
}

/* mouse handler */
void mouseHandler( int event, int x, int y, int flags, void *param )
{
    /* user clicked the image, save subimage as template */
    if( event == CV_EVENT_LBUTTONUP ) {
        object_x0 = x - ( TPL_WIDTH  / 2 );
        object_y0 = y - ( TPL_HEIGHT / 2 );

        cvSetImageROI( frame,
                       cvRect( object_x0,
                               object_y0,
                               TPL_WIDTH,
                               TPL_HEIGHT ) );
        cvCopy( frame, tpl, NULL );
        cvResetImageROI( frame );

        /* template is available, start tracking! */
        fprintf( stdout, "Template selected. Start tracking... \n" );
        is_tracking = 1;
    }
}

/* track object */
void trackObject()
{
    CvPoint minloc, maxloc;
    double  minval, maxval;

    /* setup position of search window */
    int win_x0 = object_x0 - ( ( WINDOW_WIDTH  - TPL_WIDTH  ) / 2 );
    int win_y0 = object_y0 - ( ( WINDOW_HEIGHT - TPL_HEIGHT ) / 2 );

    /*
     * Ooops, some bugs here.
     * If the search window exceed the frame boundaries,
     * it will trigger errors.
     *
     * Add some code to make sure that the search window
     * is still within the frame.
     */

    /* search object in search window */
    cvSetImageROI( frame,
                   cvRect( win_x0,
                           win_y0,
                           WINDOW_WIDTH,
                           WINDOW_HEIGHT ) );
    cvMatchTemplate( frame, tpl, tm, CV_TM_SQDIFF_NORMED );
    cvMinMaxLoc( tm, &minval, &maxval, &minloc, &maxloc, 0 );
    cvResetImageROI( frame );

    /* if object found... */
    if( minval <= THRESHOLD ) {
        /* save object's current location */
        object_x0 = win_x0 + minloc.x;
        object_y0 = win_y0 + minloc.y;

        /* and draw a box there */
        cvRectangle( frame,
                     cvPoint( object_x0, object_y0 ),
                     cvPoint( object_x0 + TPL_WIDTH,
                              object_y0 + TPL_HEIGHT ),
                     cvScalar( 0, 0, 255, 0 ), 1, 0, 0 );
    } else {
        /* if not found... */
        fprintf( stdout, "Lost object.\n" );
        is_tracking = 0;
    }
}

        if Assigned(Eye[I].Template) then cvReleaseImage(Eye[I].Template);
        Size.Width:=Eye[I].W;
        Size.Height:=Eye[I].H;
        cvSetImageROI(Image,Eye[I].Rect);
        cvCopy(Image,Eye[I].Template,nil);

        if Assigned(Eye[I].TplResult) then cvReleaseImage(Eye[I].TplResult);
        Eye[I].Template:=cvCreateImage(Size,IPL_DEPTH_32F,1);
        Size.Width:=Size.Width*2;
        Size.height:=Size.Height*2;
        Eye[I].TplResult:=cvCreateImage(Size,IPL_DEPTH_32F,1);

