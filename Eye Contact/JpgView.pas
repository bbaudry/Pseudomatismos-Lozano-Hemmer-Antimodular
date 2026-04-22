unit JpgView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, AprSpin, Global;

type
  TJpgViewFrm = class(TForm)
    Label1: TLabel;
    PaintBox: TPaintBox;
    VideoEdit: TAprSpinEdit;
    ScrollBar: TScrollBar;
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ScrollBarChange(Sender: TObject);
    procedure VideoEditChange(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure DrawBmp;
    function  SelectedVideo:Integer;
    procedure ClearCell(X,Y:Integer);
    procedure InitScrollBar;

  public
    procedure Initialize;

  end;

var
  JpgViewFrm: TJpgViewFrm;

implementation

{$R *.dfm}

uses
  TilerU;

const
  Cols = 10;
  Rows = 5;

procedure TJpgViewFrm.Initialize;
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
  Bmp.Canvas.Font.Name:='Arial';
  Bmp.Canvas.Font.Size:=8;
  Bmp.Canvas.Font.Color:=clWhite;
  InitScrollBar;
  DrawBmp;
end;

procedure TJpgViewFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TJpgViewFrm.InitScrollBar;
var
  V,Max : Integer;
begin
  V:=SelectedVideo;
  with Tiler.Video[V] do Max:=(ExtroEnd-IntroStart)-(Cols*Rows);
  ScrollBar.Min:=0;
  ScrollBar.Max:=Max;
  ScrollBar.Position:=0;
end;

function TJpgViewFrm.SelectedVideo:Integer;
begin
  Result:=Round(VideoEdit.Value);
end;

procedure TJpgViewFrm.ClearCell(X,Y:Integer);
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

procedure TJpgViewFrm.DrawBmp;
var
  V,R,C,X,Y,I : Integer;
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
      F:=(R-1)*Cols+C+ColOffset+(Tiler.Video[V].IntroStart-1);
      if F>Tiler.Video[V].ExtroEnd then ClearCell(X,Y)
      else begin
        if Assigned(Tiler.Video[V].Bmp[F]) then Draw(X,Y,Tiler.Video[V].Bmp[F])
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

procedure TJpgViewFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TJpgViewFrm.ScrollBarChange(Sender: TObject);
begin
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TJpgViewFrm.VideoEditChange(Sender: TObject);
begin
  InitScrollBar;
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

end.
