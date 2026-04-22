unit MathUnit;

//*********************************************************************
// This unit contains all the non-3d math functions and procedures.
// 3D math is in a seperate unit called Math3D.
//*********************************************************************

interface

uses
  Global;

// trig functions
function CalcTan(Angle:Double):Double;
function ArcSin(X:Double):Double;
function ArcCos(X:Double):Double;
function CalcArcTangentOfTangentFraction(Numerator,Denominator:Double): Double;

// rads <--> degrees conversion functions
function RadiansToDegrees(radAngle: Double): Double;
function DegreesToRadians(degreeAngle: Double): Double;

// misc math routines
function Project2RadiiToSolveForLa(Ra,Rb,D: Double): Double;
function CalcDistance(Point1,Point2:TPoint3d) : single;

function CorrectedRadians(Rads:Single):Single;

function DistanceTo2DLine(Pt1,Pt2:TPoint3D;X,Y:Single):Single;

function FindAngle(Origin,Point:TPoint3D):Single;

implementation

uses
  SysUtils, Dialogs, Math3D;

const
  EffectivelyZero = 1E-6;

function FindAngle(Origin,Point:TPoint3D):Single;
begin
  if Point.X=Origin.X then begin
    if Point.Y>Origin.Y then Result:=Pi/2
    else Result:=-Pi/2;
  end
  else Result:=ArcTan((Point.Y-Origin.Y)/(Point.X-Origin.X));
end;

function CorrectedRadians(Rads:Single):Single;
begin
  if Rads<-Pi then Result:=Rads+(2*Pi)
  else if Rads>+Pi then Result:=Rads-(2*Pi)
  else Result:=Rads;
end;

function CalcDistance(Point1,Point2:TPoint3D) : single;
var
  L1,L2,L3 : single;
begin
  L1:=abs(Point1.x-Point2.x);
  L2:=abs(Point1.y-point2.y);
  L3:=abs(point1.z-point2.z);
  Result:=Sqrt(Sqr(l1)+Sqr(l2)+Sqr(l3));
end;

procedure ClampToOnePointZeroMaximum(var Value: Double);
begin
  if Value > 1.0 then Value:=1.0
  else if Value < -1.0 then Value:=-1.0;
end;

function ArcSin(x: Double): Double;
begin
  ClampToOnePointZeroMaximum(X);
  if X=1.0 then Result:=pi/2
  else if X=-1.0 then Result:=-pi/2
  else Result:=ArcTan(X/Sqrt(1-Sqr(X)));
end;

function ArcCos(x: Double): Double;
begin
  ClampToOnePointZeroMaximum(X);
  if X<>0 then begin
    Result:=ArcTan(Sqrt(1-Sqr(X))/X);

// Now correct for the mirroring of tangent function..
    if X<0 then Result:=Result+pi;
  end
  else Result:=pi/2;
end;

function CalcTan(Angle:Double):Double;
var
  SinOfAngle,CosOfAngle : Double;
begin
  SinOfAngle:=Sin(Angle);
  CosOfAngle:=Cos(Angle);

// if the denominator term is not zero, calc. the tangent normally..if the
// denominator is zero, set the tangent to a big number, respecting the
// sign of the numerator and denominator
  if Abs(CosOfAngle)>EffectivelyZero then Result:=SinOfAngle/CosOfAngle
  else begin
    if ((SinOfAngle>0) and (CosOfAngle>0)) or
       ((SinOfAngle<0) and (CosOfAngle<0)) then
    begin
      Result:=100000;
    end
    else Result:=-100000;
  end;
end;

function Project2RadiiToSolveForLa(Ra,Rb,D:Double): Double;
begin
// This calculation is based on Will's logbook entry of Feb. 6/97
//          /|\          :Lb=D-La  Sqr(Lb)=Sqr(D)-2DLa+Sqr(La)
//    Ra   / | \   Rb    :h=Sqr(Rb)-Sqr(Lb)=Sqr(Ra)-Sqr(La)
//        /  |h \        :Sqr(La)=Sqr(Ra)-Sqr(Rb)+Sqr(Lb)
//       /___|_ _\       :0=Sqr(Ra)-Sqr(Rb)+Sqr(D)-2DLa
//        La   Lb        :2DLa=Sqr(Ra)-Sqr(Rb)+Sqr(D)
//      <--- D --->      :La=Sqr(Ra)+Sqr(D)-Sqr(Rb)/2D
//
  Result:=(Sqr(Ra)+Sqr(D)-Sqr(Rb))/(2*D);
end;

// returns true if S is Infinity, NAN or indeterminate
// 4byte IEEE: bit[31] = sign, bits[23-30] exponent, bits[0..22] mantissa
// if exponent is all 1s the single = Infinity, NAN or Indeterminate
function InvalidSingle(S:Single):Boolean;
var
  Overlay : LongInt absolute S;
const
  Exponent = 255 shl 23;
begin
  Result:=((Overlay and Exponent)=Exponent);
end;

function CalcArcTangentOfTangentFraction(numerator,denominator: Double): Double;
var
  TangentOfAngle : Double;
begin
  if Abs(Denominator)>EffectivelyZero then begin
    TangentOfAngle:=Numerator/Denominator;
  end

// if our denominator is basically zero, make up a large number for the tangent
// while respecting the sign of the fraction..
  else begin
    if Numerator>0 then TangentOfAngle:=100000
    else TangentOfAngle:=-100000;
  end;

// return the arctan...
  Result:=ArcTan(TangentOfAngle);
end;

function RadiansToDegrees(RadAngle: Double): Double;
begin
  Result:=RadAngle/(2*pi)*360.0;
end;

function DegreesToRadians(DegreeAngle: Double): Double;
begin
  Result:=DegreeAngle/360*(2*pi);
end;

function DistanceTo2DLine(Pt1,Pt2:TPoint3D;X,Y:Single):Single;
var
  Length : Single;
begin
  Length:=DistanceBetween3DPoints(Pt1,Pt2);
  Result:=((Pt1.Y-Y)*(Pt2.X-Pt1.X)-(Pt1.X-X)*(Pt2.Y-Pt1.Y))/Length;
end;

end.


