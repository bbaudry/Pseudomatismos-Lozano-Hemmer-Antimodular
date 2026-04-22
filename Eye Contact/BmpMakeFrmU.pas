unit BmpMakeFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, PBar;

type
  TBmpMakeFrm = class(TForm)
    VideoPB: TAprProgBar;
    FramePB: TAprProgBar;
    CancelBtn: TBitBtn;
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    Activated : Boolean;
    BmpW,BmpH : Integer;

    procedure VideoLoaded(Sender:TObject;Count,Total:Integer);
    procedure FrameLoaded(Sender:TObject;Count,Total:Integer);
    procedure BmpMakerDone(Sender:TObject);

  public
    procedure Initialize(W,H:Integer;Overwrite:Boolean);

  end;

var
  BmpMakeFrm: TBmpMakeFrm;

implementation

{$R *.dfm}

uses
  BmpMakerU, Routines;

procedure TBmpMakeFrm.Initialize(W,H:Integer;Overwrite:Boolean);
begin
  Activated:=False;
  BmpW:=W;
  BmpH:=H;
  BmpMaker:=TBmpMaker.Create;
  BmpMaker.OnLoadVideo:=VideoLoaded;
  BmpMaker.OnLoadFrame:=FrameLoaded;
  BmpMaker.OnDoneMake:=BmpMakerDone;
  BmpMaker.Overwrite:=Overwrite;
end;

procedure TBmpMakeFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(BmpMaker) then BmpMaker.Free;
end;

procedure TBmpMakeFrm.FormActivate(Sender: TObject);
var
  VideoFolder : String;
begin
  if not Activated then begin
    Activated:=True;
    VideoFolder:=Path+'Movs';
    BmpMaker.MakeBmpsFromAllMoviesInFolder(VideoFolder,BmpW,BmpH);
  end;
end;

procedure TBmpMakeFrm.VideoLoaded(Sender:TObject;Count,Total:Integer);
begin
  VideoPB.Max:=Total;
  VideoPB.Value:=Count;
  VideoPB.Title:='Video #'+IntToStr(Count)+' of '+IntToStr(Total);
  VideoPB.Paint;
end;

procedure TBmpMakeFrm.FrameLoaded(Sender:TObject;Count,Total:Integer);
var
  MousePt : TPoint;
begin
  FramePB.Max:=Total;
  FramePB.Value:=Count;
  FramePB.Title:='Frame #'+IntToStr(Count)+' of '+IntToStr(Total);
  FramePB.Paint;
  GetCursorPos(MousePt);
  MousePt:=CancelBtn.ScreenToClient(MousePt);
  if (MousePt.X>=0) and (MousePt.X<CancelBtn.Width) and
     (MousePt.Y>=0) and (MousePt.Y<CancelBtn.Height) then
  begin
    BmpMaker.Cancelled:=LeftMouseBtnDown;
    if BmpMaker.Cancelled then Close;
  end;
  Application.ProcessMessages;
end;

procedure TBmpMakeFrm.BmpMakerDone(Sender:TObject);
begin
  PostMessage(Handle,WM_CLOSE,0,0);
end;

procedure TBmpMakeFrm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TBmpMakeFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  BmpMaker.Cancelled:=True;
  Action:=caFree;
end;

end.
