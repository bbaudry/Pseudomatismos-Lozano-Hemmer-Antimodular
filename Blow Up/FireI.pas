unit FireI;

{$A8}

interface

uses
  Windows, DirectShow9;
  
const
  IID_FiExpoControl : TGUID = (D1:$92750B52;D2:$7FB7;D3:$411B;
                               D4:($96,$30,$98,$D3,$DA,$FD,$93,$49));

  IID_FiColorControl : TGUID = (D1:$92750B62;D2:$7FB7;D3:$411B;
                                D4:($96,$30,$98,$D3,$DA,$FD,$93,$49));

  IID_FiBasicControl : TGUID = (D1:$92750B72;D2:$7FB7;D3:$411B;
                                D4:($96,$30,$98,$D3,$DA,$FD,$93,$49));

  IID_FiCameraInfo : TGUID = (D1:$5B44AFE7;D2:$6EFF;D3:$4B29;
                              D4:($90,$8B,$47,$0A,$33,$27,$D1,$E7));

	IID_FiVideoFormatConfig : TGUID = (D1:$63D0FAF7;D2:$CFBC;D3:$4DE5;
                                     D4:($B5,$39,$5B,$BD,$F0,$BC,$07,$3B));

  IID_IYuv2Rgb : TGUID = (D1:$92DCFFA8;D2:$C116;D3:$49A0;
                          D4:($AB,$AE,$6D,$EF,$D0,$3F,$EC,$A2));

  FiFeatureControl_Flags_Auto     = $01;
  FiFeatureControl_Flags_Manual   = $02;
  FiFeatureControl_Flags_One_Push = $04;
  FiFeatureControl_Flags_On       = $08;

  FiFeatureControl_Flags_Off      = $10;
  FiFeatureControl_Flags_Absolute = $20;
  FiFeatureControl_Flags_Relative = $40;

  FiExpoControl_Autoexp = 0;
  FiExpoControl_Shutter = 1;
	FiExpoControl_Gain    = 2;
  FiExpoControl_Iris    = 3;

	FiColorControl_UB         = 0;
	FiColorControl_VR         = 1;
	FiColorControl_Hue        = 2;
	FiColorControl_Saturation = 3;

	FiBasicControl_Focus      = 0;
	FiBasicControl_Zoom       = 1;
	FiBasicControl_Brightness = 2;
	FiBasicControl_Sharpness  = 3;
	FiBasicControl_Gamma      = 4;

  LICENCE_TYPE_HASP_VGA   = 0;
  LICENCE_TYPE_HASP_PRO   = 1;
  LICENCE_TYPE_UB_ADAPTER = 2;
  LICENCE_TYPE_UB_CAMERA  = 3;
  LICENCE_TYPE_PK         = 4;
  LICENCE_TYPE_DEMO       = 5;

  FPS_NONE = -1;
  FPS_1_875 = 0;
  FPS_3_75  = 1;
  FPS_7_5   = 2;
  FPS_15    = 3;
  FPS_30    = 4;
  FPS_60    = 5;
  FPS_120   = 6;

type
  TYuvToRgbCallBack = procedure(Data:PByte;BmpInfo:PBitmapInfoHeader;var Buffer) of Object;

  TCameraGUID = array[1..8] of Byte;
  PCameraGUID = ^TCameraGUID;

  TFiVenderInfo = record
    CameraGuid        : TCameraGUID;
	  uCameraNodeID     : Integer;
    szCameraVender    : array[1..64] of Char;
 	  szCameraModelName : array[1..64] of Char;
    uCameraSerial     : Integer;
  end;
  PFiVenderInfo = ^TFiVenderInfo;

  TFiPixelFormat = (FormatRGB32,FormatY800,FormatY444,FormatY422,FormatY411,
                    FormatY160);

  TFiRawMode = (Raw_Mode_None,Raw_Mode_RGGB,Raw_Mode_GRBG,Raw_Mode_GBRG,
                   Raw_Mode_BGGR);
  PFiRawMode = ^TFiRawMode;

  TFiVideoFormatInfo = record
 // A pointer to the media type of the stream format
    pMediaType : PAMMEDIATYPE;

// A structure describing extra configuration capabilities of the stream format
    ConfigCaps : TVideoStreamConfigCaps; 

// A bitmask that lists all the supported frame rates for the current format
    SupportedFpsMask : DWord;

// A rectangle describing the custom image position and dimentions.
// This is applicable only to scalable formats.
    CustomRect : TRect;
  end;
  PFiVideoFormatInfo = ^TFiVideoFormatInfo;
  PPFiVideoFormatInfo = ^PFiVideoFormatInfo;

  TFiVideoFormatInfoArray = array[1..32] of TFiVideoFormatInfo;
  PFiVideoFormatInfoArray = ^TFiVideoFormatInfoArray;

//  TFiVideoFormatInfoArray = array[1..High(Word)] of PFiVideoFormatInfo;
//  PFiVideoFormatInfoArray = ^TFiVideoFormatInfoArray;

  IFiExpoControl = interface(IUnknown)
    ['{92750B52-7FB7-411b-9630-98D3DAFD9349}']

    function GetRange(Property_:Integer;out pMin,pMax:Single;
              out pSteppingDelta,pDefault,pCapsFlags:Integer):HResult; stdcall;

    function Set_(Property_:Integer;Value:Single;Flags:Integer):HResult; stdcall;

    function Get(Property_:Integer;out Value:Single;out Flags:Integer):HResult; stdcall;

    function RelativeToAbsolute(Property_:Integer;RelativeValue:Single;
                                out AbsoluteValue:Single):HResult; stdcall;

    function AbsoluteToRelative(Property_:Integer;AbsoluteValue:Single;
                                out RelativeValue:Single):HResult; stdcall;

    function GetAbs(Property_:Integer;out Value:Single):HResult; stdcall;

    function SetAbs(Property_:Integer;Value:Single):HResult; stdcall;

    function GetAbsRange(Property_:Integer;out Min,Max:Single):HResult; stdcall;
  end;

  IFiColorControl = interface(IUnknown)
    ['{92750B62-7FB7-411b-9630-98D3DAFD9349}']

    function GetRange(Property_:Integer;out pMin,pMax:Single;
              out pSteppingDelta,pDefault,pCapsFlags:Integer):HResult; stdcall;

    function Set_(Property_:Integer;Value:Single;Flags:Integer):HResult; stdcall;

    function Get(Property_:Integer;out Value:Single;out Flags:Integer):HResult; stdcall;
  end;

  IFiBasicControl = interface(IUnknown)
    ['{92750B72-7FB7-411B-9630-98D3DAFD9349}']

    function GetRange(Property_:Integer;out pMin,pMax:Single;
                  out pSteppingDelta,pDefault,pCapsFlags:Integer):HResult; stdcall;

    function Set_(Property_:Integer;Value:Single;Flags:Integer):HResult; stdcall;

    function Get(Property_:Integer;out Value:Single;out Flags:Integer):HResult; stdcall;

    function GetAbs(Property_:Integer;out Value:Single):HResult; stdcall;

    function SetAbs(Property_:Integer;Value:Single):HResult; stdcall;

    function GetAbsRange(Property_:Integer;out Min,Max:Single):HResult; stdcall;
  end;

  IFiCameraInfo = interface(IUnknown)
    ['{5B44AFE7-6EFF-4B29-908B-470A3327D1E7}']

    function GetVenderInfo(out VenderInfo:TFiVenderInfo):HResult; stdcall;

    function GetRegister(Offset:Integer;out Value:Integer):HResult; stdcall;

    function SetRegister(Offset:Integer;out Value:Integer):HResult; stdcall;

    function ReadBlock(Offset,NumBytesToRead:Integer;out Buffer):HResult; stdcall;

    function WriteBlock(Offset,NumBytesToRead:Integer;out Buffer):HResult; stdcall;

//    function GetLicenceType(out LicenceType:TFiLicenceType):HResult; stdcall;
    function GetLicenceType(out LicenceType:Integer):HResult; stdcall;

    function GetCommandRegBase(out CommandRegBase:Integer):HResult; stdcall;
  end;

  IFiVideoFormatConfig = interface(IUnknown)
    ['{63D0FAF7-CFBC-4de5-B539-5BBDF0BC073B}']

    function GetVideoFormatList(out VideoFormatInfoList:PFiVideoFormatInfoArray;
                                out FormatNum:DWord):HResult; stdcall;

    function FreeVideoFormatList(out VideoFormatInfoList:TFiVideoFormatInfoArray):
                                 HResult; stdcall;

    function GetDefaultFormat(out DefaultFormatIdx:DWord):HResult; stdcall;

    function SetDefaultFormat(DefaultFormatIdx:DWord):HResult; stdcall;

    function SetupVideoFormat(FormatIdx:DWord;
                            pVideoInfoHeader:PVideoInfoHeader):HResult; stdcall;

    function GetF7PacketInfo(FormatIdx,UnitPacketSize,MaxPacketSize:DWord):HResult; stdcall;

    function GetF7PacketSize(FormatIdx,PacketSize:DWord):HResult; stdcall;

    function SetF7PacketSize(FormatIdx,PacketSize:DWord):HResult; stdcall;

    function GetCurrentFps(FormatIdx:DWord;out CurrentFps:Integer):HResult; stdcall;

    function SetCurrentFps(FormatIdx:DWord;CurrentFps:Integer):HResult; stdcall;

    function Enable16BitSwap(Enable:Boolean):HResult; stdcall;

    function Is16BitSwapEnabled(out Enabled:Boolean):HResult; stdcall;

    function SetCustomRect(FormatIdx:DWord;CustomRect:TRect):HResult; stdcall;

    function GetCustomRect(FormatIdx:DWord;out CustomRect:TRect):HResult; stdcall;
  end;

  IYuv2Rgb = class //interface(IUnknown)
//    ['{92DCFFA8-C116-49A0-ABAE-6DEFD03FECA2}']

    procedure EnableOverlays(Enable:Boolean); virtual; abstract;

    procedure IsEnabledOverlay(out Enable:Boolean); virtual; abstract;

    procedure GetNextFrameBuffer(out FrameSize,FrameBuffer:Integer;
                        Format:TFiPixelFormat); virtual; abstract;

    procedure SaveFrameSequence(Frames:DWord;SavePath:PChar;Flags:DWord); virtual; abstract;

    procedure SaveNextFrame(SavePath:PChar;EncoderClsID:PGUID); virtual; abstract;

    procedure SetRawMode(RawMode:TFiRawMode); virtual; abstract;

    procedure GetRawMode(out RawMode:TFiRawMode); virtual; abstract;

    procedure SetRawConversionCoefficients(RCoeff,GCoeff,BCoeff:Single); virtual; abstract;

    procedure SetCallback(CallBack:TYuvToRgbCallback;Format:TFiPixelFormat;
                          var Context); virtual; abstract;

    procedure SetYMono16SignificantBits(NumSignificantBits:Integer); virtual; abstract;

    procedure GetYMono16SignificantBits(out NumSignificantBits:Integer); virtual; abstract;
  end;

implementation

{$A-}

end.


