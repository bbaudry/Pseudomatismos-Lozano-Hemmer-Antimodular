unit VidFile;

interface

uses
  Windows, FreeImage, Global, SysUtils, StrUtils, Dialogs;

const
  MaxVideosPerLine = 5;

type
  TVideoRecord = record
    Count      : Integer;   // # of videos done by this person
    Index      : array[1..MaxVideosPerLine] of Integer;  // indexes of videos
    TakenCount : Integer;
    Taken      : array[1..MaxVideosPerLine] of Boolean;  // flags for which videos are taken
  end;
  TVideoRecordArray = array[1..MaxVideos] of TVideoRecord;

  TVideoListEntry = record
    Index   : Integer; // index of video - filename is generated from it
    VRIndex : Integer; // index in video record array - so we know its duplicates
  end;
  TVideoList = array[1..MaxVideos] of TVideoListEntry;

procedure SaveVideoFile(Image8:PFiBitmap;FileName:String;Frames:Integer);
procedure LoadVideoFile(FileName:String;var Video:TVideo);
procedure TestVideoFiles;

procedure GenerateVideoList(var VideoList:TVideoList;VideosNeeded:Integer);
procedure TestVideoList(var VideoList:TVideoList;Count:Integer);

implementation

uses
  TilerU, Routines;

procedure SaveVideoFile(Image8:PFiBitmap;FileName:String;Frames:Integer);
type
  TRGBQuadArray = array[0..255] of TRGBQuad;
  PRGBQuadArray = ^TRGBQuadArray;
var
  VideoHeader     : TVideoFileHeader;
  I,F,Y,Y1,Y2,R,C : Integer;
  Palette         : PRGBQuadArray;
  VideoFile       : File;
  Line            : PByteArray;
  W,H,Cols,Rows   : Integer;
begin
  W:=Tiler.CellW;
  H:=Tiler.CellH;
  Cols:=1+(FreeImage_GetWidth(Image8)-1) div W;
  Rows:=1+(FreeImage_GetHeight(Image8)-1) div H;

// prepare the header
  VideoHeader.Frames:=Frames;
  VideoHeader.W:=W;
  VideoHeader.H:=H;
  Palette:=PRGBQuadArray(FreeImage_GetPalette(Image8));
  for I:=0 to 255 do begin
    VideoHeader.Palette[I].Red:=Palette[I].rgbRed;
    VideoHeader.Palette[I].Green:=Palette[I].rgbGreen;
    VideoHeader.Palette[I].Blue:=Palette[I].rgbBlue;
  end;

// write the file
  Assign(VideoFile,FileName);
  try
    Rewrite(VideoFile,1);

// write the header
    BlockWrite(VideoFile,VideoHeader,SizeOf(VideoHeader));

// write the scan lines
    R:=0; C:=1;
    for F:=1 to Frames do begin
      if R<Rows then Inc(R)
      else begin
        Inc(C);
        R:=1;
      end;
      Y1:=(R-1)*H;
      Y2:=Y1+H-1;
      for Y:=Y1 to Y2 do begin
        Line:=PByteArray(FreeImage_GetScanLine(Image8,Y));
        I:=(C-1)*W;
        BlockWrite(VideoFile,Line^[I],W);
      end;
    end;
  finally
    Close(VideoFile);
  end;
end;

procedure LoadVideoFile(FileName:String;var Video:TVideo);
var
  VideoFile   : File;
  VideoHeader : TVideoFileHeader;
  F,FrameSize : Integer;
  LastFrame   : Integer;
begin
  FrameSize:=Tiler.CellW*Tiler.CellH;
  if not FileExists(FileName) then Exit;
  Assign(VideoFile,FileName);
  Reset(VideoFile,1);
  try

// read the header
    BlockRead(VideoFile,VideoHeader,SizeOf(VideoHeader));

// make sure it looks ok
    Assert((VideoHeader.W=Tiler.CellW) and (VideoHeader.H=Tiler.CellH),
            'File = '+FileName+' W='+IntToStr(VideoHeader.W)+' H='+IntToStr(VideoHeader.H));
    LastFrame:=Video.ExtroEnd;
    if LastFrame>VideoHeader.Frames then LastFrame:=VideoHeader.Frames;

// read the palette
    Video.Palette:=VideoHeader.Palette;

// read the frames starting from the intro start
    Seek(VideoFile,SizeOf(VideoHeader)+(Video.IntroStart-1)*FrameSize);
    for F:=Video.IntroStart to LastFrame do begin
      if not Assigned(Video.BmpData[F]) then begin
        GetMem(Video.BmpData[F],FrameSize);
      end;
      BlockRead(VideoFile,Video.BmpData[F]^,FrameSize);
    end;
  finally
    Close(VideoFile);
  end;
end;

procedure TestVideoFiles;
var
  V           : Integer;
  FileName    : String;
  VideoFile   : File;
  VideoHeader : TVideoFileHeader;
begin
  for V:=1 to MaxVideos do begin
    FileName:=Tiler.VideoFileName(V);
    if FileExists(FileName) then begin
      Assign(VideoFile,FileName);
      try
        Reset(VideoFile,1);

// read the header
        BlockRead(VideoFile,VideoHeader,SizeOf(VideoHeader));

// make sure it looks ok
        with VideoHeader do begin
          if (W<>Tiler.CellW) or (H<>Tiler.CellH) then begin
            ShowMessage('File = '+FileName+' W='+IntToStr(W)+' H='+IntToStr(H));
          end;  
        end;
      finally
       Close(VideoFile);
      end;
    end
    else begin
      ShowMessage(FileName+' missing');
    end;
  end;
end;


function VideoRecordFromLine(Line:String):TVideoRecord;
var
  I1,I2,I : Integer;
  SubStr  : String;
begin
  FillChar(Result,SizeOf(Result),0);

// extract the ones between the commas
  I1:=1;
  I2:=Pos(',',Line);
  I:=1;
  while (I2>0) and (I<MaxVideosPerLine) do begin
    SubStr:=Copy(Line,I1,I2-I1);
    try
      Result.Index[I]:=StrToInt(SubStr);
      Inc(Result.Count);
    except
      Exit;
    end;
    I1:=I2+1;
    I2:=PosEx(',',Line,I1);
    Inc(I);
  end;

// get the one at the end
  I2:=Length(Line);
  SubStr:=Copy(Line,I1,I2);
  try
    Result.Index[I]:=StrToInt(SubStr);
    Inc(Result.Count);
  except
    Exit;
  end;
end;

{procedure TestVideoRecord(VideoRecord:TVideoRecord);
begin
  if VideoRecord.Count>0) or (VideoRecord.Co
  [Count]);
  end
  else ShowMessage('Empty video record');
 }

procedure LoadVideoRecordArray(var VideoRecord:TVideoRecordArray;var Count:Integer);
var
  VideoFile : TextFile;
  Line      : String;
begin
  FillChar(VideoRecord,SizeOf(VideoRecord),0);
  Assign(VideoFile,Path+'Videos.txt');
  try
    Reset(VideoFile);
    Count:=0;
    while not EOF(VideoFile) and (Count<MaxVideos) do begin
      Inc(Count);
      Readln(VideoFile,Line);
      VideoRecord[Count]:=VideoRecordFromLine(Line);
    end;
  finally
    Close(VideoFile);
  end;
end;

function AnyAvailableVideosInVideoRecord(var VideoRecord:TVideoRecord):Boolean;
var
  I : Integer;
begin
  I:=0;
  Result:=False;
  with VideoRecord do begin
    while (I<Count) and (not Result) do begin
      Inc(I);
      if not Taken[I] then Result:=True;
    end;
  end;
end;

function AvailableVideos(var VideoRecord:TVideoRecord):Integer;
var
  I : Integer;
begin
  Result:=0;
  with VideoRecord do for I:=1 to Count do begin
    if not Taken[I] then Inc(Result);
  end;
end;

procedure TestVideoRecordArray(var VideoRecord:TVideoRecordArray;Size:Integer);
var
  Count,I,I2,V : Integer;
  VidTaken     : array[1..MaxVideos] of Boolean;
begin
  FillChar(VidTaken,SizeOf(VidTaken),False);
  Count:=0;
  for I:=1 to Size do begin
    Count:=Count+VideoRecord[I].Count;
    for I2:=1 to VideoRecord[I].Count do begin
      V:=VideoRecord[I].Index[I2];
      if (V<1) or (V>MaxVideos) then begin
        ShowMessage('Bad record at '+IntToStr(I)+','+IntToStr(I2));
      end
      else begin
        if VidTaken[V] then begin
          ShowMessage('Video #'+IntToStr(V)+' taken twice at '+IntToStr(I)+','+IntToStr(I2));
        end
        else VidTaken[V]:=True;
      end;
    end;
  end;
end;

procedure GenerateVideoList(var VideoList:TVideoList;VideosNeeded:Integer);
const
  MaxD = 7;
  MaxCount = MaxVideos*MaxVideosPerLine;
var
  VideoFile     : TextFile;
  VideoRecord   : TVideoRecordArray;
  R,C,V,I1,I2   : Integer;
  I,Count,Rt,Ct : Integer;
  LineCount,VR  : Integer;

// VRIndex = test index
// V = video #
function VRIndexOkForVideoNumber(VRIndex,VNumber:Integer):Boolean;
const
  MinR = 3;
var
  R,C,Ro,Co,Vt : Integer;
  TestVRIndex  : Integer;
  D            : Single;
begin
// make sure there's at least one available and no more than 1 has been taken
  with VideoRecord[VRIndex] do Result:=(Count>1) and (TakenCount<2);
  if not Result then Exit;

// find the row and column for this video #
  Tiler.ConvertVideoNumberToRowAndColumn(VNumber,R,C);

// look through the neighbours
  Ro:=-MinR;
  repeat
    Rt:=R+Ro;
    Co:=-MinR;
    repeat
      Ct:=C+Co;

// find the Video Index this column and row corresponds to
      Vt:=Tiler.ConvertRowAndColumnToVideoNumber(Rt,Ct);
      if Vt>0 then begin

// find the VideoRecord index used by this cell
        TestVRIndex:=VideoList[Vt].VRIndex;

// if it matches we're done
        if TestVRIndex=VRIndex then Result:=False;
      end;
      Inc(Co);
    until (not Result) or (Co>MinR);
    Inc(Ro);
  until (not Result) or (Ro>0);
end;

begin
// load the video index - this is an array of video indexes saved in Video.txt
// each line in the text file holds one of more video indexes
  LoadVideoRecordArray(VideoRecord,LineCount);
  TestVideoRecordArray(VideoRecord,LineCount);
  FillChar(VideoList,SizeOf(VideoList),0);

// pick one from each to start
  V:=0;
  while (V<VideosNeeded) and (V<LineCount) do begin
    Inc(V);

// pick a random index into the VideoRecord array
    VR:=1+Random(LineCount);
    while VideoRecord[VR].TakenCount>0 do begin
      if VR<LineCount then Inc(VR)
      else VR:=1;
    end;

// pick one of the duplicates at random
    I:=1+Random(VideoRecord[VR].Count);

// store it
    VideoList[V].Index:=VideoRecord[VR].Index[I];
    VideoList[V].VRIndex:=VR;
    VideoRecord[VR].Taken[I]:=True;
    VideoRecord[VR].TakenCount:=1;
  end;

// pick doubles of the remainders - never triples
  for V:=LineCount+1 to VideosNeeded do begin

// find the row and column for this video number - #'d left->right, top->bottom
    Tiler.ConvertVideoNumberToRowAndColumn(V,R,C);

// pick one from the VRRecord[] at random
    Count:=0;
    repeat
      Inc(Count);
      VR:=1+Random(LineCount);

// see if it's ok to use - time out just in case
      if VRIndexOkForVideoNumber(VR,V) or (Count>MaxCount) then begin

// pick a duplicate at random
        I:=1+Random(VideoRecord[VR].Count);

// make sure it's not taken
        while VideoRecord[VR].Taken[I] do begin
          if I<VideoRecord[VR].Count then Inc(I)
          else I:=1;
        end;
        VideoList[V].Index:=VideoRecord[VR].Index[I];
        VideoList[V].VRIndex:=VR;
        VideoRecord[VR].Taken[I]:=True;
        Inc(VideoRecord[VR].TakenCount);
      end;
    until (VideoList[V].Index>0) or (Count>MaxCount);
  end;
end;

procedure TestVideoList(var VideoList:TVideoList;Count:Integer);
var
  V,VR,I  : Integer;
  VRCount : array[1..MaxVideos] of Integer;
begin
  FillChar(VRCount,SizeOf(VRCount),0);
  for V:=1 to Count do begin
    I:=VideoList[V].Index;
    if (I<1) or (I>MaxVideos) then begin
      ShowMessage('Video #'+IntToStr(V)+' = '+IntToStr(I));
    end
    else begin
      VR:=VideoList[V].VRIndex;
      Inc(VRCount[VR]);
      if VRCount[VR]>2 then begin
        ShowMessage('Video #'+IntToStr(V)+' too many duplicates');
      end;
    end;
  end;
end;

end.


