unit DebugMenuFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TDebugMenuFrm = class(TForm)
    RecalBtn: TButton;
    DisplayBtn: TBitBtn;
    TrackingBtn: TBitBtn;
    ViewTrackingBtn: TBitBtn;
    procedure RecalBtnClick(Sender: TObject);
    procedure DisplayBtnClick(Sender: TObject);
    procedure TrackingBtnClick(Sender: TObject);
    procedure ViewTrackingBtnClick(Sender: TObject);

  private

  public
    procedure ShowAt(X,Y:Integer);
  end;

var
  DebugMenuFrm: TDebugMenuFrm;

implementation

{$R *.dfm}

uses
  CameraU, Main, DisplaySetupFrmU, TrackingSetupFrmU, SegmenterSetupFrmU,
  Global, TrackViewFrmU;

procedure TDebugMenuFrm.ShowAt(X,Y:Integer);
begin
  Left:=X-Width div 2;
  Top:=Y-Height div 2;
  FormStyle:=fsStayOnTop;
  ShowModal;
end;

procedure TDebugMenuFrm.DisplayBtnClick(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
  MainFrm.CameraTimer.Enabled:=False;
  DisplaySetupFrm:=TDisplaySetupFrm.Create(Application);
  try
    DisplaySetupFrm.Initialize;
    DisplaySetupFrm.ShowModal;
  finally
    DisplaySetupFrm.Free;
  end;
  MainFrm.Resume;
  Camera.OnNewFrame:=MainFrm.NewCameraFrame;
end;

procedure TDebugMenuFrm.RecalBtnClick(Sender: TObject);
begin
  MainFrm.BackGndTimer.Interval:=10000;
  MainFrm.BackGndTimer.Enabled:=True;
end;

procedure TDebugMenuFrm.TrackingBtnClick(Sender: TObject);
begin
  Case TrackMethod of
    tmBlobs :
      begin
        TrackingSetupFrm:=TTrackingSetupFrm.Create(Application);
        try
          TrackingSetupFrm.Initialize;
          TrackingSetupFrm.ShowModal;
        finally
          TrackingSetupFrm.Free;
        end;
      end;
    tmSegmenter :
      begin
        SegmenterSetupFrm:=TSegmenterSetupFrm.Create(Application);
        try
          SegmenterSetupFrm.Initialize;
          SegmenterSetupFrm.ShowModal;
        finally
          SegmenterSetupFrm.Free;
        end;
      end;
  end;
  Camera.OnNewFrame:=MainFrm.NewCameraFrame;
end;

procedure TDebugMenuFrm.ViewTrackingBtnClick(Sender: TObject);
begin
  ShowTrackViewFrm;
end;

end.
