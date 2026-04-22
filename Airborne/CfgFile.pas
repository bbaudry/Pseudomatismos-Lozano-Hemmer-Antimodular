unit CfgFile;

interface

uses
  Graphics, Math, Global, CloudU, CameraU, BackGndFind, BlobFindU, ProjectorU,
  ProjectorMaskU, FountainU;

procedure LoadCfgFile;
procedure SaveCfgFile;

type
  TFileSignature = String[10];

  TFolderName = String[100];

  TCfgRecord = packed record
    Signature         : TFileSignature;
    CameraInfo        : TCameraInfo;
    BackGndFinderInfo : TBackGndFinderInfo;
    BlobFinderInfo    : TBlobFinderInfo;
    CloudInfo         : TCloudInfo;
    ScreenW           : Integer;
    ScreenH           : Integer;
    ProjectorInfo     : TProjectorInfo;
    ProjectorMaskInfo : TProjectorMaskInfo;
    FountainInfo      : TFountainInfo;
    Reserved          : array[1..148] of Byte;
  end;
  TCfgFile = file of TCfgRecord;

function  FileSignature(FileName:string) : TFileSignature;
function  DefaultCfgRecord:TCfgRecord;
procedure ApplyCfgRecord(var CfgRecord:TCfgRecord);
function  SizeOfFile(FileName:String):Integer;

implementation

uses
  SysUtils, Forms, Dialogs, Routines;

const
  CfgFileName      = 'Settings.Cfg';
  CfgFileSignature : TFileSignature = 'Settings10';

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

  Result.CameraInfo:=DefaultCameraInfo;
  Result.BackGndFinderInfo:=DefaultBackGndFinderInfo;
  Result.BlobFinderInfo:=DefaultBlobFinderInfo;

  Result.CloudInfo:=DefaultCloudInfo;

  Result.ScreenW:=1280;
  Result.ScreenH:=800;

  Result.ProjectorInfo:=DefaultProjectorInfo;
  Result.ProjectorMaskInfo:=DefaultProjectorMaskInfo;

  Result.FountainInfo:=DefaultFountainInfo;

  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure ApplyCfgRecord(var CfgRecord:TCfgRecord);
begin
  Camera.Info:=CfgRecord.CameraInfo;
  BackGndFinder.Info:=CfgRecord.BackGndFinderInfo;
  BlobFinder.Info:=CfgRecord.BlobFinderInfo;

  Cloud.Info:=CfgRecord.CloudInfo;

  ScreenW:=CfgRecord.ScreenW;
  ScreenH:=CfgRecord.ScreenH;

  Projector.Info:=CfgRecord.ProjectorInfo;
  ProjectorMask.Info:=CfgRecord.ProjectorMaskInfo;

  Fountain.Info:=CfgRecord.FountainInfo;
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
  if MakeDefault then begin
    CfgRecord:=DefaultCfgRecord;
  end;

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
  CfgRecord.BackGndFinderInfo:=BackGndFinder.Info;
  CfgRecord.BlobFinderInfo:=BlobFinder.Info;

  CfgRecord.CloudInfo:=Cloud.Info;
  CfgRecord.ScreenW:=ScreenW;
  CfgRecord.ScreenH:=ScreenH;

  CfgRecord.ProjectorInfo:=Projector.Info;
  CfgRecord.ProjectorMaskInfo:=ProjectorMask.Info;

  CfgRecord.FountainInfo:=Fountain.Info;

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
