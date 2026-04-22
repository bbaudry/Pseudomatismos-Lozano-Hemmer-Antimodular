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
    AutoCalibrateItem: TMenuItem;
    Dash2: TMenuItem;
    ViewTrackingItem: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TakeBackGndItemClick(Sender: TObject);
    procedure ExitItemClick(Sender: TObject);
    procedure ShowTriggeredCellsItemClick(Sender: TObject);
    procedure SaveToFileItemClick(Sender: TObject);
    procedure BackGndTimerTimer(Sender: TObject);
    procedure CameraSettingsItemClick(Sender: TObject);
    procedure AutoCalibrateItemClick(Sender: TObject);
    procedure ViewTrackingItemClick(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure NewCameraFrame(Sender:TObject);

  public
    procedure Initialize;
  end;

var
  RunFrm: TRunFrm;

implementation

{$R *.dfm}

uses
  Routines, BmpUtils, CameraU, TrackerU, TilerU, Main, SegmenterU, Global,
  CalibrateFrmU, TrackingCfgFrmU;

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
  Bmp.PixelFormat:=pf24Bit;
  Bmp.Width:=Tiler.CellW*Tiler.XCells;
  Bmp.Height:=Tiler.CellH*Tiler.YCells;
  ClearBmp(Bmp,clBlack);

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
MainFrm.StopWatch.Start(1);
  Tiler.SyncWithTracker;
MainFrm.StopWatch.Stop(1);
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
MainFrm.StopWatch.Start(5);

MainFrm.StopWatch.Start(2);
  Tiler.UpdateScrubbing;
MainFrm.StopWatch.Stop(2);

MainFrm.StopWatch.Start(3);
  Tiler.DrawOnBmp(Bmp);
MainFrm.StopWatch.Stop(3);

  if ShowTriggeredCellsItem.Checked then begin
    Tiler.ShowEyeContactCells(Bmp);
  end;

MainFrm.StopWatch.Start(4);
  BitBlt(Canvas.Handle,0,0,ClientWidth,ClientHeight,Bmp.Canvas.Handle,0,0,SrcCopy);
//  Canvas.Draw(0,0,Bmp);
MainFrm.StopWatch.Stop(4);

MainFrm.StopWatch.Stop(5);
end;

procedure TRunFrm.SaveToFileItemClick(Sender: TObject);
begin
  Bmp.SaveToFile('c:\big.bmp');
end;

procedure TRunFrm.TakeBackGndItemClick(Sender: TObject);
begin
  BackGndTimer.Enabled:=True;
end;

procedure TRunFrm.BackGndTimerTimer(Sender: TObject);
begin
  BackGndTimer.Enabled:=False;
  Segmenter.ForceAllToBackGnd(Camera.SmallBmp);
end;

procedure TRunFrm.CameraSettingsItemClick(Sender: TObject);
begin
  Camera.ShowCameraPropertyPages;
end;

procedure TRunFrm.AutoCalibrateItemClick(Sender: TObject);
begin
  CalibrateFrm:=TCalibrateFrm.Create(Application);
  try
    CalibrateFrm.Initialize;
    CalibrateFrm.ShowModal;
  finally
    CalibrateFrm.Free;
  end;
end;

procedure TRunFrm.ViewTrackingItemClick(Sender: TObject);
begin
  TrackingCfgFrm:=TTrackingCfgFrm.Create(Application);
  try
    TrackingCfgFrm.Initialize;
    TrackingCfgFrm.ShowModal;
  finally
    TrackingCfgFrm.Free;
  end;
end;

end.


