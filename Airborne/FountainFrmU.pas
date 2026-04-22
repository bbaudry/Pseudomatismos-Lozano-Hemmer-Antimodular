unit FountainFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AprSpin, StdCtrls, ExtCtrls, Math;

type
  TFountainFrm = class(TForm)
    ThresholdsPanel: TPanel;
    Label4: TLabel;
    ColorDlg: TColorDialog;
    TextPanel: TPanel;
    Label11: TLabel;
    PlacementPanel: TPanel;
    Label24: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    StaticYEdit: TAprSpinEdit;
    StaticXEdit: TAprSpinEdit;
    SpacingPanel: TPanel;
    Label16: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    StaticYSpacingEdit: TAprSpinEdit;
    StaticXSpacingEdit: TAprSpinEdit;
    ShowTextBtn: TButton;
    Label2: TLabel;
    HomeThresholdEdit: TAprSpinEdit;
    Label15: TLabel;
    MoveThresholdEdit: TAprSpinEdit;
    Label17: TLabel;
    ColorPanel: TPanel;
    FadeTimePanel: TPanel;
    Label22: TLabel;
    FadeTimeEdit: TAprSpinEdit;
    Label1: TLabel;
    SizeEdit: TAprSpinEdit;
    Label3: TLabel;
    Label5: TLabel;
    WaitAlphaEdit: TAprSpinEdit;

    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure StaticXEditChange(Sender: TObject);
    procedure StaticYEditChange(Sender: TObject);
    procedure StaticXSpacingEditChange(Sender: TObject);
    procedure StaticYSpacingEditChange(Sender: TObject);
    procedure ShowTextBtnClick(Sender: TObject);
    procedure SizeEditChange(Sender: TObject);
    procedure FadeTimeEditChange(Sender: TObject);
    procedure MoveThresholdEditChange(Sender: TObject);
    procedure HomeThresholdEditChange(Sender: TObject);
    procedure ColorPanelClick(Sender: TObject);
    procedure WaitAlphaEditChange(Sender: TObject);

  private

  public
    procedure Initialize;

  end;

var
  FountainFrm: TFountainFrm;

implementation

{$R *.dfm}

uses
  FountainU, memofrmu;

procedure TFountainFrm.Initialize;
begin
  with Fountain do begin

// text panel
    StaticXEdit.Value:=Static.Position.X;
    StaticYEdit.Value:=Static.Position.Y;
    StaticXSpacingEdit.Value:=Static.Spacing.X;
    StaticYSpacingEdit.Value:=Static.Spacing.Y;
    ColorPanel.Color:=Fountain.Color;
    SizeEdit.Value:=SpriteSize;

// thresholds
    MoveThresholdEdit.Value:=MoveThreshold;
    HomeThresholdEdit.Value:=HomeThreshold;

// fade in time
    FadeTimeEdit.Value:=FadeInTime;

// wait alpha
    WaitAlphaEdit.Value:=Fountain.WaitAlpha;
  end;
end;

procedure TFountainFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TFountainFrm.StaticXEditChange(Sender: TObject);
begin
  Fountain.Static.Position.X:=StaticXEdit.Value;
//  Fountain.ArrangeText;
// / Fountain.InitParticlesFromText;
end;

procedure TFountainFrm.StaticYEditChange(Sender: TObject);
begin
  Fountain.Static.Position.Y:=StaticYEdit.Value;
{  Fountain.ArrangeText;
  Fountain.InitParticlesFromText;}
end;

procedure TFountainFrm.StaticXSpacingEditChange(Sender: TObject);
begin
  Fountain.Static.Spacing.X:=StaticXSpacingEdit.Value;
{  Fountain.ArrangeText;
  Fountain.InitParticlesFromText;}
end;

procedure TFountainFrm.StaticYSpacingEditChange(Sender: TObject);
begin
  Fountain.Static.Spacing.Y:=StaticYSpacingEdit.Value;
{  Fountain.ArrangeText;
  Fountain.InitParticlesFromText;}
end;

procedure TFountainFrm.ShowTextBtnClick(Sender: TObject);
var
  I : Integer;
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    for I:=1 to Fountain.Lines do begin
      MemoFrm.Memo.Lines.Add(Fountain.Text[I]);
    end;
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

procedure TFountainFrm.SizeEditChange(Sender: TObject);
begin
  Fountain.SpriteSize:=Round(SizeEdit.Value);
end;

procedure TFountainFrm.FadeTimeEditChange(Sender: TObject);
begin
  Fountain.FadeInTime:=FadeTimeEdit.Value;
end;

procedure TFountainFrm.MoveThresholdEditChange(Sender: TObject);
begin
  Fountain.MoveThreshold:=MoveThresholdEdit.Value;
end;

procedure TFountainFrm.HomeThresholdEditChange(Sender: TObject);
begin
  Fountain.HomeThreshold:=HomeThresholdEdit.Value;
end;

procedure TFountainFrm.ColorPanelClick(Sender: TObject);
begin
  ColorDlg.Color:=Fountain.Color;
  if ColorDlg.Execute then begin
    Fountain.Color:=ColorDlg.Color;
    ColorPanel.Color:=Fountain.Color;
  end;  
end;

procedure TFountainFrm.WaitAlphaEditChange(Sender: TObject);
begin
  Fountain.WaitAlpha:=WaitAlphaEdit.Value;
end;

end.
