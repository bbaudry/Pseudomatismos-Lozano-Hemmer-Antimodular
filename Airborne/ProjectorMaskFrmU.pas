unit ProjectorMaskFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AprChkBx, AprSpin, StdCtrls, ExtCtrls, Buttons;

type
  TProjectorMaskFrm = class(TForm)
    EnableCB: TAprCheckBox;
    Panel1: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    TopLeftXEdit: TAprSpinEdit;
    Label4: TLabel;
    TopLeftYEdit: TAprSpinEdit;
    Panel2: TPanel;
    Label1: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    TopRightXEdit: TAprSpinEdit;
    TopRightYEdit: TAprSpinEdit;
    Panel3: TPanel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    BottomRightXEdit: TAprSpinEdit;
    BottomRightYEdit: TAprSpinEdit;
    Panel4: TPanel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    BottomLeftXEdit: TAprSpinEdit;
    BottomLeftYEdit: TAprSpinEdit;
    Panel5: TPanel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    CenterXEdit: TAprSpinEdit;
    CenterYEdit: TAprSpinEdit;
    Label16: TLabel;
    CenterREdit: TAprSpinEdit;
    DrawMaskBtn: TButton;
    ScrollBox: TScrollBox;
    PaintBox: TPaintBox;
    SaveBtn: TBitBtn;
    procedure EditChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DrawMaskBtnClick(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EnableCBClick(Sender: TObject);

  private

  public
    procedure Initialize;
  end;

var
  ProjectorMaskFrm: TProjectorMaskFrm;

implementation

{$R *.dfm}

uses
  ProjectorMaskU;

procedure TProjectorMaskFrm.Initialize;
begin
  EnableCB.Checked:=ProjectorMask.Enabled;
  with ProjectorMask.TopLeftPt do begin
    TopLeftXEdit.Value:=X;
    TopLeftYEdit.Value:=Y;
  end;
  with ProjectorMask.TopRightPt do begin
    TopRightXEdit.Value:=X;
    TopRightYEdit.Value:=Y;
  end;
  with ProjectorMask.BottomRightPt do begin
    BottomRightXEdit.Value:=X;
    BottomRightYEdit.Value:=Y;
  end;
  with ProjectorMask.BottomLeftPt do begin
    BottomLeftXEdit.Value:=X;
    BottomLeftYEdit.Value:=Y;
  end;
  with ProjectorMask.CenterPt do begin
    CenterXEdit.Value:=X;
    CenterYEdit.Value:=Y;
  end;
  CenterREdit.Value:=ProjectorMask.CenterRadius;
  PaintBox.Width:=ProjectorMaskW;
  PaintBox.Height:=ProjectorMaskH;
end;

procedure TProjectorMaskFrm.EditChange(Sender: TObject);
begin
  with ProjectorMask do begin
    TopLeftPt.X:=Round(TopLeftXEdit.Value);
    TopLeftPt.Y:=Round(TopLeftYEdit.Value);
    TopRightPt.X:=Round(TopRightXEdit.Value);
    TopRightPt.Y:=Round(TopRightYEdit.Value);
    BottomLeftPt.X:=Round(BottomLeftXEdit.Value);
    BottomLeftPt.Y:=Round(BottomLeftYEdit.Value);
    BottomRightPt.X:=Round(BottomRightXEdit.Value);
    BottomRightPt.Y:=Round(BottomRightYEdit.Value);
    CenterPt.X:=Round(CenterXEdit.Value);
    CenterPt.Y:=Round(CenterYEdit.Value);
    CenterRadius:=Round(CenterREdit.Value);
  end;
  ProjectorMask.DrawBmp;
  PaintBoxPaint(nil);
  DrawMaskBtnClick(nil);
end;

procedure TProjectorMaskFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TProjectorMaskFrm.DrawMaskBtnClick(Sender: TObject);
begin
  ProjectorMask.FillBmp;
  ProjectorMask.UpdateTexture;
end;

procedure TProjectorMaskFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,ProjectorMask.Bmp);
end;

procedure TProjectorMaskFrm.SaveBtnClick(Sender: TObject);
begin
  ProjectorMask.SaveBmp;
end;

procedure TProjectorMaskFrm.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ProjectorMask.Bmp.Canvas.Brush.Color:=clBlack;
  ProjectorMask.Bmp.Canvas.Brush.Style:=bsSolid;

  if Button=mbRight then ProjectorMask.Bmp.Canvas.FloodFill(X,Y,clBlack,fsBorder)
  else ProjectorMask.Bmp.Canvas.FloodFill(X,Y,clBlack,fsSurface);
  PaintBox.Canvas.Draw(0,0,ProjectorMask.Bmp);
end;

procedure TProjectorMaskFrm.EnableCBClick(Sender: TObject);
begin
  ProjectorMask.Enabled:=EnableCB.Checked;
end;

end.
