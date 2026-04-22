unit DisplayCfg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, AprSpin, StdCtrls, Buttons, AprChkBx;

type
  TDisplaySetupFrm = class(TForm)
    WidthLbl: TLabel;
    WidthEdit: TAprSpinEdit;
    RowsLbl: TLabel;
    ColumnsLbl: TLabel;
    ColumnsEdit: TAprSpinEdit;
    RowsEdit: TAprSpinEdit;
    HeightLbl: TLabel;
    HeightEdit: TAprSpinEdit;
    MakeBmpsBtn: TBitBtn;
    DoneBtn: TButton;
    OverwriteCB: TAprCheckBox;
    procedure MakeBmpsBtnClick(Sender: TObject);
    procedure ColumnsEditChange(Sender: TObject);
    procedure RowsEditChange(Sender: TObject);
    procedure WidthEditChange(Sender: TObject);
    procedure HeightEditChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DoneBtnClick(Sender: TObject);

  private

  public
    procedure Initialize;

  end;

var
  DisplaySetupFrm: TDisplaySetupFrm;

implementation

{$R *.dfm}

uses
  Global, CameraU, BmpMakeFrmU, TilerU, CfgFile, BmpMakerU;

procedure TDisplaySetupFrm.Initialize;
begin
  ColumnsEdit.Value:=Tiler.XCells;
  RowsEdit.Value:=Tiler.YCells;
  WidthEdit.Value:=Tiler.CellW;
  HeightEdit.Value:=Tiler.CellH;
end;

procedure TDisplaySetupFrm.MakeBmpsBtnClick(Sender: TObject);
begin
  BmpMakeFrm:=TBmpMakeFrm.Create(Application);
  try
    BmpMakeFrm.Initialize(Tiler.CellW,Tiler.CellH,OverwriteCB.Checked);
    BmpMakeFrm.ShowModal;
  finally
    BmpMakeFrm.Free;
  end;
end;

procedure TDisplaySetupFrm.ColumnsEditChange(Sender: TObject);
begin
  Tiler.XCells:=Round(ColumnsEdit.Value);
  Tiler.VideosLoaded:=False;
end;

procedure TDisplaySetupFrm.RowsEditChange(Sender: TObject);
begin
  Tiler.YCells:=Round(RowsEdit.Value);
  Tiler.VideosLoaded:=False;
end;

procedure TDisplaySetupFrm.WidthEditChange(Sender: TObject);
begin
  Tiler.CellW:=Round(WidthEdit.Value);
  Tiler.VideosLoaded:=False;
end;

procedure TDisplaySetupFrm.HeightEditChange(Sender: TObject);
begin
  Tiler.CellH:=Round(HeightEdit.Value);
  Tiler.VideosLoaded:=False;
end;

procedure TDisplaySetupFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TDisplaySetupFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveCfgFile;
end;

procedure TDisplaySetupFrm.DoneBtnClick(Sender: TObject);
begin
  Close;
end;

end.
