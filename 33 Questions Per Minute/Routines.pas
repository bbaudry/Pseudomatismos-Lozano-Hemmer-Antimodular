unit Routines;

interface

uses
  SysUtils, Dialogs, Registry, Forms, Windows, ShlObj, ShellAPI;

type
  PHWnd = ^HWnd;

procedure DisableSysKeys;
procedure EnableSysKeys;
procedure SetRegistryToAutoStartApplication;
procedure HideTaskBar;
procedure ShowTaskBar;
procedure MaximizeForm(Form:TForm);
function  EnumWndProc(Hwnd: THandle;FoundWnd:PHWnd):Boolean; stdcall;
function  Path:String;
function  BrowseForFolder(Handle:HWnd;Title:String;var Folder:String):Boolean;

implementation

procedure DisableSysKeys;
var
  Old : Integer;
begin
  SystemParametersInfo(SPI_SCREENSAVERRUNNING,1,@Old,0);
end;

procedure EnableSysKeys;
var
  Old : Integer;
begin
  SystemParametersInfo(SPI_SCREENSAVERRUNNING,0,@Old,0);
end;

procedure SetRegistryToAutoStartApplication;
var
  Reg : TRegistry;
begin
// record the currently selected config file in the Registry
  Reg:=TRegistry.Create;
  try
    Reg.LazyWrite:=False;
    Reg.RootKey:=HKEY_LOCAL_MACHINE;

// open \SOFTWARE\Microsoft\Windows\CurrentVersion\Run
    Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',True);
    if not Reg.KeyExists('Turkey') then begin
      Reg.WriteString('Turkey',Application.ExeName);
    end;
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;

procedure HideTaskBar;
var
  HTaskBar : THandle;
begin
  HTaskbar:=FindWindow('Shell_TrayWnd',nil);
  if HTaskBar>0 then ShowWindow(HTaskBar,SW_Hide)
end;

procedure ShowTaskBar;
var
  HTaskBar : THandle;
begin
  HTaskbar:=FindWindow('Shell_TrayWnd',nil);
  if HTaskBar>0 then ShowWindow(HTaskBar,SW_Show)
end;

procedure MaximizeForm(Form:TForm);
var
  TaskBarHandle : HWnd;      // Handle to the Win95 Taskbar
  TaskBarCoord  : TRect;     // Coordinates of the Win95 Taskbar
  CxScreen      : integer;   // Width of screen in pixels
  CyScreen      : integer;   // Height of screen in pixels
  CxFullScreen  : integer;   // Width of client area in pixels
  CyFullScreen  : integer;   // Heigth of client area in pixels
  CyCaption     : integer;   // Height of a window's title bar in pixels
begin
// Get the taskbar handle
  TaskBarHandle:=FindWindow('Shell_TrayWnd',nil);

// Get coordinates of the taskbar
  GetWindowRect(TaskBarHandle,TaskBarCoord);

// Get screen dimensions and set form's width/height
  CxScreen:=GetSystemMetrics(SM_CXSCREEN);
  CyScreen:=GetSystemMetrics(SM_CYSCREEN);
  CxFullScreen:=GetSystemMetrics(SM_CXFULLSCREEN);
  CyFullScreen:=GetSystemMetrics(SM_CYFULLSCREEN);
  CyCaption:=GetSystemMetrics(SM_CYCAPTION);
  Form.Width:=CxScreen-(CxScreen - CxFullScreen);
  Form.Height:=CyScreen-(CyScreen-CyFullScreen)+CyCaption+TaskBarCoord.Bottom-TaskBarCoord.Top;
  Form.Top:=0;
  Form.Left:=0;
end;

function EnumWndProc(Hwnd: THandle;FoundWnd: PHWND): boolean; stdcall;
var
  ClassName, ModuleName, WinModuleName: string;
  WinInstance: THandle;
begin
  Result:=True;
  SetLength(ClassName,100);

// get the classname for this window
  GetClassName(Hwnd,PChar(ClassName),Length(ClassName));
  ClassName:=PChar(ClassName);
  if ClassName = 'TMainFrm' then begin

// if there's a match, see if this exe name matches with this one
    SetLength(ModuleName, 200);
    SetLength(WinModuleName, 200);

// get the exe name for this program
    GetModuleFileName(HInstance,PChar(ModuleName),Length(ModuleName));
    ModuleName:=PChar(ModuleName); // adjust length

// get the exe name of the program that has a matching LaunchFrm
    WinInstance:=GetWindowLong(Hwnd,GWL_HINSTANCE);
    GetModuleFileName(WinInstance,PChar(WinModuleName),Length(WinModuleName));
    WinModuleName:=PChar(WinModuleName); // adjust length

// if they're the same, we have a match
    if ModuleName=WinModuleName then begin
      FoundWnd^:=Hwnd;
      Result:=False;
    end;
  end;
end;

function Path:String;
begin
  Result:=ExtractFilePath(Application.ExeName);
end;

function BrowseForFolder(Handle:HWnd;Title:String;var Folder:String):Boolean;
var
  Info    : TBROWSEINFO;
  PathStr : array[0..MAX_PATH] of Char;
  Items   : PItemIdList;
begin
  PathStr:='';
  with Info do begin
    HWndOwner:=Handle;
    pIdlRoot:=nil;
    pszDisplayName:=nil;
    lpszTitle:=PChar(Title);
    ulFlags:=BIF_RETURNONLYFSDIRS;
    lpfn:=nil;
  end;
  Items:=SHBrowseForFolder(Info);
  if Assigned(Items) then begin
    SHGetPathFromIDList(Items,PathStr);
    Folder:=PathStr;
    Result:=True;
  end
  else Result:=False;
end;

end.

uses
  ShlObj, ShellAPI;

......

function BrowseForFolder(handle : HWND; strTitle : string; var strPath : string) : boolean;
var info : TBROWSEINFO;
    path : array[0..MAX_PATH] of Char;
    items : PITEMIDLIST;
begin
 Result:=false;
 path:='';

 with info do
  begin
    hwndOwner:=handle;
    pidlRoot:=nil;
    pszDisplayName:=nil;
    lpszTitle:=PChar(strTitle);
    ulFlags:=BIF_RETURNONLYFSDIRS;
    lpfn:=nil;
  end;

 items:=SHBrowseForFolder(info);

 if assigned(items) then
  begin
    SHGetPathFromIDList(items,path);
    Result:=true;
  end;

 strPath:=Path;
end;



