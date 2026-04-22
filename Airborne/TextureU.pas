unit TextureU;

interface

uses
  Windows, SysUtils, Dialogs, GLDraw, OpenGL1x, Bitmap, Graphics, Classes,
  OpenGLTokens, Ipl, OpenCV_CV, OpenCV, Global;

type
  TTexture = class(TObject)
  private

  public
    W,H,Tag  : Integer;
    Data     : PBmpData;
    DataSize : Integer;
    Name     : Integer;
    HasAlpha : Boolean;

    constructor Create;
    destructor Destroy; override;

    procedure Load(FileName:String);
    procedure LoadWithAlpha(FileName:String);
    procedure FreeData;
    procedure Apply;
    procedure Resize(iW,iH:Integer);
    procedure SetSize(iW,iH:Integer);
    procedure CopyFromBmp(iBmp:TBitmap);
    procedure Bind;
    procedure Store;
    procedure ApplyBmp(iBmp:TBitmap);

    procedure ApplyAndStoreBmp(iBmp:TBitmap);
    procedure ApplyAndStoreBmpWithAlpha(iBmp:TBitmap);

    procedure QuarterScaleData;
    procedure CopyFromTexture(Texture:TTexture);
    procedure QuarterCopyFromTexture(Texture:TTexture);
    procedure DrawOnBmp(iBmp:TBitmap);
    procedure QuickCopyFromBmp(iBmp:TBitmap);

    procedure SaveAsBmp(FileName:String);

    procedure CopyFromData(iData:PByte;iX,iY,iW,iH:Integer);
    procedure Clear;
  end;

var
  MaskTexture : TTexture;

implementation

uses
  Routines;

constructor TTexture.Create;
begin
  inherited;
  Data:=nil;
  DataSize:=0;
  HasAlpha:=False;
end;

destructor TTexture.Destroy;
begin
  FreeData;
  inherited;
end;

procedure TTexture.Resize(iW,iH:Integer);
begin
  W:=iW; H:=iH;
  FreeData;
  if HasAlpha then DataSize:=W*H*4
  else DataSize:=W*H*3;

  GetMem(Data,DataSize);
end;

procedure TTexture.SetSize(iW,iH:Integer);
begin
  W:=iW; H:=iH;

  FreeData;

  if HasAlpha then DataSize:=W*H*4
  else DataSize:=W*H*3;

  GetMem(Data,DataSize);

  Store;
  glGenTextures(1,@Name);
end;

procedure TTexture.Store;
begin
  if Name=0 then glGenTextures(1,@Name);
  glBindTexture(GL_TEXTURE_2D,Name);
  Apply;
  glBindTexture(GL_TEXTURE_2D,0);
end;

procedure TTexture.Load(FileName:String);
var
  Bmp : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    Bmp.LoadFromFile(FileName);
    Bmp.PixelFormat:=pf24Bit;
    CopyFromBmp(Bmp);
  finally
    Bmp.Free;
  end;

//  if not AbleToLoadDIBitmap(FileName,Data,W,H) then begin
//    ShowMessage('Unable to load '+FileName);
//  end;
  Store;
end;

procedure TTexture.LoadWithAlpha(FileName:String);
begin
  if not AbleToLoadDIBitmapWithAlpha(FileName,Data,W,H) then begin
    ShowMessage('Unable to load '+FileName);
  end
  else begin
    HasAlpha:=True;
    DataSize:=W*H*4;
    Store;
  end;
end;

procedure TTexture.FreeData;
begin
  if Name>0 then begin
    glDeleteTextures(1,@Name);
    Name:=0;
  end;
  if Assigned(Data) then begin
    FreeMem(Data);
    Data:=nil;
  end;
  DataSize:=0;
end;

procedure TTexture.Apply;
begin
// set it to repeat in S and T
  glTexParameterI(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameterI(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

// set the filters
  glTexParameterI(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  glTexParameterI(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

  if HasAlpha then begin
    glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,W,H,0,GL_RGBA,GL_UNSIGNED_BYTE,Data);
  end
  else glTexImage2D(GL_TEXTURE_2D,0,3,W,H,0,GL_RGB,GL_UNSIGNED_BYTE,Data);
end;

procedure TTexture.Bind;
begin
  if Name=0 then Store;
  glBindTexture(GL_TEXTURE_2D,Name);
end;

procedure TTexture.CopyFromBmp(iBmp:TBitmap);
var
  DataPtr  : PByte;
  Line     : PByteArray;
  X,Y,I    : Integer;
  Bpp      : Integer;
  SrcBpp   : Integer;
begin
  if HasAlpha then Bpp:=4
  else Bpp:=3;

  if iBmp.PixelFormat=pf32Bit then SrcBpp:=4
  else SrcBpp:=3;

  if (W<>iBmp.Width) or (H<>iBmp.Height) or (Data=nil) then begin
    FreeData;
    W:=iBmp.Width;
    H:=iBmp.Height;
    DataSize:=W*H*SrcBpp;
    GetMem(Data,DataSize);
 end;

  DataPtr:=PByte(Data);
  for Y:=0 to iBmp.Height-1 do begin
    Line:=iBmp.ScanLine[iBmp.Height-1-Y];
    for X:=0 to iBmp.Width-1 do begin
//    for X:=iBmp.Width-1 downto 0 do begin

      I:=X*SrcBpp;
      DataPtr^:=Line^[I+2];
      Inc(DataPtr);
      DataPtr^:=Line^[I+1];
      Inc(DataPtr);
      DataPtr^:=Line^[I+0];
      Inc(DataPtr);
      if HasAlpha then begin
        DataPtr^:=255;
        Inc(DataPtr);
      end;
    end;
  end;
//Store;
end;

// doesn't store the data as a texture name - useful for a live feed with
// constantly changing data
procedure TTexture.ApplyBmp(iBmp:TBitmap);
var
  DataPtr  : PByte;
  Line     : PByteArray;
  X,Y,I    : Integer;
  Bpp      : Integer;
  SrcBpp   : Integer;
begin
  Bpp:=3;

  SrcBpp:=3;

  if (W<>iBmp.Width) or (H<>iBmp.Height) or (Data=nil) then begin
    FreeData;
    W:=iBmp.Width;
    H:=iBmp.Height;
    DataSize:=W*H*SrcBpp;
    GetMem(Data,DataSize);
 end;

  DataPtr:=PByte(Data);
  for Y:=0 to iBmp.Height-1 do begin
    Line:=iBmp.ScanLine[iBmp.Height-1-Y];
    for X:=0 to iBmp.Width-1 do begin
      I:=X*SrcBpp;
      DataPtr^:=Line^[I+2];
      Inc(DataPtr);
      DataPtr^:=Line^[I+1];
      Inc(DataPtr);
      DataPtr^:=Line^[I+0];
      Inc(DataPtr);
    end;
  end;
  glTexImage2D(GL_TEXTURE_2D,0,3,W,H,0,GL_RGB,GL_UNSIGNED_BYTE,Data);
end;

procedure TTexture.ApplyAndStoreBmp(iBmp:TBitmap);
var
  DataPtr  : PByte;
  Line     : PByteArray;
  X,Y,I    : Integer;
  Bpp      : Integer;
  SrcBpp   : Integer;
begin
  Bpp:=3;

  SrcBpp:=3;

  if (W<>iBmp.Width) or (H<>iBmp.Height) or (Data=nil) then begin
    FreeData;
    W:=iBmp.Width;
    H:=iBmp.Height;
    DataSize:=W*H*SrcBpp;
    GetMem(Data,DataSize);
  end;

  DataPtr:=PByte(Data);
  for Y:=0 to iBmp.Height-1 do begin
    Line:=iBmp.ScanLine[iBmp.Height-1-Y];
    for X:=0 to iBmp.Width-1 do begin
      I:=X*SrcBpp;
      DataPtr^:=Line^[I+2];
      Inc(DataPtr);
      DataPtr^:=Line^[I+1];
      Inc(DataPtr);
      DataPtr^:=Line^[I+0];
      Inc(DataPtr);
    end;
  end;
  Store;
end;

procedure TTexture.ApplyAndStoreBmpWithAlpha(iBmp:TBitmap);
var
  DataPtr  : PByte;
  Line     : PByteArray;
  X,Y,I    : Integer;
  Bpp      : Integer;
  SrcBpp   : Integer;
begin
  Bpp:=3;
  SrcBpp:=3;

  if (W<>iBmp.Width) or (H<>iBmp.Height) or (Data=nil) then begin
    FreeData;
    W:=iBmp.Width;
    H:=iBmp.Height;
    DataSize:=W*H*4;
    GetMem(Data,DataSize);
  end;

  DataPtr:=PByte(Data);
  for Y:=0 to iBmp.Height-1 do begin
    Line:=iBmp.ScanLine[iBmp.Height-1-Y];
    for X:=0 to iBmp.Width-1 do begin
      I:=X*SrcBpp;
      DataPtr^:=Line^[I+2];
      Inc(DataPtr);
      DataPtr^:=Line^[I+1];
      Inc(DataPtr);
      DataPtr^:=Line^[I+0];
      Inc(DataPtr);
      if (Line^[I+2]>0) or (Line^[I+1]>0) or (Line^[I]>0) then DataPtr^:=255
      else DataPtr^:=0;
      Inc(DataPtr);
    end;
  end;
  Store;
end;

procedure TTexture.QuickCopyFromBmp(iBmp:TBitmap);
var
  DataPtr  : PByte;
  Line     : PByteArray;
  X,Y,I    : Integer;
  Bpp      : Integer;
  SrcBpp   : Integer;
begin
  Bpp:=3;

  SrcBpp:=3;

  if (W<>iBmp.Width) or (H<>iBmp.Height) or (Data=nil) then begin
    FreeData;
    W:=iBmp.Width;
    H:=iBmp.Height;
    DataSize:=W*H*SrcBpp;
    GetMem(Data,DataSize);
  end;

  DataPtr:=PByte(Data);
  for Y:=0 to iBmp.Height-1 do begin
    Line:=iBmp.ScanLine[iBmp.Height-1-Y];
    for X:=iBmp.Width-1 downto 0 do begin
      I:=X*SrcBpp;

      DataPtr^:=Line^[I+2]; //  DataPtr^:=255;
      Inc(DataPtr);

      DataPtr^:=Line^[I+1];//DataPtr^:=255;
      Inc(DataPtr);

      DataPtr^:=Line^[I+0];//DataPtr^:=255;
      Inc(DataPtr);
    end;
  end;
end;

procedure TTexture.QuarterScaleData;
var
  OldData : PBmpData;
  SrcPtr  : PBmpData;
  DestPtr : PBmpData;
  X,Y     : Integer;
begin
  if not Assigned(Data) then Exit;

  OldData:=Data;

// halve each dimension
  W:=W shr 1;
  H:=H shr 1;

  DataSize:=W*H*3;
  GetMem(Data,DataSize);

  DestPtr:=Data;
  for Y:=0 to H-1 do begin
    SrcPtr:=OldData;
    Inc(SrcPtr,Y*2*W*2*3);
    for X:=0 to W-1 do begin

// red
      DestPtr^:=SrcPtr^;
      Inc(SrcPtr);
      Inc(DestPtr);

// green
      DestPtr^:=SrcPtr^;
      Inc(SrcPtr);
      Inc(DestPtr);

// blue
      DestPtr^:=SrcPtr^;

// next pixel
      Inc(SrcPtr,4);
      Inc(DestPtr);
    end;
  end;

  Store;
  FreeMem(OldData);
end;

procedure TTexture.CopyFromTexture(Texture:TTexture);
begin
  if (W<>Texture.W) or (H<>Texture.H) then begin
    FreeData;
    W:=Texture.W;
    H:=Texture.H;
    DataSize:=W*H*3;
    GetMem(Data,DataSize);
  end;
  Move(Texture.Data^,Data^,DataSize);
  Store;
end;

procedure TTexture.QuarterCopyFromTexture(Texture:TTexture);
var
  SrcPtr  : PBmpData;
  DestPtr : PBmpData;
  X,Y     : Integer;
begin
// free the old data and get the new data
  if Assigned(Data) then FreeMem(Data);
  W:=Texture.W div 2;
  H:=Texture.H div 2;
  DataSize:=W*H*3;
  GetMem(Data,DataSize);

  DestPtr:=Data;
  for Y:=0 to H-1 do begin
    SrcPtr:=Texture.Data;
    Inc(SrcPtr,Y*2*W*2*3);
    for X:=0 to W-1 do begin

// red
      DestPtr^:=SrcPtr^;
      Inc(SrcPtr);
      Inc(DestPtr);

// green
      DestPtr^:=SrcPtr^;
      Inc(SrcPtr);
      Inc(DestPtr);

// blue
      DestPtr^:=SrcPtr^;

// next pixel
      Inc(SrcPtr,4);
      Inc(DestPtr);
    end;
  end;
  Store;
end;

procedure TTexture.DrawOnBmp(iBmp:TBitmap);
var
  DataPtr  : PByte;
  LineSize : Integer;
  Line     : PByteArray;
  Y        : Integer;
begin
  iBmp.Width:=W;
  iBmp.Height:=H;
  if HasAlpha then begin
    LineSize:=W*4;
    iBmp.PixelFormat:=pf32Bit;
  end
  else begin
    LineSize:=W*3;
    iBmp.PixelFormat:=pf24Bit;
  end;

  DataPtr:=PByte(Data);
  for Y:=H-1 downto 0 do begin
    Line:=iBmp.ScanLine[Y];
    Move(DataPtr^,Line^,LineSize);
    Inc(DataPtr,LineSize);
  end;
end;

procedure TTexture.SaveAsBmp(FileName:String);
var
  Bmp : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    DrawOnBmp(Bmp);
    Bmp.SaveToFile(FileName);
  finally
    Bmp.Free;
  end;
end;

procedure TTexture.CopyFromData(iData:PByte;iX,iY,iW,iH:Integer);
type
  TRGBPixel = record
    R,G,B : Byte;
  end;
  PRGBPixel = ^TRGBPixel;
var
  SrcPtr,DestPtr : PRGBPixel;
//  DestBpr,SrcBpr : Integer;
  SrcX,SrcY      : Integer;
  X,Y,I,Bpp      : Integer;
begin
  Bpp:=3;

// the width needs to be a multiple of 4
  iW:=GoodTextureW(iW);

// get new data if we need to
  if (W<>iW) or (H<>iH) or (Data=nil) then begin
    if Assigned(Data) then begin
      FreeMem(Data);
      Data:=nil;
    end;
//    FreeData;
    W:=iW;
    H:=iH;
    DataSize:=W*H*4;
    GetMem(Data,DataSize);//Bpp);
  end;

// copy it over
//  SrcBpr:=MaxImageW*3;

//  DestBpr:=W*3;
  DestPtr:=PRGBPixel(Data);

  for Y:=0 to iH-1 do begin
    SrcY:=Y+iY;
    if (SrcY>=0) and (SrcY<MaxImageH) then begin
      SrcPtr:=PRGBPixel(iData);
      Inc(SrcPtr,SrcY*ImageW+iX);
      for X:=0 to W-1 do begin
        SrcX:=X+iX;
        if (SrcX>=0) and (SrcX<MaxImageW) then begin
          DestPtr^.R:=SrcPtr^.B;
          DestPtr^.G:=SrcPtr^.G;
          DestPtr^.B:=SrcPtr^.R;
        end
        else begin
          DestPtr^.R:=0;
          DestPtr^.G:=0;
          DestPtr^.B:=0;
        end;
        Inc(SrcPtr);
        Inc(DestPtr);
      end;
    end
    else begin
      FillChar(DestPtr^,W*3,0);
      Inc(DestPtr,W);
    end;
  end;
end;

procedure TTexture.Clear;
begin
  FillChar(Data^,DataSize,0);
end;

end.

