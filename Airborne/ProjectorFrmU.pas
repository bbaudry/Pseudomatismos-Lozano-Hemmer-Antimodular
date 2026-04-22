unit ProjectorFrmU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Global;

type
  TProjectorCalFrm = class(TForm)
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);

  private
    Bmp    : TBitmap;
    Window : TWindow;

  public
    procedure DrawBmp;
    procedure Initialize(iWindow:TWindow);
    procedure UpdateTracking;
    procedure WhiteOut;
  end;

var
  ProjectorCalFrm: TProjectorCalFrm;

implementation

{$R *.DFM}

uses
  BmpUtils, CameraU, ProjectorU, Routines;

procedure TProjectorCalFrm.Initialize(iWindow:TWindow);
begin
  Window:=iWindow;
  BorderStyle:=bsNone;
  Cursor:=crNone;

  Bmp:=TBitmap.Create;
  Bmp.PixelFormat:=pf24Bit;
  Bmp.Width:=Window.Width;
  Bmp.Height:=Window.Height;

  Bmp.Canvas.Pen.Width:=3;
  Bmp.Canvas.Brush.Style:=bsClear;
  Bmp.Canvas.Font.Color:=clWhite;
  Bmp.Canvas.Font.Size:=9;
  Bmp.Canvas.Font.Style:=Bmp.Canvas.Font.Style+[fsBold];
end;

procedure TProjectorCalFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TProjectorCalFrm.UpdateTracking;
begin
  DrawBmp;
  Canvas.Draw(0,0,Bmp);
end;

procedure TProjectorCalFrm.DrawBmp;
var
  Txt : String;
begin
end;

procedure TProjectorCalFrm.WhiteOut;
begin
  ClearBmp(Bmp,clWhite);
  Canvas.Draw(0,0,Bmp);
end;

procedure TProjectorCalFrm.FormActivate(Sender: TObject);
begin
  PlaceFormInWindow(Self,Window);
  Cursor:=crNone;
end;

end.
