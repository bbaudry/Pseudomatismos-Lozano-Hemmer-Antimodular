unit MouseTestFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AprSpin, StdCtrls, ExtCtrls, ComCtrls, Global, ShadTrkr;

type
  TMouseTgt = record
    X,Y : Integer;
    Bmp : TBitmap;
  end;

  TMouseTestFrm = class(TForm)
    PaintBox: TPaintBox;
    TabControl: TTabControl;
    Label2: TLabel;
    TargetsEdit: TAprSpinEdit;
    Label3: TLabel;
    AprSpinEdit2: TAprSpinEdit;
    ScrollBar: TScrollBar;
    Button1: TButton;
    ObstacleSB: TScrollBar;
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ScrollBarChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ObstacleSBChange(Sender: TObject);

  private
    MouseTgt  : array[1..MaxTargets] of TMouseTgt;
    MouseTgts : Integer;

    Bmp : TBitmap;

    procedure NewCameraFrame(Sender:TObject);

  public
    procedure Initialize;
  end;

var
  MouseTestFrm: TMouseTestFrm;

implementation

{$R *.dfm}

uses
  CameraU, BlobFindU, CloudU, Routines, BmpUtils;

procedure TMouseTestFrm.Initialize;
var
  FileName : String;
  I        : Integer;
begin
  Tracker.InitForMouseTest;
  
  Bmp:=TBitmap.Create;
  FileName:=Path+'Mouse.bmp';
  if FileExists(FileName) then Bmp.LoadFromFile(Path+'Mouse.bmp')
  else begin
    Bmp.Width:=MaxImageW;
    Bmp.Height:=MaxImageH;
    ClearBmp(Bmp,clWhite);
  end;
  Bmp.PixelFormat:=pf24Bit;

  MouseTgts:=1;

  for I:=1 to MaxBlobs do begin
    MouseTgt[I].Bmp:=TBitmap.Create;
    MouseTgt[I].Bmp.PixelFormat:=pf24Bit;
  end;

  MouseTgt[1].Bmp.Assign(Bmp);
  MouseTgt[1].Y:=MaxImageH-Bmp.Height+(Bmp.Height shr 3);

  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TMouseTestFrm.FormDestroy(Sender: TObject);
var
  I : Integer;
begin
  Camera.OnNewFrame:=nil;
  if Assigned(Bmp) then Bmp.Free;
  for I:=1 to MaxBlobs do begin
    if Assigned(MouseTgt[I].Bmp) then MouseTgt[I].Bmp.Free;
  end;
end;

procedure TMouseTestFrm.NewCameraFrame(Sender: TObject);
var
  MousePt : TPoint;
  I       : Integer;
begin
  ClearBmp(Camera.Bmp,clWhite);
  for I:=1 to MouseTgts do begin
    Camera.Bmp.Canvas.Draw(MouseTgt[I].X,MouseTgt[I].Y,MouseTgt[I].Bmp);
  end;

  Tracker.Update(Camera.Bmp);
  Tracker.DrawChains(Camera.Bmp);

  PaintBox.Canvas.Draw(0,0,Camera.Bmp);
//  PaintBox.Canvas.Draw(0,0,MouseTgt[1].Bmp);
//  PaintBox.Canvas.Draw(300,0,Bmp);
end;

procedure TMouseTestFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TMouseTestFrm.ScrollBarChange(Sender: TObject);
var
  T : Integer;
begin
  T:=TabControl.TabIndex+1;
  MouseTgt[T].X:=ScrollBar.Position-(MouseTgt[T].Bmp.Width shr 1);
end;

procedure TMouseTestFrm.Button1Click(Sender: TObject);
begin
  Cloud.SaveSmokeTexture:=True;
end;

procedure TMouseTestFrm.ObstacleSBChange(Sender: TObject);
begin
  Cloud.ObstacleX:=ObstacleSB.Position;
end;

end.
