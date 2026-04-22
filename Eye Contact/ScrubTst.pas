unit ScrubTst;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AprSpin, StdCtrls, ExtCtrls, VCellU, AprChkBx;

type
  TScrubTestFrm = class(TForm)
    FramePB: TPaintBox;
    VelocityPB: TPaintBox;
    VideoPB: TPaintBox;
    VideoLbl: TLabel;
    VideoEdit: TAprSpinEdit;
    Timer: TTimer;
    TriggeredCB: TAprCheckBox;
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FramePBPaint(Sender: TObject);
    procedure VelocityPBPaint(Sender: TObject);
    procedure VideoEditChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure TriggeredCBClick(Sender: TObject);

  private
    FrameBmp    : TBitmap;
    VelocityBmp : TBitmap;
    VideoBmp    : TBitmap;
    Cell        : TVideoCell;

  public
    procedure Initialize;
  end;

var
  ScrubTestFrm: TScrubTestFrm;

implementation

{$R *.dfm}

uses
  TilerU;

procedure TScrubTestFrm.Initialize;
const
  Border = 10;
var
  Sum : Integer;
begin
  VideoEdit.Max:=Tiler.Videos;
  VideoPB.Width:=Tiler.CellW;
  VideoPB.Height:=Tiler.CellH;
  Sum:=VideoPB.Left+VideoPB.Width+Border;
  if Sum>ClientWidth then ClientWidth:=Sum;
  Sum:=VideoPB.Top+VideoPB.Height+Border;
  if Sum>ClientHeight then ClientHeight:=Sum;

  FrameBmp:=TBitmap.Create;
  FrameBmp.Width:=FramePB.Width;
  FrameBmp.Height:=FramePB.Height;
  VelocityBmp:=TBitmap.Create;
  VelocityBmp.Width:=VelocityPB.Width;
  VelocityBmp.Height:=VelocityPB.Height;
  VideoBmp:=TBitmap.Create;
  VideoBmp.Width:=VideoPB.Width;
  VideoBmp.Height:=VideoPB.Height;

  Cell:=TVideoCell.Create;
  Cell.X:=0;
  Cell.Y:=0;
  Cell.W:=Tiler.CellW;
  Cell.H:=Tiler.CellH;
  VideoEditChange(nil);
  Timer.Enabled:=True;
end;

procedure TScrubTestFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(FrameBmp) then FrameBmp.Free;
  if Assigned(VelocityBmp) then VelocityBmp.Free;
  if Assigned(VideoBmp) then VideoBmp.Free;
  if Assigned(Cell) then Cell.Free;
end;

procedure TScrubTestFrm.FramePBPaint(Sender: TObject);
begin
  FramePB.Canvas.Draw(0,0,FrameBmp);
end;

procedure TScrubTestFrm.VelocityPBPaint(Sender: TObject);
begin
  VelocityPB.Canvas.Draw(0,0,VelocityBmp);
end;

procedure TScrubTestFrm.VideoEditChange(Sender: TObject);
var
  V : Integer;
begin
  V:=Round(VideoEdit.Value);
  Cell.Video:=@Tiler.Video[V];
  Cell.InitForTracking;
  TriggeredCB.Checked:=False;
end;

procedure TScrubTestFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TScrubTestFrm.TimerTimer(Sender: TObject);
begin
  Cell.UpdateScrubbing(GetTickCount);

  Cell.DrawOnBmp(VideoBmp);
  VideoPB.Canvas.Draw(0,0,VideoBmp);

  Cell.DrawFrameBmp(FrameBmp);
  FramePB.Canvas.Draw(0,0,FrameBmp);

  Cell.DrawVelocityBmp(VelocityBmp);
  VelocityPB.Canvas.Draw(0,0,VelocityBmp);
end;

procedure TScrubTestFrm.TriggeredCBClick(Sender: TObject);
begin
  if Cell.ScrubMode=smEyeContact then begin
    if Random(100)>50 then Cell.ScrubIntro
    else Cell.ScrubExtro;
  end
  else Cell.ScrubEyeContact;
end;

end.
