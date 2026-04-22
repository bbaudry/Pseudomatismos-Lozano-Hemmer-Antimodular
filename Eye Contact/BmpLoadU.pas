unit BmpLoadU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, PBar;

type
  TBmpLoadFrm = class(TForm)
    VideoPB: TAprProgBar;
    CancelBtn: TBitBtn;
    procedure FormActivate(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    Activated : Boolean;

    procedure VideoLoaded(Sender:TObject;Count,Total:Integer);
    procedure BmpsLoaded(Sender:TObject);

  public
    procedure Initialize;
  end;

var
  BmpLoadFrm: TBmpLoadFrm;

implementation

{$R *.dfm}

uses
  TilerU, Routines;

procedure TBmpLoadFrm.Initialize;
begin
  Activated:=False;
  Tiler.OnVideoLoaded:=VideoLoaded;
  Tiler.OnDoneLoad:=BmpsLoaded;
  VideoPB.Value:=0;
end;

procedure TBmpLoadFrm.FormActivate(Sender: TObject);
begin
  if not Activated then begin
    Activated:=True;
    Tiler.AbleToLoadVideos;
  end;
end;

procedure TBmpLoadFrm.CancelBtnClick(Sender: TObject);
begin
  Tiler.LoadCancelled:=True;
  Close;
end;

procedure TBmpLoadFrm.VideoLoaded(Sender:TObject;Count,Total:Integer);
begin
  VideoPB.Max:=Total;
  VideoPB.Value:=Count;
  VideoPB.Title:='Video #'+IntToStr(Count)+' of '+IntToStr(Total);
  VideoPB.Paint;
  Application.ProcessMessages;
  if Tiler.VideosLoaded then Close;
end;

procedure TBmpLoadFrm.BmpsLoaded;
begin
  PostMessage(Handle,WM_CLOSE,0,0);
end;

procedure TBmpLoadFrm.FormDestroy(Sender: TObject);
begin
  Tiler.OnFrameLoaded:=nil;
  Tiler.OnVideoLoaded:=nil;
  Tiler.OnDoneLoad:=nil;
end;

procedure TBmpLoadFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Tiler.LoadCancelled:=True;
  Action:=caFree;
end;

end.
                                    

