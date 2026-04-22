unit CfgFile;

interface

uses
  SysUtils, Forms, Dialogs, Global, CameraU, TrackerU, TilerU, PixelBackGndFind,
  CellBackGndFind;

procedure LoadCfgFile;
procedure SaveCfgFile;

type
  TFileSignature = String[10];

  TFolderName = String[100];

  TCfgRecord = packed record
    Signature              : TFileSignature;
    CameraInfo             : TCameraInfo;
    AutoBackGndMode        : TAutoBackGndMode;
    PixelBackGndFinderInfo : TPixelBackGndFinderInfo;
    CellBackGndFinderInfo  : TCellBackGndFinderInfo;
    TrackerInfo            : TTrackerInfo;
    TilerInfo              : TTilerInfo;
    TrackingShowOptions    : TTrackingShowOptionSet;
    Reserved               : array[1..1024] of Byte;
  end;
  TCfgFile = file of TCfgRecord;

function  FileSignature(FileName:string) : TFileSignature;
function  DefaultCfgRecord:TCfgRecord;
procedure ApplyCfgRecord(CfgRecord:TCfgRecord);
function  SizeOfFile(FileName:String):Integer;

implementation

uses
  Routines;

const
  CfgFileName      = 'Settings.Cfg';
  CfgFileSignature : TFileSignature = 'CfgFile1.0';

function SizeOfFile(FileName:String):Integer;
var
  TestFile : File;
begin
  Assign(TestFile,FileName);
  try
    Reset(TestFile,1);
    Result:=FileSize(TestFile);
  finally
    CloseFile(TestFile);
  end;
end;

function FileSignature(FileName:string) : TFileSignature;
type
  TSigFile = file of TFileSignature;
var
  TestFile : TSigFile;
begin
  Assign(TestFile,FileName);
  try
    System.Reset(TestFile);
    Read(TestFile,Result);
  finally
    Close(TestFile);
  end;
end;

function DefaultCfgRecord:TCfgRecord;
begin
  Result.Signature:=CfgFileSignature;
  Result.CameraInfo:=Camera.DefaultCameraInfo;
  Result.AutoBackGndMode:=amPixel;
  Result.PixelBackGndFinderInfo:=DefaultPixelBackGndFinderInfo;
  Result.CellBackGndFinderInfo:=DefaultCellBackGndFinderInfo;
  Result.TrackerInfo:=DefaultTrackerInfo;
  Result.TilerInfo:=DefaultTilerInfo;
  Result.TrackingShowOptions:=[];
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure ApplyCfgRecord(CfgRecord:TCfgRecord);
begin
  Camera.Info:=CfgRecord.CameraInfo;
  AutoBackGndMode:=CfgRecord.AutoBackGndMode;
  PixelBackGndFinder.Info:=CfgRecord.PixelBackGndFinderInfo;
  CellBackGndFinder.Info:=CfgRecord.CellBackGndFinderInfo;
  Tracker.Info:=CfgRecord.TrackerInfo;
  Tiler.Info:=CfgRecord.TilerInfo;
  TrackingShowOptions:=CfgRecord.TrackingShowOptions;
end;

procedure LoadCfgFile;
var
  CfgRecord   : TCfgRecord;
  CfgFile     : TCfgFile;
  FileName    : String;
  MakeDefault : Boolean;
begin
  FileName:=Path+CfgFileName;
  MakeDefault:=False;
  if not FileExists(FileName) then begin
    ShowMessage('Config file missing. A default will be generated.');
    MakeDefault:=True;
  end
  else if SizeOfFile(FileName)<>SizeOf(CfgRecord) then begin
    ShowMessage('Config file is the wrong size. A default will be generated.');
    MakeDefault:=True;
  end
  else if FileSignature(FileName)<>CfgFileSignature then begin
    ShowMessage('Config file signature wrong. A default file will be generated.');
    MakeDefault:=True;
  end
  else begin
    Assign(CfgFile,FileName);
    try
      Reset(CfgFile);
      Read(CfgFile,CfgRecord);
    except
      ShowMessage('Error loading config file. A default will be generated.');
      MakeDefault:=True;
    end;
    Close(CfgFile);
  end;

// go with the defaults if there was a problem
  if MakeDefault then CfgRecord:=DefaultCfgRecord;

// init the global vars from the CfgRecord
  ApplyCfgRecord(CfgRecord);

// save if there was a problem
  if MakeDefault then SaveCfgFile;
end;

procedure SaveCfgFile;
var
  CfgRecord : TCfgRecord;
  CfgFile   : TCfgFile;
  FileName  : String;
begin
// prepare the record
  CfgRecord.Signature:=CfgFileSignature;

  CfgRecord.CameraInfo:=Camera.Info;
  CfgRecord.AutoBackGndMode:=AutoBackGndMode;
  CfgRecord.PixelBackGndFinderInfo:=PixelBackGndFinder.Info;
  CfgRecord.CellBackGndFinderInfo:=CellBackGndFinder.Info;
  CfgRecord.TrackerInfo:=Tracker.Info;
  CfgRecord.TilerInfo:=Tiler.Info;
  CfgRecord.TrackingShowOptions:=TrackingShowOptions;

  FillChar(CfgRecord.Reserved,SizeOf(CfgRecord.Reserved),0);

// open the file and write to it
  FileName:=Path+CfgFileName;
  Assign(CfgFile,FileName);
  try
    Rewrite(CfgFile);
    Write(CfgFile,CfgRecord);
  finally
    Close(CfgFile);
  end;
end;

end.
