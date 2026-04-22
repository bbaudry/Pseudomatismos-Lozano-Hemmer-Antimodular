unit TxtFileU;

interface

uses
  StrUtils, SysUtils, Global;

function AbleToParseToComma(Line:String;var Txt:String;var I:Integer):Boolean;
function AbleToParseTraits(Line:String;var Traits:TVideoTraits;V:Integer):Boolean;
function AbleToReadVideoTraits(FileName:String;var Traits:TVideoTraits;V:Integer):Boolean;

implementation

function AbleToParseToComma(Line:String;var Txt:String;var I:Integer):Boolean;
var
  I2 : Integer;
begin
  I2:=PosEx(',',Line,I);
  if I2>0 then begin
    Txt:=Copy(Line,I,I2-I);
    I:=I2+1;
    Result:=True;
  end
  else Result:=False;
end;

function AbleToParseTraits(Line:String;var Traits:TVideoTraits;V:Integer):Boolean;
var
  Txt  : String;
  I,V2 : Integer;
begin
  Result:=False;
  Traits:=[];
  I:=1;
  if not AbleToParseToComma(Line,Txt,I) then Exit;
  try

// check the #
    V2:=StrToInt(Txt);
    if V=V2 then begin

// mx/us
      if not AbleToParseToComma(Line,Txt,I) then Exit;
      if Txt='mx' then Traits:=[vtMx]
      else if Txt='us' then Traits:=[vtUs]
      else Exit;

// male/female
      if not AbleToParseToComma(Line,Txt,I) then Exit;
      if Txt='male' then Traits:=Traits+[vtMale]
      else if Txt='female' then Traits:=Traits+[vtFemale]
      else Exit;

// white/non-white
      if not AbleToParseToComma(Line,Txt,I) then Exit;
      if Txt='white' then Traits:=Traits+[vtLight]
      else if Txt='other' then Traits:=Traits+[vtDark]
      else Exit;
      
      Result:=True;
    end;
  except
  end;
end;

function AbleToReadVideoTraits(FileName:String;var Traits:TVideoTraits;V:Integer):Boolean;
var
  TxtFile : TextFile;
  Line    : String;
begin
  Result:=False;
  if FileExists(FileName) then begin
    AssignFile(TxtFile,FileName);
    try
      Reset(TxtFile);
      ReadLn(TxtFile,Line);
      Result:=AbleToParseTraits(Line,Traits,V);
    finally
      Close(TxtFile);
    end;
  end;
end;

end.
