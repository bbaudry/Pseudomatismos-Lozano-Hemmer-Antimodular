unit AVTYUV800Lib_TLB;

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
// File generated on 9/3/2006 3:28:20 PM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Program Files\Allied Vision Technologies\DirectFire Package 4\Include\AVTYUV800.tlb (1)
// LIBID: {6A802AAC-BBBA-4927-8B25-18207301D633}
// LCID: 0
// Helpfile: 
// HelpString: AVTYUV800 Library
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
  AVTYUV800LibMajorVersion = 1;
  AVTYUV800LibMinorVersion = 0;

  LIBID_AVTYUV800Lib: TGUID = '{6A802AAC-BBBA-4927-8B25-18207301D633}';

  IID_IYUV800Parameter: TGUID = '{6B7339D5-B0E9-495E-BFF0-4B80B2E4DFBD}';
  CLASS_AVTYUV800: TGUID = '{142A006A-1E81-4578-8FF2-79EB802021E0}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IYUV800Parameter = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  AVTYUV800 = IYUV800Parameter;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PInteger1 = ^Integer; {*}


// *********************************************************************//
// Interface: IYUV800Parameter
// Flags:     (0)
// GUID:      {6B7339D5-B0E9-495E-BFF0-4B80B2E4DFBD}
// *********************************************************************//
  IYUV800Parameter = interface(IUnknown)
    ['{6B7339D5-B0E9-495E-BFF0-4B80B2E4DFBD}']
    function GetFlipImage(var pbFlip: Integer): HResult; stdcall;
    function SetFlipImage(bFlip: Integer): HResult; stdcall;
    function SetRGB32(b32: Integer): HResult; stdcall;
    function GetRGB32(var pb32: Integer): HResult; stdcall;
    function SetDeBayering(bDeBayering: Integer): HResult; stdcall;
    function GetDeBayering(var pbDeBayering: Integer): HResult; stdcall;
    function SetBWDeBayering(bBWDeBayering: Integer): HResult; stdcall;
    function GetBWDeBayering(var pbBWDeBayering: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// The Class CoAVTYUV800 provides a Create and CreateRemote method to          
// create instances of the default interface IYUV800Parameter exposed by              
// the CoClass AVTYUV800. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAVTYUV800 = class
    class function Create: IYUV800Parameter;
    class function CreateRemote(const MachineName: string): IYUV800Parameter;
  end;

implementation

uses ComObj;

class function CoAVTYUV800.Create: IYUV800Parameter;
begin
  Result := CreateComObject(CLASS_AVTYUV800) as IYUV800Parameter;
end;

class function CoAVTYUV800.CreateRemote(const MachineName: string): IYUV800Parameter;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_AVTYUV800) as IYUV800Parameter;
end;

end.
