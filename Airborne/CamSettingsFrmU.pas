unit CamSettingsFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NBFill, StdCtrls, ExtCtrls;

type
  TCamSettingsFrm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    ExposureEdit: TNBFillEdit;
    Panel2: TPanel;
    Label2: TLabel;
    GainEdit: TNBFillEdit;
    procedure ExposureEditValueChange(Sender: TObject);
    procedure GainEditValueChange(Sender: TObject);

  private

  public
    procedure Initialize;
  end;

var
  CamSettingsFrm: TCamSettingsFrm;

implementation

{$R *.dfm}

uses
  CameraU;

procedure TCamSettingsFrm.Initialize;
begin
  Camera.ReadExposure;
  ExposureEdit.Min:=Camera.Exposure.Min;
  ExposureEdit.Max:=Camera.Exposure.Max;
  ExposureEdit.Value:=Camera.Exposure.Value;

  Camera.ReadGain;
  GainEdit.Min:=Camera.Gain.Min;
  GainEdit.Max:=Camera.Gain.Max;
  GainEdit.Value:=Camera.Gain.Value;
end;

procedure TCamSettingsFrm.ExposureEditValueChange(Sender: TObject);
begin
  Camera.SetExposure(Round(ExposureEdit.Value));
end;

procedure TCamSettingsFrm.GainEditValueChange(Sender: TObject);
begin
  Camera.SetGain(Round(GainEdit.Value));
end;

end.
