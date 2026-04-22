unit NVidia;

interface

uses
  Windows, Forms;

procedure InitNVidiaDisplays;

implementation

uses
  NvCpl, SysUtils;

function GetSystemDir:String;// TFileName;
var
  SysDir: array [0..MAX_PATH-1] of Char;
begin
  SetString(Result,SysDir,GetSystemDirectory(SysDir, MAX_PATH));
end;

function Path:String;
begin
  Result:=ExtractFilePath(Application.ExeName);
end;

procedure InitNVidiaDisplays;
var
  Found    : Boolean;
  FullName : String;
begin
  Found:=False;
  FullName:=Path+NvCplDll;
  Found:=FileExists(FullName);
  if not Found then begin
    FullName:=GetSystemDir+'\'+NvCplDll;
    Found:=FileExists(FullName);
  end;
  if Found then DtCfgEx('setview 1 standard DB');
end;

end.
