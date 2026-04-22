unit FileUtils;

interface

procedure WriteTextFile(FileName,Txt:String);

implementation

procedure WriteTextFile(FileName,Txt:String);
var
  TxtFile : Text;
begin
  Assign(TxtFile,FileName);
  try
    Rewrite(TxtFile);
    Writeln(TxtFile,Txt);
  finally
    Close(TxtFile);
  end;
end;

end.
