unit CropWindowFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, AprChkBx, Global, Buttons;

type
  TCropWindowFrm = class(TForm)
    CameraPB: TPaintBox;
    SmallPB: TPaintBox;
    Memo: TMemo;
    FlipImageCB: TAprCheckBox;
    CamSettingsBtn: TBitBtn;
    MirrorImageCB: TAprCheckBox;
    procedure FormDestroy(Sender: TObject);
    procedure CameraPBMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CameraPBMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FlipImageCBClick(Sender: TObject);
    procedure CamSettingsBtnClick(Sender: TObject);
    procedure MirrorImageCBClick(Sender: TObject);
    procedure SmallPBMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
    Bmp           : TBitmap;
    OrientedBmp   : TBitmap;
    DrawingWindow : Boolean;
    MouseWindow   : TCropWindow;
    StartTime     : DWord;
    MousePt       : TPoint;
    SmallMousePt  : TPoint;

    MouseX1,MouseY1 : Integer;
    MouseX2,MouseY2 : Integer;

    procedure NewCameraFrame(Sender:TObject);
    procedure UpdateMouseWindow(X,Y:Integer);

    procedure ClipMouseWindow;
    procedure FixMouseWindowX;
    procedure FixMouseWindowY;

  public
    procedure Initialize;

  end;

var
  CropWindowFrm: TCropWindowFrm;

implementation

{$R *.dfm}

uses
  CameraU, BmpUtils, Main, Routines;

procedure TCropWindowFrm.Initialize;
begin
  MousePt.X:=MaxImageW div 2;
  MousePt.Y:=MaxImageH div 2;

  SmallMousePt:=Camera.XYToSmallXY(MousePt.X,MousePt.Y);

  RunMode:=rmNone;
  FlipImageCB.Checked:=Camera.FlipImage;
  MirrorImageCB.Checked:=Camera.MirrorImage;
  DrawingWindow:=False;
  Bmp:=TBitmap.Create;
  Camera.InitBmp(Bmp);
  OrientedBmp:=TBitmap.Create;
  Camera.InitBmp(OrientedBmp);
  Camera.OnNewFrame:=NewCameraFrame;
  StartTime:=GetTickCount;
end;

procedure TCropWindowFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
  if Assigned(Bmp) then Bmp.Free;
  RunMode:=rmRunning;
end;

procedure TCropWindowFrm.NewCameraFrame(Sender:TObject);
begin
  OrientBmp(Camera.Bmp,Bmp,Camera.FlipImage,Camera.MirrorImage);

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
  DrawXHairs(Bmp,MousePt.X,MousePt.Y,5);
  DrawXHairs(Camera.SmallBmp,SmallMousePt.X,SmallMousePt.Y,3);
  CameraPB.Canvas.Draw(0,0,Bmp);
  SmallPB.Canvas.Draw(0,0,Camera.SmallBmp);
end;

{procedure TCropWindowFrm.FoundMouseLimits;
begin
// find the max width we can have when the left edge of the rect = 0
  W:=MouseX1+1;

// find the height this will be
// find the max height of the drawn rectangle from the starting point
  MaxH:=Max(MouseY1+1,Camera.ImageH-MouseY1);

// find the calculated width
  CalcW:=Round(MaxH*Camera.ImageW/Camera.ImageH);

 MinMouseX:=MouseX1+}

procedure TCropWindowFrm.UpdateMouseWindow(X,Y:Integer);
var
  X1,X2,Y1,Y2 : Integer;
  W,CalcW     : Integer;
  H,CalcH     : Integer;
begin
// clip XY to the tracking window
  if X<0 then X:=0
  else if X>=Camera.ImageW then X:=Camera.ImageW-1;
  if Y<0 then Y:=0
  else if Y>=Camera.ImageH then Y:=Camera.ImageH-1;

// set the 2nd mouse point to the passed in X,Y
// the 1st mouse point is where we originally clicked
  MouseX2:=X;
  MouseY2:=Y;

// sort out the two corners
  if MouseX1<MouseX2 then begin
    X1:=MouseX1;
    X2:=MouseX2;
  end
  else begin
    X1:=MouseX2;
    X2:=MouseX1;
  end;
  W:=X2-X1+1;

  if MouseY1<MouseY2 then begin
    Y1:=MouseY1;
    Y2:=MouseY2;
  end
  else begin
    Y1:=MouseY2;
    Y2:=MouseY1;
  end;
  H:=Y2-Y1+1;

// calculate the height based on the width
  CalcH:=Round(W*Camera.ImageH/Camera.ImageW);

// calculate the width based on the height
  CalcW:=Round(H*Camera.ImageW/Camera.ImageH);

// go with the biggest
  if CalcW>W then begin
    MouseWindow.W:=CalcW;
    MouseWindow.H:=H;
  end
  else begin
    MouseWindow.W:=W;
    Mousewindow.H:=CalcH;
  end;

  if MouseX1<MouseX2 then MouseWindow.X:=X1
  else MouseWindow.X:=MouseX1-MouseWindow.W+1;

  if MouseY1<MouseY2 then MouseWindow.Y:=Y1
  else MouseWindow.Y:=MouseY1-MouseWindow.H+1;
  ClipMouseWindow;
end;

procedure TCropWindowFrm.FixMouseWindowX;
begin
// recalculate the W and the X origin
  MouseWindow.W:=Round(MouseWindow.H*Camera.ImageW/Camera.ImageH);
  if MouseX1<MouseX2 then MouseWindow.X:=MouseX1
  else MouseWindow.X:=MouseX1-(MouseWindow.W-1);
end;

procedure TCropWindowFrm.FixMouseWindowY;
begin
// recalculate the H and the Y origin
  MouseWindow.H:=Round(MouseWindow.W*Camera.ImageH/Camera.ImageW);
  if MouseY1<MouseY2 then MouseWindow.Y:=MouseY1
  else MouseWindow.Y:=MouseY1-(MouseWindow.H-1);
end;

procedure TCropWindowFrm.ClipMouseWindow;
begin
// drawing to the left
  if MouseX2<MouseX1 then begin

// check the left edge
    if MouseWindow.X<0 then begin
      MouseWindow.W:=MouseWindow.W+MouseWindow.X;
      MouseWindow.X:=0;
      FixMouseWindowY;
    end;
  end

// drawing to the right
  else begin

// check the right edge
    if (MouseWindow.X+MouseWindow.W)>=Camera.ImageW then begin
      MouseWindow.W:=Camera.ImageW-MouseX1;
      FixMouseWindowY;
    end;
  end;

// drawing to the up
  if MouseY2<MouseY1 then begin

// check the top edge
    if MouseWindow.Y<0 then begin
      MouseWindow.H:=MouseWindow.H+MouseWindow.Y;
      MouseWindow.Y:=0;
      FixMouseWindowX;
    end;
  end

// drawing to the down
  else begin

// check the bottom edge
    if (MouseWindow.Y+MouseWindow.H)>=Camera.ImageH then begin
      MouseWindow.H:=Camera.ImageH-MouseY1;
      FixMouseWindowX;
    end;
  end;
end;

procedure TCropWindowFrm.CameraPBMouseDown(Sender: TObject;Button:TMouseButton;
                                           Shift: TShiftState; X, Y: Integer);
begin
  if (GetTickCount-StartTime)<500 then Exit;

  if X<0 then X:=0
  else if X>=CameraPB.Width then X:=CameraPB.Width-1;

  if Y<0 then X:=0
  else if Y>=CameraPB.Height then Y:=CameraPB.Height-1;

  if DrawingWindow then begin
    DrawingWindow:=False;
    UpdateMouseWindow(X,Y);
    Camera.CropWindow:=MouseWindow;
    Camera.BuildDrawTable;
    Camera.CalculateSmallITable;
  end
  else begin
    DrawingWindow:=True;
    MouseX1:=X;
    MouseY1:=Y;
    UpdateMouseWindow(X,Y);
  end;
end;

procedure TCropWindowFrm.CameraPBMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if DrawingWindow then UpdateMouseWindow(X,Y)
  else begin
    MousePt.X:=X;
    MousePt.Y:=Y;
    SmallMousePt:=Camera.XYToSmallXY(X,Y);
  end;
end;

procedure TCropWindowFrm.CamSettingsBtnClick(Sender: TObject);
begin
  Camera.ShowCameraSettingsFrm;//(False);
end;

procedure TCropWindowFrm.FlipImageCBClick(Sender: TObject);
begin
  Camera.FlipImage:=FlipImageCB.Checked;
  Camera.BuildDrawTable;
end;

procedure TCropWindowFrm.MirrorImageCBClick(Sender: TObject);
begin
  Camera.MirrorImage:=MirrorImageCB.Checked;
  Camera.BuildDrawTable;
end;

procedure TCropWindowFrm.SmallPBMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  SmallMousePt.X:=X;
  SmallMousePt.Y:=Y;
  MousePt:=Camera.SmallXYToXY(X,Y);
end;

end.
