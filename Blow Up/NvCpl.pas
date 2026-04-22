unit NvCpl;

interface

uses
  Windows;

const
  NvCplDll = 'NvCpl.dll';

  NV_DISPLAY_DIGITAL_VIBRANCE_MIN = 0;
  NV_DISPLAY_DIGITAL_VIBRANCE_MAX = 63;
  NV_DISPLAY_BRIGHTNESS_MIN = -125;
  NV_DISPLAY_BRIGHTNESS_MAX = 125;
  NV_DISPLAY_CONTRAST_MIN = -82;
  NV_DISPLAY_CONTRAST_MAX = 82;
  NV_DISPLAY_GAMMA_MIN = 0.5;
  NV_DISPLAY_GAMMA_MAX = 6;

function dtcfgex(Cmd:PChar):DWord; stdcall;
function NvSelectDisplayDevice(Number:Word):Boolean; stdcall;
function NvSetFullScreenVideoMirroringEnabled(pszUserDisplay:PChar;
                                              Enabled:Boolean):Boolean; stdcall;
function NvCplRefreshConnectedDevices(Flags:DWord):Boolean; stdcall;
function NvCplGetRealConnectedDevicesString(var TxtBuffer:PChar;BufferSize:DWord;
                                            ActiveOnly:Boolean):Boolean; stdcall;
implementation

function dtcfgex; external NvCplDll;
function NvSelectDisplayDevice; external NvCplDll;
function NvSetFullScreenVideoMirroringEnabled; external NvCplDll;
function NvCplRefreshConnectedDevices; external NvCplDll;
function NvCplGetRealConnectedDevicesString; external NvCplDll;

end.

