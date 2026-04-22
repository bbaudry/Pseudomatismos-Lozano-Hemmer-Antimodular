unit FreeImgU;

interface

uses
  FreeImage, Windows, Graphics, SysUtils;

type
  TFreeImg = class(TObject)
  private
    Bmp24 : PFiBitmap;
    Bmp8  : PFiBitmap;

  public
    QMethod : FREE_IMAGE_QUANTIZE;

    constructor Create;
    destructor Destroy;

    procedure CopyFromBmp(SrcBmp:TBitmap);
    procedure DrawBmp8OnBmp(DestBmp:TBitmap);
    procedure DrawBmp24OnBmp(DestBmp:TBitmap);
    procedure Make8BitBmp;
  end;

implementation

uses
  Main;

constructor TFreeImg.Create;
begin
  Bmp24:=FreeImage_Allocate(64,80,24);
//  Bmp8:=FreeImage_Allocate(64,80,8);
  QMethod:=FIQ_WUQUANT;	// Xiaolin Wu color quantization algorithm
//         FIQ_NNQUANT  // NeuQuant neural-net quantization algorithm
end;

destructor TFreeImg.Destroy;
begin
  if Assigned(Bmp24) then FreeImage_Unload(Bmp24);
  if Assigned(Bmp8) then FreeImage_Unload(Bmp8);
end;

procedure TFreeImg.CopyFromBmp(SrcBmp:TBitmap);
var
  DestPtr : PByte;
  SrcLine : PByteArray;
  Y,Bpr   : Integer;
begin
  Bpr:=64*3;
  for Y:=0 to SrcBmp.Height-1 do begin
    SrcLine:=SrcBmp.ScanLine[Y];
    DestPtr:=FreeImage_GetScanLine(Bmp24,Y);
    Move(SrcLine^,DestPtr^,Bpr);
  end;
end;

procedure TFreeImg.Make8BitBmp;
begin
  if Assigned(Bmp8) then FreeImage_Unload(Bmp8);
  Bmp8:=FreeImage_ColorQuantize(Bmp24,QMethod);
end;

procedure TFreeImg.DrawBmp8OnBmp(DestBmp:TBitmap);
type
  TRGBQuadArray = array[0..255] of TRGBQuad;
  PRGBQuadArray = ^TRGBQuadArray;
var
  X,Y      : Integer;
  I        : Byte;
  DestLine : PByteArray;
  Palette  : PRGBQuad;
  Pal      : PRGBQuadArray;
  SrcPtr  : PByte;
begin
  Palette:=FreeImage_GetPalette(Bmp8);
  Pal:=PRGBQuadArray(Palette);
  for Y:=0 to DestBmp.Height-1 do begin
    SrcPtr:=FreeImage_GetScanLine(Bmp8,Y);
    DestLine:=DestBmp.ScanLine[Y];
    for X:=0 to DestBmp.Width-1 do begin
      I:=SrcPtr^;
      Inc(SrcPtr);
      DestLine^[X*3+0]:=Pal^[I].rgbBlue;
      DestLine^[X*3+1]:=Pal^[I].rgbGreen;
      DestLine^[X*3+2]:=Pal^[I].rgbRed;
    end;
  end;
//FreeMem(Palette);
end;

procedure TFreeImg.DrawBmp24OnBmp(DestBmp:TBitmap);
var
  Y        : Integer;
  DestLine : PByteArray;
  SrcPtr   : PByte;
begin
  for Y:=0 to DestBmp.Height-1 do begin
    SrcPtr:=FreeImage_GetScanLine(Bmp24,Y);
    DestLine:=DestBmp.ScanLine[Y];
    Move(SrcPtr^,DestLine^,64*3);
  end;
end;

end.
  function FreeImage_GetPixelColor(dib: PFIBITMAP; X, Y: Longint; var Value: PRGBQuad): Boolean; stdcall; external FIDLL name '_FreeImage_GetPixelColor@16';

  FREE_IMAGE_QUANT
  IZE = (
    FIQ_WUQUANT = 0,		// Xiaolin Wu color quantization algorithm
    FIQ_NNQUANT = 1			// NeuQuant neural-net quantization algorithm by Anthony Dekker
  );
