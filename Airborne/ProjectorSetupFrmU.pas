unit ProjectorSetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AprSpin, StdCtrls, Buttons, ComCtrls;

type
  TProjectorSetupFrm = class(TForm)
    Label2: TLabel;
    Label3: TLabel;
    WidthEdit: TAprSpinEdit;
    Label4: TLabel;
    Label1: TLabel;
    TopEdit: TAprSpinEdit;
    HeightEdit: TAprSpinEdit;
    LeftEdit: TAprSpinEdit;
    procedure LeftEditChange(Sender: TObject);
    procedure TopEditChange(Sender: TObject);
    procedure WidthEditChange(Sender: TObject);
    procedure HeightEditChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);

  private

  public
    procedure Initialize;

  end;

var
  ProjectorSetupFrm: TProjectorSetupFrm;

implementation

{$R *.dfm}

uses
  Routines, ProjectorU, Global;

procedure TProjectorSetupFrm.Initialize;
begin
//  FormStyle:=fsStayOnTop;
  LeftEdit.Value:=Projector.X;
  TopEdit.Value:=Projector.Y;
  WidthEdit.Value:=Projector.W;
  HeightEdit.Value:=Projector.H;
end;

procedure TProjectorSetupFrm.FormClose(Sender: TObject;var Action: TCloseAction);
begin
//
end;

procedure TProjectorSetupFrm.LeftEditChange(Sender: TObject);
begin
  Projector.X:=Round(LeftEdit.Value);
end;

procedure TProjectorSetupFrm.TopEditChange(Sender: TObject);
begin
  Projector.Y:=Round(TopEdit.Value);
end;

procedure TProjectorSetupFrm.WidthEditChange(Sender: TObject);
begin
  Projector.W:=Round(WidthEdit.Value);
end;

procedure TProjectorSetupFrm.HeightEditChange(Sender: TObject);
begin
  Projector.H:=Round(HeightEdit.Value);
end;

procedure TProjectorSetupFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

end.

  NSTimer *timer;

-(void) applicationDidFinishLaunching:(NSNotification *)aNotification;
{
  timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self
     selector:@selector(timerFired:) userInfo:nil repeats:YES];
}

- (void) timerFired
{
}
