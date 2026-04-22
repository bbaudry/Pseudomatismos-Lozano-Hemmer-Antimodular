unit AdvancedFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TAdvancedSetupFrm = class(TForm)
    DisplaySetupBtn: TBitBtn;
    SetupTrackingBtn: TBitBtn;
    ScrubTstBtn: TBitBtn;
    LoadBmpsBtn: TBitBtn;
    ViewBmpsBtn: TBitBtn;
    procedure DisplaySetupBtnClick(Sender: TObject);
    procedure SetupTrackingBtnClick(Sender: TObject);
    procedure LoadBmpsBtnClick(Sender: TObject);
    procedure ViewBmpsBtnClick(Sender: TObject);
    procedure ScrubTstBtnClick(Sender: TObject);

  private

  public
    procedure Initialize;
  end;

var
  AdvancedSetupFrm: TAdvancedSetupFrm;

implementation

uses
  DisplayCfg, TrackingCfg, BmpLoadU, BmpView, ScrubTst, TilerU;

{$R *.dfm}

procedure TAdvancedSetupFrm.Initialize;
begin
//
end;

procedure TAdvancedSetupFrm.DisplaySetupBtnClick(Sender: TObject);
begin
  DisplaySetupFrm:=TDisplaySetupFrm.Create(Application);
  try
    DisplaySetupFrm.Initialize;
    DisplaySetupFrm.ShowModal;
  finally
    DisplaySetupFrm.Free;
  end;
end;

procedure TAdvancedSetupFrm.SetupTrackingBtnClick(Sender: TObject);
begin
  TrackingSetupFrm:=TTrackingSetupFrm.Create(Application);
  try
    TrackingSetupFrm.Initialize;
    TrackingSetupFrm.ShowModal
  finally
    TrackingSetupFrm.Free;
  end;
end;

procedure TAdvancedSetupFrm.LoadBmpsBtnClick(Sender: TObject);
begin
  BmpLoadFrm:=TBmpLoadFrm.Create(Application);
  try
    BmpLoadFrm.Initialize;
    BmpLoadFrm.ShowModal;
  finally
    BmpLoadFrm.Free;
  end;
  Tiler.VideosLoaded:=True;
end;

procedure TAdvancedSetupFrm.ViewBmpsBtnClick(Sender: TObject);
begin
  if Tiler.BmpsLoadedOk then begin
    BmpViewFrm:=TBmpViewFrm.Create(Application);
    try
      BmpViewFrm.Initialize;
      BmpViewFrm.ShowModal;
    finally
      BmpViewFrm.Free;
    end;
  end;
end;

procedure TAdvancedSetupFrm.ScrubTstBtnClick(Sender: TObject);
begin
  if Tiler.BmpsLoadedOk then begin
    ScrubTestFrm:=TScrubTestFrm.Create(Application);
    try
      ScrubTestFrm.Initialize;
      ScrubTestFrm.ShowModal;
    finally
      ScrubTestFrm.Free;
    end;
  end;
end;

end.

