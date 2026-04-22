unit CellBackGndFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, AprSpin, FileCtrl, ExtCtrls, AprChkBx, Jpeg,
  ComCtrls;

type
  TCellBackGndFrm = class(TForm)
    BackGndBtn: TBitBtn;
    XCellsLbl: TLabel;
    YCellsLbl: TLabel;
    XCellsEdit: TAprSpinEdit;
    YCellsEdit: TAprSpinEdit;
    MaxCountLbl: TLabel;
    MaxCountEdit: TAprSpinEdit;
    ThresholdLbl: TLabel;
    ThresholdEdit: TAprSpinEdit;
    TimeLbl: TLabel;
    MinTimeEdit: TAprSpinEdit;
    DrawGB: TGroupBox;
    DrawCellsCB: TAprCheckBox;
    ShowCountsCB: TAprCheckBox;
    EnabledCB: TCheckBox;
    TabControl: TTabControl;
    PaintBox: TPaintBox;
    ShowAgesCB: TAprCheckBox;
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure XCellsEditChange(Sender: TObject);
    procedure YCellsEditChange(Sender: TObject);
    procedure ThresholdEditChange(Sender: TObject);
    procedure MaxCountEditChange(Sender: TObject);
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
  CellBackGndFrm: TCellBackGndFrm;

implementation

{$R *.dfm}

uses
  BmpUtils, CameraU, Global, Routines, CellBackGndFind;

procedure TCellBackGndFrm.Initialize;
begin
  with CellBackGndFinder do begin
    XCellsEdit.Value:=XCells;
    YCellsEdit.Value:=YCells;
    ThresholdEdit.Value:=Threshold;
    MaxCountEdit.Value:=MaxCount;
    MinTimeEdit.Value:=CellBackGndFinder.MinTime/1000;
    InitForTracking;
  end;
  Bmp:=CreateSmallBmp;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TCellBackGndFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TCellBackGndFrm.DrawBmp;
begin
  Case TabControl.TabIndex of
    0: Bmp.Canvas.Draw(0,0,Camera.SmallBmp);
    1: Bmp.Canvas.Draw(0,0,Camera.BackGndBmp);
    2: Bmp.Canvas.Draw(0,0,Camera.SubtractedBmp);
    3: CellBackGndFinder.ShowPixelsAboveAutoBackGndThreshold(Bmp);
    4: Bmp.Canvas.Draw(0,0,CellBackGndFinder.TestBackGndBmp);
    5: Bmp.Canvas.Draw(0,0,CellBackGndFinder.TestSubtractedBmp);
  end;
  if DrawCellsCB.Checked then CellBackGndFinder.DrawAutoBackGndCells(Bmp);
  if ShowCountsCB.Checked then CellBackGndFinder.ShowAutoBackGndChangeCounts(Bmp);
  if ShowAgesCB.Checked then CellBackGndFinder.ShowCellAges(Bmp);
end;

procedure TCellBackGndFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TCellBackGndFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TCellBackGndFrm.NewCameraFrame(Sender:TObject);
begin
  Camera.DrawSubtractedBmp;
  CellBackGndFinder.Update(Camera.SmallBmp);
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TCellBackGndFrm.XCellsEditChange(Sender: TObject);
begin
  CellBackGndFinder.XCells:=Round(XCellsEdit.Value);
end;

procedure TCellBackGndFrm.YCellsEditChange(Sender: TObject);
begin
  CellBackGndFinder.YCells:=Round(YCellsEdit.Value);
end;

procedure TCellBackGndFrm.ThresholdEditChange(Sender: TObject);
begin
  CellBackGndFinder.Threshold:=Round(ThresholdEdit.Value);
end;

procedure TCellBackGndFrm.MaxCountEditChange(Sender: TObject);
begin
  CellBackGndFinder.MaxCount:=Round(MaxCountEdit.Value);
end;

procedure TCellBackGndFrm.MinTimeEditChange(Sender: TObject);
begin
  CellBackGndFinder.MinTime:=Round(MinTimeEdit.Value*1000);
end;

procedure TCellBackGndFrm.BackGndBtnClick(Sender: TObject);
begin
  CellBackGndFinder.SetBackGndBmp(Camera.SmallBmp);
end;

end.
