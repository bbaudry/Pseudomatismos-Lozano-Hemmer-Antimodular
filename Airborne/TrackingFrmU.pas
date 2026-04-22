unit TrackingFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AprSpin, StdCtrls, ExtCtrls;

type
  TTrackingFrm = class(TForm)
    PaintBox: TPaintBox;
    Panel2: TPanel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    ScalingEdit: TAprSpinEdit;
    ConsensusEdit: TAprSpinEdit;
    MinSizeEdit: TAprSpinEdit;
    Panel9: TPanel;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label49: TLabel;
    EyesScalingEdit: TAprSpinEdit;
    EyesConsensusEdit: TAprSpinEdit;
    EyesMinSizeEdit: TAprSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ConsensusEditChange(Sender: TObject);
    procedure ScalingEditChange(Sender: TObject);
    procedure MinSizeEditChange(Sender: TObject);
    procedure EyesScalingEditChange(Sender: TObject);
    procedure EyesConsensusEditChange(Sender: TObject);
    procedure EyesMinSizeEditChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PaintBoxPaint(Sender: TObject);

  private
    OldCallBack : TNotifyEvent;
    Bmp         : TBitmap;

    procedure DrawBmp;
    procedure NewCameraFrame(Sender:TObject);

  public

  end;

var
  TrackingFrm: TTrackingFrm;

implementation

{$R *.dfm}

uses
  FaceTrackerU, CameraU;

procedure TTrackingFrm.FormCreate(Sender: TObject);
begin
  Bmp:=TBitmap.Create;
  Bmp.Width:=Camera.Bmp.Width;
  Bmp.Height:=Camera.Bmp.Height;
  Bmp.PixelFormat:=pf24Bit;

  ScalingEdit.Value:=FaceTracker.Scaling;
  ConsensusEdit.Value:=FaceTracker.Consensus;
  MinSizeEdit.Value:=FaceTracker.MinSize;

  EyesScalingEdit.Value:=FaceTracker.EyesScaling;
  EyesConsensusEdit.Value:=FaceTracker.EyesConsensus;
  EyesMinSizeEdit.Value:=FaceTracker.EyesMinSize;

  OldCallBack:=Camera.OnNewFrame;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TTrackingFrm.FormClose(Sender: TObject;var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TTrackingFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=OldCallBack;
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TTrackingFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TTrackingFrm.ConsensusEditChange(Sender: TObject);
begin
  FaceTracker.Consensus:=Round(ConsensusEdit.Value);
end;

procedure TTrackingFrm.ScalingEditChange(Sender: TObject);
begin
  FaceTracker.Scaling:=ScalingEdit.Value;
end;

procedure TTrackingFrm.MinSizeEditChange(Sender: TObject);
begin
  FaceTracker.MinSize:=Round(MinSizeEdit.Value);
end;

procedure TTrackingFrm.EyesScalingEditChange(Sender: TObject);
begin
  FaceTracker.EyesScaling:=EyesScalingEdit.Value;
end;

procedure TTrackingFrm.EyesConsensusEditChange(Sender: TObject);
begin
  FaceTracker.EyesConsensus:=Round(EyesConsensusEdit.Value);
end;

procedure TTrackingFrm.EyesMinSizeEditChange(Sender: TObject);
begin
  FaceTracker.EyesMinSize:=Round(EyesMinSizeEdit.Value);
end;

procedure TTrackingFrm.NewCameraFrame(Sender:TObject);
begin
  FaceTracker.UpdateWithBmp(Camera.Bmp);
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TTrackingFrm.DrawBmp;
begin
  Bmp.Canvas.Draw(0,0,Camera.Bmp);
  FaceTracker.DrawFacesScaled(Bmp,2.0);
  FaceTracker.DrawEyes(Bmp);
end;
  
end.
