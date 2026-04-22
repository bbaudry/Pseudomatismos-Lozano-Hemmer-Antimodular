unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, StrUtils, LCD, AlignEdt;

const
  MaxQLabels = 10;

type
  TMainFrm = class(TForm)
    Timer: TTimer;
    LCD: TLCD;
    Edit: TAlignEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
                            Shift:TShiftState; X, Y: Integer);
    procedure TimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject;var Key:Word;Shift: TShiftState);
    procedure EditKeyPress(Sender: TObject; var Key: Char);

  private
    QLabel        : array[1..MaxQLabels] of TLabel;
    QLblCount     : Integer;
    EditTime      : DWord;
    CountDownTime : DWord;

    procedure SpreadQuestionOverQLabels;
    procedure UpdateLcd;
    procedure UpdateEditTimeOut;

  public
    procedure InitQLabelFonts;
    procedure InitEditAndLcd;
    procedure PositionQLabels;
    procedure ShowQuestion;
    procedure SetBackGndColor;
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}
{$R 33Q.res}

uses
  QMakerU, Setup, CfgFile, Global, Routines, LogFile;

procedure TMainFrm.FormCreate(Sender: TObject);
var
  I : Integer;
begin
  MaximizeForm(Self);
  DisableSysKeys;
  HideTaskBar;
  Cursor:=crNone;
  Randomize();
  QuestionMaker:=TQuestionMaker.Create;
  LoadCfgFile;
  SetBackGndColor;

// create the labels
  for I:=1 to MaxQLabels do begin
    QLabel[I]:=TLabel.Create(Self);
    QLabel[I].Parent:=Self;
    QLabel[I].OnMouseDown:=Self.OnMouseDown;
    QLabel[I].Transparent:=True;
  end;
  InitQLabelFonts;
  InitEditAndLcd;
  Edit.Visible:=False;
  Lcd.Visible:=False;
  Timer.Enabled:=True;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
var
  I : Integer;
begin
  EnableSysKeys;
  ShowTaskBar;
  if Assigned(QuestionMaker) then QuestionMaker.Free;
  for I:=1 to MaxQLabels do if Assigned(QLabel[I]) then QLabel[I].Free;
end;

procedure TMainFrm.InitQLabelFonts;
var
  I : Integer;
begin
  for I:=1 to MaxQLabels do begin
    QLabel[I].Font.Name:=QuestionFont.Name;
    QLabel[I].Font.Color:=QuestionFont.Color;
    QLabel[I].Font.Style:=QuestionFont.Style;
    QLabel[I].Font.Size:=QuestionFont.Size;
  end;
end;

procedure TMainFrm.InitEditAndLcd;
begin
  Edit.Font.Name:=InputFont.Name;
  Edit.Font.Color:=InputFont.Color;
  Edit.Font.Style:=InputFont.Style;
  Edit.Font.Size:=InputFont.Size;
  Edit.Height:=Canvas.TextHeight('X')+10;
  Edit.Top:=Screen.Height-Edit.Height*2;

  Lcd.Left:=(Width-Lcd.Width) div 2;
  Lcd.Top:=Edit.Top-((Lcd.Height-Edit.Height) div 2)-4;

  Edit.Left:=XBorder;
  Edit.Width:=Screen.Width-XBorder*2;
end;

procedure TMainFrm.FormMouseDown(Sender: TObject; Button: TMouseButton;
                                 Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then Close
  else begin
    Timer.Enabled:=False;
    SetupFrm:=TSetupFrm.Create(Application);
    try
      SetupFrm.Initialize;
      SetupFrm.ShowModal;
    finally
      SetupFrm.Free;
    end;
    Timer.Enabled:=True;
  end;
end;

procedure TMainFrm.TimerTimer(Sender: TObject);
begin
  if QuestionMaker.TimeForANewQuestion then begin
    QuestionMaker.MakeNextQuestion;
    ShowQuestion;
  end;
//Exit;
  if Lcd.Visible then UpdateLcd
  else if Edit.Visible then UpdateEditTimeOut;
end;

procedure TMainFrm.PositionQLabels;
var
  I,W,Y  : Integer;
  TotalY : Integer;
begin
// accumulate the total height
  TotalY:=YBorder*2+(QLblCount-1)*LineSpacing;
  for I:=1 to QLblCount do begin
    TotalY:=TotalY+QLabel[I].Canvas.TextHeight(QLabel[I].Caption);
  end;
  Case VAlignment of
    vaTop    : Y:=YBorder;
    vaMiddle : Y:=(Screen.Height-TotalY) div 2;
    vaBottom : Y:=Screen.Height-TotalY-YBorder;
  end;
  for I:=1 to QLblCount do begin

// X
    if HAlignment=haLeft then QLabel[I].Left:=XBorder
    else begin
      W:=QLabel[I].Canvas.TextWidth(QLabel[I].Caption);
      Case HAlignment of
        haMiddle : QLabel[I].Left:=(Screen.Width-W) div 2;
        haRight  : QLabel[I].Left:=Screen.Width-W-XBorder;
      end;
    end;

// Y
    QLabel[I].Top:=Y;
    Inc(Y,QLabel[I].Canvas.TextHeight(QLabel[I].Caption));
    Inc(Y,LineSpacing);
  end;
end;

procedure TMainFrm.ShowQuestion;
var
  I : Integer;
begin
 SpreadQuestionOverQLabels;
 for I:=1 to MaxQLabels do QLabel[I].Visible:=(I<=QLblCount);
 PositionQLabels;
end;

procedure TMainFrm.SpreadQuestionOverQLabels;
var
  LastI     : Integer;
  LastSpace : Integer;
  MaxW,I,I2 : Integer;
  TakenI,W  : Integer;
  Done      : Boolean;
  Text      : String;
  Question  : String;
begin
  Question:=QuestionMaker.Question;
  QLblCount:=0;
  LastI:=1;
  TakenI:=1;
  LastSpace:=0;
  MaxW:=Screen.Width-XBorder*2;
  Done:=False;
  repeat

// find the next space
    I:=PosEx(#32,Question,LastI);

// if there's no space (one word), take what we can
    if I=0 then begin

// try to take it all
      Text:=Copy(Question,TakenI,Length(Question)-TakenI+1);
      W:=QLabel[QLblCount+1].Canvas.TextWidth(Text);
      if W<=MaxW then begin
        Inc(QLblCount);
        QLabel[QLblCount].Caption:=Text;
        Done:=True;
      end

// take what we can
      else begin

// take up to the last space if we found one
        if LastSpace>TakenI then begin
          Text:=Copy(Question,TakenI,LastSpace-TakenI);
          Inc(QLblCount);
          QLabel[QLblCount].Caption:=Text;
          LastI:=LastSpace+1;
          TakenI:=LastI;
          LastSpace:=0;
        end

// otherwise take as many characters as we can
        else begin
          I2:=LastI;
          Text:='';
          repeat
            Text:=Text+Question[I2];
            Inc(I2);
          until QLabel[QLblCount+1].Canvas.TextWidth(Text)>MaxW;
          Inc(QLblCount);
          QLabel[QLblCount].Caption:=Copy(Text,1,Length(Text)-1);
          LastI:=I2-1;
          TakenI:=LastI;
        end;
      end;
      Continue;
    end;

// if we did find a space, see if we can fit the text up to it on a line
    Text:=Copy(Question,TakenI,I-TakenI);

// if so, record the index of the space
    W:=QLabel[QLblCount+1].Canvas.TextWidth(Text);
    if W<=MaxW then begin
      LastSpace:=I;
      LastI:=I+1;
    end

// otherwise, cut up to the last space
    else begin
      if LastSpace>0 then begin
        Text:=Copy(Question,TakenI,LastSpace-TakenI);
        Inc(QLblCount);
        QLabel[QLblCount].Caption:=Text;
        LastI:=LastSpace+1;
        TakenI:=LastI;
        LastSpace:=0;
      end
      else begin
        I2:=LastI;
        Text:='';
        repeat
          Text:=Text+Question[I2];
        until QLabel[QLblCount].Canvas.TextWidth(Text)>MaxW;
        Dec(I2);
        Inc(QLblCount);
        QLabel[QLblCount].Caption:=Copy(Text,1,Length(Text)-1);
        LastI:=I2-1;
        TakenI:=LastI;
      end;
    end;
  until Done or (QLblCount=MaxQLabels);
end;

procedure TMainFrm.FormKeyDown(Sender:TObject;var Key:Word;Shift:TShiftState);
begin
  if not (Edit.Visible or LCD.Visible) then begin
    EditTime:=GetTickCount;
    Edit.Enabled:=True;
    Edit.Visible:=True;
    Edit.SetFocus;
    Edit.Text:=Char(Key);
    Edit.SelStart:=1;
  end;
end;

procedure TMainFrm.SetBackGndColor;
begin
  Color:=BackGndColor;
  Edit.Color:=BackGndColor;
end;

procedure TMainFrm.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then begin
    Edit.Enabled:=False;
    Edit.Visible:=False;
    Lcd.Value:=Round(CountDownPeriod/1000);
    Lcd.Visible:=True;
    CountDownTime:=GetTickCount;
    AppendLogFile(Edit.Text);
  end;
end;

procedure TMainFrm.UpdateLcd;
var
  TimeElapsed : DWord;
begin
  if Lcd.Value=0 then begin
    Lcd.Visible:=False;
    QuestionMaker.Question:=Edit.Text;
    QuestionMaker.LastQuestionTime:=GetTickCount;
    ShowQuestion;
  end
  else begin
    TimeElapsed:=GetTickCount-CountDownTime;
    Lcd.Value:=Round((CountDownPeriod-TimeElapsed)/1000);
  end;
end;

procedure TMainFrm.UpdateEditTimeOut;
var
  TimeElapsed : DWord;
begin
  TimeElapsed:=GetTickCount-EditTime;
  if TimeElapsed>=EditTimeOut then begin
    Edit.Visible:=False;
    Edit.Enabled:=False;
  end;
end;

end.

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
end;


procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
end;



