unit Password;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TPasswordFrm = class(TForm)
    OkBtn: TBitBtn;
    Edit: TEdit;
    procedure OkBtnClick(Sender: TObject);

  private
    function TwoDigitStr(Value:Integer):String;

  public
    PasswordOk : Boolean;
    procedure Initialize;
  end;

var
  PasswordFrm: TPasswordFrm;

implementation

{$R *.dfm}

uses
  DateUtils;

procedure TPasswordFrm.Initialize;
begin
  PasswordOk:=False;
end;

function TPasswordFrm.TwoDigitStr(Value:Integer):String;
begin
  if Value<10 then Result:='0'+IntToStr(Value)
  else Result:=IntToStr(Value);
end;

procedure TPasswordFrm.OkBtnClick(Sender: TObject);
var
  Password : String;
  Present  : TDateTime;
  Date     : Integer;
  Month    : Integer;
  Year     : Integer;
begin
  Present:=Now();
  Date:=DayOfTheMonth(Present);
  Month:=MonthOf(Present);
  Year:=CurrentYear();
  Password:=TwoDigitStr(Date)+TwoDigitStr(Month)+IntToStr(Year);
  if Edit.Text=Password then PasswordOk:=True;
  Close;
end;

end.
