unit CropWindowFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, AprChkBx, Global, Buttons;

type
  TCropWindowFrm = class(TForm)
    CameraPB: TPaintBox;
    AspectRatioCB: TAprCheckBox;
    SmallPB: TPaintBox;
    Memo: TMemo;
    FlipImageCB: TAprCheckBox;
    CamSettingsBtn: TBitBtn;
    procedure FormDestroy(Sender: TObject);
    procedure CameraPBMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CameraPBMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure AspectRatioCBClick(Sender: TObject);
    procedure FlipImageCBClick(Sender: TObject);
    procedure CamSettingsBtnClick(Sender: TObject);

  private
    Bmp           : TBitmap;
    DrawingWindow : Boolean;
    MouseWindow   : TCropWindow;

    procedure NewCameraFrame(Sender:TObject);
    procedure UpdateMouseWindow(X,Y:Integer);

  public
    procedure Initialize;

  end;

var
  CropWindowFrm: TCropWindowFrm;

implementation

{$R *.dfm}

uses
  CameraU;

procedure TCropWindowFrm.Initialize;
begin
  FlipImageCB.Checked:=Camera.FlipImage;
  with Camera.CropWindow do AspectRatioCB.Checked:=(H/W)=(3/4);
  DrawingWindow:=False;
  Bmp:=TBitmap.Create;
  Camera.InitBmp(Bmp);
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TCropWindowFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TCropWindowFrm.NewCameraFrame(Sender:TObject);
begin
  Bmp.Canvas.Draw(0,0,Camera.Bmp);

// current crop window
  Bmp.Canvas.Brush.Style:=bsClear;
  Bmp.Canvas.Pen.Color:=clGreen;
  Bmp.Canvas.Pen.Style:=psSolid;
  with Camera.CropWindow do Bmp.Canvas.Rectangle(X,Y,X+W,Y+H);

// mouse crop window
  if DrawingWindow then begin
    Bmp.Canvas.Pen.Color:=clYellow;
    Bmp.Canvas.Pen.Style:=psDash;
    with MouseWindow do Bmp.Canvas.Rectangle(X,Y,X+W,Y+H);
  end;

  CameraPB.Canvas.Draw(0,0,Bmp);
  SmallPB.Canvas.Draw(0,0,Camera.SmallBmp);
end;

procedure TCropWindowFrm.UpdateMouseWindow(X,Y:Integer);
var
  OldWindow : TCropWindow;
begin
  OldWindow:=MouseWindow;
  if X<MouseWindow.X then begin
    MouseWindow.X:=X;
    MouseWindow.W:=OldWindow.X-X+1;
  end
  else begin
    MouseWindow.W:=X-MouseWindow.X+1;
  end;
  if Y<MouseWindow.Y then begin
    MouseWindow.Y:=Y;
    MouseWindow.H:=OldWindow.Y-Y+1;
  end
  else begin
    MouseWindow.H:=Y-MouseWindow.Y+1;
  end;
  if AspectRatioCB.Checked then begin
    MouseWindow.H:=Round(MouseWindow.W*0.75);
  end;
end;

procedure TCropWindowFrm.CameraPBMouseDown(Sender: TObject;Button:TMouseButton;
                                           Shift: TShiftState; X, Y: Integer);
begin
  if DrawingWindow then begin
    DrawingWindow:=False;
    UpdateMouseWindow(X,Y);
    Camera.CropWindow:=MouseWindow;
  end
  else begin
    DrawingWindow:=True;
    MouseWindow.X:=X;
    MouseWindow.W:=1;
    MouseWindow.Y:=Y;
    MouseWindow.H:=1;
  end;
end;

procedure TCropWindowFrm.CameraPBMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if DrawingWindow then UpdateMouseWindow(X,Y);
end;

procedure TCropWindowFrm.AspectRatioCBClick(Sender: TObject);
begin
  if AspectRatioCB.Checked then begin
    MouseWindow.H:=Round(MouseWindow.W*0.75);
    Camera.CropWindow.H:=Round(Camera.CropWindow.W*0.75);
  end;
end;

procedure TCropWindowFrm.FlipImageCBClick(Sender: TObject);
begin
  Camera.FlipImage:=FlipImageCB.Checked;
end;

procedure TCropWindowFrm.CamSettingsBtnClick(Sender: TObject);
begin
  Camera.ShowCameraSettingsFrm(False);
end;

end.
