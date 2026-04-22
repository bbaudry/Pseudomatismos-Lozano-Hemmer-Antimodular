unit BackGndFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, AprSpin, FileCtrl, ExtCtrls, AprChkBx, Jpeg,
  ComCtrls;

type
  TBackGndFrm = class(TForm)
    BackGndBtn: TBitBtn;
    ThresholdLbl: TLabel;
    ThresholdEdit: TAprSpinEdit;
    TimeLbl: TLabel;
    MinTimeEdit: TAprSpinEdit;
    EnabledCB: TCheckBox;
    TabControl: TTabControl;
    PaintBox: TPaintBox;
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ThresholdEditChange(Sender: TObject);
    procedure MinTimeEditChange(Sender: TObject);
    procedure BackGndBtnClick(Sender: TObject);
    procedure EnabledCBClick(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure DrawBmp;
    procedure NewCameraFrame(Sender:TObject);

  public
    procedure Initialize;

  end;

var
  BackGndFrm: TBackGndFrm;

implementation

{$R *.dfm}

uses
  BmpUtils, CameraU, Global, Routines, BackGndFind;

procedure TBackGndFrm.Initialize;
begin
  with BackGndFinder do begin
    EnabledCB.Checked:=(BackGndFinder.Enabled);
    ThresholdEdit.Value:=Threshold;
    MinTimeEdit.Value:=BackGndFinder.MinTime/1000;
    InitForTracking;
  end;
  Bmp:=CreateSmallBmp;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TBackGndFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TBackGndFrm.DrawBmp;
begin
  Case TabControl.TabIndex of
    0: Bmp.Canvas.Draw(0,0,Camera.SmallBmp);
    1: Bmp.Canvas.Draw(0,0,BackGndFinder.BackGndBmp);
    2: Bmp.Canvas.Draw(0,0,BackGndFinder.SubtractedBmp);
    3: BackGndFinder.ShowPixelsAboveAutoBackGndThreshold(Bmp);
    4: BackGndFinder.ShowPixelStates(Bmp);
  end;
end;

procedure TBackGndFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TBackGndFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TBackGndFrm.NewCameraFrame(Sender:TObject);
begin
  BackGndFinder.DrawSubtractedBmp(Camera.SmallBmp);
  if BackGndFinder.Enabled then begin
    BackGndFinder.UpdateAutoBackGnd(Camera.SmallBmp);
  end;
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TBackGndFrm.ThresholdEditChange(Sender: TObject);
begin
  BackGndFinder.Threshold:=Round(ThresholdEdit.Value);
end;

procedure TBackGndFrm.MinTimeEditChange(Sender: TObject);
begin
  BackGndFinder.MinTime:=Round(MinTimeEdit.Value*1000);
end;

procedure TBackGndFrm.BackGndBtnClick(Sender: TObject);
begin
  BackGndFinder.SetBackGndBmp(Camera.SmallBmp);
end;

procedure TBackGndFrm.EnabledCBClick(Sender: TObject);
begin
  BackGndFinder.Enabled:=EnabledCB.Checked;
end;

end.
