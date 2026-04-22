unit SecretMenuFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, AprChkBx;

type
  TSecretMenuFrm = class(TForm)
    CellTestBtn: TBitBtn;
    BlowupTestBtn: TBitBtn;
    TrackTestBtn: TBitBtn;
    StopWatchBtn: TBitBtn;
    TestCellsBtn: TBitBtn;
    ShowSuperCellsCB: TAprCheckBox;
    ShowTestPatternCB: TAprCheckBox;
    procedure CellTestBtnClick(Sender: TObject);
    procedure BlowupTestBtnClick(Sender: TObject);
    procedure TrackTestBtnClick(Sender: TObject);
    procedure StopWatchBtnClick(Sender: TObject);
    procedure TestCellsBtnClick(Sender: TObject);
    procedure ShowSuperCellsCBClick(Sender: TObject);
    procedure ShowTestPatternCBClick(Sender: TObject);

  private

  public
    procedure ShowAt(X,Y:Integer);

  end;

var
  SecretMenuFrm: TSecretMenuFrm;

implementation

{$R *.dfm}

uses
  Main, TilerU, CellTestFrmU, BlowUpTestFrmU, TrackTestFrmU, StopWatchU,
  MemoFrmU, CameraU;

procedure TSecretMenuFrm.ShowAt(X,Y:Integer);
begin
  Left:=X-Width div 2;
  Top:=Y-Height div 2;
  FormStyle:=fsStayOnTop;

  ShowSuperCellsCB.Checked:=Tiler.ShowSuperCells;
  ShowTestPatternCB.Checked:=Tiler.ShowTestPattern;

  ShowModal;
end;

procedure TSecretMenuFrm.CellTestBtnClick(Sender: TObject);
begin
  MainFrm.CameraTimer.Enabled:=False;
  CellTestFrm:=TCellTestFrm.Create(Application);
  try
    CellTestFrm.Initialize;
    CellTestFrm.ShowModal;
  finally
    CellTestFrm.Free;
  end;
  MainFrm.Resume;
end;

procedure TSecretMenuFrm.BlowupTestBtnClick(Sender: TObject);
begin
  BlowUpTestFrm:=TBlowUpTestFrm.Create(Application);
  try
    BlowUpTestFrm.Initialize;
    BlowUpTestFrm.ShowModal;
  finally
    BlowUpTestFrm.Free;
  end;
  Camera.OnNewFrame:=MainFrm.NewCameraFrame;
end;

procedure TSecretMenuFrm.TrackTestBtnClick(Sender: TObject);
begin
   TrackTestFrm:=TTrackTestFrm.Create(Application);
  try
    TrackTestFrm.Initialize;
    TrackTestFrm.ShowModal;
  finally
    TrackTestFrm.Free;
  end;
  Camera.OnNewFrame:=MainFrm.NewCameraFrame;
end;

procedure TSecretMenuFrm.StopWatchBtnClick(Sender: TObject);
var
  C : Integer;
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    MemoFrm.Memo.Lines.Add('Total loop: '+StopWatch.ChannelStr(1));
    MemoFrm.Memo.Lines.Add('Bmps from camera: '+StopWatch.ChannelStr(2));
    MemoFrm.Memo.Lines.Add('BackGnd: '+StopWatch.ChannelStr(3));
    MemoFrm.Memo.Lines.Add('Tracking: '+StopWatch.ChannelStr(4));
    MemoFrm.Memo.Lines.Add('Tiler: '+StopWatch.ChannelStr(5));
    MemoFrm.Memo.Lines.Add('Rendering: '+StopWatch.ChannelStr(6));

    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
  for C:=1 to 8 do StopWatch.Reset(8);

end;

procedure TSecretMenuFrm.TestCellsBtnClick(Sender: TObject);
begin
   MemoFrm:=TMemoFrm.Create(Application);
  try
    Tiler.TestCells(MemoFrm.Memo.Lines);
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

procedure TSecretMenuFrm.ShowSuperCellsCBClick(Sender: TObject);
begin
  Tiler.ShowSuperCells:=ShowSuperCellsCB.Checked;
end;

procedure TSecretMenuFrm.ShowTestPatternCBClick(Sender: TObject);
begin
  Tiler.ShowTestPattern:=ShowTestPatternCB.Checked;
end;

end.
