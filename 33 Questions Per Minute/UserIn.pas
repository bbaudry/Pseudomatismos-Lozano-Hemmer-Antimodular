unit UserIn;

interface

uses
  Windows;
  
const
  CursorPeriod = 200;

type
  TUserInput = class(TObject)
  private

  public
    Active      : Boolean; // true if someone's typing
    LastKeyTime : Integer; // last time a key was pressed
    Text        : String;
    CursorI     : Integer;
    CursorOn    : Boolean;
    CursorTime  : DWord;
    CursorChar  : Char;

    constructor Create;

    procedure Update;
    procedure KeyPressed(Ch:Char);
    procedure FlashCursor;
    procedure Initialize;
  end;

var
  UserInput : TUserInput;

implementation

constructor TUserInput.Create;
begin
  inherited;
  Initialize;
end;

procedure TUserInput.Initialize;
begin
  Text:='';
  Active:=False;
  CursorI:=0;
  CursorOn:=False;
  CursorTime:=0;
end;

procedure TUserInput.Update;
begin
  FlashCursor;
  CheckForTimeOut;
end;

procedure TUserInput.MoveCursor(NewI:Integer);
begin
  if CursorI>0 then Text[CursorI]:=CursorChar;
  CursorI:=NewI;
  CursorChar:=Text[CursorI];
end;

procedure TUserInput.KeyPressed(Ch:Char);
begin
  LastKeyTime:=GetTickCount;
  Case Ch of

// backspace
    #8:if Length(Text)>0 then begin
         Delete(Text,CursorI-1,1);
         CursorI:=0;
         MoveCursor(CursorI-1);
       end;

// left arrow
    #37:if CursorI>1 then begin
          MoveCursor(CursorI-1);
        end;

// right arrow
    #39:if CursorI<Length(Text) then begin
          MoveCursor(CursorI+1);
        end;

//          


  end;



//  Text

end;

procedure TUserInput.FlashCursor;
var
  Time : DWord;
begin
  Time:=GetTickCount;
  if (Time-CursorTime)>=CursorPeriod then begin
    CursorTime:=Time;
    CursorOn:=not CursorOn;
    if CursorOn then Text[CursorI]:='_'
    else Text[CursorI]:=CursorChar;
  end;
end;

procedure TUserInput.CheckForTimeOut;
const
  TimeOut = 10000;
begin
  if (GetTickCount-LastKeyTime)>=TimeOut then

end;

end.



