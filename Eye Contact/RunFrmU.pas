unit RunFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, ThreadU;

type
  TRunFrm = class(TForm)
    Timer: TTimer;
    PopupMenu: TPopupMenu;
    TakeBackGndItem: TMenuItem;
    ShowTriggeredCellsItem: TMenuItem;
    N1: TMenuItem;
    ExitItem: TMenuItem;
    SaveToFileItem: TMenuItem;
    BackGndTimer: TTimer;
    CameraSettingsItem: TMenuItem;
    N2: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TakeBackGndItemClick(Sender: TObject);
    procedure ExitItemClick(Sender: TObject);
    procedure ShowTriggeredCellsItemClick(Sender: TObject);
    procedure SaveToFileItemClick(Sender: TObject);
    procedure BackGndTimerTimer(Sender: TObject);
    procedure CameraSettingsItemClick(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure NewCameraFrame(Sender:TObject);
    procedure ThreadCallBack(var Msg:TMessage); message CallBackMsg;

  public
    procedure Initialize;
  end;

var
  RunFrm: TRunFrm;

implementation

{$R *.dfm}

uses
  Routines, BmpUtils, CameraU, TrackerU, TilerU, Main, PixelBackGndFind,
  CellBackGndFind, Global;

procedure TRunFrm.Initialize;
begin
  ControlStyle:=ControlStyle + [csOpaque];
  HideTaskBar;
  Cursor:=crNone;
  BorderStyle:=bsNone;
  Left:=0;
  Top:=0;
  Width:=Screen.Width;
  Height:=Screen.Height;
  Bmp:=TBitmap.Create;
  Bmp.Width:=Tiler.CellW*Tiler.XCells;
  Bmp.Height:=Tiler.CellH*Tiler.YCells;
  Bmp.PixelFormat:=pf24Bit;
  ClearBmp(Bmp,clBlack);

  Camera.InitForTracking;
  PixelBackGndFinder.InitForTracking;
  CellBackGndFinder.InitForTracking;
  Tracker.InitForTracking;
  Tiler.InitForTracking;
  
  Camera.OnNewFrame:=NewCameraFrame;
  Timer.Enabled:=True;
end;

procedure TRunFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ShowTaskBar;
  Cursor:=crDefault;
end;

procedure TRunFrm.NewCameraFrame(Sender:TObject);
begin
  Camera.DrawSubtractedBmp;
  Case AutoBackGndMode of
    amNone  : ;
    amPixel : PixelBackGndFinder.Update(Camera.SmallBmp);
    amCell  : CellBackGndFinder.Update(Camera.SmallBmp);
  end;
  Tracker.Update(Camera.SubtractedBmp);
  Tiler.SyncWithTracker;
end;

procedure TRunFrm.FormClick(Sender: TObject);
begin
  Close;
end;

procedure TRunFrm.ExitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TRunFrm.ShowTriggeredCellsItemClick(Sender: TObject);
begin
  ShowTriggeredCellsItem.Checked:=not ShowTriggeredCellsItem.Checked;
end;

procedure TRunFrm.TimerTimer(Sender: TObject);
begin
//MainFrm.Zprof.Mark(1,True);
  Tiler.UpdateScrubbing;
//MainFrm.ZProf.Mark(2,True);
  Tiler.DrawOnBmp(Bmp);
//MainFrm.ZProf.Mark(2,False);

  if ShowTriggeredCellsItem.Checked then begin
    Tiler.ShowEyeContactCells(Bmp);
  end;
//MainFrm.ZProf.Mark(3,True);
  Canvas.Draw(0,0,Bmp);
//MainFrm.ZProf.Mark(3,False);

//MainFrm.ZProf.Mark(1,False);

//  BitBlt(Canvas.Handle,0,0,Bmp.Width,Bmp.Height,Bmp.Handle,0,0,SRCCOPY);
end;

procedure TRunFrm.SaveToFileItemClick(Sender: TObject);
begin
  Bmp.SaveToFile('c:\big.bmp');
end;

procedure TRunFrm.ThreadCallBack(var Msg:TMessage);
begin
  Tiler.UpdateScrubbing;
  Tiler.DrawOnBmp(Bmp);
  if ShowTriggeredCellsItem.Checked then begin
    Tiler.ShowEyeContactCells(Bmp);
  end;
  Canvas.Draw(0,0,Bmp);
  PostThreadMessage(Thread.ThreadID,DoneCallBackMsg,0,0);
end;

procedure TRunFrm.TakeBackGndItemClick(Sender: TObject);
begin
  BackGndTimer.Enabled:=True;
end;

procedure TRunFrm.BackGndTimerTimer(Sender: TObject);
begin
  BackGndTimer.Enabled:=False;
  Camera.BackGndBmp.Assign(Camera.SmallBmp);
  ClearBmp(Bmp,clWhite);
  Canvas.Draw(0,0,Bmp);
  Sleep(100);
  ClearBmp(Bmp,clBlack);
end;

procedure TRunFrm.CameraSettingsItemClick(Sender: TObject);
begin
  Camera.ShowCameraPropertyPages;
end;

end.


