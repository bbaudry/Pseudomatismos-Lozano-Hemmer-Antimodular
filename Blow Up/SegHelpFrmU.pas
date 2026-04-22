unit SegHelpFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TSegmenterHelpFrm = class(TForm)
    Memo: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private

  public

  end;

var
  SegmenterHelpFrm: TSegmenterHelpFrm;
  SegmenterHelpFrmCreated : Boolean = False;

implementation

{$R *.dfm}

procedure TSegmenterHelpFrm.FormCreate(Sender: TObject);
begin
  SegmenterHelpFrmCreated:=True;
end;

procedure TSegmenterHelpFrm.FormClose(Sender: TObject;var Action: TCloseAction);
begin
  Action:=caFree;
end;


procedure TSegmenterHelpFrm.FormDestroy(Sender: TObject);
begin
  SegmenterHelpFrmCreated:=False;
end;

end.
