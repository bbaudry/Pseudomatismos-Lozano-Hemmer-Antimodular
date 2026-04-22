unit Math2D;

interface

uses
  Global;
  
function XYInPoly(X,Y:Integer;var Poly:TPixelPtArray):Boolean;

implementation

function XYInPoly(X,Y:Integer;var Poly:TPixelPtArray):Boolean;
var
  I,J : Integer;
  Den : Single;
begin
  Result:=False;
  I:=1; J:=4;
  repeat
    Den:=Poly[J].Y-Poly[I].Y;

// Y must be between these 2 adjacent point Y's to cross a line
    if (Abs(Den)>1E-6) and ((((Y>=Poly[I].Y) and (Y<=Poly[J].Y)) or
         ((Y>=Poly[J].Y) and (Y<=Poly[I].Y)))) and

// see which side of the line X is on
        (X<(Poly[J].X-Poly[I].X)*(Y-Poly[I].Y)/Den+Poly[I].X)
    then begin
      Result:=not Result;
    end;
    Inc(I);
    J:=I-1;
  until (I>4);
end;

end.
 