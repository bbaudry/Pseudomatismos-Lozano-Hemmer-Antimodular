unit SetupU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, AprSpin, StdCtrls;

type
  TSetupFrm = class(TForm)
    ShowLbl: TLabel;
    AprSpinEdit1: TAprSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
  private
    procedure NewCameraFrame(Sender:TObject);

  public
    procedure Initialize;

  end;

var
  SetupFrm: TSetupFrm;

implementation

{$R *.dfm}

uses
  Global, CameraU;

procedure TSetupFrm.Initialize;
begin
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TSetupFrm.NewCameraFrame(Sender:TObject);
begin

//
end;

end.
