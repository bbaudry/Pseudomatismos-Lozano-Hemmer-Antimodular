unit ProjectorCalFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Global;

type
  TProjectorCalFrm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure DrawBmp;

  public
    MouseX : Integer;
    MouseY : Integer;
    XHairX : Integer;
    XHairY : Integer;

    procedure UpdateFrm;
    procedure PlaceXHairs(X,Y:Integer);

    procedure DrawXHairs(X,Y:Integer);
    procedure Position;
  end;

var
  ProjectorCalFrm : TProjectorCalFrm;

implementation

{$R *.dfm}

uses
  ProjectorU, Routines;

procedure TProjectorCalFrm.FormCreate(Sender:TObject);
begin
  BorderStyle:=bsNone;
  Color:=clBlack;
  Bmp:=TBitmap.Create;
  Bmp.PixelFormat:=pf24Bit;
  Position;
end;

procedure TProjectorCalFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TProjectorCalFrm.DrawXHairs(X,Y:Integer);
begin
  with Bmp.Canvas do begin
    MoveTo(0,Y);
    LineTo(Width,Y);
    MoveTo(X,0);
    LineTo(X,Height);
  end;
end;

procedure TProjectorCalFrm.DrawBmp;
begin
  Bmp.Width:=ClientWidth;
  Bmp.Height:=ClientHeight;
  with Bmp.Canvas do begin
    Brush.Color:=clBlack;
    FillRect(ClientRect);
    Pen.Color:=clYellow;
    DrawXHairs(MouseX,MouseY);
    Pen.Color:=clWhite;
    DrawXHairs(XHairX,XHairY);
  end;
end;

procedure TProjectorCalFrm.FormPaint(Sender: TObject);
begin
  Canvas.Draw(0,0,Bmp);
end;

procedure TProjectorCalFrm.UpdateFrm;
begin
  DrawBmp;
  Canvas.Draw(0,0,Bmp);
end;

procedure TProjectorCalFrm.Position;
begin
  PlaceFormInWindow(Self,Projector.Window);
end;

procedure TProjectorCalFrm.PlaceXHairs(X,Y:Integer);
begin
  XHairX:=X;
  XHairY:=Y;
  UpdateFrm;
end;

end.
