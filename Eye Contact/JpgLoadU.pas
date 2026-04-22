unit JpgLoadU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, PBar;

type
  TJpgLoadFrm = class(TForm)
    VideoPB: TAprProgBar;
    FramePB: TAprProgBar;
    CancelBtn: TBitBtn;
    procedure FormActivate(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    Activated : Boolean;

    procedure VideoLoaded(Sender:TObject;Count,Total:Integer);
    procedure FrameLoaded(Sender:TObject;Count,Total:Integer;var Cancelled:Boolean);
    procedure JpgsLoaded(Sender:TObject);

  public
    procedure Initialize;
  end;

var
  JpgLoadFrm: TJpgLoadFrm;

implementation

{$R *.dfm}

uses
  TilerU, Routines;

procedure TJpgLoadFrm.Initialize;
begin
  Activated:=False;
  Tiler.OnVideoLoaded:=VideoLoaded;
  Tiler.OnFrameLoaded:=FrameLoaded;
  Tiler.OnDoneLoad:=JpgsLoaded;
  VideoPB.Value:=0;
  FramePB.Value:=0;
end;

procedure TJpgLoadFrm.FormActivate(Sender: TObject);
begin
  if not Activated then begin
    Activated:=True;
    Tiler.AbleToLoadJpgs;
  end;
end;

procedure TJpgLoadFrm.CancelBtnClick(Sender: TObject);
begin
//
end;

procedure TJpgLoadFrm.VideoLoaded(Sender:TObject;Count,Total:Integer);
begin
  VideoPB.Max:=Total;
  VideoPB.Value:=Count;
  VideoPB.Title:='Video #'+IntToStr(Count)+' of '+IntToStr(Total);
  VideoPB.Paint;
end;

procedure TJpgLoadFrm.FrameLoaded(Sender:TObject;Count,Total:Integer;var Cancelled:Boolean);
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
    if Cancelled then PostMessage(Handle,WM_CLOSE,0,0);
  end;
  if Tiler.JpgsLoaded then Close;
end;

procedure TJpgLoadFrm.JpgsLoaded;
begin
  PostMessage(Handle,WM_CLOSE,0,0);
end;

procedure TJpgLoadFrm.FormDestroy(Sender: TObject);
begin
  Tiler.OnFrameLoaded:=nil;
  Tiler.OnVideoLoaded:=nil;
  Tiler.OnDoneLoad:=nil;
end;

end.
                                    

