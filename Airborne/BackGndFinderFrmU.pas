unit BackGndFinderFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, AprSpin, StdCtrls, AprChkBx;

type
  TBackGndFinderFrm = class(TForm)
    BackGndPanel: TPanel;
    BackGndFinderLbl: TLabel;
    Label10: TLabel;
    Label1: TLabel;
    ForceBackGndBtn: TButton;
    DelayCB: TAprCheckBox;
    BrighterRB: TRadioButton;
    AbsoluteRB: TRadioButton;
    BackGndThresholdEdit: TAprSpinEdit;
    BackGndTimeEdit: TAprSpinEdit;
    PaintBox: TPaintBox;
    Panel3: TPanel;
    Label9: TLabel;
    BackGndDrawPanel: TPanel;
    Label11: TLabel;
    NormalRB: TRadioButton;
    SubtractedRB: TRadioButton;
    ForeGndDrawPanel: TPanel;
    Label14: TLabel;
    NormalFGRB: TRadioButton;
    ThresholdsRB: TRadioButton;
    ChangingRB: TRadioButton;
    PixelStatesRB: TRadioButton;
    BackGndTimer: TTimer;
    BackGndRB: TRadioButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure BrighterRBClick(Sender: TObject);
    procedure AbsoluteRBClick(Sender: TObject);
    procedure ForceBackGndBtnClick(Sender: TObject);
    procedure BackGndThresholdEditChange(Sender: TObject);
    procedure BackGndTimeEditChange(Sender: TObject);
    procedure BackGndTimerTimer(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure NewCameraFrame(Sender:TObject);
    procedure DrawBmp;

  public
    procedure Initialize;
  end;

var
  BackGndFinderFrm: TBackGndFinderFrm;

implementation

{$R *.dfm}

uses
  BmpUtils, CameraU, BackGndFind;

procedure TBackGndFinderFrm.Initialize;
begin
  Bmp:=CreateBmpForPaintBox(PaintBox);

// backgnd finder
  Case BackGndFinder.SubtractMethod of
    smBrighter : BrighterRB.Checked:=True;
    smAbsolute : AbsoluteRB.Checked:=True;
  end;
  BackGndThresholdEdit.Value:=BackGndFinder.Threshold;
  BackGndTimeEdit.Value:=BackGndFinder.MinTime/1000;

  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TBackGndFinderFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
  Camera.OnNewFrame:=nil;
end;

procedure TBackGndFinderFrm.NewCameraFrame(Sender:TObject);
begin
  BackGndFinder.Update(Camera.Bmp);
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TBackGndFinderFrm.DrawBmp;
begin
  if NormalRB.Checked then Bmp.Canvas.Draw(0,0,Camera.Bmp)
  else if BackGndRB.Checked then Bmp.Canvas.Draw(0,0,BackGndFinder.BackGndBmp)
  else Bmp.Canvas.Draw(0,0,BackGndFinder.SubtractedBmp);

  if ThresholdsRB.Checked then begin
    BackGndFinder.ShowPixelsAboveAutoBackGndThreshold(Bmp);
  end
  else if ChangingRB.Checked then begin
    BackGndFinder.ShowAutoBackGndChangingPixels(Bmp);
  end
  else if PixelStatesRB.Checked then begin
    BackGndFinder.ShowPixelStates(Bmp);
  end;
end;

procedure TBackGndFinderFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TBackGndFinderFrm.BrighterRBClick(Sender: TObject);
begin
  BackGndFinder.SubtractMethod:=smBrighter;
end;

procedure TBackGndFinderFrm.AbsoluteRBClick(Sender: TObject);
begin
  BackGndFinder.SubtractMethod:=smAbsolute;
end;

procedure TBackGndFinderFrm.ForceBackGndBtnClick(Sender: TObject);
begin
  if DelayCB.Checked then BackGndTimer.Enabled:=True
  else BackGndTimerTimer(nil);

end;

procedure TBackGndFinderFrm.BackGndThresholdEditChange(Sender: TObject);
begin
  BackGndFinder.Threshold:=Round(BackGndThresholdEdit.Value);
end;

procedure TBackGndFinderFrm.BackGndTimeEditChange(Sender: TObject);
begin
  BackGndFinder.MinTime:=Round(BackGndTimeEdit.Value*1000);
end;

procedure TBackGndFinderFrm.BackGndTimerTimer(Sender: TObject);
begin
  BackGndTimer.Enabled:=False;
  BackGndFinder.SetBackGndBmp(Camera.Bmp);
end;

end.



