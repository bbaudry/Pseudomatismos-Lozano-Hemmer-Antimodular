unit AVTAccessLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 9/4/2006 1:18:06 AM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Program Files\Allied Vision Technologies\DirectFire Package 4\Include\AVTAccess.tlb (1)
// LIBID: {6C9D08E1-C976-46DB-8796-BB537F5F24E0}
// LCID: 0
// Helpfile: 
// HelpString: AVTAccess 1.0 Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\System32\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  AVTAccessLibMajorVersion = 1;
  AVTAccessLibMinorVersion = 0;

  LIBID_AVTAccessLib: TGUID = '{6C9D08E1-C976-46DB-8796-BB537F5F24E0}';

  DIID__IAVTFrameAccessEvents: TGUID = '{F8936E5C-40C3-496A-8977-8F45C09442B6}';
  IID_IAVTFrameAccess: TGUID = '{0F021A97-702F-4781-B183-25B3188038AD}';
  CLASS_AVTFrameAccess: TGUID = '{7B53C2A2-A688-439D-85BE-6F96F2E29C16}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _IAVTFrameAccessEvents = dispinterface;
  IAVTFrameAccess = interface;
  IAVTFrameAccessDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  AVTFrameAccess = IAVTFrameAccess;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PByte1 = ^Byte; {*}


// *********************************************************************//
// DispIntf:  _IAVTFrameAccessEvents
// Flags:     (4096) Dispatchable
// GUID:      {F8936E5C-40C3-496A-8977-8F45C09442B6}
// *********************************************************************//
  _IAVTFrameAccessEvents = dispinterface
    ['{F8936E5C-40C3-496A-8977-8F45C09442B6}']
    procedure SavePicture(const file_: WideString); dispid 1;
    procedure NextPicture(time: Double); dispid 2;
    procedure SaveOk; dispid 3;
  end;

// *********************************************************************//
// Interface: IAVTFrameAccess
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0F021A97-702F-4781-B183-25B3188038AD}
// *********************************************************************//
  IAVTFrameAccess = interface(IDispatch)
    ['{0F021A97-702F-4781-B183-25B3188038AD}']
    procedure InitCameraList; safecall;
    function Get_CameraCount: Integer; safecall;
    function GetCameraName(index: Integer): WideString; safecall;
    procedure SelectCamera(index: Integer); safecall;
    procedure Start; safecall;
    procedure Stop; safecall;
    function Get_BW: WordBool; safecall;
    procedure CameraProperties(hWnd: Integer); safecall;
    procedure FormatProperties(hWnd: Integer); safecall;
    function Get_Width: Integer; safecall;
    function Get_Height: Integer; safecall;
    procedure SavePicture(const fileName: WideString); safecall;
    procedure Format(Width: Integer; Height: Integer; color: WordBool); safecall;
    procedure SetValue(address: LongWord; value: LongWord); safecall;
    function GetValue(address: LongWord): LongWord; safecall;
    function GetColorCount: Integer; safecall;
    function GetColor(index: Integer): WideString; safecall;
    function GetResolutionCount(color: Integer): Integer; safecall;
    function GetResolution(color: Integer; index: Integer): WideString; safecall;
    function GetMaxFPS(color: Integer; index: Integer): Double; safecall;
    procedure SetFormatFPS(color: Integer; resolution: Integer; fps: Double); safecall;
    function GetBuffer(index: Integer): PByte1; safecall;
    function GetBufferSize: Integer; safecall;
    function GetBitmapHeader: PByte1; safecall;
    function GetBitmapHeaderSize: Integer; safecall;
    function GetBitmapFileHeader: PByte1; safecall;
    function GetBitmapFileHeaderSize: Integer; safecall;
    function Get_BufferCount: Integer; safecall;
    procedure Set_BufferCount(pVal: Integer); safecall;
    function GetCameraForFormat: IUnknown; safecall;
    function GetStreamForFormat: IUnknown; safecall;
    property CameraCount: Integer read Get_CameraCount;
    property BW: WordBool read Get_BW;
    property Width: Integer read Get_Width;
    property Height: Integer read Get_Height;
    property BufferCount: Integer read Get_BufferCount write Set_BufferCount;
  end;

// *********************************************************************//
// DispIntf:  IAVTFrameAccessDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0F021A97-702F-4781-B183-25B3188038AD}
// *********************************************************************//
  IAVTFrameAccessDisp = dispinterface
    ['{0F021A97-702F-4781-B183-25B3188038AD}']
    procedure InitCameraList; dispid 1;
    property CameraCount: Integer readonly dispid 2;
    function GetCameraName(index: Integer): WideString; dispid 3;
    procedure SelectCamera(index: Integer); dispid 4;
    procedure Start; dispid 5;
    procedure Stop; dispid 6;
    property BW: WordBool readonly dispid 7;
    procedure CameraProperties(hWnd: Integer); dispid 8;
    procedure FormatProperties(hWnd: Integer); dispid 9;
    property Width: Integer readonly dispid 11;
    property Height: Integer readonly dispid 12;
    procedure SavePicture(const fileName: WideString); dispid 13;
    procedure Format(Width: Integer; Height: Integer; color: WordBool); dispid 14;
    procedure SetValue(address: LongWord; value: LongWord); dispid 15;
    function GetValue(address: LongWord): LongWord; dispid 16;
    function GetColorCount: Integer; dispid 17;
    function GetColor(index: Integer): WideString; dispid 18;
    function GetResolutionCount(color: Integer): Integer; dispid 19;
    function GetResolution(color: Integer; index: Integer): WideString; dispid 20;
    function GetMaxFPS(color: Integer; index: Integer): Double; dispid 21;
    procedure SetFormatFPS(color: Integer; resolution: Integer; fps: Double); dispid 22;
    function GetBuffer(index: Integer): {??PByte1}OleVariant; dispid 23;
    function GetBufferSize: Integer; dispid 25;
    function GetBitmapHeader: {??PByte1}OleVariant; dispid 26;
    function GetBitmapHeaderSize: Integer; dispid 27;
    function GetBitmapFileHeader: {??PByte1}OleVariant; dispid 28;
    function GetBitmapFileHeaderSize: Integer; dispid 29;
    property BufferCount: Integer dispid 30;
    function GetCameraForFormat: IUnknown; dispid 31;
    function GetStreamForFormat: IUnknown; dispid 32;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TAVTFrameAccess
// Help String      : AVTFrameAccess Class
// Default Interface: IAVTFrameAccess
// Def. Intf. DISP? : No
// Event   Interface: _IAVTFrameAccessEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TAVTFrameAccessSavePicture = procedure(ASender: TObject; const file_: WideString) of object;
  TAVTFrameAccessNextPicture = procedure(ASender: TObject; time: Double) of object;

  TAVTFrameAccess = class(TOleControl)
  private
    FOnSavePicture: TAVTFrameAccessSavePicture;
    FOnNextPicture: TAVTFrameAccessNextPicture;
    FOnSaveOk: TNotifyEvent;
    FIntf: IAVTFrameAccess;
    function  GetControlInterface: IAVTFrameAccess;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    procedure InitCameraList;
    function GetCameraName(index: Integer): WideString;
    procedure SelectCamera(index: Integer);
    procedure Start;
    procedure Stop;
    procedure CameraProperties(hWnd: Integer);
    procedure FormatProperties(hWnd: Integer);
    procedure SavePicture(const fileName: WideString);
    procedure Format(Width: Integer; Height: Integer; color: WordBool);
    procedure SetValue(address: LongWord; value: LongWord);
    function GetValue(address: LongWord): LongWord;
    function GetColorCount: Integer;
    function GetColor(index: Integer): WideString;
    function GetResolutionCount(color: Integer): Integer;
    function GetResolution(color: Integer; index: Integer): WideString;
    function GetMaxFPS(color: Integer; index: Integer): Double;
    procedure SetFormatFPS(color: Integer; resolution: Integer; fps: Double);
    function GetBuffer(index: Integer): PByte1;
    function GetBufferSize: Integer;
    function GetBitmapHeader: PByte1;
    function GetBitmapHeaderSize: Integer;
    function GetBitmapFileHeader: PByte1;
    function GetBitmapFileHeaderSize: Integer;
    function GetCameraForFormat: IUnknown;
    function GetStreamForFormat: IUnknown;
    property  ControlInterface: IAVTFrameAccess read GetControlInterface;
    property  DefaultInterface: IAVTFrameAccess read GetControlInterface;
    property CameraCount: Integer index 2 read GetIntegerProp;
    property BW: WordBool index 7 read GetWordBoolProp;
  published
    property Anchors;
    property BufferCount: Integer index 30 read GetIntegerProp write SetIntegerProp stored False;
    property OnSavePicture: TAVTFrameAccessSavePicture read FOnSavePicture write FOnSavePicture;
    property OnNextPicture: TAVTFrameAccessNextPicture read FOnNextPicture write FOnNextPicture;
    property OnSaveOk: TNotifyEvent read FOnSaveOk write FOnSaveOk;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'Servers';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TAVTFrameAccess.InitControlData;
const
  CEventDispIDs: array [0..2] of DWORD = (
    $00000001, $00000002, $00000003);
  CControlData: TControlData2 = (
    ClassID: '{7B53C2A2-A688-439D-85BE-6F96F2E29C16}';
    EventIID: '{F8936E5C-40C3-496A-8977-8F45C09442B6}';
    EventCount: 3;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80004002*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnSavePicture) - Cardinal(Self);
end;

procedure TAVTFrameAccess.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IAVTFrameAccess;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TAVTFrameAccess.GetControlInterface: IAVTFrameAccess;
begin
  CreateControl;
  Result := FIntf;
end;

procedure TAVTFrameAccess.InitCameraList;
begin
  DefaultInterface.InitCameraList;
end;

function TAVTFrameAccess.GetCameraName(index: Integer): WideString;
begin
  Result := DefaultInterface.GetCameraName(index);
end;

procedure TAVTFrameAccess.SelectCamera(index: Integer);
begin
  DefaultInterface.SelectCamera(index);
end;

procedure TAVTFrameAccess.Start;
begin
  DefaultInterface.Start;
end;

procedure TAVTFrameAccess.Stop;
begin
  DefaultInterface.Stop;
end;

procedure TAVTFrameAccess.CameraProperties(hWnd: Integer);
begin
  DefaultInterface.CameraProperties(hWnd);
end;

procedure TAVTFrameAccess.FormatProperties(hWnd: Integer);
begin
  DefaultInterface.FormatProperties(hWnd);
end;

procedure TAVTFrameAccess.SavePicture(const fileName: WideString);
begin
  DefaultInterface.SavePicture(fileName);
end;

procedure TAVTFrameAccess.Format(Width: Integer; Height: Integer; color: WordBool);
begin
  DefaultInterface.Format(Width, Height, color);
end;

procedure TAVTFrameAccess.SetValue(address: LongWord; value: LongWord);
begin
  DefaultInterface.SetValue(address, value);
end;

function TAVTFrameAccess.GetValue(address: LongWord): LongWord;
begin
  Result := DefaultInterface.GetValue(address);
end;

function TAVTFrameAccess.GetColorCount: Integer;
begin
  Result := DefaultInterface.GetColorCount;
end;

function TAVTFrameAccess.GetColor(index: Integer): WideString;
begin
  Result := DefaultInterface.GetColor(index);
end;

function TAVTFrameAccess.GetResolutionCount(color: Integer): Integer;
begin
  Result := DefaultInterface.GetResolutionCount(color);
end;

function TAVTFrameAccess.GetResolution(color: Integer; index: Integer): WideString;
begin
  Result := DefaultInterface.GetResolution(color, index);
end;

function TAVTFrameAccess.GetMaxFPS(color: Integer; index: Integer): Double;
begin
  Result := DefaultInterface.GetMaxFPS(color, index);
end;

procedure TAVTFrameAccess.SetFormatFPS(color: Integer; resolution: Integer; fps: Double);
begin
  DefaultInterface.SetFormatFPS(color, resolution, fps);
end;

function TAVTFrameAccess.GetBuffer(index: Integer): PByte1;
begin
  Result := DefaultInterface.GetBuffer(index);
end;

function TAVTFrameAccess.GetBufferSize: Integer;
begin
  Result := DefaultInterface.GetBufferSize;
end;

function TAVTFrameAccess.GetBitmapHeader: PByte1;
begin
  Result := DefaultInterface.GetBitmapHeader;
end;

function TAVTFrameAccess.GetBitmapHeaderSize: Integer;
begin
  Result := DefaultInterface.GetBitmapHeaderSize;
end;

function TAVTFrameAccess.GetBitmapFileHeader: PByte1;
begin
  Result := DefaultInterface.GetBitmapFileHeader;
end;

function TAVTFrameAccess.GetBitmapFileHeaderSize: Integer;
begin
  Result := DefaultInterface.GetBitmapFileHeaderSize;
end;

function TAVTFrameAccess.GetCameraForFormat: IUnknown;
begin
  Result := DefaultInterface.GetCameraForFormat;
end;

function TAVTFrameAccess.GetStreamForFormat: IUnknown;
begin
  Result := DefaultInterface.GetStreamForFormat;
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TAVTFrameAccess]);
end;

end.
