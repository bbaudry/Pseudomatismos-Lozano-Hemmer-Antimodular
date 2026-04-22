unit AVTPropSetLib_TLB;

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
// File generated on 9/3/2006 11:12:58 PM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Program Files\Allied Vision Technologies\DirectFire Package 4\Include\AVTPropSet.tlb (1)
// LIBID: {528165CF-1499-43A3-96E9-DFA985F4C219}
// LCID: 0
// Helpfile: 
// HelpString: AVTPropSet Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\System32\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  AVTPropSetLibMajorVersion = 1;
  AVTPropSetLibMinorVersion = 0;

  LIBID_AVTPropSetLib: TGUID = '{528165CF-1499-43A3-96E9-DFA985F4C219}';

  IID_IAVTDolphinPropSet: TGUID = '{DEC6F81A-8C51-4279-A45F-2623826BA892}';
  CLASS_AVTDolphinPropSet: TGUID = '{91336381-2277-4052-9BE0-6C5C601549B6}';
  IID_Interface1: TGUID = '{2881CDB3-345D-4106-AFCF-30080EC1665D}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum __MIDL___MIDL_itf_propset_0000_0001
type
  __MIDL___MIDL_itf_propset_0000_0001 = TOleEnum;
const
  Input1 = $00000000;
  Input2 = $00000001;
  Output1 = $00000002;
  Output2 = $00000003;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IAVTDolphinPropSet = interface;
  Interface1 = interface;
  Interface1Disp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  AVTDolphinPropSet = IAVTDolphinPropSet;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PInteger1 = ^Integer; {*}
  PUINT1 = ^LongWord; {*}
  PShortint1 = ^Shortint; {*}
  PPShortint1 = ^PShortint1; {*}

  IORegister = __MIDL___MIDL_itf_propset_0000_0001; 

// *********************************************************************//
// Interface: IAVTDolphinPropSet
// Flags:     (0)
// GUID:      {DEC6F81A-8C51-4279-A45F-2623826BA892}
// *********************************************************************//
  IAVTDolphinPropSet = interface(IUnknown)
    ['{DEC6F81A-8C51-4279-A45F-2623826BA892}']
    function GetGamma(var pbOn: Integer): HResult; stdcall;
    function SetGamma(bOn: Integer): HResult; stdcall;
    function GetGain(var pulGain: LongWord; var pbAuto: Integer; var pbOnePush: Integer): HResult; stdcall;
    function SetGain(ulGain: LongWord; bAuto: Integer; bOnePush: Integer): HResult; stdcall;
    function GetGainRange(var pulGainMin: LongWord; var pulGainMax: LongWord; var pbAuto: Integer; 
                          var pbOnePush: Integer): HResult; stdcall;
    function GetWhitebalanceU(var pulWhitebalanceU: LongWord; var pbAuto: Integer; 
                              var pbOnePush: Integer): HResult; stdcall;
    function SetWhitebalanceU(ulWhitebalanceU: LongWord; bAuto: Integer; bOnePush: Integer): HResult; stdcall;
    function GetWhitebalanceURange(var pulWhitebalanceUMin: LongWord; 
                                   var pulWhitebalanceUMax: LongWord; var pbAuto: Integer; 
                                   var pbOnePush: Integer): HResult; stdcall;
    function GetWhitebalanceV(var pulWhitebalanceV: LongWord; var pbAuto: Integer; 
                              var pbOnePush: Integer): HResult; stdcall;
    function SetWhitebalanceV(ulWhitebalanceV: LongWord; bAuto: Integer; bOnePush: Integer): HResult; stdcall;
    function GetWhitebalanceVRange(var pulWhitebalanceVMin: LongWord; 
                                   var pulWhitebalanceVMax: LongWord; var pbAuto: Integer; 
                                   var pbOnePush: Integer): HResult; stdcall;
    function GetTestImage(var pulImage: LongWord): HResult; stdcall;
    function SetTestImage(ulImage: LongWord): HResult; stdcall;
    function GetTestImageAvailable(var pulMask: LongWord): HResult; stdcall;
    function GetBrightness(var pulBrightness: LongWord; var pbAuto: Integer; var pbOnePush: Integer): HResult; stdcall;
    function SetBrightness(ulBrightness: LongWord; bAuto: Integer; bOnePush: Integer): HResult; stdcall;
    function GetBrightnessRange(var pulBrightnessMin: LongWord; var pulBrightnessMax: LongWord; 
                                var pbAuto: Integer; var pbOnePush: Integer): HResult; stdcall;
    function GetExposure(var pulExposure: LongWord; var pbAuto: Integer; var pbOnePush: Integer): HResult; stdcall;
    function SetExposure(ulExposure: LongWord; bAuto: Integer; bOnePush: Integer): HResult; stdcall;
    function GetExposureRange(var pulExposureMin: LongWord; var pulExposureMax: LongWord; 
                              var pbAuto: Integer; var pbOnePush: Integer): HResult; stdcall;
    function GetExtShutter(var pulExtShutter: LongWord): HResult; stdcall;
    function SetExtShutter(ulExtShutter: LongWord): HResult; stdcall;
    function GetExtShutterRange(var pulExtShutterMin: LongWord; var pulExtShutterMax: LongWord): HResult; stdcall;
    function GetTimeBase(var pulTimeBase: LongWord): HResult; stdcall;
    function SetTimeBase(ulTimeBase: LongWord): HResult; stdcall;
    function GetModelInfo(vendor: PPShortint1; model: PPShortint1; driver: PPShortint1; 
                          var serial: LongWord): HResult; stdcall;
    function GetModelInfoEx(vendor: PPShortint1; model: PPShortint1; driver: PPShortint1; 
                            var serial: LongWord; microc: PPShortint1; fpga: PPShortint1): HResult; stdcall;
    function SetFormat7(bAvailable: Integer; xPos: LongWord; yPos: LongWord; width: LongWord; 
                        height: LongWord; payload: LongWord; bAvailable2: Integer; xPos2: LongWord; 
                        yPos2: LongWord; width2: LongWord; height2: LongWord; payload2: LongWord; 
                        multishot: LongWord): HResult; stdcall;
    function GetFormat7(var bAvailable: Integer; var pxPos: LongWord; var pyPos: LongWord; 
                        var pwidth: LongWord; var pheight: LongWord; var ppayload: LongWord; 
                        var bAvailable2: Integer; var pxPos2: LongWord; var pyPos2: LongWord; 
                        var pwidth2: LongWord; var pheight2: LongWord; var ppayload2: LongWord; 
                        var pmultishot: LongWord): HResult; stdcall;
    function SetValue(address: LongWord; value: LongWord): HResult; stdcall;
    function GetValue(address: LongWord; var pvalue: LongWord): HResult; stdcall;
    function GetFormat7Count(var pcount: LongWord): HResult; stdcall;
    function GetFormat7All(index: LongWord; var pxPos: LongWord; var pyPos: LongWord; 
                           var pwidth: LongWord; var pheight: LongWord; var ppayload: LongWord; 
                           var punitWidth: LongWord; var punitHeight: LongWord; 
                           var pmaxWidth: LongWord; var pmaxHeight: LongWord; 
                           var pColorCoding: LongWord; var pmultishot: LongWord): HResult; stdcall;
    function SetFormat7All(index: LongWord; xPos: LongWord; yPos: LongWord; width: LongWord; 
                           height: LongWord; ColorCoding: LongWord; multishot: LongWord): HResult; stdcall;
    function SetEnableFormat7(index: LongWord; enable: LongWord): HResult; stdcall;
    function GetEnableFormat7(var pindex: LongWord; var penable: LongWord): HResult; stdcall;
    function SetFormat7Index(index: LongWord): HResult; stdcall;
    function SetFlags(flags: LongWord): HResult; stdcall;
    function GetFlags(var pFlags: LongWord): HResult; stdcall;
    function SetFormat7AllPayload(index: LongWord; xPos: LongWord; yPos: LongWord; width: LongWord; 
                                  height: LongWord; ColorCoding: LongWord; multishot: LongWord; 
                                  payload: LongWord): HResult; stdcall;
    function GetFormat7PayloadRange(index: LongWord; var min: LongWord; var max: LongWord): HResult; stdcall;
    function GetMirrorAvailable(var pbOK: Integer): HResult; stdcall;
    function GetMirror(var pbOn: Integer): HResult; stdcall;
    function SetMirror(bOn: Integer): HResult; stdcall;
    function GetFormat7MaxPayload(index: LongWord; ColorCoding: LongWord; x: LongWord; y: LongWord; 
                                  w: LongWord; h: LongWord; var min: LongWord; var max: LongWord): HResult; stdcall;
    function GetSharpness(var pulSharpness: LongWord; var pbAuto: Integer; var pbOnePush: Integer): HResult; stdcall;
    function SetSharpness(ulSharpness: LongWord; bAuto: Integer; bOnePush: Integer): HResult; stdcall;
    function GetSharpnessRange(var pulSharpnessMin: LongWord; var pulSharpnessMax: LongWord; 
                               var pbAuto: Integer; var pbOnePush: Integer): HResult; stdcall;
    function GetHue(var pulHue: LongWord; var pbAuto: Integer; var pbOnePush: Integer): HResult; stdcall;
    function SetHue(ulHue: LongWord; bAuto: Integer; bOnePush: Integer): HResult; stdcall;
    function GetHueRange(var pulHueMin: LongWord; var pulHueMax: LongWord; var pbAuto: Integer; 
                         var pbOnePush: Integer): HResult; stdcall;
    function GetSaturation(var pulSaturation: LongWord; var pbAuto: Integer; var pbOnePush: Integer): HResult; stdcall;
    function SetSaturation(ulSaturation: LongWord; bAuto: Integer; bOnePush: Integer): HResult; stdcall;
    function GetSaturationRange(var pulSaturationMin: LongWord; var pulSaturationMax: LongWord; 
                                var pbAuto: Integer; var pbOnePush: Integer): HResult; stdcall;
    function GetAutoShutter(var pulMin: LongWord; var pulMax: LongWord): HResult; stdcall;
    function SetAutoShutter(ulMin: LongWord; ulMax: LongWord): HResult; stdcall;
    function GetAutoGain(var pulMin: LongWord; var pulMax: LongWord): HResult; stdcall;
    function SetAutoGain(ulMin: LongWord; ulMax: LongWord): HResult; stdcall;
    function GetAutoAOI(var pbShow: Integer; var pbOn: Integer; var pulXPos: LongWord; 
                        var pulYPos: LongWord; var pulWidth: LongWord; var pulHeight: LongWord): HResult; stdcall;
    function SetAutoAOI(bShow: Integer; bOn: Integer; ulXPos: LongWord; ulYPos: LongWord; 
                        ulWidth: LongWord; ulHeight: LongWord): HResult; stdcall;
    function GetColorCorrection(var pbOn: Integer): HResult; stdcall;
    function SetColorCorrection(bOn: Integer): HResult; stdcall;
    function GetFrameInfo(var counter: LongWord): HResult; stdcall;
    function ResetFrameInfo: HResult; stdcall;
    function ResetCamera: HResult; stdcall;
    function GetShadingControl(var pbOn: Integer; var pbShow: Integer; var pbBuild: Integer; 
                               var pbError: Integer; var pbBusy: Integer; var pulGrabCount: LongWord): HResult; stdcall;
    function SetShadingControl(bOn: Integer; bShow: Integer; bBuild: Integer; bError: Integer; 
                               bBusy: Integer; ulGrabCount: LongWord): HResult; stdcall;
    function GetShadingImage(var buffer: LongWord; var size: LongWord): HResult; stdcall;
    function SetShadingImage(var buffer: LongWord; size: LongWord): HResult; stdcall;
    function GetLUTControl(var pbOn: Integer; var pulLutNum: LongWord; var pulMaxLuts: LongWord; 
                           var pulLutSize: LongWord): HResult; stdcall;
    function SetLUTControl(bOn: Integer; ulLutNum: LongWord): HResult; stdcall;
    function SetLUT(var buffer: LongWord; size: LongWord; ulLutNum: LongWord): HResult; stdcall;
    function SetDSNU(bOn: Integer; bShowImage: Integer; bComputeData: Integer; bLoadData: Integer; 
                     bZeroData: Integer; ulGrabCount: LongWord): HResult; stdcall;
    function GetDSNU(var pbOn: Integer; var pbShowImage: Integer; var pbComputeError: Integer; 
                     var pbBusy: Integer; var pulGrabCount: LongWord): HResult; stdcall;
    function SetBlemish(bOn: Integer; bShowImage: Integer; bComputeData: Integer; 
                        bLoadData: Integer; bZeroData: Integer; ulGrabCount: LongWord): HResult; stdcall;
    function GetBlemish(var pbOn: Integer; var pbShowImage: Integer; var pbComputeError: Integer; 
                        var pbBusy: Integer; var pulGrabCount: LongWord): HResult; stdcall;
    function SetHDR(bOn: Integer; ulKneePoints: LongWord): HResult; stdcall;
    function GetHDR(var pbOn: Integer; var pulKneePoints: LongWord; var pulMaxKneePoints: LongWord): HResult; stdcall;
    function SetKneepoint(ulPoint: LongWord; ulValue: LongWord): HResult; stdcall;
    function GetKneepoint(ulPoint: LongWord; var pulValue: LongWord): HResult; stdcall;
    function SetIntegrationDelay(bOn: Integer; ulTime: LongWord): HResult; stdcall;
    function GetIntegrationDelay(var pbOn: Integer; var pulTime: LongWord): HResult; stdcall;
    function SetTriggerDelay(bOn: Integer; ulTime: LongWord): HResult; stdcall;
    function GetTriggerDelay(var pbOn: Integer; var pulTime: LongWord): HResult; stdcall;
    function SetHighSNR(bOn: Integer; ulImages: LongWord): HResult; stdcall;
    function GetHighSNR(var pbOn: Integer; var pulImages: LongWord): HResult; stdcall;
    function SetDeferredTrans(bSend: Integer; bHold: Integer; bFastCapture: Integer; 
                              ulNumImages: LongWord): HResult; stdcall;
    function GetDeferredTrans(var pbSend: Integer; var pbHold: Integer; var pbFastCapture: Integer; 
                              var pulNumImages: LongWord; var pulFifoSize: LongWord): HResult; stdcall;
    function SetIOCtrl(reg: IORegister; ulPolarity: LongWord; ulMode: LongWord; ulState: LongWord): HResult; stdcall;
    function GetIOCtrl(reg: IORegister; var pulPolarity: LongWord; var pulMode: LongWord; 
                       var pulState: LongWord): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: Interface1
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2881CDB3-345D-4106-AFCF-30080EC1665D}
// *********************************************************************//
  Interface1 = interface(IDispatch)
    ['{2881CDB3-345D-4106-AFCF-30080EC1665D}']
  end;

// *********************************************************************//
// DispIntf:  Interface1Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2881CDB3-345D-4106-AFCF-30080EC1665D}
// *********************************************************************//
  Interface1Disp = dispinterface
    ['{2881CDB3-345D-4106-AFCF-30080EC1665D}']
  end;

// *********************************************************************//
// The Class CoAVTDolphinPropSet provides a Create and CreateRemote method to          
// create instances of the default interface IAVTDolphinPropSet exposed by              
// the CoClass AVTDolphinPropSet. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAVTDolphinPropSet = class
    class function Create: IAVTDolphinPropSet;
    class function CreateRemote(const MachineName: string): IAVTDolphinPropSet;
  end;

implementation

uses ComObj;

class function CoAVTDolphinPropSet.Create: IAVTDolphinPropSet;
begin
  Result := CreateComObject(CLASS_AVTDolphinPropSet) as IAVTDolphinPropSet;
end;

class function CoAVTDolphinPropSet.CreateRemote(const MachineName: string): IAVTDolphinPropSet;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_AVTDolphinPropSet) as IAVTDolphinPropSet;
end;

end.
