unit BmpView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, AprSpin, Global, PBar, NBFill;

type
  TBmpViewFrm = class(TForm)
    Label1: TLabel;
    PaintBox: TPaintBox;
    VideoEdit: TAprSpinEdit;
    ScrollBar: TScrollBar;
    IntensityEdit: TNBFillEdit;
    VideoNumberLbl: TLabel;
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ScrollBarChange(Sender: TObject);
    procedure VideoEditChange(Sender: TObject);
    procedure IntensityEditValueChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure DrawBmp;
    function  SelectedVideo:Integer;
    procedure ClearCell(X,Y:Integer);
    procedure InitScrollBar;
    procedure SetVideoNumberLbl;

  public
    procedure Initialize;

  end;

var
  BmpViewFrm: TBmpViewFrm;

implementation

{$R *.dfm}

uses
  TilerU, BmpUtils, Routines, MemoFrmU;

const
  Cols = 10;
  Rows = 5;

procedure TBmpViewFrm.Initialize;
begin
  PaintBox.Width:=Cols*Tiler.CellW;
  PaintBox.Height:=Rows*Tiler.CellH;
  ClientWidth:=PaintBox.Left*2+PaintBox.Width;
  ClientHeight:=PaintBox.Top+PaintBox.Height+PaintBox.Left;
  if Tiler.Videos>0 then VideoEdit.Max:=Tiler.Videos
  else VideoEdit.Max:=1;
  Bmp:=TBitmap.Create;
  Bmp.Width:=PaintBox.Width;
  Bmp.Height:=PaintBox.Height;
  Bmp.PixelFormat:=pf24bit;
  Bmp.Canvas.Font.Name:='Arial';
  Bmp.Canvas.Font.Size:=8;
  Bmp.Canvas.Font.Color:=clWhite;
  InitScrollBar;
  DrawBmp;
  IntensityEdit.Value:=Round(Tiler.DimScale*100);
  IntensityEdit.Title:='Intensity = '+IntToStr(IntensityEdit.Value);
  SetVideoNumberLbl;
end;

procedure TBmpViewFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TBmpViewFrm.InitScrollBar;
var
  V,Max : Integer;
begin
  V:=SelectedVideo;
  with Tiler.Video[V] do Max:=1+(ExtroEnd-IntroStart+1)-(Cols*Rows);
  ScrollBar.Min:=1;
  ScrollBar.Max:=Max;
  if ScrollBar.Position>Max then ScrollBar.Position:=Max;
end;

function TBmpViewFrm.SelectedVideo:Integer;
begin
  Result:=Round(VideoEdit.Value);
end;

procedure TBmpViewFrm.ClearCell(X,Y:Integer);
var
  X2,Y2 : Integer;
begin
  X2:=X+Tiler.CellW;
  Y2:=Y+Tiler.CellH;
  with Bmp.Canvas do begin
    Pen.Color:=clRed;
    Brush.Color:=$222222;
    Rectangle(X,Y,X2,Y2);
    MoveTo(X,Y);
    LineTo(X2,Y2);
    MoveTo(X2,Y);
    LineTo(X,Y2);
  end;
end;

procedure TBmpViewFrm.DrawBmp;
var
  V,R,C,X,Y   : Integer;
  ColOffset,F : Integer;
  TxtX,TxtY   : Integer;
  Txt         : String;
begin
  ColOffset:=ScrollBar.Position;
  V:=SelectedVideo;
  with Bmp.Canvas do for C:=1 to Cols do begin
    X:=(C-1)*Tiler.CellW;
    for R:=1 to Rows do begin
      Y:=(R-1)*Tiler.CellH;
      F:=(R-1)*Cols+(C-1)+ColOffset+(Tiler.Video[V].IntroStart-1);
//if Tiler.Video[V].Number=1 then F:=225;
      if F>Tiler.Video[V].ExtroEnd then ClearCell(X,Y)
      else with Tiler.Video[V] do begin
        if Assigned(BmpData[F]) then begin
          if C=R then CopyBmpDataTo24BitBmp(BmpData[F],Bmp,Palette,X,Y)
          else CopyBmpDataTo24BitBmp(BmpData[F],Bmp,DimPalette,X,Y);
        end
        else begin
          Brush.Color:=clBlack;
          Pen.Color:=clRed;
          Rectangle(X,Y,X+Tiler.CellW,Y+Tiler.CellH);
        end;
      end;
      Brush.Color:=clBlack;
      Txt:=IntToStr(F);
      TxtX:=X+(Tiler.CellW-TextWidth(Txt)) div 2;
      TxtY:=Y+(Tiler.CellH-TextWidth(Txt)) div 2;
      TextOut(TxtX,TxtY,Txt);
    end;
  end;
end;

procedure TBmpViewFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TBmpViewFrm.ScrollBarChange(Sender: TObject);
begin
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TBmpViewFrm.VideoEditChange(Sender: TObject);
begin
  SetVideoNumberLbl;
  InitScrollBar;
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TBmpViewFrm.IntensityEditValueChange(Sender: TObject);
begin
  IntensityEdit.Title:='Intensity = '+IntToStr(IntensityEdit.Value);
  Tiler.DimScale:=IntensityEdit.Value/100;
  Tiler.MakeDimPalettes;
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TBmpViewFrm.SetVideoNumberLbl;
var
  V,I : Integer;
begin
  V:=SelectedVideo;
  I:=Tiler.Video[V].Number;
  VideoNumberLbl.Caption:='('+FourDigitIntStr(I)+'.mov)';
end;
  
procedure TBmpViewFrm.Button1Click(Sender: TObject);
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    Tiler.TestVideos(MemoFrm.Memo.Lines);
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

end.


