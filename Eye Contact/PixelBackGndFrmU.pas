unit PixelBackGndFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, AprSpin, FileCtrl, ExtCtrls, AprChkBx, Jpeg,
  ComCtrls;

type
  TPixelBackGndFrm = class(TForm)
    BackGndBtn: TBitBtn;
    ThresholdLbl: TLabel;
    ThresholdEdit: TAprSpinEdit;
    TimeLbl: TLabel;
    MinTimeEdit: TAprSpinEdit;
    TabControl: TTabControl;
    PaintBox: TPaintBox;
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ThresholdEditChange(Sender: TObject);
    procedure MinTimeEditChange(Sender: TObject);
    procedure BackGndBtnClick(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure DrawBmp;
    procedure NewCameraFrame(Sender:TObject);

  public
    procedure Initialize;

  end;

var
  PixelBackGndFrm: TPixelBackGndFrm;

implementation

{$R *.dfm}

uses
  BmpUtils, CameraU, Global, Routines, PixelBackGndFind;

procedure TPixelBackGndFrm.Initialize;
begin
  with PixelBackGndFinder do begin
    ThresholdEdit.Value:=Threshold;
    MinTimeEdit.Value:=PixelBackGndFinder.MinTime/1000;
    InitForTracking;
  end;
  Bmp:=CreateSmallBmp;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TPixelBackGndFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TPixelBackGndFrm.DrawBmp;
begin
  Case TabControl.TabIndex of
    0: Bmp.Canvas.Draw(0,0,Camera.SmallBmp);
    1: Bmp.Canvas.Draw(0,0,Camera.BackGndBmp);
    2: Bmp.Canvas.Draw(0,0,Camera.SubtractedBmp);
    3: PixelBackGndFinder.ShowPixelsAboveAutoBackGndThreshold(Bmp);
    4: PixelBackGndFinder.ShowPixelStates(Bmp);
  end;
end;

procedure TPixelBackGndFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TPixelBackGndFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TPixelBackGndFrm.NewCameraFrame(Sender:TObject);
begin
  Camera.DrawSubtractedBmp;
  PixelBackGndFinder.Update(Camera.SmallBmp);
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TPixelBackGndFrm.ThresholdEditChange(Sender: TObject);
begin
  PixelBackGndFinder.Threshold:=Round(ThresholdEdit.Value);
end;

procedure TPixelBackGndFrm.MinTimeEditChange(Sender: TObject);
begin
  PixelBackGndFinder.MinTime:=Round(MinTimeEdit.Value*1000);
end;

procedure TPixelBackGndFrm.BackGndBtnClick(Sender: TObject);
begin
  PixelBackGndFinder.SetBackGndBmp(Camera.SmallBmp);
end;

end.
