unit CameraU;

interface

uses
  DirectShow9, ActiveX, Classes, Windows, Graphics, Messages, Forms, Jpeg,
  Global, FiCommon, FireI, FiUtils, DShowUtils, PgrKsMedia, PgrInterface;

const
  NewBufferMsg       = WM_USER+1;
  FrameRateAverages  = 10;
  MaxBufferSize      = MaxImageW*MaxImageH*4;
  MaxCallBackRecords = 10;
  FPS                = 15.0;

type
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
    ImageW,ImageH,Bpp : Integer;

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

    FlipImage         : Boolean;
    CropWindow        : TCropWindow;
    Reserved          : array[1..1024] of Byte;
  end;

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
    FOnNewFrame      : TNotifyEvent;
    MediaType        : TAM_Media_Type;
    FHandle          : THandle;
    LastSampleTime   : Double;
    FrameRateFrame   : Integer;
    CBRecord         : TCallBackRecordArray;
    CamIndex         : Integer;
    CallBackI        : Integer;

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
    procedure DrawSmallBmp;
    procedure ApplyPropertiesAndControls;
    procedure ApplyFireIControls;

  public
    Tag           : Integer;
    FrameRate     : Single;
    MeasuredFPS   : Single;
    DoneLastFrame : Boolean;
    FrameCount    : Integer;
    CameraName    : String;
    ImageW,ImageH : Integer;
    Bmp           : TBitmap; // original camera bmp
    FlippedBmp    : TBitmap; // cam bmp flipped right side up
    SmallBmp      : TBitmap; // scaled down version for tracking
    BackGndBmp    : TBitmap;
    SubtractedBmp : TBitmap;
    Found         : Boolean;
    Bpp           : Integer;
    FlipImage     : Boolean;
    CropWindow    : TCropWindow;
    VideoWidth     : Integer;
    VideoHeight    : Integer;

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
    procedure SetFrameRate(NewFrameRate:Single);
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
    procedure ShowCameraSettingsFrm(ShowVideo:Boolean);

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
    procedure LoadBackGndBmp;
    procedure SaveBackGndBmp;
    procedure DrawSubtractedBmp;
    procedure InitAfterCropWindowChange;
    function  AbleToSetSize(NewWidth,NewHeight:Integer):Boolean;
    function  DefaultCropWindow:TCropWindow;
    function  DefaultCameraInfo:TCameraInfo;
  end;

var
  Camera : TCamera;

implementation

uses
  Dialogs, DSUtil, SysUtils, WMFUtil, BmpUtils, Math, Controls, FileCtrl,
  Routines, FireISetupFrmU, CamSetupFrmU, PtGreySetupFrmU, AvtYuv800Lib_TLB,
  AvtPropSetLib_TLB, AvtSetupFrmU, CfgFile;

function TCamera.DefaultCropWindow:TCropWindow;
begin
  with Result do begin
    X:=Round(ImageW*0.25);
    W:=Round(ImageW*0.50);
    Y:=Round(ImageH*0.25);
    H:=Round(ImageH*0.50);
  end;
end;

function TCamera.DefaultCameraInfo:TCameraInfo;
begin
  Result.ImageW:=ImageW;
  Result.ImageH:=ImageH;
  Result.Bpp:=3;
  FillChar(Result.CamProperty,SizeOf(Result.CamProperty),0);
  FillChar(Result.CamControl,SizeOf(Result.CamControl),0);
  FillChar(Result.FireIExpoControl,SizeOf(Result.FireIExpoControl),0);
  FillChar(Result.FireIColorControl,SizeOf(Result.FireIColorControl),0);
  FillChar(Result.FireIBasicControl,SizeOf(Result.FireIBasicControl),0);
  FillChar(Result.PointGreyWhiteBal,SizeOf(Result.PointGreyWhiteBal),0);
  FillChar(Result.AvtDriverSettings,SizeOf(Result.AvtDriverSettings),0);
  Result.FlipImage:=False;
  Result.CropWindow:=DefaultCropWindow;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

constructor TCamera.Create;
begin
  inherited Create;

// init vars
  ImageW:=MaxImageW;
  ImageH:=MaxImageH;
  Bpp:=3;
  Found:=False;
  FHandle:=AllocateHWnd(WndProc);
  CameraOut.Added:=False;
  Grabber.Added:=False;
  NullRenderer.Added:=False;

  FOnNewFrame:=nil;

  Bmp:=TBitmap.Create;
  FlippedBmp:=CreateSmallBmp;
  SmallBmp:=CreateSmallBmp;

  BackGndBmp:=CreateSmallBmp;
  ClearBmp(BackGndBmp,clBlack);
  LoadBackGndBmp;

  SubtractedBmp:=CreateSmallBmp;
  ClearBmp(SubtractedBmp,clBlack);

  LastSampleTime:=0;
  FrameRateFrame:=0;
  FrameCount:=0;
  DoneLastFrame:=True;
  MeasuredFPS:=0;

// initialize COM
  CoInitialize(nil);

// create the foundation interfaces
  CreateBaseInterfaces;
end;

destructor TCamera.Destroy;
begin
  SaveBackGndBmp;

  CoUninitialize;
  DeAllocateHWnd(FHandle);

  if Assigned(Bmp) then Bmp.Free;
  if Assigned(SmallBmp) then SmallBmp.Free;
  if Assigned(FlippedBmp) then FlippedBmp.Free;
  if Assigned(BackGndBmp) then BackGndBmp.Free;
  if Assigned(SubtractedBmp) then SubtractedBmp.Free;

  inherited;
end;

function TCamera.GetInfo:TCameraInfo;
begin
  Result.ImageW:=ImageW;
  Result.ImageH:=ImageH;
  Result.Bpp:=Bpp;
  Result.CamProperty:=CamProperty;
  Result.CamControl:=CamControl;
  Result.FireIExpoControl:=FireIExpoControl;
  Result.FireIColorControl:=FireIColorControl;
  Result.FireIBasicControl:=FireIBasicControl;
  Result.PointGreyWhiteBal:=PointGreyWhiteBal;
  Result.AvtDriverSettings:=AvtDriverSettings;
  Result.FlipImage:=FlipImage;
  Result.CropWindow:=CropWindow;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TCamera.SetInfo(NewInfo:TCameraInfo);
begin
//  ImageW:=NewInfo.ImageW;
//  ImageH:=NewInfo.ImageH;
  Bpp:=NewInfo.Bpp;
  InitBmp(Bmp);
  CamProperty:=NewInfo.CamProperty;
  CamControl:=NewInfo.CamControl;
  FireIExpoControl:=NewInfo.FireIExpoControl;
  FireIColorControl:=NewInfo.FireIColorControl;
  FireIBasicControl:=NewInfo.FireIBasicControl;
  PointGreyWhiteBal:=NewInfo.PointGreyWhiteBal;
  AvtDriverSettings:=NewInfo.AvtDriverSettings;
  FlipImage:=NewInfo.FlipImage;
  CropWindow:=NewInfo.CropWindow;
  if CropWindow.W=0 then CropWindow:=DefaultCropWindow;
  if FireIDriverUsed then ApplyFireIControls
  else if AvtDriverUsed then SetAvtDriverSettings(AvtDriverSettings)
  else begin
    ApplyPropertiesAndControls;
    if PointGreyDriverUsed then with PointGreyWhiteBal do begin
      SetPointGreyWhiteBalance(Red,Blue,Enabled);
    end;
  end;
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

// start it
  MediaControl.Run;
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

procedure TCamera.SetFrameRate(NewFrameRate:Single);
var
  pSc      : IAMStreamConfig;
  pMt      : PAM_MEDIA_TYPE;
  VIHeader : PVideoInfoHeader;
  HR       : HResult;
  Filter   : IBaseFilter;
begin
  FrameRate:=NewFrameRate;
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
  MediaControl:=nil;
  HR:=GraphBuilder.Disconnect(Grabber.InputPin);
  HR:=GraphBuilder.Disconnect(CameraOut.OutputPin);


  if CompareMem(@pMt.FormatType,@FORMAT_VideoInfo,SizeOf(TGuid)) then begin
    VIHeader:=PVideoInfoHeader(pMt^.pbFormat);

// set the frame rate part of the MediaType structure
    VIHeader.AvgTimePerFrame:=Round(10000000/FrameRate);

// give it back
    HR:=pSc.SetFormat(pMt^);
    if HR<>S_OK then begin
      ShowMessage('Error setting frame rate');
    end;
  end;
  DeleteMediaType(pMt);

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

// don't fight the image size
//  if VIHeader^.bmiHeader.biWidth<640 then begin
//    VIHeader^.bmiHeader.biWidth:=640;
//    VIHeader^.bmiHeader.biHeight:=480;
//  end;
    ImageW:=VIHeader^.bmiHeader.biWidth;
    ImageH:=VIHeader^.bmiHeader.biHeight;

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

procedure TCamera.DrawSmallBmp;
var
  Bpr,X,Y  : Integer;
  DestX    : Integer;
  SrcLine  : PByteArray;
  DestLine : PByteArray;
//  CropRect : TRect;
begin
//  with CropWindow do CropRect:=Rect(X,Y,X+W,Y+H);
//  FlippedBmp.Canvas.CopyRect(SmallRect,Bmp.Canvas,CropRect);

// shrink it down to SmallBmp size - no point in processing all the pixels
  SetStretchBltMode(FlippedBmp.Canvas.Handle,COLORONCOLOR);
  StretchBlt(FlippedBmp.Canvas.Handle,0,0,FlippedBmp.Width,FlippedBmp.Height,
       Bmp.Canvas.Handle,CropWindow.X,CropWindow.Y,CropWindow.W,CropWindow.H,SRCCOPY);

  Bpr:=3*SmallBmp.Width;

// flip it in Y
  if FlipImage then begin
    for Y:=0 to SmallRect.Bottom-1 do begin
      SrcLine:=FlippedBmp.ScanLine[Y];
      DestLine:=SmallBmp.ScanLine[SmallRect.Bottom-1-Y];
      Move(SrcLine^,DestLine^,Bpr);
    end;
  end

// mirror it in X
  else begin
    for Y:=0 to SmallRect.Bottom-1 do begin
      SrcLine:=FlippedBmp.ScanLine[Y];
      DestLine:=SmallBmp.ScanLine[Y];
      DestX:=SmallRect.Right-1;
      for X:=0 to SmallRect.Right-1 do begin
        Move(SrcLine^[X*3],DestLine^[DestX*3],3);
        Dec(DestX);
      end;
    end;
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

// copy it into the BmpInfo
      ZeroMemory(@BmpInfo,SizeOf(TBitmapInfo));
      CopyMemory(@BmpInfo.BMIHeader,@(VIHeader^.bmiHeader),SizeOf(TBitmapInfoHeader));

// get a pointer to the bmp's bits
      Bmp.Handle:=CreateDIBSection(0,BmpInfo,DIB_RGB_COLORS,PixelBuf,0,0);
      if Bmp.Width<>ImageW then begin
        ImageW:=Bmp.Width;
        ImageH:=Bmp.Height;
      end;

// copy the bits over
      if PixelBuf<>nil then begin
        I:=Msg.wParam;
        Move(CBRecord[I].Buffer,PixelBuf^,CBRecord[I].BufferSize);
        DrawSmallBmp;

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
      end;
    end;
    FreeMediaType(@MediaType);
    Msg.Result:=0;
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
  FrameRate:=15;
  FrameCount:=0;
  if FireIDriverUsed then begin
    SetFireIFormatSizeAndFPS(MEDIASUBTYPE_RGB24,ImageW,ImageH,FrameRate);
    ApplyFireIControls;
  end
  else if AvtDriverUsed then begin
    if AvtDriverSettings.Changed then SetAvtDriverSettings(AvtDriverSettings);
    SetAvtFPS;
  end
  else ApplyPropertiesAndControls;
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

procedure TCamera.SetFireIFrameRate(NewFrameRate:Single);
var
  Filter           : IBaseFilter;
  FiVideoFormatCfg : IFiVideoFormatConfig;
  HR               : HResult;
  FireIFps         : Integer;
  VideoFormatArray : PFiVideoFormatInfoArray;
  VideoFormatPtr   : PFiVideoFormatInfo;
  Count,I          : DWord;
begin
  FrameRate:=NewFrameRate;

  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  if HR<>S_OK then Exit;
  HR:=CaptureGraphBuilder2.FindInterface(@PIN_CATEGORY_CAPTURE,@MEDIATYPE_Video,
                               Filter,IID_FiVideoFormatConfig,FiVideoFormatCfg);
  if HR<>S_OK then Exit;

//  HR:=FiVideoFormatCfg.GetVideoFormatList(VideoFormatPtr,Count);
  VideoFormatArray:=PFiVideoFormatInfoArray(VideoFormatPtr);

  if FrameRate=1.875 then FireIFps:=FPS_1_875
  else if FrameRate=3.75 then FireIFps:=FPS_3_75
  else if FrameRate=7.5 then FireIFps:=FPS_7_5
  else if FrameRate=15 then FireIFps:=FPS_15
  else if FrameRate=30 then FireIFps:=FPS_30
  else if FrameRate=60 then FireIFps:=FPS_60
  else if FrameRate=120 then FireIFps:=FPS_120
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

procedure TCamera.ShowCameraSettingsFrm(ShowVideo:Boolean);
var
  Driver : TDriverType;
begin
  Driver:=DriverType;
  Case Driver of
    dtPtGrey :
      begin
        PointGreySettingsFrm:=TPointGreySettingsFrm.Create(Application);
        try
          PointGreySettingsFrm.Initialize(ShowVideo);
          PointGreySettingsFrm.ShowModal;
        finally
          PointGreySettingsFrm.Free;
        end;
      end;
    dtFireI :
      begin
        FireISettingsFrm:=TFireISettingsFrm.Create(Application);
        try
          FireISettingsFrm.Initialize(ShowVideo);
          FireISettingsFrm.ShowModal;
        finally
          FireISettingsFrm.Free;
        end;
      end;
    dtAvt :
      begin
        AvtSettingsFrm:=TAvtSettingsFrm.Create(Application);
        try
          AvtSettingsFrm.Initialize(ShowVideo);
          AvtSettingsFrm.ShowModal;
        finally
          AvtSettingsFrm.Free;
        end;
      end;
    dtGeneric :
      begin
        CamSettingsFrm:=TCamSettingsFrm.Create(Application);
        try
          CamSettingsFrm.Initialize(ShowVideo);
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

procedure TCamera.SetAvtDriverSettings(Settings:TAvtDriverSettings);
var
  Filter  : IBaseFilter;
  HR      : HResult;
  YUV800  : IYUV800Parameter;
  AvtProp : IAVTDolphinPropSet;
begin
  Settings.RGB32:=1;
  Settings.FlipImage:=0;

  AvtDriverSettings:=Settings;
  AvtDriverSettings.Changed:=True;

// find the YUV800 filter
	HR:=GraphBuilder.FindFilterByName('AVT YUV800',Filter);
  if HR<>S_OK then Exit;

// get an interface to the YUV800Parameter
  HR:=Filter.QueryInterface(IID_IYUV800Parameter,YUV800);
  if HR<>S_OK then Exit;
  HR:=YUV800.SetFlipImage(Settings.FlipImage);
  HR:=YUV800.SetRGB32(Settings.RGB32);

  HR:=YUV800.SetDebayering(Settings.Debayering);
  HR:=YUV800.SetBWDebayering(Settings.BWDebayering);

// we're done with this interface
  YUV800:=nil;
  Filter:=nil;

// get an interface to the property setter
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
  HR:=Filter.QueryInterface(IID_IAVTDolphinPropSet,AvtProp);
  if HR<>S_OK then Exit;

// Gamma
  HR:=AvtProp.SetGamma(Settings.GammaOn);

// Gain
  with Settings.Gain do begin
    HR:=AvtProp.SetGain(Value,Auto,OnePush);
  end;

// White Balance U
  with Settings.WhiteBalanceU do begin
    HR:=AvtProp.SetWhiteBalanceU(Value,Auto,OnePush);
  end;

// White Balance V
  with Settings.WhiteBalanceV do begin
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
  YUV800  : IYUV800Parameter;
  AvtProp : IAVTDolphinPropSet;
begin
  FillChar(Result,SizeOf(Result),0);

// find the YUV800 filter
	HR:=GraphBuilder.FindFilterByName('AVT YUV800',Filter);
  if HR<>S_OK then Exit;

// get an interface to the YUV800Parameter
  HR:=Filter.QueryInterface(IID_IYUV800Parameter,YUV800);
  if HR<>S_OK then Exit;
  HR:=YUV800.GetFlipImage(Result.FlipImage);
  HR:=YUV800.GetRGB32(Result.RGB32);
  HR:=YUV800.GetDebayering(Result.Debayering);
  HR:=YUV800.GetBWDebayering(Result.BWDebayering);

// we're done with this interface
  YUV800:=nil;
  Filter:=nil;

// get an interface to the property setter
  HR:=GraphBuilder.FindFilterByName('Camera',Filter);
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
    VIHeader.AvgTimePerFrame:=Round(10000000/FrameRate);

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

procedure TCamera.LoadBackGndBmp;
var
  FileName : String;
begin
  FileName:=Path+'BackGnd.bmp';
  if FileExists(FileName) then BackGndBmp.LoadFromFile(FileName)
  else ClearBmp(BackGndBmp,clBlack);
  BackGndBmp.PixelFormat:=pf24Bit;
end;

procedure TCamera.SaveBackGndBmp;
begin
  BackGndBmp.SaveToFile(Path+'BackGnd.bmp');
end;

procedure TCamera.DrawSubtractedBmp;
begin
  SubtractColorBmpAsm(SmallBmp,BackGndBmp,SubtractedBmp);
end;

procedure TCamera.InitAfterCropWindowChange;
begin
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
      InitBmp(FlippedBmp);
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

end.


