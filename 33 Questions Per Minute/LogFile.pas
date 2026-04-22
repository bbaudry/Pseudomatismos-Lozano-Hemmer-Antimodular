unit LogFile;

interface

procedure AppendLogFile(Txt:String);
function LogFileName:String;

implementation

uses
  Global, SysUtils;

function LogFileName:String;
begin
  Result:=LogFolder+FormatDateTime('mmmm d',Date)+'.txt';
end;

procedure AppendLogFile(Txt:String);
var
  Line     : String;
  TextFile : Text;
  I        : Integer;
begin
  Assign(TextFile,LogFileName);
  try
    if FileExists(LogFileName) then Append(TextFile)
    else Rewrite(TextFile);
    Line:=DateTimeToStr(Now);
    Writeln(TextFile,Line);
    Writeln(TextFile,Txt);
    Writeln(TextFile,'');
  finally
    Close(TextFile);
  end;
end;

end.
 