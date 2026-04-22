unit CfgFile;

interface

uses
  Windows, SysUtils, Forms, Dialogs, Global, CameraU, TrackerU, TilerU,
  Graphics, BlobFind, BackGndFind, SegmenterU, CellTrackerU;

procedure LoadCfgFile;
procedure SaveCfgFile;

type
  TFileSignature = String[10];

  TFolderName = String[100];

  TCfgRecord = packed record
    Signature           : TFileSignature;
    CameraInfo          : TCameraInfo;
    BackGndFinderInfo   : TBackGndFinderInfo;
    BlobFinderInfo      : TBlobFinderInfo;
    TrackerInfo         : TTrackerInfo;
    TilerInfo           : TTilerInfo;
    TrackingShowOptions : TTrackingShowOptionSet;
    LowRes              : Boolean;
    BlowUpMode          : TBlowUpMode;
    MinBlowUpTime       : DWord;
    MaxBlowUpTime       : DWord;
    MinCollapseTime     : DWord;
    MaxCollapseTime     : DWord;
    TrackMethod         : TTrackMethod;
    SegementerInfo      : TSegmenterInfo;
    CellTrackerInfo     : TCellTrackerInfo;
    Reserved            : array[1..1024-73-95] of Byte;
  end;
  TCfgFile = file of TCfgRecord;

function  FileSignature(FileName:string) : TFileSignature;
function  DefaultCfgRecord:TCfgRecord;
procedure ApplyCfgRecord(var CfgRecord:TCfgRecord);
function  SizeOfFile(FileName:String):Integer;

implementation

uses
  Routines;

const
  CfgFileName      = 'Settings.Cfg';
  CfgFileSignature : TFileSignature = 'BlowUpv1.0';

function SizeOfFile(FileName:String):Integer;
var
  Handle : Integer;
begin
  Handle:=FileOpen(FileName,fmOpenRead);
  if Handle>0 then begin
    Result:=FileSeek(Handle,0,2); // position at the end of the file
    FlushFileBuffers(Handle);
    FileClose(Handle);
  end
  else Result:=0;
end;

function FileSignature(FileName:string) : TFileSignature;
var
  Handle : Integer;
  Size   : Integer;
begin
  Handle:=FileOpen(FileName,fmOpenRead);
  if Handle>0 then begin
    FileSeek(Handle,0,0);
    Size:=FileRead(Handle,Result,SizeOf(Result));
    if Size<>SizeOf(Result) then Result:='';
    FlushFileBuffers(Handle);
    FileClose(Handle);
  end
  else Result:='';
end;

function DefaultCfgRecord:TCfgRecord;
begin
  Result.Signature:=CfgFileSignature;
  Result.CameraInfo:=Camera.DefaultCameraInfo;
  Result.BackGndFinderInfo:=DefaultBackGndFinderInfo;
  Result.BlobFinderInfo:=DefaultBlobFinderInfo;
  Result.TrackerInfo:=DefaultTrackerInfo;
  Result.TilerInfo:=DefaultTilerInfo;
  Result.TrackingShowOptions:=[soActiveCells];
  Result.LowRes:=True;
  Result.BlowUpMode:=bmTimed;
  Result.MinBlowUpTime:=30000;
  Result.MaxBlowUpTime:=180000;
  Result.MinCollapseTime:=30000;
  Result.MaxCollapseTime:=180000;

  Result.TrackMethod:=tmSegmenter;
  Result.SegementerInfo:=DefaultSegmenterInfo;
  Result.CellTrackerInfo:=DefaultCellTrackerInfo;

  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure ApplyCfgRecord(var CfgRecord:TCfgRecord);
begin
  Camera.Info:=CfgRecord.CameraInfo;
  BackGndFinder.Info:=CfgRecord.BackGndFinderInfo;
  BlobFinder.Info:=CfgRecord.BlobFinderInfo;
  Tracker.Info:=CfgRecord.TrackerInfo;
  Tiler.Info:=CfgRecord.TilerInfo;
  TrackingShowOptions:=CfgRecord.TrackingShowOptions;
//LowRes:=CfgRecord.LowRes;
  LowRes:=False;
//  BlowUpMode:=CfgRecord.BlowUpMode;
  BlowUpMode:=bmTracking;
  MinBlowUpTime:=CfgRecord.MinBlowUpTime;
  MaxBlowUpTime:=CfgRecord.MaxBlowUpTime;
  MinCollapseTime:=CfgRecord.MinCollapseTime;
  MaxCollapseTime:=CfgRecord.MaxCollapseTime;
  TrackMethod:=tmSegmenter;
//TrackMethod:=CfgRecord.TrackMethod;
  Segmenter.Info:=CfgRecord.SegementerInfo;
  CellTracker.Info:=CfgRecord.CellTrackerInfo;
end;

procedure LoadCfgFile;
var
  CfgRecord   : TCfgRecord;
  FileName    : String;
  MakeDefault : Boolean;
  Handle,Size : Integer;
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
    Handle:=FileOpen(FileName,fmOpenRead);
    if Handle>0 then begin
      FileSeek(Handle,0,0);
      Size:=FileRead(Handle,CfgRecord,SizeOf(CfgRecord));
      if Size<>SizeOf(CfgRecord) then begin
        ShowMessage('Error loading config file. A default will be generated.');
        MakeDefault:=True;
      end;
      FlushFileBuffers(Handle);
      FileClose(Handle);
    end
    else begin
      ShowMessage('Error loading config file. A default will be generated.');
      MakeDefault:=True;
    end;
  end;

// go with the defaults if there was a problem
  if MakeDefault then CfgRecord:=DefaultCfgRecord;

// init the global vars from the CfgRecord
//  ForceCfgDefaults(CfgRecord);
  ApplyCfgRecord(CfgRecord);

// save if there was a problem
  if MakeDefault then SaveCfgFile;
end;

procedure SaveCfgFile;
var
  CfgRecord : TCfgRecord;
  FileName  : String;
  Handle    : Integer;
begin
// prepare the record
  CfgRecord.Signature:=CfgFileSignature;

  CfgRecord.CameraInfo:=Camera.Info;
  CfgRecord.BackGndFinderInfo:=BackGndFinder.Info;
  CfgRecord.BlobFinderInfo:=BlobFinder.Info;
  CfgRecord.TrackerInfo:=Tracker.Info;
  CfgRecord.TilerInfo:=Tiler.Info;
  CfgRecord.TrackingShowOptions:=TrackingShowOptions;
  CfgRecord.LowRes:=LowRes;
  CfgRecord.BlowUpMode:=BlowUpMode;
  CfgRecord.MinBlowUpTime:=MinBlowUpTime;
  CfgRecord.MaxBlowUpTime:=MaxBlowUpTime;
  CfgRecord.MinCollapseTime:=MinCollapseTime;
  CfgRecord.MaxCollapseTime:=MaxCollapseTime;

  CfgRecord.TrackMethod:=TrackMethod;
  CfgRecord.SegementerInfo:=Segmenter.Info;
  CfgRecord.CellTrackerInfo:=CellTracker.Info;

  FillChar(CfgRecord.Reserved,SizeOf(CfgRecord.Reserved),0);

// open the file and write to it
  FileName:=Path+CfgFileName;
  if FileExists(FileName) then DeleteFile(FileName);
  Handle:=FileCreate(FileName);
  if Handle>0 then begin
    FileSeek(Handle,0,0);
    FileWrite(Handle,CfgRecord,SizeOf(CfgRecord));
    FlushFileBuffers(Handle);
    FileClose(Handle);
  end;
end;

end.
