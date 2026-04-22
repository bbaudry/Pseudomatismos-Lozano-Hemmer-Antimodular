unit Bitmap;

interface

type
  PBmpData = ^Byte;

function AbleToLoadDIBitmap(const FileName:String;var Data:PBmpData;
                            var Width,Height:Integer):Boolean;
function ValidTextureBmp(const FileName:String):Boolean;

function AbleToLoadDIBitmapWithAlpha(const FileName:String;var Data:PBmpData;
                            var Width,Height:Integer):Boolean;

implementation

uses
  Windows, SysUtils;

function AbleToLoadDIBitmapWithAlpha(const FileName:String;var Data:PBmpData;
                            var Width,Height:Integer):Boolean;
const
  HeaderSize = SizeOf(TBitmapFileHeader);
  InfoSize   = SizeOf(TBitmapInfoHeader);
type
  TRGB = record
    R,G,B : Byte;
  end;
  TRGBArray = array[1..9999999] of TRGB;
  TRGBPtr = ^TRGBArray;

  TRGBA = record
    R,G,B,A : Byte;
  end;
  TRGBAArray = array[1..9999999] of TRGBA;
  TRGBAPtr = ^TRGBAArray;
var
  RGBPtr    : TRGBPtr;
  BmpFile   : file;
  BmpHeader : TBitmapFileHeader;
  BmpInfo   : TBitmapInfoHeader;
  DataSize  : Integer;
  FileData  : TRGBPtr;
  DestData  : TRGBAPtr;
  R,I,V     : Integer;
begin
  Result:=False;
  if FileExists(FileName) then try
    AssignFile(BmpFile,FileName);
    Reset(BmpFile,1);
    DataSize:=FileSize(BmpFile)-HeaderSize-InfoSize;
    BlockRead(BmpFile,BmpHeader,HeaderSize);

// make sure it's a valid bmp
    if BmpHeader.bfType<>$4D42 then Exit;
    BlockRead(BmpFile,BmpInfo,InfoSize);
    Width:=BmpInfo.biWidth;
    Height:=BmpInfo.biHeight;
    GetMem(FileData,DataSize);
    if Assigned(FileData) then begin
      BlockRead(BmpFile,FileData^,DataSize);

      GetMem(Data,Width*Height*4);
      DestData:=TRGBAPtr(Data);

      for I:=1 to DataSize div 3 do begin
        V:=FileData^[I].R;
        if V>0 then begin
          V:=V;
        end;
        DestData^[I].R:=V;
        DestData^[I].G:=V;
        DestData^[I].B:=V;
        DestData^[I].A:=255;
      end;
      Result:=True;
    end;
  finally
    Close(BmpFile);
    if Assigned(FileData) then FreeMem(FileData);
  end;
end;

function AbleToLoadDIBitmap(const FileName:String;var Data:PBmpData;
                            var Width,Height:Integer):Boolean;
const
  HeaderSize = SizeOf(TBitmapFileHeader);
  InfoSize   = SizeOf(TBitmapInfoHeader);
type
  TRGB = record
    R,G,B : Byte;
  end;
  TRGBArray = array[1..9999999] of TRGB;
  TRGBPtr = ^TRGBArray;
var
  RGBPtr    : TRGBPtr;
  BmpFile   : file;
  BmpHeader : TBitmapFileHeader;
  BmpInfo   : TBitmapInfoHeader;
  Datasize  : Integer;
  R,I       : Integer;
begin
  Result:=False;
  if FileExists(FileName) then try
    AssignFile(BmpFile,FileName);
    Reset(BmpFile,1);
    DataSize:=FileSize(BmpFile)-HeaderSize-InfoSize;
    BlockRead(BmpFile,BmpHeader,HeaderSize);

// make sure it's a valid bmp
    if BmpHeader.bfType<>$4D42 then Exit;
    BlockRead(BmpFile,BmpInfo,InfoSize);
    Width:=BmpInfo.biWidth;
    Height:=BmpInfo.biHeight;
    GetMem(Data,DataSize);
    if Assigned(Data) then begin
      BlockRead(BmpFile,Data^,DataSize);

// swap the red and green
   {   RGBPtr:=TRGBPtr(Data);
      for I:=1 to DataSize div 3 do begin
        R:=RGBPtr^[I].R;
        RGBPtr^[I].R:=RGBPtr^[I].B;
        RGBPtr^[I].B:=R;
      end;}
      Result:=True;
    end;
  finally
    Close(BmpFile);
  end;
end;

function PowerOfTwo(Value:Integer):Boolean;
var
  V : Integer;
begin
  V:=1;
  repeat
    V:=V*2;
    Result:=(Value=V);
  until Result or (V=16384);
end;

function ValidTextureBmp(const FileName:String):Boolean;
const
  HeaderSize = SizeOf(TBitmapFileHeader);
  InfoSize   = SizeOf(TBitmapInfoHeader);
var
  BmpFile   : file;
  BmpHeader : TBitmapFileHeader;
  BmpInfo   : TBitmapInfoHeader;
  DataSize  : Integer;
begin
  Result:=False;
  if FileExists(FileName) then try
    AssignFile(BmpFile,FileName);
    Reset(BmpFile,1);
    DataSize:=FileSize(BmpFile)-HeaderSize-InfoSize;
    BlockRead(BmpFile,BmpHeader,HeaderSize);

// make sure it's a valid bmp
    if BmpHeader.bfType<>$4D42 then Exit;
    BlockRead(BmpFile,BmpInfo,InfoSize);
    Result:=PowerOfTwo(BmpInfo.biWidth) and PowerOfTwo(BmpInfo.biHeight) and
            (DataSize=(BmpInfo.biWidth*BmpInfo.biHeight*3));
  finally
    Close(BmpFile);
  end;
end;

end.


