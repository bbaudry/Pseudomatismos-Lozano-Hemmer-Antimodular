unit JpgMakeFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, PBar;

type
  TJpgMakeFrm = class(TForm)
    VideoPB: TAprProgBar;
    FramePB: TAprProgBar;
    CancelBtn: TBitBtn;
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);

  private
    Activated : Boolean;
    JpgW,JpgH : Integer;

    procedure VideoLoaded(Sender:TObject;Count,Total:Integer);
    procedure FrameLoaded(Sender:TObject;Count,Total:Integer;var Cancelled:Bool);
    procedure JpgMakerDone(Sender:TObject);

  public
    procedure Initialize(W,H:Integer);

  end;

var
  JpgMakeFrm: TJpgMakeFrm;

implementation

{$R *.dfm}

uses
  JpgMakerU, Routines;

procedure TJpgMakeFrm.Initialize(W,H:Integer);
begin
  Activated:=False;
  JpgW:=W;
  JpgH:=H;
  JpgMaker:=TJpgMaker.Create;
  JpgMaker.OnLoadVideo:=VideoLoaded;
  JpgMaker.OnLoadFrame:=FrameLoaded;
  JpgMaker.OnDoneMake:=JpgMakerDone;
end;

procedure TJpgMakeFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(JpgMaker) then JpgMaker.Free;
end;

procedure TJpgMakeFrm.FormActivate(Sender: TObject);
var
  VideoFolder : String;
begin
  if not Activated then begin
    Activated:=True;
    VideoFolder:=Path+'Movs';
    JpgMaker.MakeJpgsFromAllMoviesInFolder(VideoFolder,JpgW,JpgH);
  end;
end;

procedure TJpgMakeFrm.VideoLoaded(Sender:TObject;Count,Total:Integer);
begin
  VideoPB.Max:=Total;
  VideoPB.Value:=Count;
  VideoPB.Title:='Video #'+IntToStr(Count)+' of '+IntToStr(Total);
  VideoPB.Paint;
end;

procedure TJpgMakeFrm.FrameLoaded(Sender:TObject;Count,Total:Integer;var Cancelled:Bool);
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
    Cancelled:=LeftMouseBtnDown;
    if Cancelled then Close;
  end;
end;

procedure TJpgMakeFrm.JpgMakerDone(Sender:TObject);
begin
  PostMessage(Handle,WM_CLOSE,0,0);
end;

end.
