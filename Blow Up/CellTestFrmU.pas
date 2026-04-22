unit CellTestFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, AprSpin, StdCtrls, BlobFind;

type
  TCellTestFrm = class(TForm)
    PaintBox: TPaintBox;
    Label1: TLabel;
    HiLitCellEdit: TAprSpinEdit;
    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);

  private
    Bmp       : TBitmap;
    MouseDown : Boolean;
    Blob      : TBlob;

    procedure NewCameraFrame(Sender:TObject);
    procedure DrawBmp;
    function  HiLitCellColumn:Integer;
    function  HiLitCellRow:Integer;

  public
    procedure Initialize;

  end;

var
  CellTestFrm: TCellTestFrm;

implementation

{$R *.dfm}

uses
  CameraU, BmpUtils, Routines, TilerU, Main;

procedure TCellTestFrm.Initialize;
begin
  FillChar(Blob,SizeOf(Blob),0);
  Bmp:=CreateImageBmp;
  ClearBmp(Bmp,clBlack);
  MouseDown:=False;
  HiLitCellEdit.Max:=Tiler.CellCount;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TCellTestFrm.NewCameraFrame(Sender:TObject);
var
  C,R : Integer;
begin
// draw this bmp
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);

// draw the main one  
{  Tiler.Update;
  GLScene.Render;
  if HiLitCellEdit.Value>0 then begin
    C:=HiLitCellColumn;
    R:=HiLitCellRow;
//    Tiler.Cell[C,R].OutlineOnBmp(MainFrm.Bmp);
  end;}
end;

procedure TCellTestFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

function TCellTestFrm.HiLitCellColumn:Integer;
var
  I : Integer;
begin
  I:=Round(HiLitCellEdit.Value);
  Result:=1+((I-1) mod Tiler.XCells);
end;

function TCellTestFrm.HiLitCellRow:Integer;
var
  I : Integer;
begin
  I:=Round(HiLitCellEdit.Value);
  Result:=1+((I-1) div Tiler.YCells);
end;

procedure TCellTestFrm.DrawBmp;
var
  C,R : Integer;
begin
  Bmp.Canvas.Draw(0,0,Camera.Bmp);
  if MouseDown then Bmp.Canvas.Pen.Color:=clYellow
  else begin
    if HiLitCellEdit.Value>0 then begin
      C:=HiLitCellColumn;
      R:=HiLitCellRow;
      Tiler.Cell[C,R].DrawOnCamBmp(Bmp);
    end;
    Bmp.Canvas.Pen.Color:=clBlue;
  end;
  if Blob.Width>0 then with Blob do begin
    Bmp.Canvas.Pen.Color:=clBlue;
    Bmp.Canvas.MoveTo(XMin,YMin);
    Bmp.Canvas.LineTo(XMax,YMin);
    Bmp.Canvas.LineTo(XMax,YMax);
    Bmp.Canvas.LineTo(XMin,YMax);
    Bmp.Canvas.LineTo(XMin,YMin);
  end;
  ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
end;

procedure TCellTestFrm.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseDown:=True;
  Blob.XMin:=X;
  Blob.XMax:=X;
  Blob.YMin:=Y;
  Blob.YMax:=Y;
  Blob.Width:=0;
  Blob.Height:=0;
end;

procedure TCellTestFrm.PaintBoxMouseMove(Sender: TObject;Shift: TShiftState;
                                         X,Y:Integer);
begin
  if MouseDown then begin
    with Blob do begin
      XMax:=X;
      YMax:=Y;
      if XMin>XMax then SwapInt(XMin,XMax);
      if YMin>YMax then SwapInt(YMin,YMax);
      Blob.Width:=(XMax-XMin)+1;
      Blob.Height:=(YMax-YMin)+1;
    end;
    DrawBmp;
    PaintBox.Canvas.Draw(0,0,Bmp);
  end;
end;

procedure TCellTestFrm.PaintBoxMouseUp(Sender: TObject;Button: TMouseButton;
                                       Shift: TShiftState; X, Y: Integer);
begin
  if MouseDown then begin
    MouseDown:=False;
    Tiler.ZoomToBlob(Blob);
    DrawBmp;
    PaintBox.Canvas.Draw(0,0,Bmp);
  end;
end;

procedure TCellTestFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
end;

end.

