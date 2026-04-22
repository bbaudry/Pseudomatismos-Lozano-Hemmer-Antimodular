unit SettingsFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TSettingsFrm = class(TForm)
    CameraSettingsBtn: TBitBtn;
    TrackingSettingsBtn: TBitBtn;
    Panel1: TPanel;
    Label2: TLabel;
    ResetBtn: TBitBtn;
    CrowdedDefaultsBtn: TSpeedButton;
    QuietDefaultsBtn: TSpeedButton;
    Label1: TLabel;
    Label3: TLabel;
    procedure CameraSettingsBtnClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure TrackingSettingsBtnClick(Sender: TObject);
    procedure CrowdedDefaultsBtnClick(Sender: TObject);
    procedure QuietDefaultsBtnClick(Sender: TObject);

  private
    procedure CalDone(Sender:TObject);
    procedure InitBtns;

  public
    procedure Initialize;
  end;

var
  SettingsFrm: TSettingsFrm;

implementation

{$R *.dfm}

uses
  CameraSettingsFrmU, CfgFile, CameraU, BlobFind, TrackerU, TilerU, Main,
  CalWarningFrmU, TrackingSettingsFrmU, Global;

procedure TSettingsFrm.Initialize;
begin
  Caption:=VersionStr;
  InitBtns;
end;

procedure TSettingsFrm.InitBtns;
begin
  if Tiler.ForceUntrigger then begin
    if (Tracker.MaxSpeed=CrowdedMaxSpeed) and
       (Tiler.ForceUnTriggerDelay=CrowdedUnTriggerDelay) then
    begin
      CrowdedDefaultsBtn.Down:=True;
    end
    else if (Tracker.MaxSpeed=QuietMaxSpeed) and
            (Tiler.ForceUnTriggerDelay=QuietUnTriggerDelay) then
    begin
      QuietDefaultsBtn.Down:=True;
    end;
  end;
end;

procedure TSettingsFrm.CameraSettingsBtnClick(Sender: TObject);
begin
  CameraSettingsFrm:=TCameraSettingsFrm.Create(Application);
  try
    CameraSettingsFrm.Initialize;
    CameraSettingsFrm.ShowModal;
  finally
    CameraSettingsFrm.Free;
  end;
end;

procedure TSettingsFrm.TrackingSettingsBtnClick(Sender: TObject);
begin
  TrackingSettingsFrm:=TTrackingSettingsFrm.Create(Application);
  try
    TrackingSettingsFrm.Initialize;
    TrackingSettingsFrm.ShowModal;
  finally
    TrackingSettingsFrm.Free;
  end;
end;

procedure TSettingsFrm.ResetBtnClick(Sender: TObject);
var
  CfgRecord : TCfgRecord;
begin
  if MessageDlg('Are you sure you want to set all settings to default?',
                mtWarning,[mbYes,mbNo],0)=mrYes then
  begin
    CfgRecord:=DefaultCfgRecord;
    ApplyCfgRecord(CfgRecord);
    InitBtns;

// re-init objects
    Camera.SetAvtDriverSettings(Camera.AvtDriverSettings);

    Camera.InitForTracking;
    BlobFinder.InitForTracking;
    Tracker.InitForTracking;
    Tiler.InitForTracking;
  end;
end;

procedure TSettingsFrm.CalDone(Sender:TObject);
begin
end;

procedure TSettingsFrm.CrowdedDefaultsBtnClick(Sender: TObject);
begin
  Tracker.MaxSpeed:=CrowdedMaxSpeed;
  Tiler.ForceUntrigger:=True;
  Tiler.ForceUnTriggerDelay:=CrowdedUnTriggerDelay;
end;

procedure TSettingsFrm.QuietDefaultsBtnClick(Sender: TObject);
begin
  Tracker.MaxSpeed:=QuietMaxSpeed;
  Tiler.ForceUntrigger:=True;
  Tiler.ForceUnTriggerDelay:=QuietUnTriggerDelay;
end;

end.


