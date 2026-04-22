unit CTMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Z_prof;

type
  TCTMainFrm = class(TForm)
    RawPB: TPaintBox;
    MonoPB: TPaintBox;
    Button1: TButton;
    Zprof: TZprofiler;
    DilatedPB: TPaintBox;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RawPBPaint(Sender: TObject);
    procedure MonoPBPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DilatedPBPaint(Sender: TObject);

  private
    MonoBmp    : TBitmap;
    DilatedBmp : TBitmap;

    procedure NewCameraFrame(Sender:TObject);
    procedure DrawMonoBmp;
    procedure DrawDilatedBmp;

  public

  end;

var
  CTMainFrm: TCTMainFrm;

implementation

{$R *.dfm}

uses
  CameraU, BmpUtils;

const
//  ImageW = 160;
//  ImageH = 120;
//  ImageW = 320;
//  ImageH = 240;
  ImageW = 640;
  ImageH = 480;

function CreateSmallBmp:TBitmap;
begin
  Result:=TBitmap.Create;
  Result.Width:=160;//ImageW;
  Result.Height:=120;//ImageH;
  Result.PixelFormat:=pf24Bit;
end;

procedure TCTMainFrm.FormCreate(Sender: TObject);
begin
  MonoBmp:=CreateSmallBmp;
  ClearBmp(MonoBmp,clBlack);
  DilatedBmp:=CreateSmallBmp;
  RawPB.Width:=ImageW;
  RawPB.Height:=ImageH;
  MonoPB.Width:=MonoBmp.Width;
  MonoPB.Height:=MonoBmp.Height;
  Camera:=TCamera.Create;
  Camera.ImageW:=ImageW;
  Camera.ImageH:=ImageH;
  Camera.Bpp:=3;
  Camera.UseFirstDevice;
  Camera.Start;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TCTMainFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(Camera) then Camera.ShutDown;
end;

procedure TCTMainFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(MonoBmp) then MonoBmp.Free;
  if Assigned(DilatedBmp) then DilatedBmp.Free;
end;

procedure TCTMainFrm.NewCameraFrame(Sender:TObject);
begin
  RawPB.Canvas.Draw(0,0,Camera.Bmp);
  MonoPB.Canvas.Draw(0,0,Camera.SmallBmp);
  DrawDilatedBmp;
  DilatedPB.Canvas.Draw(0,0,DilatedBmp);
end;

procedure TCTMainFrm.DrawMonoBmp;
var
  I,X,Y    : Integer;
  SrcLine  : PByteArray;
  DestLine : PByteArray;
begin
  Assert(MonoBmp.Height=Camera.Bmp.Height);
  for Y:=0 to MonoBmp.Height-1 do begin
    SrcLine:=Camera.Bmp.ScanLine[Y];
    DestLine:=MonoBmp.ScanLine[Y];
    for X:=0 to MonoBmp.Width-1 do begin
      I:=X*3;
      DestLine^[I]:=SrcLine^[I];
    end;
  end;
end;

procedure TCTMainFrm.RawPBPaint(Sender: TObject);
begin
  RawPB.Canvas.Draw(0,0,Camera.Bmp);
end;

procedure TCTMainFrm.MonoPBPaint(Sender: TObject);
begin
  MonoPB.Canvas.Draw(0,0,MonoBmp);
end;

procedure TCTMainFrm.Button1Click(Sender: TObject);
begin
  Camera.FindCameraBmpSize;
end;

procedure TCTMainFrm.DrawDilatedBmp;
begin
  DilateBmp3x3(Camera.SmallBmp,DilatedBmp,Simple3x3Element);
end;

procedure TCTMainFrm.DilatedPBPaint(Sender: TObject);
begin
  DilatedPB.Canvas.Draw(0,0,DilatedBmp);
end;

end.
