unit VidTestMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Global, AprSpin, NBFill;

type
  TVidTestMainFrm = class(TForm)
    PaintBox: TPaintBox;
    ScrollBar: TScrollBar;
    FrameLbl: TLabel;
    IntensityEdit: TNBFillEdit;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    VideoEdit: TAprSpinEdit;
    OfLbl: TLabel;
    ViewLoadedBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ScrollBarChange(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);

  private
    Bmp : TBitmap;
    Video : TVideo;

    procedure DrawBmp;
    procedure SetFrameLbl;

  public

  end;

var
  VidTestMainFrm: TVidTestMainFrm;

implementation

{$R *.dfm}

uses
  VidFile, FreeImageUtils, BmpUtils, TilerU;

procedure TVidTestMainFrm.FormCreate(Sender: TObject);
begin
  Bmp:=TBitmap.Create;
  Bmp.Width:=64;
  Bmp.Height:=80;
  Bmp.PixelFormat:=pf24Bit;
  Tiler:=TTiler.Create;
  Tiler.CellW:=64;
  Tiler.CellH:=80;
  Video.IntroStart:=1;
  Video.ExtroEnd:=144;
  LoadVideoFile('c:\EyeContact\EyeContact\Videos64x80\003.vid',Video);
  ScrollBar.Min:=1;
  ScrollBar.Max:=Video.ExtroEnd;
  ScrollBar.Position:=1;
  DrawBmp;
  SetFrameLbl;
end;

procedure TVidTestMainFrm.FormDestroy(Sender: TObject);
var
  I : Integer;
begin
  if Assigned(Bmp) then Bmp.Free;
  for I:=1 to ScrollBar.Max do begin
    if Assigned(Video.BmpData[I]) then FreeMem(Video.BmpData[I]);
  end;
  if Assigned(Tiler) then Tiler.Free;
end;

procedure TVidTestMainFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TVidTestMainFrm.ScrollBarChange(Sender: TObject);
begin
  DrawBmp;
  SetFrameLbl;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TVidTestMainFrm.DrawBmp;
var
  F : Integer;
begin
  F:=ScrollBar.Position;
  CopyBmpDataToBmpAsm(Video.BmpData[F],Bmp,Video.Palette,0,0);
end;

procedure TVidTestMainFrm.SetFrameLbl;
begin
  FrameLbl.Caption:='Frame #'+IntToStr(ScrollBar.Position)+
                   ' of '+IntToStr(ScrollBar.Max);
end;

end.
