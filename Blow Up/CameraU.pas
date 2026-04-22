unit CameraU;

interface

uses
  DirectShow9, ActiveX, Classes, Windows, Graphics, Messages, Forms, Jpeg,
  Global, FiCommon, FireI, FiUtils, DShowUtils, PgrKsMedia, PgrInterface;

const
  ImageBpp           = 3;
  NewBufferMsg       = WM_USER+1;
  FrameRateAverages  = 10;
  MaxBufferSize      = MaxImageW*MaxImageH*ImageBpp;
  MaxCallBackRecords = 10;
  FPS                = 15;
  MaxRecordFrames    = 100;

type
  TIDrawTable = array[0..SmallW-1] of Integer;
  TYDrawTable = array[0..SmallH-1] of Integer;

  TFullITable = array[0..MaxImageW-1,0..MaxImageH-1] of Single;

  TITable = array[0..TrackW-1,0..TrackH-1] of Single;

  TAvtProperty = record   // 28
    Min,Max,Value   : DWord;
    Auto,OnePush    : Integer;
    AutoPossible    : Integer;
    OnePushPossible : Integer;
  end;

  TAvtDriverSettings = record
    Changed         : Boolean;
    FlipImage       : Integer;
    RGB32           : Integer;
    Debayering      : Integer;
    BwDebayering    : Integer;
    GammaOn         : Integer;
    Gain            : TAvtProperty;
    WhiteBalanceU   : TAvtProperty;
    WhiteBalanceV   : TAvtProperty;
    Brightness      : TAvtProperty;
    Exposure        : TAvtProperty;
    ExtShutter      : DWord;
    TimeBase        : DWord;
    Mirror          : Integer;
    SharpNess       : TAvtProperty;
    Hue             : TAvtProperty;
    Saturation      : TAvtProperty;
    ColorCorrection : Integer;
  end;

  TDriverType = (dtPtGrey,dtFireI,dtAvt,dtGeneric);

  TCameraControlType = (ccNone,ccManual,ccAuto,ccOn,ccOff);

  TCameraSetting = record
    Value    : Integer;
    CtrlType : TCameraControlType;
  end;

  TPointGreyWhiteBalance = record
    Red,Blue : DWord;
    Enabled  : Boolean;
  end;

  TCameraPropertyArray = array[TVideoProcAmpProperty] of TCameraSetting;
  TCameraControlArray = array[TCameraControlProperty] of TCameraSetting;

  TFireIExpoControlArray = array[FiExpoControl_Autoexp..FiExpoControl_Iris]
                              of TCameraSetting;

  TFireIColorControlArray = array[FiColorControl_UB..FiColorControl_Saturation]
                               of TCameraSetting;

  TFireIBasicControlArray = array[FiBasicControl_Focus..FiBasicControl_Gamma]
                               of TCameraSetting;

  TCallBackRecord = record
    Buffer     : array[1..MaxBufferSize] of Byte;
    BufferSize : Integer;
    SampleTime : Double;
  end;
  PCallBackRecord = ^TCallBackRecord;

  TCallBackRecordArray = array[1..MaxCallBackRecords] of TCallBackRecord;

  TFilter = record
    Added     : Boolean;
    BaseI     : IBaseFilter;
    InputPin  : IPin;
    OutputPin : IPin;
  end;

  TCameraName = String[64];

  TCameraInfo = record
// generic driver settings
    CamProperty       : TCameraPropertyArray;
    CamControl        : TCameraControlArray;

// fire-i driver settings
    FireIExpoControl  : TFireIExpoControlArray;
    FireIColorControl : TFireIColorControlArray;
    FireIBasicControl : TFireIBasicControlArray;

// pt grey settings
    PointGreyWhiteBal : TPointGreyWhiteBalance;

// avt settings
    AvtDriverSettings : TAvtDriverSettings;

    FlipImage   : Boolean;
    MirrorImage : Boolean;
    UseITable   : Boolean;

    CropWindow  : TCropWindow;

    Reserved    : array[1..1024-16] of Byte;
  end;

  TFullTable = array[0..MaxImageW-1] of Integer;

  TCamera = class(TInterfacedObject,ISampleGrabberCB)
  private
// DirectShow interfaces
    GraphBuilder         : IGraphBuilder;
    CaptureGraphBuilder2 : ICaptureGraphBuilder2;
    MediaControl         : IMediaControl;
    SampleGrabber        : ISampleGrabber;

// filters
    CameraOut    : TFilter;
    Grabber      : TFilter;
    NullRenderer : TFilter;

// private vars
    FOnNewFrame    : TNotifyEvent;
    MediaType      : TAM_Media_Type;
    FHandle        : THandle;
    LastSampleTime : Double;
    FrameRateFrame : Integer;
    CBRecord       : TCallBackRecordArray;
    CamIndex       : Integer;
    CallBackI      : Integer;
    Jpg            : array[1..MaxRecordFrames] of TJpegImage;
    RecordFolder   : String;

    FullXTable : TFullTable;
    FullYTable : TFullTable;

    IDrawTable : TIDrawTable;
    YDrawTable : TYDrawTable;

// SampleGrabber sample callback
    function  SampleCB(SampleTime:Double;pSample:IMediaSample):HResult; stdcall;

// SampleGrabber buffer callback
    function  BufferCB(SampleTime:Double;pBuffer:PByte;BufferLen:longint):HResult; stdcall;

    procedure EnumFilterPins(Filter:IBaseFilter);
    procedure FinishGraph;
    function  FirstFilterPin(Filter:IBaseFilter):IPin;
    function  SecondFilterPin(Filter:IBaseFilter):IPin;
    procedure WndProc(var Msg: TMessage);
    procedure AddSampleGrabberFilter;
    procedure AddNullRendererFilter;
    procedure DisconnectPins;
    procedure ConnectPins;
    procedure SetOnNewFrame(NewFrameProc:TNotifyEvent);
    function  GetInfo:TCameraInfo;
    procedure SetInfo(NewInfo:TCameraInfo);
    procedure ApplyPropertiesAndControls;
    procedure ApplyFireIControls;

    procedure MakeITableFromFullITable(var FullITable:TFullITable);
    procedure FillFullTables;
    procedure DrawTrackingBmp;
    procedure DrawSmallBmp;

  public
    Tag           : Integer;
    MeasuredFPS   : Single;
    DoneLastFrame : Boolean;
    FrameCount    : Integer;
    CameraName    : String;
    ImageW,ImageH : Integer;
    Bpp           : Integer;
    IBmp          : TBitmap; // used for i-compensate
    FlippedBmp    : TBitmap; // original camera bmp
    Bmp           : TBitmap; // final camera bmp
    FullBmp       : TBitmap;

// segmenter tracking
    TempSmallBmp : TBitmap; // scaled down cam bmp
    SmallBmp     : TBitmap; // ...after flipping and mirroring - used for tracking

    UseITable   : Boolean;
    ITable      : TITable;
    SmallITable : TITable;

    Found       : Boolean;
    FlipImage   : Boolean;
    MirrorImage : Boolean;
    Recording   : Boolean;
    RecordI     : Integer;
    CropWindow  : TCropWindow;

// generic
    CamProperty : TCameraPropertyArray;
    CamControl  : TCameraControlArray;

// fire-i
    FireIExpoControl  : TFireIExpoControlArray;
    FireIColorControl : TFireIColorControlArray;
    FireIBasicControl : TFireIBasicControlArray;

// point grey
    PointGreyWhiteBal : TPointGreyWhiteBalance;

// avt
    AvtDriverSettings : TAvtDriverSettings;

    property OnNewFrame : TNotifyEvent read FOnNewFrame write SetOnNewFrame;

    property Info : TCameraInfo read GetInfo write SetInfo;

    constructor Create;
    destructor Destroy; override;

    procedure FindVideoCaptureDevices(List:TStringList);
    procedure SelectCamera(CamName:String);
    procedure InitFromGrfFile(FileName:String);
    procedure UseFirstDevice;
    procedure Start;
    procedure Pause;
    procedure Stop;
    procedure ShutDown;
    procedure ShowCameraPropertyPages;
    procedure ShowCameraPinPropertyPages;
    procedure SetSize(NewWidth,NewHeight:Integer);
    procedure InitCapture;
    procedure FindCameraBmpSize;
    procedure UpdateWithJpg(Jpg:TJpegImage);
    procedure PurgeCallBacks;
    procedure TearDownGraph;
    procedure CreateBaseInterfaces;
    procedure RemoveCameraOut;
    procedure InitBmp(Bitmap:TBitmap);
    procedure InitForTracking;

    function  AbleToGetPropertyDetails(Prop:TVideoProcAmpProperty;
                                 var Min,Max:Integer;var Auto,CanDisable:Boolean):Boolean;
    function  AbleToGetProperty(Prop:TVideoProcAmpProperty;var Value:Integer;
                                 var Auto:Boolean):Boolean;
    function  AbleToSetProperty(Prop:TVideoProcAmpProperty;Value:Integer;
                                CtrlType:TCameraControlType):Boolean;
    function  AbleToGetControlDetails(Control:TCameraControlProperty;
                                     var Min,Max:Integer;var Auto:Boolean):Boolean;
    function  AbleToGetControl(Control:TCameraControlProperty;var Value:Integer;
                               var Auto:Boolean):Boolean;
    function  AbleToSetControl(Control:TCameraControlProperty;Value:Integer;
                                 Auto:Boolean):Boolean;

    function  AbleToGetFireIExposureControlDetails(ExpoCtrl:Integer;
                var Min,Max,Value:Single;var AutoEnabled,AutoOn:Boolean):Boolean;
    function  AbleToSetFireIExposureControl(ExpoCtrl:Integer;
                                            Value:Single;Auto:Boolean):Boolean;

    function  AbleToGetFireIColorControlDetails(ColorCtrl:Integer;
                var Min,Max,Value:Single;var AutoEnabled,AutoOn:Boolean):Boolean;
    function  AbleToSetFireIColorControl(ColorCtrl:Integer;
                                         Value:Single;Auto:Boolean):Boolean;

    function  AbleToGetFireIBasicControlDetails(BasicCtrl:Integer;
                var Min,Max,Value:Single;var AutoEnabled,AutoOn:Boolean):Boolean;
    function  AbleToSetFireIBasicControl(BasicCtrl:Integer;
                                         Value:Single;Auto:Boolean):Boolean;
    procedure SetFireIFrameRate(NewFrameRate:Single);
    procedure ShowFireIVideoFormatList(Lines:TStrings);
    procedure ShowFireIVenderInfo(Lines:TStrings);
    procedure SetFireIFormatSizeAndFPS(Format:TGUID;W,H:Integer;Fps:Single);
    procedure StopGraph;
    procedure StartGraph;
    function  FireIDriverUsed:Boolean;
    procedure ShowCameraSettingsFrm;

    function  PointGreyDriverUsed:Boolean;
    function  GetPointGreyRegister(Address:DWord):DWord;
    procedure SetPointGreyRegister(Address,Value:DWord);
    procedure GetPointGreyWhiteBalance(var Red,Blue:DWord;var CtrlEnabled:Boolean);
    procedure SetPointGreyWhiteBalance(Red,Blue:DWord;CtrlEnabled:Boolean);

    function  AvtDriverUsed:Boolean;
    function  DriverType:TDriverType;
    procedure SetAvtDriverSettings(Settings:TAvtDriverSettings);
    function  GetAvtDriverSettings:TAvtDriverSettings;
    procedure SetAvtFPS;
    function  DriverName:String;
    function  AbleToSetSize(NewWidth,NewHeight:Integer):Boolean;
    function  DefaultCameraInfo:TCameraInfo;
    procedure SetAllAvtControlsToAuto;
    procedure SetAllAvtControlsToFixed;
    procedure SetWhiteBalanceToAuto;
    procedure SetAvtControlsToDefaults;
    procedure SetFlipImage(NewSetting:Boolean);
    procedure InitAvtYUV800Filter;

    procedure ClearITable;
    procedure LoadITable;
    procedure DrawICompensatedBmp(SrcBmp,DestBmp:TBitmap);
    function  ITableFileName:String;
    procedure StartRecording(Folder:String);
    procedure UpdateRecording;
    procedure FinishRecording;
    procedure SizeBmps;
    function  LoRes:Boolean;
    function  XYToSmallXY(X,Y:Integer):TPoint;
    function  SmallXYToXY(X,Y:Integer):TPoint;
    function  SmallXYToTrackXY(X,Y:Integer):TPoint;
    procedure CalculateSmallITable;
    procedure DrawSmallICompensatedBmp(SrcBmp,DestBmp:TBitmap);
    function  DefaultCropWindow:TCropWindow;
    procedure DrawFlippedBmp;
    procedure DrawSmallBmpFromCropWindow;
    function  OrientedCropWindow:TCropWindow;
    procedure InitAfterCropWindowChange;
    procedure ClipCropWindow;
    procedure BuildDrawTable;
  end;

var
  Camera : TCamera;

implementation

uses
  Dialogs, DSUtil, SysUtils, WMFUtil, BmpUtils, Math, Controls, FileCtrl,
  Routines, FireISetupFrmU, CamSetupFrmU, PtGreySetupFrmU, AvtYuv800Lib_TLB,
  AvtPropSetLib_TLB, AvtSetupFrmU, CfgFile, TrackerU, Main, TilerU, BackGndFind,
  StopWatchU;

function DefaultAvtProperty:TAvtProperty;
begin
  Result.Min:=0;
  Result.Max:=100;
  Result.Value:=50;
  Result.Auto:=0;
  Result.OnePush:=0;
  Result.AutoPossible:=0;
  Result.OnePushPossible:=0;
end;

function DefaultAvtDriverSettings:TAvtDriverSettings;
begin
  FillChar(Result,SizeOf(Result),0);
  with Result do begin
    Changed:=True;
    FlipImage:=1;
    RGB32:=1;
    Debayering:=1;
    BwDebayering:=0;
    GammaOn:=0;

    Gain:=DefaultAvtProperty;
    WhiteBalanceU:=DefaultAvtProperty;
    WhiteBalanceV:=DefaultAvtProperty;
    Brightness:=DefaultAvtProperty;
    Exposure:=DefaultAvtProperty;
    SharpNess:=DefaultAvtProperty;
    Hue:=DefaultAvtProperty;
    Saturation:=DefaultAvtProperty;

    WhiteBalanceU.OnePush:=1;
    WhiteBalanceU.Auto:=0;
    WhiteBalanceV.OnePush:=1;
    WhiteBalanceV.Auto:=0;

    Gain.Value:=100;
    Gain.Max:=680;

    Brightness.Value:=0;
    Exposure.Value:=3000;
    Exposure.Max:=4095;
  end;
end;

function TCamera.DefaultCropWindow:TCropWindow;
begin
  with Result do begin
//    W:=Round(TrackW*0.70);
//    H:=Round(TrackH*0.70);
//    X:=(TrackW-W) div 2;
//    Y:=(TrackH-1)-H;
    X:=0;
    Y:=0;
    W:=TrackW;
    H:=TrackH;
  end;
end;

function TCamera.DefaultCameraInfo:TCameraInfo;
begin
  FillChar(Result.CamProperty,SizeOf(Result.CamProperty),0);
  FillChar(Result.CamControl,SizeOf(Result.CamControl),0);
  FillChar(Result.FireIExpoControl,SizeOf(Result.FireIExpoControl),0);
  FillChar(Result.FireIColorControl,SizeOf(Result.FireIColorControl),0);
  FillChar(Result.FireIBasicControl,SizeOf(Result.FireIBasicControl),0);
  FillChar(Result.PointGreyWhiteBal,SizeOf(Result.PointGreyWhiteBal),0);
  Result.AvtDriverSettings:=DefaultAvtDriverSettings;
  Result.FlipImage:=False;
  Result.MirrorImage:=False;
  Result.UseITable:=True;//False;
  Result.CropWindow:=DefaultCropWindow;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

constructor TCamera.Create;
begin
  inherited Create;

// init vars
  Found:=False;
  Recording:=False;
  ImageW:=MaxImageW;
  ImageH:=MaxImageH;
  Bpp:=3;

  FHandle:=AllocateHWnd(WndProc);
  CameraOut.Added:=False;
  Grabber.Added:=False;
  NullRenderer.Added:=False;

  FOnNewFrame:=nil;

  FullBmp:=TBitmap.Create;
  FullBmp.PixelFormat:=pf24Bit;
  FullBmp.Width:=MaxImageW;
  FullBmp.Height:=MaxImageH;
  
  Bmp:=CreateImageBmp;
  IBmp:=CreateImageBmp;
  FlippedBmp:=CreateImageBmp;

  TempSmallBmp:=CreateSmallBmp;
  SmallBmp:=CreateSmallBmp;

  LastSampleTime:=0;
  FrameRateFrame:=0;
  FrameCount:=0;
  DoneLastFrame:=True;
  MeasuredFPS:=0;

  FillFullTables;

// initialize COM
  CoInitialize(nil);

// create the foundation interfaces
  CreateBaseInterfaces;
end;

destructor TCamera.Destroy;
begin
  CoUninitialize;
  DeAllocateHWnd(FHandle);

  if Assigned(Bmp) then Bmp.Free;
  if Assigned(FlippedBmp) then FlippedBmp.Free;
  if Assigned(FullBmp) then FullBmp.Free;

  if Assigned(SmallBmp) then SmallBmp.Free;
  if Assigned(TempSmallBmp) then TempSmallBmp.Free;

  inherited;
end;
                   
function TCamera.GetInfo:TCameraInfo;
begin
  Result.CamProperty:=CamProperty;
  Result.CamControl:=CamControl;
  Result.FireIExpoControl:=FireIExpoControl;
  Result.FireIColorControl:=FireIColorControl;
  Result.FireIBasicControl:=FireIBasicControl;
  Result.PointGreyWhiteBal:=PointGreyWhiteBal;
  Result.AvtDriverSettings:=AvtDriverSettings;
  Result.FlipImage:=FlipImage;
  Result.MirrorImage:=MirrorImage;
  Result.UseITable:=UseITable;
  Result.CropWindow:=CropWindow;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TCamera.SetInfo(NewInfo:TCameraInfo);
begin
  CamProperty:=NewInfo.CamProperty;
  CamControl:=NewInfo.CamControl;
  FireIExpoControl:=NewInfo.FireIExpoControl;
  FireIColorControl:=NewInfo.FireIColorControl;
  FireIBasicControl:=NewInfo.FireIBasicControl;
  PointGreyWhiteBal:=NewInfo.PointGreyWhiteBal;
  AvtDriverSettings:=NewInfo.AvtDriverSettings;

  AvtDriverSettings.RGB32:=1;
  AvtDriverSettings.Debayering:=1;
  AvtDriverSettings.BwDebayering:=0;
  AvtDriverSettings.GammaOn:=0;

  FlipImage:=NewInfo.FlipImage;
  MirrorImage:=NewInfo.MirrorImage;
  UseITable:=NewInfo.UseITable;
//  UseITable:=False;
  CropWindow:=NewInfo.CropWindow;
  if CropWindow.W=0 then CropWindow:=DefaultCropWindow;
  BuildDrawTable;
end;

procedure TCamera.ShutDown;
begin
  Stop;
  FOnNewFrame:=nil;
  PurgeCallBacks;

// camera filter
  with CameraOut do if Added then begin
    GraphBuilder.Disconnect(OutputPin);
    GraphBuilder.RemoveFilter(BaseI);
    OutputPin:=nil;
    BaseI:=nil;
  end;

// sample grabber filter
  with Grabber do if Added then begin
    GraphBuilder.Disconnect(InputPin);
    GraphBuilder.Disconnect(OutputPin);
    GraphBuilder.RemoveFilter(BaseI);
    InputPin:=nil;
    OutputPin:=nil;
    BaseI:=nil;
  end;

// null renderer filter
  with NullRenderer do if Added then begin
    GraphBuilder.Disconnect(InputPin);
    GraphBuilder.RemoveFilter(BaseI);
    InputPin:=nil;
    BaseI:=nil;
  end;

// other interfaces
  GraphBuilder:=nil;
  CaptureGraphBuilder2:=nil;
  MediaControl:=nil;
  SampleGrabber:=nil;
end;

////////////////////////////////////////////////////////////////////////////////
// Creates & inits the GraphBuilder, MediaControl, and CaptureGraphBuilder2
// interfaces.
////////////////////////////////////////////////////////////////////////////////
procedure TCamera.CreateBaseInterfaces;
var
  HR : HResult;
begin
// create an instance of the Filter Graph Manager and get a pointer to the
// GraphBuilder
  HR:=CoCreateInstance(CLSID_FilterGraph,nil,CLSCTX_INPROC,IID_IGraphBuilder,
                       GraphBuilder);
  if HR<>S_OK then begin
    ShowMessage('Unable to create Filter Graph Manager.');
    Halt;
  end;

// we'll need a pointer to the MediaControl too
  HR:=GraphBuilder.QueryInterface(IID_IMediaControl,MediaControl);
  if HR<>S_OK then begin
    ShowMessage('Unable to get MediaControl interface');
    Halt;
  end;

// create the capture graph builder
  HR:=CoCreateInstance(CLSID_CaptureGraphBuilder2,nil,CLSCTX_INPROC,
                        IID_ICaptureGraphBuilder2,CaptureGraphBuilder2);
  if HR<>S_OK then begin
    ShowMessage('Unable to create CaptureGraphBuilder2');
    Halt;
  end;

// Attach the filter graph to the capture graph
  HR:=CaptureGraphBuilder2.SetFilterGraph(GraphBuilder);
  if HR<>S_OK then begin
    ShowMessage('Failed to attach filter graph');
    Halt;
  end;
end;

procedure TCamera.FindVideoCaptureDevices(List:TStringList);
var
  CreateDevEnum : ICreateDevEnum;
  Error,I,I2    : Integer;
  EnumMoniker   : IEnumMoniker;
  Moniker       : IMoniker;
  cFetched      : DWord;
  PropertyBag   : IPropertyBag;
  Name          : OleVariant;
  BeforeCount   : Integer;
  AfterCount    : Integer;
  Count         : array[0..99] of Integer;
begin
  Error:=CoCreateInstance(CLSID_SystemDeviceEnum,nil,CLSCTX_INPROC_SERVER,
                            IID_ICreateDevEnum,CreateDevEnum);
  if (Error<>S_OK) then begin
    ShowMessage('Error Creating Device Enumerator');
  end
  else begin
    Error:=CreateDevEnum.CreateClassEnumerator(CLSID_VideoInputDeviceCategory,
                                               EnumMoniker,0);

// error means no hardware found
    if Error<>S_OK then Exit
    else begin
      EnumMoniker.Reset;
      while EnumMoniker.Next(1,Moniker,@cFetched)=S_OK do begin
        Error:=Moniker.BindToStorage(nil,nil,IID_IPropertyBag,PropertyBag);
        if Error=S_OK then begin
          Error:=PropertyBag.Read('FriendlyName',Name,nil);
          if Error=S_OK then List.Add(Name);
        end;
      end;
    end;
  end;

// go through the list and look for duplicates
  FillChar(Count,SizeOf(Count),0);
  for I:=0 to List.Count-1 do begin

// count how many came before
    BeforeCount:=0;
    for I2:=0 to I-1 do begin
      if List[I2]=List[I] then Inc(BeforeCount);
    end;

// count how many came after
    AfterCount:=0;
    for I2:=I+1 to List.Count-1 do begin
      if List[I2]=List[I] then Inc(AfterCount);
    end;

// if there's more than one before or after, show the #
    if BeforeCount>0 then Count[I]:=BeforeCount+1

// add #1 to the first one
    else if AfterCount>0 then Count[I]:=1;
  end;
  for I:=0 to List.Count-1 do if Count[I]>0 then begin
    List.Strings[I]:=List.Strings[I]+' #'+IntToStr(Count[I]);
  end
end;

procedure TCamera.InitFromGrfFile(FileName:String);
var
  HR     : HResult;
  Filter : IBaseFilter;
begin
// let DirectShow(tm) build the filter
  HR:=MediaControl.RenderFile(StringToOLEStr(FileName));
  if HR<>S_OK then begin
    ShowMessage('Error building graph from "'+FileName+'"');
    Exit;
  end;

// find the sample grabber filter
  HR:=GraphBuilder.FindFilterByName('SampleGrabber',Filter);
  if HR<>S_OK then begin
    ShowMessage(
      'There doesn''t seem to be a "SampleGrabber" filter in "'+FileName+'"');
    Exit;
  end;

// get a pointer to the ISampleGrabber
  HR:=Filter.QueryInterface(IID_ISampleGrabber,SampleGrabber);
  if HR<>S_OK then begin
    ShowMessage('HR getting SampleGrabber pointer');
    Exit;
  end;

// turn on continuous mode
  SampleGrabber.SetBufferSamples(False);
  SampleGrabber.SetOneShot(False);

// setup our callback
  SampleGrabber.SetCallBack(Self,1); //0 = SampleCB, 1 = BufferCB

// start it
  MediaControl.Run;
end;

function TCamera.SampleCB(SampleTime:Double;pSample:IMediaSample):HResult;
begin
  Result:=0;
end;

function TCamera.BufferCB(SampleTime:Double;pBuffer:PByte;BufferLen:LongInt):HResult;
var
  Msg : TMsg;
begin
  Result:=0;
  if (pBuffer=nil) or (BufferLen=0) or (BufferLen>MaxBufferSize) then Exit;

// select the next CallBack index
  if CallBackI<MaxCallBackRecords then Inc(CallBackI)
  else CallBackI:=1;

// prepare it
  CBRecord[CallBackI].SampleTime:=SampleTime;
  CBRecord[CallBackI].BufferSize:=BufferLen;
  CopyMemory(@CBRecord[CallBackI].Buffer,pBuffer,BufferLen);
  PostMessage(FHandle,NewBufferMsg,Cardinal(CallBackI),0);
end;

procedure TCamera.AddSampleGrabberFilter;
var
  HR     : HResult;
  Filter : IBaseFilter;
const
  MEDIASUBTYPE_Y800 : TGUID = (D1:$30303859;D2:$0000;D3:$0010;
                               D4:($80,$00,$00,$AA,$00,$38,$9B,$71));

begin
  if Grabber.Added then Grabber.BaseI:=nil;

// create a sample grabber filter
  HR:=CoCreateInstance(CLSID_SampleGrabber,nil,CLSCTX_INPROC_SERVER,IID_IBaseFilter,
                       Filter);
  if HR<>S_OK then begin
    ShowMessage('Error creating sample grabber filter');
    Exit;
  end;

// get a pointer to the sample grabber interface
  Filter.QueryInterface(IID_ISampleGrabber,SampleGrabber);

// add it to the graph
  GraphBuilder.AddFilter(Filter,'Grabber');
  Grabber.Added:=True;
  Grabber.BaseI:=Filter;

// set its MediaType to uncompressed 24bit RGB
  ZeroMemory(@MediaType,SizeOf(TAM_MEDIA_TYPE));
  MediaType.MajorType:=MEDIATYPE_Video;
  Case Bpp of
    1: MediaType.SubType:=MEDIASUBTYPE_Y800;
    else MediaType.SubType:=MEDIASUBTYPE_RGB24;
  end;

  MediaType.bFixedSizeSamples:=True;
  MediaType.bTemporalCompression:=False;
//  MediaType.lSampleSize:=57600;//921600;

  MediaType.FormatType:=FORMAT_VideoInfo;

  HR:=SampleGrabber.SetMediaType(MediaType);
  if HR<>S_OK then begin
    ShowMessage('Error setting Sample Grabber media type');
    Exit;
  end;

// find the input pin of the sample grabber
  Grabber.InputPin:=FirstFilterPin(Filter);
  Grabber.OutputPin:=SecondFilterPin(Filter);
end;

procedure TCamera.AddNullRendererFilter;
var
  HR     : HResult;
  Filter : IBaseFilter;
begin
  if NullRenderer.Added then begin
    NullRenderer.BaseI:=nil;
  end;

// create a null renderer
  HR:=CoCreateInstance(CLSID_NullRenderer,nil,
                       CLSCTX_INPROC_SERVER,IID_IBaseFilter,Filter);
  if HR<>S_OK then begin
    ShowMessage('Error creating null renderer');
    Exit;
  end;

// add the null renderer
  GraphBuilder.AddFilter(Filter,'Null Renderer');
  NullRenderer.Added:=True;
  NullRenderer.BaseI:=Filter;

// find the input pin of the null renderer
  HR:=Filter.FindPin('In',NullRenderer.InputPin);
end;

procedure TCamera.ConnectPins;
var
  HR : HResult;
begin
// connect the capture pin of the camera filter to the input pin of the
// sample grabber
  HR:=GraphBuilder.Connect(CameraOut.OutputPin,Grabber.InputPin);

// connect the output of the sample grabber to the input of the null renderer
  HR:=GraphBuilder.Connect(Grabber.OutputPin,NullRenderer.InputPin);
end;

procedure TCamera.DisconnectPins;
var
  HR : HResult;
begin
  HR:=GraphBuilder.Disconnect(CameraOut.OutputPin);
  HR:=GraphBuilder.Disconnect(Grabber.InputPin);
  HR:=GraphBuilder.Disconnect(Grabber.OutputPin);
  HR:=GraphBuilder.Disconnect(NullRenderer.InputPin);
end;

////////////////////////////////////////////////////////////////////////////////
// Adds a SampleGrabber & NullRenderer to the camera and connects the pins.
//   Cam -> SampleGrabber -> NullRenderer
////////////////////////////////////////////////////////////////////////////////
procedure TCamera.FinishGraph;
begin
  if not CameraOut.Added then begin
    ShowMessage('Camera not added');
    Exit;
  end;

// add the sample grabber filter
  AddSampleGrabberFilter;

// add the null renderer filter
  AddNullRendererFilter;

// connect it up
  ConnectPins;

// init the sample grabber
  SampleGrabber.SetBufferSamples(False);
  SampleGrabber.SetOneShot(False);
  SampleGrabber.SetCallBack(Self,1);
end;

procedure TCamera.TearDownGraph;
begin
  DisconnectPins;
  if CameraOut.Added then begin
    GraphBuilder.RemoveFilter(CameraOut.BaseI);
    CameraOut.Added:=False;
  end;
  if Grabber.Added then begin
    GraphBuilder.RemoveFilter(Grabber.BaseI);
    Grabber.Added:=False;
  end;
  if NullRenderer.Added then begin
    GraphBuilder.RemoveFilter(NullRenderer.BaseI);
    NullRenderer.Added:=False;
  end;
  GraphBuilder:=nil;
  CaptureGraphBuilder2:=nil;
  MediaControl:=nil;
  SampleGrabber:=nil;
end;

procedure TCamera.RemoveCameraOut;
begin
  MediaControl.Stop;
  MediaControl:=nil;
  DisconnectPins;
  GraphBuilder.RemoveFilter(CameraOut.BaseI);
  CameraOut.BaseI:=nil;
  CameraOut.OutputPin:=nil;
end;

procedure TCamera.SelectCamera(CamName:String);
var
  CreateDevEnum : ICreateDevEnum;
  HR            : HResult;
  EnumMoniker   : IEnumMoniker;
  Moniker       : IMoniker;
  cFetched      : DWord;
  Filter        : IBaseFilter;
  PropertyBag   : IPropertyBag;
  Name          : OleVariant;
  CamWasAdded   : Boolean;
  L,Count       : Integer;
begin
  CameraName:=CamName;
  if CamName='' then Exit;
  L:=Length(CamName);
  if (CamName[L-1]='#') and (CamName[L] in ['1'..'9']) then begin
    CamIndex:=Ord(CamName[L])-Ord('0');
    CamName:=Copy(CamName,1,L-3);
  end
  else CamIndex:=0;
  Name:=CamName;
  HR:=CoCreateInstance(CLSID_SystemDeviceEnum,nil,CLSCTX_INPROC_SERVER,
                            IID_ICreateDevEnum,CreateDevEnum);
  if (HR<>S_OK) then begin
    ShowMessage('Error Creating Device Enumerator');
    Exit;
  end;
  HR:=CreateDevEnum.CreateClassEnumerator(CLSID_VideoInputDeviceCategory,
                                          EnumMoniker,0);
  if HR<>S_OK then begin
    ShowMessage('Unable to find any video capture hardware.');
    Exit;
  end;
  EnumMoniker.Reset;

// look for the camera
  Found:=False;
  Count:=0;
  while (EnumMoniker.Next(1,Moniker,@cFetched)=S_OK) and not Found do begin
    Moniker.BindToStorage(nil,nil,IID_IPropertyBag,PropertyBag);
    PropertyBag.Read('FriendlyName',Name,nil);
    if CamName=Name then begin
      Inc(Count);
      if Count>=CamIndex then begin
        Found:=True;
        Moniker.BindToObject(nil,nil,IID_IBaseFilter,Filter);
      end;
    end;
  end;

// if we found the camera, add it to the graph and finish
  if Found then begin

// remove the old one first
    if CameraOut.Added then begin
      CamWasAdded:=True;
      RemoveCameraOut;
    end
    else CamWasAdded:=False;
    GraphBuilder.AddFilter(Filter,'Camera');
    if CamWasAdded then begin
      HR:=GraphBuilder.QueryInterface(IID_IMediaControl,MediaControl);
      if HR<>S_OK then begin
        ShowMessage('Unable to get MediaControl interface');
        Found:=False;
      end;
    end;
    CameraOut.Added:=True;
    CameraOut.OutputPin:=FirstFilterPin(Filter);
    if Assigned(CameraOut.OutputPin) then begin
      InitCapture;
      FinishGraph;
      FindCameraBmpSize;
    end
    else Found:=False;
  end
  else ShowMessage('Unable to find camera');

// clean up
  CreateDevEnum:=nil;
  EnumMoniker:=nil;
  Moniker:=nil;
  PropertyBag:=nil;
end;

procedure TCamera.Start;
begin
  MediaControl.Run;
end;

procedure TCamera.Pause;
begin
  MediaControl.Pause;
end;

procedure TCamera.Stop;
begin
  MediaControl.Stop;
  PurgeCallBacks;
end;

procedure TCamera.EnumFilterPins(Filter:IBaseFilter);
var
  Enum : IEnumPins;
  Pin  : IPin;
  Info : TPin_Info;
begin
  Filter.EnumPins(Enum);
  while Enum.Next(1,Pin,nil)=S_OK do begin
    Pin.QueryPinInfo(Info);
  end;
end;

function TCamera.FirstFilterPin(Filter:IBaseFilter):IPin;
var
  Enum : IEnumPins;
  HR   : HResult;
begin
  HR:=Filter.EnumPins(Enum);
  HR:=Enum.Next(1,Result, nil);
  if HR<>S_OK then begin
    ShowMessage('Unable to find 1st filter pin');
    Exit;
  end;
end;

function TCamera.SecondFilterPin(Filter:IBaseFilter):IPin;
var
  Enum : IEnumPins;
  HR   : HResult;
begin
  HR:=Filter.EnumPins(Enum);
  HR:=Enum.Skip(1);
  HR:=Enum.Next(1,Result, nil);
  if HR<>S_OK then begin
    ShowMessage('Unable to find 2nd filter pin');
    Exit;
  end;
end;

procedure TCamera.SizeBmps;
begin
  Bmp.Width:=TrackW;
  Bmp.Height:=TrackH;
  IBmp.Width:=TrackW;
  IBmp.Height:=TrackH;
  FlippedBmp.Width:=TrackW;
  FlippedBmp.Height:=TrackH;
  BackGndFinder.SizeBmps;
end;

procedure TCamera.UseFirstDevice;
var
  CreateDevEnum : ICreateDevEnum;
  HR            : HResult;
  EnumMoniker   : IEnumMoniker;
  Moniker       : IMoniker;
  cFetched      : DWord;
  Filter        : IBaseFilter;
  PropertyBag   : IPropertyBag;
  Name          : OleVariant;
begin
  Found:=False;
  HR:=CoCreateInstance(CLSID_SystemDeviceEnum,nil,CLSCTX_INPROC_SERVER,
                            IID_ICreateDevEnum,CreateDevEnum);
  if (HR<>S_OK) then begin
    ShowMessage('Error Creating Device Enumerator');
    Exit;
  end;
  HR:=CreateDevEnum.CreateClassEnumerator(CLSID_VideoInputDeviceCategory,
                                          EnumMoniker,0);
  if HR<>S_OK then begin
    ShowMessage('Unable to find any video capture hardware.');
    Exit;
  end;
  EnumMoniker.Reset;
  if EnumMoniker.Next(1,Moniker,@cFetched)<>S_OK then begin
    ShowMessage('Unable to find moniker');
    Exit;
  end;
  Moniker.BindToObject(nil,nil,IID_IBaseFilter,Filter);
  Moniker.BindToStorage(nil,nil,IID_IPropertyBag,PropertyBag);
  PropertyBag.Read('FriendlyName',Name,nil);
  CameraName:=Name;
  if Pos('GF080',Name)>0 then begin
    ImageW:=MaxImageW;
    ImageH:=MaxImageH;
  end
  else begin
    ImageW:=640;
    ImageH:=480;
  end;
  FullBmp.Width:=ImageW;
  FullBmp.Height:=ImageH;

// add it to the GraphBuilder
  HR:=GraphBuilder.AddFilter(Filter,'Camera');
  if HR=S_OK then begin
    CameraOut.Added:=True;
    CameraOut.BaseI:=Filter;
    CameraOut.OutputPin:=FirstFilterPin(Filter);
    InitCapture;
    FinishGraph;
    Camera.Found:=True;
  end;
end;

procedure TCamera.ShowCameraPropertyPages;
var
  PropertyPages : ISpecifyPropertyPages;
  HR            : HResult;
  Info          : TFilterInfo;
  UnknownI      : IUnknown;
  caGUID        : CAUUID;
  Filter        : IBaseFilter;
begin
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then begin
    ShowMessage('Unable to find Camera filter');
    Exit;
  end;
  HR:=Filter.QueryInterface(IID_ISpecifyPropertyPages,PropertyPages);
  if HR<>S_OK then begin
    ShowMessage('No property pages for this camera');
    Exit;
  end;

// Get the filter's name and IUnknown pointer.
  Filter.QueryFilterInfo(Info);
  Filter.QueryInterface(IID_IUnknown,UnknownI);

// show the pages
  PropertyPages.GetPages(caGUID);
  PropertyPages:=nil;
  OleCreatePropertyFrame(
    FHandle,       // Parent window
    0, 0,          // (Reserved)
    Info.achName,  // Caption for the dialog box
    1,             // Number of objects (just the filter)
    @UnknownI,     // Array of object pointers.
    caGUID.cElems, // Number of property pages
    caGUID.pElems, // Array of property page CLSIDs
    0,             // Locale identifier
    0, nil         // Reserved
  );

// Clean up.
  CoTaskMemFree(caGUID.pElems);
end;

procedure TCamera.ShowCameraPinPropertyPages;
var
  HR     : HResult;
  caGUID : CAUUID;
  Pages  : ISpecifyPropertyPages;
begin
  if AvtDriverUsed then begin
    if MessageDlg(
      'View the camera filter''s pin properties will cause the camera''s '+
      'to loose its debayering. This can be restored by restarting the program.'+
      'Do you want to continues?',mtWarning,[mbYes,mbNo],0)=mrNo then Exit;
  end;

// look for the pages interface
  HR:=CameraOut.OutputPin.QueryInterface(IID_ISpecifyPropertyPages,Pages);

  if HR<>S_OK then begin
    ShowMessage('No property pages found for the camera capture pin');
  end;
  HR:=Pages.GetPages(caGuid);

// disconnect the pin
  MediaControl.Stop;
  MediaControl:=nil;
  HR:=GraphBuilder.Disconnect(Grabber.InputPin);
  HR:=GraphBuilder.Disconnect(CameraOut.OutputPin);

//show the pages
  HR:=OleCreatePropertyFrame(FHandle,30,30,nil,1,@CameraOut.OutputPin,
                             caGuid.cElems,caGuid.pElems,0,0,nil);

  CoTaskMemFree(caGuid.pElems);

// re-connect
  HR:=GraphBuilder.Connect(CameraOut.OutputPin,Grabber.InputPin);

// we'll need a pointer to the MediaControl too
  HR:=GraphBuilder.QueryInterface(IID_IMediaControl,MediaControl);
  if HR<>S_OK then begin
    ShowMessage('Unable to get MediaControl interface');
    Halt;
  end;
  MediaControl.Run;
end;

procedure TCamera.FindCameraBmpSize;
var
  VIHeader : PVideoInfoHeader;
  HR       : HResult;
begin
  HR:=SampleGrabber.GetConnectedMediaType(MediaType);
  if HR=S_OK then begin
    if CompareMem(@MediaType.FormatType,@FORMAT_VideoInfo,SizeOf(TGuid)) then begin
      VIHeader:=PVideoInfoHeader(MediaType.pbFormat);

// get the width,height
      ImageW:=VIHeader^.bmiHeader.biWidth;
      ImageH:=VIHeader^.bmiHeader.biHeight;
    end;
    FreeMediaType(@MediaType);
  end;
end;

procedure TCamera.SetSize(NewWidth,NewHeight:Integer);
var
  pSc      : IAMStreamConfig;
  pMt      : PAM_MEDIA_TYPE;
  VIHeader : PVideoInfoHeader;
  HR       : HResult;
  Filter   : IBaseFilter;
begin
  if (ImageW=NewWidth) and (ImageH=NewHeight) then Exit;
  ImageW:=NewWidth;
  ImageH:=NewHeight;
  if not Found then Exit;

// find the camera filter
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then begin
    ShowMessage('Unable to find Camera filter');
    Exit;
  end;

// find the output pin's cfg interface
  HR:=CaptureGraphBuilder2.FindInterface(@PIN_CATEGORY_CAPTURE,@MEDIATYPE_Video,
                                         Filter,IID_IAMStreamConfig,pSc);
  if HR<>S_OK then begin
    ShowMessage('No cfg interface found for camera capture pin');
    Exit;
  end;

// get the current format
  HR:=pSc.GetFormat(pMt);
  if HR<>S_OK then begin
    ShowMessage('Unable to get current format');
    Exit;
  end;
  if CompareMem(@pMt.FormatType,@FORMAT_VideoInfo,SizeOf(TGuid)) then begin
    VIHeader:=PVideoInfoHeader(pMt^.pbFormat);

    VIHeader.dwBitRate:=Round(ImageW*ImageH*Bpp*FPS);

// set the frame rate part of the structure
    VIHeader.AvgTimePerFrame:=Round(10000000/FPS);

// set the width,height size of the structure
    VIHeader^.bmiHeader.biWidth:=ImageW;
    VIHeader^.bmiHeader.biHeight:=ImageH;

// set the bits/pixel
    VIHeader^.bmiHeader.biBitCount:=8;
    VIHeader^.bmiHeader.biCompression:=808466521; //$30303859;//
    VIHeader^.bmiHeader.biSizeImage:=ImageW*ImageH*Bpp;

// give it back
    HR:=pSc.SetFormat(pMt^);
    if HR<>S_OK then begin
      ShowMessage('Error setting image size');
    end;
  end;
  DeleteMediaType(pMt);
end;

procedure TCamera.InitCapture;
var
  pSc      : IAMStreamConfig;
  pMt      : PAM_MEDIA_TYPE;
  VIHeader : PVideoInfoHeader;
  HR       : HResult;
  Filter   : IBaseFilter;
begin
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then begin
    ShowMessage('Unable to find Camera filter');
    Exit;
  end;
  HR:=CaptureGraphBuilder2.FindInterface(@PIN_CATEGORY_CAPTURE,@MEDIATYPE_Video,
                                         Filter,IID_IAMStreamConfig,pSc);
  if HR<>S_OK then begin
    ShowMessage('No cfg interface found for camera capture pin');
    Exit;
  end;

// get the current format
  HR:=pSc.GetFormat(pMt);
  if HR<>S_OK then begin
    ShowMessage('Unable to get current format');
    pSc:=nil;
    Exit;
  end;
  if CompareMem(@pMt.FormatType,@FORMAT_VideoInfo,SizeOf(TGuid)) then begin
    VIHeader:=PVideoInfoHeader(pMt^.pbFormat);

// set the frame rate part of the structure
    VIHeader.AvgTimePerFrame:=Round(10000000/FPS);

// set the image size
    VIHeader^.bmiHeader.biWidth:=ImageW;
    VIHeader^.bmiHeader.biHeight:=ImageH;

// bit rate
    VIHeader.dwBitRate:=Round(ImageW*ImageH*Bpp*FPS);

// set the bits/pixel
    VIHeader^.bmiHeader.biBitCount:=8;
    VIHeader^.bmiHeader.biCompression:=808466521; //$30303859;//
    VIHeader^.bmiHeader.biSizeImage:=ImageW*ImageH;

// give it back
    HR:=pSc.SetFormat(pMt^);
    if HR<>S_OK then begin
    end;
  end;
  pSc:=nil;
  DeleteMediaType(pMt);
end;

procedure TCamera.PurgeCallBacks;
var
  PurgeMsg : TMsg;
begin
  while PeekMessage(PurgeMsg,FHandle,NewBufferMsg,NewBufferMsg,PM_REMOVE) do;
end;

function TCamera.LoRes:Boolean;
begin
  Result:=(ImageW=TrackW) and (ImageH=TrackH);
end;

procedure TCamera.FillFullTables;
var
  X,FullX : Integer;
  Y,FullY : Integer;
begin
  for X:=0 to TrackW-1 do begin
    FullX:=Round((MaxImageW-1)*(X/(TrackW-1)));
    FullXTable[X]:=FullX;
  end;
  for Y:=0 to TrackH-1 do begin
    FullY:=Round((MaxImageH-1)*(Y/(TrackH-1)));
    FullYTable[Y]:=FullY;
  end;
end;

procedure TCamera.DrawTrackingBmp;
var
  SrcX,SrcY,SrcI,X,Y : Integer;
  DestX,DestY,DestI  : Integer;
  SrcLine,DestLine   : PByteArray;
begin
  if LoRes then Bmp.Canvas.Draw(0,0,FullBmp)
  else for Y:=0 to TrackH-1 do begin
    DestLine:=Bmp.ScanLine[Y];
    SrcY:=FullYTable[Y];
    SrcLine:=FullBmp.ScanLine[SrcY];
    for X:=0 to TrackW-1 do begin
      DestI:=X*Bpp;
      SrcX:=FullXTable[X];
      SrcI:=SrcX*Bpp;
      DestLine^[DestI]:=SrcLine^[SrcI];
      DestLine^[DestI+1]:=SrcLine^[SrcI+1];
      DestLine^[DestI+2]:=SrcLine^[SrcI+2];
    end;
  end;
end;

procedure TCamera.DrawSmallBmp;
var
  SrcBpp,DestBpp    : Integer;
  SrcY,SrcYInc,SrcI : Integer;
  StartSrcI,SrcIInc : Integer;
  DestY,DestI,X     : Integer;
  SrcLine,DestLine  : PByteArray;
begin
  SrcBpp:=BytesPerPixel(Bmp);
  DestBpp:=BytesPerPixel(SmallBmp);

  if FlipImage then begin
    SrcY:=Bmp.Height-1;
    SrcYInc:=-4;
  end
  else begin
    SrcY:=0;
    SrcYInc:=+4;
  end;
  if MirrorImage then begin
    StartSrcI:=(Bmp.Width-1)*SrcBpp;
    SrcIInc:=-SrcBpp*4;
  end
  else begin
    StartSrcI:=0;
    SrcIInc:=SrcBpp*4;
  end;

  for DestY:=0 to SmallBmp.Height-1 do begin
    SrcLine:=Bmp.ScanLine[SrcY];
    SrcI:=StartSrcI;
    DestLine:=SmallBmp.ScanLine[DestY];
    DestI:=0;
    for X:=0 to SmallBmp.Width-1 do begin
      DestLine^[DestI]:=SrcLine^[SrcI];
      DestLine^[DestI+1]:=SrcLine^[SrcI+1];
      DestLine^[DestI+2]:=SrcLine^[SrcI+2];
      SrcI:=SrcI+SrcIInc;
      DestI:=DestI+DestBpp;
    end;
    SrcY:=SrcY+SrcYInc;
  end;
end;

procedure TCamera.WndProc(var Msg:TMessage);
var
  HR       : HResult;
  VIHeader : PVideoInfoHeader;
  BmpInfo  : TBitmapInfo;
  PixelBuf : Pointer;
  Den      : Single;
  I        : Integer;
begin
  if Msg.Msg=NewBufferMsg then begin
    HR:=SampleGrabber.GetConnectedMediaType(MediaType);
    if HR=S_OK then begin

// get a pointer to the video header
      VIHeader:=MediaType.pbFormat;
      if (VIHeader^.bmiHeader.biWidth<>ImageW) or
         (VIHeader^.bmiHeader.biHeight<>ImageH) then
      begin
        ImageW:=VIHeader^.bmiHeader.biWidth;
        ImageH:=VIHeader^.bmiHeader.biHeight;
        FullBmp.Width:=ImageW;
        FullBmp.Height:=ImageH;
      end;

// copy it into the BmpInfo
      ZeroMemory(@BmpInfo,SizeOf(TBitmapInfo));
      CopyMemory(@BmpInfo.BMIHeader,@(VIHeader^.bmiHeader),SizeOf(TBitmapInfoHeader));

// copy the data into the first bmp
      Case TrackMethod of
        tmBlobs :
          begin
            if LoRes then begin // LoRes means 640x480
              if UseITable then IBmp.Handle:=CreateDIBSection(0,BmpInfo,DIB_RGB_COLORS,PixelBuf,0,0)
              else if FlipImage or MirrorImage then begin
                FlippedBmp.Handle:=CreateDIBSection(0,BmpInfo,DIB_RGB_COLORS,PixelBuf,0,0);
              end
              else Bmp.Handle:=CreateDIBSection(0,BmpInfo,DIB_RGB_COLORS,PixelBuf,0,0);
            end
            else begin
              FullBmp.Handle:=CreateDIBSection(0,BmpInfo,DIB_RGB_COLORS,PixelBuf,0,0);
            end;
          end;
        tmSegmenter :
          begin
            FullBmp.Handle:=CreateDIBSection(0,BmpInfo,DIB_RGB_COLORS,PixelBuf,0,0);
          end;
      end;

// copy the bits over
      if PixelBuf<>nil then begin
        I:=Msg.wParam;
        Move(CBRecord[I].Buffer,PixelBuf^,CBRecord[I].BufferSize);
      end;

// draw the final full size bmp - I-compensated, flipped, and mirrored
      Case TrackMethod of
        tmBlobs :
          begin
            if not LoRes then begin // LoRes means 640x480
              if UseITable then IBmp.Canvas.StretchDraw(Rect(0,0,TrackW,TrackH),FullBmp)
              else if FlipImage or MirrorImage then begin
                FlippedBmp.Canvas.StretchDraw(Rect(0,0,TrackW,TrackH),FullBmp);
              end
              else begin
                DrawTrackingBmp;
              end;
            end;

// intensity compensation
            if UseITable then begin
              if FlipImage or MirrorImage then begin
                DrawICompensatedBmp(IBmp,FlippedBmp);

// orient it the right way
                if FlipImage and MirrorImage then FlipAndMirrorBmp(FlippedBmp,Bmp)
                else if FlipImage then FlipBmp(FlippedBmp,Bmp)
                else if MirrorImage then MirrorBmp(FlippedBmp,Bmp);
              end
              else DrawICompensatedBmp(IBmp,Bmp);
            end
            else begin
              if FlipImage and MirrorImage then FlipAndMirrorBmp(FlippedBmp,Bmp)
              else if FlipImage then FlipBmp(FlippedBmp,Bmp)
              else if MirrorImage then MirrorBmp(FlippedBmp,Bmp);
            end;
          end;
        tmSegmenter :
          begin
            DrawTrackingBmp; // scale down to 640x480
            DrawSmallBmpFromCropWindow;
//            DrawSmallBmp;    // draw the small one - this will flip and mirror
            if UseITable then DrawSmallICompensatedBmp(SmallBmp,SmallBmp);
{f FrameCount=50 then begin
  FullBmp.SaveToFile('C:\Full.bmp');
  Bmp.SaveToFile('C:\Track.bmp');
  SmallBmp.SaveToFile('C:\Small.bmp');
end;}
          end;
      end;
      FreeMediaType(@MediaType);

// measure the frame rate
      Inc(FrameCount);
      if (FrameCount-FrameRateFrame)>=FrameRateAverages then begin
        Den:=CBRecord[I].SampleTime-LastSampleTime;
        if Den>0 then MeasuredFPS:=FrameRateAverages/Den
        else MeasuredFPS:=0;
        LastSampleTime:=CBRecord[I].SampleTime;
        FrameRateFrame:=FrameCount;
      end;

// call a callback
      if Assigned(FOnNewFrame) then FOnNewFrame(Self);
      Msg.Result:=0;
    end;
  end
  else with Msg do begin
    Result:=DefWindowProc(FHandle,Msg,wParam,lParam);
  end;
end;

procedure TCamera.SetOnNewFrame(NewFrameProc:TNotifyEvent);
begin
  FOnNewFrame:=NewFrameProc;
  DoneLastFrame:=True;
end;

procedure TCamera.UpdateWithJpg(Jpg:TJpegImage);
begin
  Inc(FrameCount);
  Bmp.Canvas.Draw(0,0,Jpg);
  if Assigned(FOnNewFrame) then FOnNewFrame(Self);
end;

procedure TCamera.InitBmp(Bitmap:TBitmap);
begin
  Case Bpp of
    1: Bitmap.PixelFormat:=pf8Bit;
    2: Bitmap.PixelFormat:=pf16Bit;
    3: Bitmap.PixelFormat:=pf24Bit;
    else Bitmap.PixelFormat:=pf32Bit;
  end;
  Bitmap.Width:=ImageW;
  Bitmap.Height:=ImageH;
end;

procedure TCamera.InitForTracking;
begin
  FrameCount:=0;
  if FireIDriverUsed then begin
    SetFireIFormatSizeAndFPS(MEDIASUBTYPE_RGB24,ImageW,ImageH,FPS);
    ApplyFireIControls;
  end
  else if AvtDriverUsed then begin
    InitAvtYUV800Filter;
    SetAvtDriverSettings(AvtDriverSettings);
  end
  else ApplyPropertiesAndControls;
  LoadITable;
  CalculateSmallITable;
end;

procedure TCamera.ApplyPropertiesAndControls;
var
  Prop : TVideoProcAmpProperty;
  Ctrl : TCameraControlProperty;
begin
  for Prop:=Low(TVideoProcAmpProperty) to High(TVideoProcAmpProperty) do begin
    with CamProperty[Prop] do if CtrlType<>ccNone then begin
      AbleToSetProperty(Prop,Value,CtrlType);
    end;
  end;
  for Ctrl:=Low(TCameraControlProperty) to High(TCameraControlProperty) do begin
    with CamControl[Ctrl] do if CtrlType<>ccNone then begin
      AbleToSetControl(Ctrl,Value,(CtrlType=ccAuto));
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Valid properties are "VideoProcAmp_" Brightness, Contrast, Hue, Saturation,
// Sharpness,_Gamma, ColorEnable, WhiteBalance, Backlight Compensation, Gain
////////////////////////////////////////////////////////////////////////////////
function TCamera.AbleToGetPropertyDetails(Prop:TVideoProcAmpProperty;
                        var Min,Max:Integer;var Auto,CanDisable:Boolean):Boolean;
var
  HR           : HResult;
  VideoProcAmp : IAMVideoProcAmp;
  Filter       : IBaseFilter;
  Flags        : Integer;
  Step,Default : Integer;
begin
  Result:=False;
  Auto:=False;
  CanDisable:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_IAMVideoProcAmp,VideoProcAmp);
  if HR<>S_OK then Exit;
  HR:=VideoProcAmp.GetRange(Prop,Min,Max,Step,Default,Flags);
  if HR=S_OK then begin
    Auto:=(Flags and 1)>0;
    CanDisable:=PointGreyDriverUsed and (Flags=2);
    Result:=True;
  end;
end;

function TCamera.AbleToGetProperty(Prop:TVideoProcAmpProperty;var Value:Integer;
                                   var Auto:Boolean):Boolean;
var
  HR           : HResult;
  VideoProcAmp : IAMVideoProcAmp;
  Filter       : IBaseFilter;
  Flags        : Integer;
begin
  Result:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_IAMVideoProcAmp,VideoProcAmp);
  if HR<>S_OK then Exit;
  HR:=VideoProcAmp.Get(Prop,Value,Flags);
  Auto:=(Flags and $1)>0;
  Result:=(HR=S_OK);
end;

function TCamera.AbleToSetProperty(Prop:TVideoProcAmpProperty;Value:Integer;
                                   CtrlType:TCameraControlType):Boolean;
var
  HR           : HResult;
  VideoProcAmp : IAMVideoProcAmp;
  Filter       : IBaseFilter;
  Flags        : Integer;
begin
  Result:=False;
  CamProperty[Prop].Value:=Value;
  CamProperty[Prop].CtrlType:=CtrlType;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_IAMVideoProcAmp,VideoProcAmp);
  if HR<>S_OK then Exit;
  Case CtrlType of
    ccAuto   : Flags:=3;
    ccManual : Flags:=2;
    ccOn     : Flags:=2;
    ccOff    : Flags:=1;
  end;
  HR:=VideoProcAmp.Set_(Prop,Value,Flags);
  Result:=(HR=S_OK);
end;

////////////////////////////////////////////////////////////////////////////////
// Valid controls are :
//  "CameraControl_"+ Pan, Tilt, Roll, Zoom, Exposure,Iris, Focus
////////////////////////////////////////////////////////////////////////////////
function TCamera.AbleToGetControlDetails(Control:TCameraControlProperty;
                   var Min,Max:Integer;var Auto:Boolean):Boolean;
var
  HR           : HResult;
  Filter       : IBaseFilter;
  Step,Default : Longint;
  Flags        : Longint;
  CamCtrl      : IAMCameraControl;
begin
  Result:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_IAMCameraControl,CamCtrl);
  if HR<>S_OK then Exit;
  HR:=CamCtrl.GetRange(Control,Min,Max,Step,Default,Flags);
  if HR=S_OK then begin
    Auto:=(TCameraControlFlags(Flags)=CameraControl_Flags_Auto);
    Result:=True;
  end;
end;

function TCamera.AbleToGetControl(Control:TCameraControlProperty;
                                  var Value:Integer;var Auto:Boolean):Boolean;
var
  HR           : HResult;
  Filter       : IBaseFilter;
  Flags        : Integer;
  CamCtrl      : IAMCameraControl;
begin
  Result:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_IAMCameraControl,CamCtrl);
  if HR<>S_OK then Exit;
  HR:=CamCtrl.Get(Control,Value,Flags);
  Auto:=(Flags and $1)>0;
  if HR=S_OK then Result:=True;
end;

function TCamera.AbleToSetControl(Control:TCameraControlProperty;Value:Integer;
                                  Auto:Boolean):Boolean;
var
  HR           : HResult;
  Filter       : IBaseFilter;
  Flags        : Integer;
  CamCtrl      : IAMCameraControl;
begin
  Result:=False;
  CamControl[Control].Value:=Value;
  if Auto then CamControl[Control].CtrlType:=ccAuto
  else CamControl[Control].CtrlType:=ccManual;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_IAMCameraControl,CamCtrl);
  if HR<>S_OK then Exit;
  if Auto then Flags:=3
  else Flags:=2;
  HR:=CamCtrl.Set_(Control,Value,Flags);
  if HR=S_OK then Result:=True;
end;

//  TFiExpoControlProperty = (FiExpoControl_Autoexp,FiExpoControl_Shutter,
//              	FiExpoControl_Gain,FiExpoControl_Iris);
function TCamera.AbleToGetFireIExposureControlDetails(ExpoCtrl:Integer;
                   var Min,Max,Value:Single;var AutoEnabled,AutoOn:Boolean):Boolean;
var
  Flags,Delta,Default : Integer;
  HR                  : HResult;
  Filter              : IBaseFilter;
  FiExpoControl       : IFiExpoControl;
begin
  Result:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_FiExpoControl,FiExpoControl);
  if HR<>S_OK then Exit;

// Query for the current value of auto exposure
  HR:=FiExpoControl.Get(ExpoCtrl,Value,Flags);
  if HR<>S_OK then Exit;
  AutoOn:=(Flags and FiFeatureControl_Flags_Auto)>0;

// Query for supported values of auto exposure
  HR:=FiExpoControl.GetRange(ExpoCtrl,Min,Max,Delta,Default,Flags);
  AutoEnabled:=(Flags and FiFeatureControl_Flags_Auto)>0;

  Result:=(HR=S_OK);

// free the control
  FiExpoControl:=nil;
end;

//  TFiExpoControlProperty = (FiExpoControl_Autoexp,FiExpoControl_Shutter,
//                          	FiExpoControl_Gain,FiExpoControl_Iris);
function TCamera.AbleToSetFireIExposureControl(ExpoCtrl:Integer;
                                             Value:Single;Auto:Boolean):Boolean;
var
  Flags          : Integer;
  FiExpoControl  : IFiExpoControl;
  HR             : HResult;
  Filter         : IBaseFilter;
begin
  Result:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_FiExpoControl,FiExpoControl);
  if HR<>S_OK then Exit;

// Query for the current value of the flags
//  HR:=FiExpoControl.Get(ExpoCtrl,CurValue,Flags);
  if Auto then Flags:=FiFeatureControl_Flags_On or FiFeatureControl_Flags_Auto
  else Flags:=FiFeatureControl_Flags_On or FiFeatureControl_Flags_Manual;

// Query for the current value of auto exposure = set in value
  HR:=FiExpoControl.Set_(ExpoCtrl,Value,Flags);
  if HR<>S_OK then Exit;

// free the control
  FiExpoControl:=nil;

// save the settings
  FireIExpoControl[ExpoCtrl].Value:=Round(Value);
  if Auto then FireIExpoControl[ExpoCtrl].CtrlType:=ccAuto
  else FireIExpoControl[ExpoCtrl].CtrlType:=ccManual;
end;

function TCamera.AbleToGetFireIColorControlDetails(ColorCtrl:Integer;
                   var Min,Max,Value:Single;var AutoEnabled,AutoOn:Boolean):Boolean;
var
  Flags,Delta,Default : Integer;
  HR                  : HResult;
  Filter              : IBaseFilter;
  FiColorControl       : IFiColorControl;
begin
  Result:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_FiColorControl,FiColorControl);
  if HR<>S_OK then Exit;

// Query for the current value of auto Colorsure
  HR:=FiColorControl.Get(ColorCtrl,Value,Flags);
  if HR<>S_OK then Exit;
  AutoOn:=(Flags and FiFeatureControl_Flags_Auto)>0;

// Query for supported values of auto Colorsure
  HR:=FiColorControl.GetRange(ColorCtrl,Min,Max,Delta,Default,Flags);
  AutoEnabled:=(Flags and FiFeatureControl_Flags_Auto)>0;

  Result:=(HR=S_OK);

// free the control
  FiColorControl:=nil;
end;

function TCamera.AbleToSetFireIColorControl(ColorCtrl:Integer;
                                             Value:Single;Auto:Boolean):Boolean;
var
  Flags          : Integer;
  FiColorControl : IFiColorControl;
  HR             : HResult;
  Filter         : IBaseFilter;
begin
  Result:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_FiColorControl,FiColorControl);
  if HR<>S_OK then Exit;

// Query for the current value of the flags
  if Auto then Flags:=FiFeatureControl_Flags_On or FiFeatureControl_Flags_Auto
  else Flags:=FiFeatureControl_Flags_On or FiFeatureControl_Flags_Manual;

// Query for the current value of auto Colorsure = set in value
  HR:=FiColorControl.Set_(ColorCtrl,Value,Flags);
  if HR<>S_OK then Exit;

// free the control
  FiColorControl:=nil;

// save the settings
  FireIColorControl[ColorCtrl].Value:=Round(Value);
  if Auto then FireIColorControl[ColorCtrl].CtrlType:=ccAuto
  else FireIColorControl[ColorCtrl].CtrlType:=ccManual;
end;

function TCamera.AbleToGetFireIBasicControlDetails(BasicCtrl:Integer;
                   var Min,Max,Value:Single;var AutoEnabled,AutoOn:Boolean):Boolean;
var
  Flags,Delta,Default : Integer;
  HR                  : HResult;
  Filter              : IBaseFilter;
  FiBasicControl       : IFiBasicControl;
begin
  Result:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_FiBasicControl,FiBasicControl);
  if HR<>S_OK then Exit;

// Query for the current value of auto Basicsure
  HR:=FiBasicControl.Get(BasicCtrl,Value,Flags);
  if HR<>S_OK then Exit;
  AutoOn:=(Flags and FiFeatureControl_Flags_Auto)>0;

// Query for supported values of auto Basicsure
  HR:=FiBasicControl.GetRange(BasicCtrl,Min,Max,Delta,Default,Flags);
  AutoEnabled:=(Flags and FiFeatureControl_Flags_Auto)>0;

  Result:=(HR=S_OK);

// free the control
  FiBasicControl:=nil;
end;

function TCamera.AbleToSetFireIBasicControl(BasicCtrl:Integer;
                                            Value:Single;Auto:Boolean):Boolean;
var
  Flags          : Integer;
  FiBasicControl : IFiBasicControl;
  HR             : HResult;
  Filter         : IBaseFilter;
begin
  Result:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_FiBasicControl,FiBasicControl);
  if HR<>S_OK then Exit;

// Query for the current value of the flags
  if Auto then Flags:=FiFeatureControl_Flags_On or FiFeatureControl_Flags_Auto
  else Flags:=FiFeatureControl_Flags_On or FiFeatureControl_Flags_Manual;

// Query for the current value of auto Basicsure = set in value
  HR:=FiBasicControl.Set_(BasicCtrl,Value,Flags);
  if HR<>S_OK then Exit;

// free the control
  FiBasicControl:=nil;

// save the settings
  FireIBasicControl[BasicCtrl].Value:=Round(Value);
  if Auto then FireIBasicControl[BasicCtrl].CtrlType:=ccAuto
  else FireIBasicControl[BasicCtrl].CtrlType:=ccManual;
end;

procedure TCamera.ShowFireIVideoFormatList(Lines:TStrings);
var
  FiVideoFormatCfg    : IFiVideoFormatConfig;
  Filter              : IBaseFilter;
  pMt                 : PAM_MEDIA_TYPE;
  HR                  : HResult;
  Count               : DWord;
  VideoFormatArray    : PFiVideoFormatInfoArray;
  I,B                 : Integer;
  CurrentFPS,FireIFps : Integer;
  VIHeader            : PVideoInfoHeader;
begin
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_FiVideoFormatConfig,FiVideoFormatCfg);
  if HR<>S_OK then Exit;
  HR:=FiVideoFormatCfg.GetVideoFormatList(VideoFormatArray,Count);

  if Assigned(Lines) then for I:=1 to Count do begin
    if Lines.Count>0 then Lines.Add('');
    pMt:=VideoFormatArray^[I].pMediaType;
    if Assigned(pMt) then begin

// major type
      if GuidsEqual(pMt^.MajorType,MEDIATYPE_VIDEO) then begin
        Lines.Add('Major type = video')
      end
      else Lines.Add('Major type = ???');

// sub type
      Lines.Add('Sub type = '+MediaSubTypeStr(pMt^.SubType));

      VIHeader:=PVideoInfoHeader(pMt^.pbFormat);
      if Assigned(VIHeader) then with VIHeader^.bmiHeader do begin
        Lines.Add('Bmp Info:');
        Lines.Add('Size = '+IntToStr(biSize));
        Lines.Add('Width = '+IntToStr(biWidth));
        Lines.Add('Height = '+IntToStr(biHeight));
      end;
    end;

    if FiIsScalableFormat(VideoFormatArray^[I].ConfigCaps) then begin
      Lines.Add('Scalable');
    end
    else Lines.Add('Not scalable');
    ShowVideoStreamCfgCaps(VideoFormatArray^[I].ConfigCaps,Lines);

// custom rect
    with VideoFormatArray^[I].CustomRect do begin
      Lines.Add('Left:'+IntToStr(Left)+' top:'+IntToStr(Top)+
                ' right:'+IntToStr(Right)+' bottom:'+IntToStr(Bottom));;
    end;

// FPS
  //  FiVideoFormatCfg.GetCurrentFps(I-1,CurrentFps);
  //  Lines.Add('Current FPS = '+FireIFpsStr(CurrentFps));

    Lines.Add('Supported FPS:');
    for FireIFps:=FPS_1_875 to FPS_120 do begin
      if FiFpsSupported(VideoFormatArray^[I].SupportedFpsMask,FireIFps) then begin
        Lines.Add(FireIFpsStr(FireIFps)+' FPS');
      end;
    end;
  end;
  HR:=FiVideoFormatCfg.FreeVideoFormatList(VideoFormatArray^);//InfoList);
end;

procedure TCamera.SetFireIFrameRate;
var
  Filter           : IBaseFilter;
  FiVideoFormatCfg : IFiVideoFormatConfig;
  HR               : HResult;
  FireIFps         : Integer;
  VideoFormatArray : PFiVideoFormatInfoArray;
  VideoFormatPtr   : PFiVideoFormatInfo;
  Count,I          : DWord;
begin
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=CaptureGraphBuilder2.FindInterface(@PIN_CATEGORY_CAPTURE,@MEDIATYPE_Video,
                               Filter,IID_FiVideoFormatConfig,FiVideoFormatCfg);
  if HR<>S_OK then Exit;

//  HR:=FiVideoFormatCfg.GetVideoFormatList(VideoFormatPtr,Count);
  VideoFormatArray:=PFiVideoFormatInfoArray(VideoFormatPtr);

  if FPS=1.875 then FireIFps:=FPS_1_875
  else if FPS=3.75 then FireIFps:=FPS_3_75
  else if FPS=7.5 then FireIFps:=FPS_7_5
  else if FPS=15 then FireIFps:=FPS_15
  else if FPS=30 then FireIFps:=FPS_30
  else if FPS=60 then FireIFps:=FPS_60
  else if FPS=120 then FireIFps:=FPS_120
  else FireIFps:=FPS_NONE;

// disconnect the pin
  MediaControl.Stop;
  MediaControl:=nil;
  HR:=GraphBuilder.Disconnect(Grabber.InputPin);
  HR:=GraphBuilder.Disconnect(CameraOut.OutputPin);

// set the fps
  for I:=0 to Count-1 do begin
    HR:=FiVideoFormatCfg.SetCurrentFps(I,FireIFps);
  end;
  VideoFormatArray:=nil;
  FiVideoFormatCfg:=nil;

// re-connect
  HR:=GraphBuilder.Connect(CameraOut.OutputPin,Grabber.InputPin);

// we'll need a pointer to the MediaControl too
  HR:=GraphBuilder.QueryInterface(IID_IMediaControl,MediaControl);
  if HR<>S_OK then begin
    ShowMessage('Unable to get MediaControl interface');
    Halt;
  end;
  MediaControl.Run;
end;

procedure TCamera.ShowFireIVenderInfo(Lines:TStrings);
var
  Filter      : IBaseFilter;
  HR          : HResult;
  CamInfo     : IFiCameraInfo;
  VenderInfo  : TFiVenderInfo;
  LicenceType : Integer;
begin
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;

  HR:=Filter.QueryInterface(IID_FiCameraInfo,CamInfo);
  if HR<>S_OK then Exit;

  CamInfo.GetVenderInfo(VenderInfo);
  with VenderInfo do begin
    if Lines.Count>0 then Lines.Add('');
    Lines.Add(szCameraVender);
    Lines.Add(szCameraModelName);
    Lines.Add(IntToStr(uCameraSerial));
  end;
  CamInfo.GetLicenceType(LicenceType);
  Lines.Add('Licence type = '+FiLicenceTypeToStr(LicenceType));
  CamInfo:=nil;
end;

procedure TCamera.SetFireIFormatSizeAndFPS(Format:TGUID;W,H:Integer;Fps:Single);
var
  FiVideoFormatCfg : IFiVideoFormatConfig;
  Filter           : IBaseFilter;
  pMt              : PAM_MEDIA_TYPE;
  HR               : HResult;
  Count            : DWord;
  VideoFormatArray : PFiVideoFormatInfoArray;
  I,MaxX,MaxY      : Integer;
  VIHeader         : PVideoInfoHeader;
  FiFPS            : Integer;
  Done             : Boolean;
begin
  FiFPS:=FpsToFiFps(FPS);
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_FiVideoFormatConfig,FiVideoFormatCfg);
  if HR<>S_OK then Exit;
  HR:=FiVideoFormatCfg.GetVideoFormatList(VideoFormatArray,Count);

  I:=0;
  Done:=False;
  while (I<Count) and (not Done) do begin
    Inc(I);
    pMt:=VideoFormatArray[I].pMediaType;
    if Assigned(pMt) then begin

// check the pixel format
      if GuidsEqual(pMt^.MajorType,MEDIATYPE_VIDEO) and
         GuidsEqual(pMt^.SubType,Format) then
      begin

// check the frame rate
        if FiFpsSupported(VideoFormatArray[I].SupportedFpsMask,FiFps) then begin

// check the resolution
          with VideoFormatArray^[I].ConfigCaps.MaxOutputSize do begin
            MaxX:=Cx;
            MaxY:=Cy;
          end;
          if (MaxX=W) and (MaxY=H) then begin
            StopGraph;

// set the fps
            FiVideoFormatCfg.SetCurrentFPS(I-1,FiFPS);

// make sure this is the selected format
            FiVideoFormatCfg.SetDefaultFormat(I-1);
            Done:=True;
            StartGraph;
          end;
        end;
      end;
    end;
  end;
  HR:=FiVideoFormatCfg.FreeVideoFormatList(VideoFormatArray^);//InfoList);
end;

procedure TCamera.StopGraph;
var
  HR : HResult;
begin
  if Assigned(MediaControl) then begin
    MediaControl.Stop;
    MediaControl:=nil;
  end;
  if Assigned(GraphBuilder) then begin
    HR:=GraphBuilder.Disconnect(Grabber.InputPin);
    HR:=GraphBuilder.Disconnect(CameraOut.OutputPin);
  end;
end;

procedure TCamera.StartGraph;
var
  HR : HResult;
begin
// re-connect
  HR:=GraphBuilder.Connect(CameraOut.OutputPin,Grabber.InputPin);

// we'll need a pointer to the MediaControl too
  HR:=GraphBuilder.QueryInterface(IID_IMediaControl,MediaControl);
  if HR<>S_OK then begin
    ShowMessage('Unable to get MediaControl interface');
    Halt;
  end;
  MediaControl.Run;
end;

function TCamera.FireIDriverUsed:Boolean;
var
  HR          : HResult;
  Filter      : IBaseFilter;
  CamInfo     : IFiCameraInfo;
begin
  Result:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_FiCameraInfo,CamInfo);
  Result:=(HR=S_OK);
end;

function TCamera.DriverType:TDriverType;
begin
  if PointGreyDriverUsed then Result:=dtPtGrey
  else if FireIDriverUsed then Result:=dtFireI
  else if AvtDriverUsed then Result:=dtAvt
  else Result:=dtGeneric;
end;

procedure TCamera.ShowCameraSettingsFrm;
var
  Driver : TDriverType;
begin
  Driver:=DriverType;
  Case Driver of
    dtPtGrey :
      begin
        PointGreySettingsFrm:=TPointGreySettingsFrm.Create(Application);
        try
          PointGreySettingsFrm.Initialize;
          PointGreySettingsFrm.ShowModal;
        finally
          PointGreySettingsFrm.Free;
        end;
      end;
    dtFireI :
      begin
        FireISettingsFrm:=TFireISettingsFrm.Create(Application);
        try
          FireISettingsFrm.Initialize;
          FireISettingsFrm.ShowModal;
        finally
          FireISettingsFrm.Free;
        end;
      end;
    dtAvt :
      begin
        AvtSettingsFrm:=TAvtSettingsFrm.Create(Application);
        try
          AvtSettingsFrm.Initialize;
          AvtSettingsFrm.ShowModal;
        finally
          AvtSettingsFrm.Free;
        end;
      end;
    dtGeneric :
      begin
        CamSettingsFrm:=TCamSettingsFrm.Create(Application);
        try
          CamSettingsFrm.Initialize;
          CamSettingsFrm.ShowModal;
        finally
          CamSettingsFrm.Free;
        end;
      end;
  end;
  SaveCfgFile;
end;

procedure TCamera.ApplyFireIControls;
var
  C : Integer;
begin
  for C:=FiExpoControl_Autoexp to FiExpoControl_Iris do begin
    with FireIExpoControl[C] do if CtrlType<>ccNone then begin
      AbleToSetFireIExposureControl(C,Value,CtrlType=ccAuto);
    end;
  end;
  for C:=FiColorControl_UB to FiColorControl_Saturation do begin
    with FireIColorControl[C] do if CtrlType<>ccNone then begin
      AbleToSetFireIColorControl(C,Value,CtrlType=ccAuto);
    end;
  end;
  for C:=FiBasicControl_Focus to FiBasicControl_Gamma do begin
    with FireIBasicControl[C] do if CtrlType<>ccNone then begin
      AbleToSetFireIBasicControl(C,Value,CtrlType=ccAuto);
    end;
  end;
end;

function TCamera.PointGreyDriverUsed:Boolean;
var
  PgrInterface : IPGRInterface;
  HR           : HResult;
  Filter       : IBaseFilter;
begin
  Result:=False;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR=S_OK then begin
	  HR:=Filter.QueryInterface(PROPSETID_CUSTOM,PgrInterface);
    Result:=(HR=S_OK) and Assigned(PgrInterface);
    PgrInterface:=nil;
  end;
//Result:=Pos('PGR Streaming Digital Camera',CameraName)>0;
end;

function TCamera.GetPointGreyRegister(Address:DWord):DWord;
var
  PgrInterface : IPGRInterface;
  HR           : HResult;
  Filter       : IBaseFilter;
  Value        : DWord;//Integer;
  Format7      : TKsPropertyCustomFormat7S;
begin
  Result:=0;
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then begin
    ShowMessage('Unable to find Camera filter');
    Exit;
  end;
 	HR:=Filter.QueryInterface(PROPSETID_CUSTOM,PgrInterface);
  if HR=S_OK then begin
    HR:=PgrInterface.GetRegister(Address,Value);
  end;
  PgrInterface:=nil;
  Result:=Value;
end;

procedure TCamera.SetPointGreyRegister(Address,Value:DWord);
var
  PgrInterface : IPGRInterface;
  HR           : HResult;
  Filter       : IBaseFilter;
begin
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then begin
    ShowMessage('Unable to find Camera filter');
    Exit;
  end;
  PgrInterface:=nil;
	HR:=Filter.QueryInterface(PROPSETID_CUSTOM,PgrInterface);

	HR:=CaptureGraphBuilder2.FindInterface(@PIN_CATEGORY_CAPTURE,@MEDIATYPE_Video,
                                         Filter,PROPSETID_CUSTOM,PgrInterface);
  if HR=S_OK then PgrInterface.SetRegister(Address,Value);
  PgrInterface:=nil;
end;

// read the register directly - 8xbbbrrr
// x = 2 if enabled, 0 if disabled
// bbb = 12 bits of blue, rrr = 12 bits of red
procedure TCamera.GetPointGreyWhiteBalance(var Red,Blue:DWord;var CtrlEnabled:Boolean);
const
  Address = $80C;
var
  Value : DWord;
begin
  Value:=GetPointGreyRegister(Address);
  Blue:=(Value and $FFF000) shr 12;
  Red:= (Value and $000FFF);
//                         xbbbrrr
  CtrlEnabled:=(Value and $2000000)>0;
end;

// Set the register directly - 8xbbbrrr
// x = 2 if enabled, 0 if disabled
// bbb = 12 bits of blue, rrr = 12 bits of red
procedure TCamera.SetPointGreyWhiteBalance(Red,Blue:DWord;CtrlEnabled:Boolean);
const
  Address = $80C;
var
  Value : DWord;
begin
  Value:=(Red shl 12)+Blue;
  if CtrlEnabled then Value:=Value+$82000000
  else Value:=Value+$80000000;
  SetPointGreyRegister(Address,Value);
end;

function TCamera.AvtDriverUsed:Boolean;
var
  HR     : HResult;
  Filter : IBaseFilter;
begin
  HR:=GraphBuilder.FindFilterByName('AVT YUV800',Filter);
  Result:=(HR=S_OK);
end;

procedure TCamera.SetFlipImage(NewSetting:Boolean);
var
  Filter : IBaseFilter;
  HR     : HResult;
  YUV800 : IYUV800Parameter;
begin
  FlipImage:=NewSetting;

// find the YUV800 filter
  HR:=GraphBuilder.FindFilterByName('AVT YUV800',Filter);
  if HR<>S_OK then Exit;

// get an interface to the YUV800Parameter
  HR:=Filter.QueryInterface(IID_IYUV800Parameter,YUV800);
  if HR<>S_OK then Exit;
  HR:=YUV800.SetFlipImage(Integer(FlipImage));

// we're done with this interface
  YUV800:=nil;
  Filter:=nil;
end;

procedure TCamera.InitAvtYUV800Filter;
var
  Filter  : IBaseFilter;
  HR      : HResult;
  YUV800  : IYUV800Parameter;
begin
// find the YUV800 filter
  HR:=GraphBuilder.FindFilterByName('AVT YUV800',Filter);
  if HR<>S_OK then Exit;

// get an interface to the YUV800Parameter
  HR:=Filter.QueryInterface(IID_IYUV800Parameter,YUV800);
  if HR<>S_OK then Exit;
  HR:=YUV800.SetFlipImage(0);
  HR:=YUV800.SetRGB32(1);

  HR:=YUV800.SetDebayering(1);
  HR:=YUV800.SetBWDebayering(AvtDriverSettings.BwDebayering);

// we're done with this interface
  YUV800:=nil;
  Filter:=nil;
end;

procedure TCamera.SetAvtDriverSettings(Settings:TAvtDriverSettings);
var
  Filter  : IBaseFilter;
  HR      : HResult;
  AvtProp : IAVTDolphinPropSet;
begin
// get an interface to the property setter
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;

  HR:=Filter.QueryInterface(IID_IAVTDolphinPropSet,AvtProp);
  if HR<>S_OK then Exit;

  AvtDriverSettings:=Settings;

// Gamma
  HR:=AvtProp.SetGamma(Settings.GammaOn);

// Gain
  with Settings.Gain do begin
    HR:=AvtProp.SetGain(Value,Auto,OnePush);
  end;

// White Balance U
  with Settings.WhiteBalanceU do begin
    OnePush:=1;
    HR:=AvtProp.SetWhiteBalanceU(Value,Auto,OnePush);
  end;

// White Balance V
  with Settings.WhiteBalanceV do begin
    OnePush:=1;
    HR:=AvtProp.SetWhiteBalanceV(Value,Auto,OnePush);
  end;

// Brightness
  with Settings.Brightness do begin
    HR:=AvtProp.SetBrightness(Value,Auto,OnePush);
  end;

// Exposure
  with Settings.Exposure do begin
    HR:=AvtProp.SetExposure(Value,Auto,OnePush);
  end;
end;

function TCamera.GetAvtDriverSettings:TAvtDriverSettings;
var
  Filter  : IBaseFilter;
  HR      : HResult;
  AvtProp : IAVTDolphinPropSet;
begin
  Result:=DefaultAvtDriverSettings;

// get an interface to the property setter
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=Filter.QueryInterface(IID_IAVTDolphinPropSet,AvtProp);
  if HR<>S_OK then Exit;

// Gamma
  HR:=AvtProp.GetGamma(Result.GammaOn);

// Gain
  with Result.Gain do begin
    HR:=AvtProp.GetGainRange(Min,Max,AutoPossible,OnePushPossible);
    HR:=AvtProp.GetGain(Value,Auto,OnePush);
  end;

// WhiteBalanceU
  with Result.WhiteBalanceU do begin
    HR:=AvtProp.GetWhiteBalanceURange(Min,Max,AutoPossible,OnePushPossible);
    HR:=AvtProp.GetWhiteBalanceU(Value,Auto,OnePush);
  end;

// WhiteBalanceV
  with Result.WhiteBalanceV do begin
    HR:=AvtProp.GetWhiteBalanceVRange(Min,Max,AutoPossible,OnePushPossible);
    HR:=AvtProp.GetWhiteBalanceV(Value,Auto,OnePush);
  end;

// Brightness
  with Result.Brightness do begin
    HR:=AvtProp.GetBrightnessRange(Min,Max,AutoPossible,OnePushPossible);
    HR:=AvtProp.GetBrightness(Value,Auto,OnePush);
  end;

// Exposure
  with Result.Exposure do begin
    HR:=AvtProp.GetExposureRange(Min,Max,AutoPossible,OnePushPossible);
    HR:=AvtProp.GetExposure(Value,Auto,OnePush);
  end;
end;

procedure TCamera.SetAvtFPS;
var
  pSc      : IAMStreamConfig;
  pMt      : PAM_MEDIA_TYPE;
  VIHeader : PVideoInfoHeader;
  HR       : HResult;
  Filter   : IBaseFilter;
begin
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then begin
    ShowMessage('Unable to find Camera filter');
    Exit;
  end;
  HR:=CaptureGraphBuilder2.FindInterface(@PIN_CATEGORY_CAPTURE,@MEDIATYPE_Video,
                                         Filter,IID_IAMStreamConfig,pSc);
  if HR<>S_OK then begin
    ShowMessage('No cfg interface found for camera capture pin');
    Exit;
  end;

// get the current format
  HR:=pSc.GetFormat(pMt);
  if HR<>S_OK then begin
    ShowMessage('Unable to get current format');
    Exit;
  end;

// disconnect the pin
  MediaControl.Stop;

  if CompareMem(@pMt.FormatType,@FORMAT_VideoInfo,SizeOf(TGuid)) then begin
    VIHeader:=PVideoInfoHeader(pMt^.pbFormat);

// set the frame rate part of the MediaType structure
    VIHeader.AvgTimePerFrame:=Round(10000000/FPS);

// give it back
    HR:=pSc.SetFormat(pMt^);
    if HR<>S_OK then begin
      ShowMessage('Error setting frame rate');
    end;
  end;
  DeleteMediaType(pMt);

  MediaControl.Run;
end;

function TCamera.DriverName:String;
var
  Driver : TDriverType;
begin
  Driver:=DriverType;
  Case Driver of
    dtFireI   : Result:='Unibrain driver';
    dtPtGrey  : Result:='Point grey driver';
    dtAvt     : Result:='AVT driver';
    else Result:='Generic driver';
  end;
end;

function TCamera.AbleToSetSize(NewWidth,NewHeight:Integer):Boolean;
var
  pSc      : IAMStreamConfig;
  pMt      : PAmMediaType;
  VIHeader : PVideoInfoHeader;
  HR       : HResult;
  Filter   : IBaseFilter;
begin
  Result:=False;
  if not Found then Exit;

// find the camera filter
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then begin
    ShowMessage('Unable to find Camera filter');
    Exit;
  end;

// find the output pin's cfg interface
  HR:=CaptureGraphBuilder2.FindInterface(@PIN_CATEGORY_CAPTURE,@MEDIATYPE_Video,
                                         Filter,IID_IAMStreamConfig,pSc);
  if HR<>S_OK then begin
    ShowMessage('No cfg interface found for camera capture pin');
    Exit;
  end;

// get the current format
  HR:=pSc.GetFormat(pMt);
  if HR<>S_OK then begin
    ShowMessage('Unable to get current format');
    Exit;
  end;

  if CompareMem(@pMt.FormatType,@FORMAT_VideoInfo,SizeOf(TGuid)) then begin
    VIHeader:=PVideoInfoHeader(pMt^.pbFormat);

    VIHeader.dwBitRate:=Round(NewWidth*NewHeight*Bpp*FPS);

// set the frame rate part of the structure
    VIHeader.AvgTimePerFrame:=Round(10000000/FPS);

// set the width,height size of the structure
    VIHeader^.bmiHeader.biWidth:=NewWidth;
    VIHeader^.bmiHeader.biHeight:=NewHeight;

// set the bits/pixel
    VIHeader^.bmiHeader.biBitCount:=8;
    VIHeader^.bmiHeader.biCompression:=808466521; //$30303859;//
    VIHeader^.bmiHeader.biSizeImage:=NewWidth*NewHeight*Bpp;

// give it back
    StopGraph;
    HR:=pSc.SetFormat(pMt^);
    if HR<>S_OK then begin
      ShowMessage('Error setting image size');
    end
    else begin
      ImageW:=NewWidth;
      ImageH:=NewHeight;
      InitBmp(Bmp);
      with CropWindow do begin
        if ((X+W)>ImageW) or ((Y+H)>ImageH) then begin
          X:=Round(0.25*ImageW);
          W:=Round(ImageW*0.5);
          Y:=Round(0.25*ImageH);
          H:=Round(ImageH*0.5);
          InitAfterCropWindowChange;
        end;
      end;
      Result:=True;
    end;
    StartGraph;
  end;
  DeleteMediaType(pMt);
end;

procedure TCamera.SetAllAvtControlsToAuto;
var
  Settings : TAvtDriverSettings;
begin
  Settings:=GetAvtDriverSettings;
  Settings.Gain.Auto:=1;
  Settings.WhiteBalanceU.Auto:=1;
  Settings.WhiteBalanceV.Auto:=1;
  Settings.Exposure.Auto:=1;
  SetAvtDriverSettings(Settings);
end;

procedure TCamera.SetAllAvtControlsToFixed;
begin
  AvtDriverSettings:=GetAvtDriverSettings;
  AvtDriverSettings.Gain.Auto:=0;
  AvtDriverSettings.WhiteBalanceU.Auto:=0;
  AvtDriverSettings.WhiteBalanceV.Auto:=0;
  AvtDriverSettings.Exposure.Auto:=0;
  SetAvtDriverSettings(AvtDriverSettings);
end;

procedure TCamera.SetWhiteBalanceToAuto;
var
  Settings : TAvtDriverSettings;
begin
  Settings:=GetAvtDriverSettings;
  Settings.Gain.Auto:=0;
  Settings.WhiteBalanceU.Auto:=1;
  Settings.WhiteBalanceV.Auto:=1;
  Settings.Exposure.Auto:=0;
  SetAvtDriverSettings(Settings);
end;

procedure TCamera.SetAvtControlsToDefaults;
var
  Settings : TAvtDriverSettings;
begin
  Settings:=GetAvtDriverSettings;

// brightness = 0
  with Settings.Brightness do begin
    Auto:=0;
    Value:=Min;
  end;

// gain = 0 or 30%
  with Settings.Gain do begin
    Auto:=0;
    Value:=250;
  end;

// white balance = not auto
  Settings.WhiteBalanceU.Auto:=0;
  Settings.WhiteBalanceV.Auto:=0;

// exposure = 50%
  with Settings.Exposure do begin
    Auto:=0;
    Value:=3300;
  end;

  SetAvtDriverSettings(Settings);
end;

function TCamera.ITableFileName:String;
begin
  Result:=Path+'\ITable.dat';
end;

procedure TCamera.ClearITable;
var
  X,Y,I : Integer;
begin
  for Y:=0 to TrackH-1 do for X:=0 to TrackW-1 do begin
    ITable[X,Y]:=1.00;
//    for I:=0 to 255 do ITable[X,Y,I]:=I;
  end;
end;

procedure TCamera.MakeITableFromFullITable(var FullITable:TFullITable);
var
  X,Y,I : Integer;
  X2,Y2 : Integer;
begin
  for Y:=0 to TrackH-1 do begin
    Y2:=Round(Y*(MaxImageH-1)/(TrackH-1));
    for X:=0 to TrackW-1 do begin
      X2:=Round(X*(MaxImageW-1)/(TrackW-1));
      ITable[X,Y]:=FullITable[X2,Y2];
    end;
  end;
end;

procedure TCamera.LoadITable;
var
  Handle     : Integer;
  Size       : Integer;
  FileName   : String;
  Loaded     : Boolean;
  FullITable : TFullITable;
begin
  Loaded:=False;
  FileName:=ITableFileName;
  if FileExists(FileName) then begin
    Handle:=FileOpen(ITableFileName,fmOpenRead);
    if Handle>0 then begin
      Size:=FileSeek(Handle,0,2);
      if Size=SizeOf(FullITable) then begin
        FileSeek(Handle,0,0);
        Size:=FileRead(Handle,FullITable,SizeOf(FullITable));
        Loaded:=(Size=SizeOf(FullITable));
      end;
      FlushFileBuffers(Handle);
      FileClose(Handle);
    end;
  end;
  if Loaded then MakeITableFromFullITable(FullITable)
  else ClearITable;
end;

procedure TCamera.DrawICompensatedBmp(SrcBmp,DestBmp:TBitmap);
var
  X,Y,I,TY : Integer;
  BV       : Byte;
  V        : Single;
  SrcLine  : PByteArray;
  DestLine : PByteArray;
begin
  for Y:=0 to TrackH-1 do begin
    if FlipImage then TY:=(TrackH-1)-Y
    else TY:=Y;
    SrcLine:=SrcBmp.ScanLine[Y];
    DestLine:=DestBmp.ScanLine[Y];
    for X:=0 to TrackW-1 do begin
      I:=X*3;
      V:=ITable[X,TY]*SrcLine^[I+0];
      if V>=255 then BV:=255
      else BV:=Round(V);

// blue
      DestLine^[I+0]:=BV;

// green
      DestLine^[I+1]:=BV;

// red
      DestLine^[I+2]:=BV;
    end;
  end;
end;

procedure TCamera.StartRecording(Folder:String);
var
  I : Integer;
begin
  RecordFolder:=Folder;
  Recording:=True;
  RecordI:=0;
  for I:=1 to MaxRecordFrames do Jpg[I]:=TJpegImage.Create;
end;

procedure TCamera.UpdateRecording;
begin
  Inc(RecordI);
  Jpg[RecordI].Assign(Camera.Bmp);
  if RecordI=MaxRecordFrames then FinishRecording;
end;

procedure TCamera.FinishRecording;
var
  I : Integer;
begin
  for I:=1 to MaxRecordFrames do begin
    Jpg[I].SaveToFile(RecordFolder+ThreeDigitIntStr(I)+'.jpg');
    Jpg[I].Free;
    Recording:=False;
  end;
end;

function TCamera.XYToSmallXY(X,Y:Integer):TPoint;
begin
  Result.X:=Round(X/(ImageW-1)*(SmallW-1));
  Result.Y:=Round(Y/(ImageH-1)*(SmallH-1));
end;

function TCamera.SmallXYToXY(X,Y:Integer):TPoint;
begin
  Result.X:=Round(X/(SmallW-1)*(ImageW-1));
  Result.Y:=Round(Y/(SmallH-1)*(ImageH-1));
end;

function TCamera.SmallXYToTrackXY(X,Y:Integer):TPoint;
begin
  Result.X:=Round(X/(SmallW-1)*(TrackW-1));
  Result.Y:=Round(Y/(SmallH-1)*(TrackH-1));
end;

procedure TCamera.CalculateSmallITable;
var
  X,Y     : Integer;
  ImagePt : TPoint;
begin
  for X:=0 to SmallW-1 do for Y:=0 to SmallH-1 do begin
    ImagePt:=SmallXYToTrackXY(X,Y);
    SmallITable[X,Y]:=ITable[ImagePt.X,ImagePt.Y];
  end;
end;

procedure TCamera.DrawSmallICompensatedBmp(SrcBmp,DestBmp:TBitmap);
var
  X,Y,I    : Integer;
  V        : Single;
  SrcLine  : PByteArray;
  DestLine : PByteArray;
begin
  for Y:=0 to SmallH-1 do begin
    SrcLine:=SrcBmp.ScanLine[Y];
    DestLine:=DestBmp.ScanLine[Y];
    for X:=0 to SmallW-1 do begin
      I:=X*3;

// blue
      V:=SrcLine^[I+0]*SmallITable[X,Y];
      if V>255 then DestLine^[I+0]:=255
      else DestLine^[I+0]:=Round(V);

// green
      V:=SrcLine^[I+1]*SmallITable[X,Y];
      if V>255 then DestLine^[I+1]:=255
      else DestLine^[I+1]:=Round(V);

// red
      V:=SrcLine^[I+2]*SmallITable[X,Y];
      if V>255 then DestLine^[I+2]:=255
      else DestLine^[I+2]:=Round(V);
    end;
  end;
end;

procedure TCamera.DrawFlippedBmp;
begin
  OrientBmp(Bmp,FlippedBmp,FlipImage,MirrorImage);
end;

function TCamera.OrientedCropWindow:TCropWindow;
begin
  with Result do begin
    W:=CropWindow.W;
    H:=CropWindow.H;
    if FlipImage then Y:=Bmp.Height-(CropWindow.Y+CropWindow.H)
    else Y:=CropWindow.Y;
    if MirrorImage then X:=Bmp.Width-(CropWindow.X+CropWindow.W)
    else X:=CropWindow.X;
  end
end;

procedure TCamera.DrawSmallBmpFromCropWindow;
var
  X,Y,SrcI   : Integer;
  DestI,SrcY : Integer;
  DestBpp    : Integer;
  SrcLine    : PByteArray;
  DestLine   : PByteArray;
begin
  DestBpp:=BytesPerPixel(SmallBmp);
  for Y:=0 to SmallH-1 do begin
    SrcY:=YDrawTable[Y];
    if SrcY>=Bmp.Height-1 then SrcY:=Bmp.Height-1;
    SrcLine:=Bmp.ScanLine[SrcY];
    DestLine:=SmallBmp.ScanLine[Y];
    DestI:=0;
    for X:=0 to SmallW-1 do begin
      SrcI:=IDrawTable[X];
      DestLine^[DestI]:=SrcLine^[SrcI];
      DestLine^[DestI+1]:=SrcLine^[SrcI+1];
      DestLine^[DestI+2]:=SrcLine^[SrcI+2];
      Inc(DestI,DestBpp);
    end;
  end;
end;

procedure TCamera.InitAfterCropWindowChange;
begin
end;

procedure TCamera.BuildDrawTable;
var
  XScale,YScale  : Single;
  X,SrcX,Y,SrcY  : Integer;
  SrcI           : Integer;
  OrientedWindow : TCropWindow;
  OrientedX2     : Integer;
  OrientedY2     : Integer;
begin
  OrientedWindow:=OrientedCropWindow;

  Bpp:=BytesPerPixel(Bmp);

  OrientedX2:=OrientedWindow.X+OrientedWindow.W-1;
  XScale:=(OrientedWindow.W-1)/(SmallW-1);
  for X:=0 to SmallW-1 do begin
    SrcX:=Round(X*XScale);
    if MirrorImage then SrcX:=OrientedX2-SrcX
    else SrcX:=OrientedWindow.X+SrcX;
    SrcI:=SrcX*Bpp;
    IDrawTable[X]:=SrcI;
  end;

  OrientedY2:=OrientedWindow.Y+OrientedWindow.H-1;
  YScale:=(OrientedWindow.H-1)/(SmallH-1);
  for Y:=0 to SmallH-1 do begin
    SrcY:=Round(Y*YScale);
    if FlipImage then SrcY:=OrientedY2-SrcY
    else SrcY:=OrientedWindow.Y+SrcY;
    YDrawTable[Y]:=SrcY;
  end;
end;

procedure TCamera.ClipCropWindow;
begin
  with CropWindow do begin
    if (X+W)>ImageW then W:=ImageW-X;
    if (Y+H)>ImageH then H:=ImageH-Y;
    H:=Round(W*ImageH/ImageW);
  end;
end;

end.

