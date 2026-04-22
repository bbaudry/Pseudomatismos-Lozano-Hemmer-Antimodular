unit PopUpFrmU;

interface

uses
  Windows, ExtCtrls, Classes, Controls, StdCtrls, SysUtils, Variants, Graphics,
  Forms, Dialogs;

type
  TPopUpFrm = class(TForm)
    RecalBtn: TButton;
    SettingsBtn: TButton;
    QuitBtn: TButton;
    Timer1: TTimer;
    procedure RecalBtnClick(Sender: TObject);
    procedure SettingsBtnClick(Sender: TObject);
    procedure QuitBtnClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private

  public
    procedure ShowAt(X,Y:Integer);
  end;

var
  PopUpFrm: TPopUpFrm;

implementation

{$R *.dfm}

uses
  SettingsFrmU, Main;

procedure TPopUpFrm.ShowAt(X,Y:Integer);
begin
  Left:=X-Width div 2;
  Top:=Y-Height div 2;
  FormStyle:=fsStayOnTop;
  ShowModal;
end;

procedure TPopUpFrm.Timer1Timer(Sender: TObject);
begin
BringToFront;
end;

procedure TPopUpFrm.QuitBtnClick(Sender: TObject);
begin
  MainFrm.Close;
end;

procedure TPopUpFrm.RecalBtnClick(Sender: TObject);
begin
  MainFrm.BackGndTimer.Interval:=3000;
  MainFrm.BackGndTimer.Enabled:=True;
end;

procedure TPopUpFrm.SettingsBtnClick(Sender: TObject);
begin
   SettingsFrm:=TSettingsFrm.Create(Application);
  try
    SettingsFrm.Initialize;
    SettingsFrm.ShowModal;
  finally
    SettingsFrm.Free;
  end;
end;

end.
