unit TrackViewFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TTrackViewFrm = class(TForm)
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private
    OldCallBack : TNotifyEvent;

  public
    procedure NewCameraFrame(Sender:TObject);
    procedure Initialize;
    procedure Update;
  end;

var
  TrackViewFrm: TTrackViewFrm;

implementation

{$R *.dfm}

uses
  CameraU, BlobFindU, MenuFrmU;

procedure TTrackViewFrm.Initialize;
begin
  Cursor:=crNone;
//  OldCallBack:=Camera.OnNewFrame;
//  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TTrackViewFrm.NewCameraFrame(Sender: TObject);
begin
//  OldCallBack;
//  Canvas.StretchDraw(ClientRect,Camera.Bmp);
end;

procedure TTrackViewFrm.FormDestroy(Sender: TObject);
begin
//  Camera.OnNewFrame:=OldCallBack;
end;

procedure TTrackViewFrm.Update;
begin
  BlobFinder.DrawStrips(Camera.Bmp);
  Canvas.StretchDraw(ClientRect,Camera.Bmp);
end;

procedure TTrackViewFrm.FormActivate(Sender: TObject);
begin
  Left:=0; Top:=0;
  Width:=Screen.Width;
  Height:=Screen.Height;
end;

procedure TTrackViewFrm.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  MousePt : TPoint;
begin
  MenuFrm.Show;
  MousePt.X:=X;
  MousePt.Y:=Y;
  MousePt:=ClientToScreen(MousePt);
  MenuFrm.Left:=MousePt.X-(MenuFrm.Width div 2);
  MenuFrm.Top:=MousePt.Y-(MenuFrm.Height div 2);
  Cursor:=crDefault;
  Screen.Cursor:=crDefault;
end;

end.
