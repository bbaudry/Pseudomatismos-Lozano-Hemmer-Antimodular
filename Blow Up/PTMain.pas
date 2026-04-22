unit PTMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Z_prof;

type
  TPTMainFrm = class(TForm)
    PaintBox: TPaintBox;
    Button1: TButton;
    Button2: TButton;
    Zprof: TZprofiler;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    Bmp : TBitmap;

  public

  end;

var
  PTMainFrm: TPTMainFrm;

implementation

{$R *.dfm}

uses
  TilerU, BmpUtils, Routines;

procedure TPTMainFrm.FormCreate(Sender: TObject);
var
  Size : Integer;
begin
  Bmp:=TBitmap.Create;
  Bmp.LoadFromFile(Path+'Bmps64x80/V002/0001.bmp');
  Tiler:=TTiler.Create;
  Tiler.CellW:=Bmp.Width;
  Tiler.CellH:=Bmp.Height;
  Tiler.SetPaletteFromBmp(Bmp);//FirstBmp;
  Size:=Bmp.Height*Bmp.Width;
  GetMem(Tiler.Video[1].BmpData[1],Size);
  CopyBmpIntoBmpData(Bmp,Tiler.Video[1].BmpData[1]);
  Bmp.PixelFormat:=pf24Bit;
end;

procedure TPTMainFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
  if Assigned(Tiler) then begin
    FreeMem(Tiler.Video[1].BmpData[1]);
  end;
end;

procedure TPTMainFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TPTMainFrm.Button1Click(Sender: TObject);
begin
  CopyBmpDataTo24BitBmp(Tiler.Video[1].BmpData[1],Bmp,0,0);
  CopyBmpDataTo24BitBmpAsm(Tiler.Video[1].BmpData[1],Bmp,0,0);
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TPTMainFrm.Button2Click(Sender: TObject);
var
  I : Integer;
begin
  for I:=1 to 1000 do begin
    ZProf.Mark(1,True);
    CopyBmpDataTo24BitBmp(Tiler.Video[1].BmpData[1],Bmp,0,0);
    ZProf.Mark(1,False);

    ZProf.Mark(2,True);
    CopyBmpDataTo24BitBmpAsm(Tiler.Video[1].BmpData[1],Bmp,0,0);
    ZProf.Mark(2,False);
  end;
end;

procedure TPTMainFrm.Button3Click(Sender: TObject);
begin
  
  //
end;

end.
