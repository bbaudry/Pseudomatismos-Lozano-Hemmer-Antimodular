unit Math3d;

interface

uses
  Global, Windows;

var
  Tag1,Tag2,Tag3,Tag4 : Integer;

procedure FindPlaneCoefficients(var Plane:TPlane);
function  AbleToFindTargetOnZPlane(var Pose:TPose;Pan,Tilt,Height,ZOffset:Single;
                                   var Target:TPoint3D):Boolean;
procedure FindPanAndTiltToTarget(var Pose:TPose;Target:TPoint3D;var Pan,Tilt:Single);
function  PointIsOnPlane(Pt:TPoint3D;Plane:TPlane):Boolean;
function  LineBetweenPointsIntersectsPlane(P1,P2:TPoint3D;Plane:TPlane;
                                           var IPoint:TPoint3D):Boolean;
procedure RotateXYPoint(var X,Y:Single;Rz:Single);
procedure RotateYZPoint(var Y,Z:Single;Rx:Single);
procedure Rotate2DPoint(var Point:TPoint2D;Rz:Single);
procedure Rotate2DPointAboutCtrPoint(var Point,Ctr:TPoint2D;Rz:Single);
procedure Rotate3DPoint(var Point:TPoint3D;Rz:Single);
function  Rotated3DPoint(Point:TPoint3D;Rz:Single): TPoint3D;
procedure Rotate3DPointsAboutCenter(var Pt1,Pt2:TPoint3D;Rz:Single);
function  ThreeDToTwoD(Point,Origin:TPoint3D):TPoint;
function  DistanceBetween2DPoints(const Pt1,Pt2:TPoint2D):Single;
function  DistanceBetween3DPoints(const Pt1,Pt2:TPoint3D):Single;
function  XYDistanceBetween3DPoints(const Pt1,Pt2:TPoint3D):Single;
function  Vector(P1,P2:TPoint3D):TPoint3D;
function  FindNormal(P1,P2,P3:TPoint3D):TPoint3D;
function  LinesIntersectIn2D(var A,B,C,D:TPoint3D):Boolean;
function  Lines2DIntersect(var A,B,C,D:TPoint2D):Boolean;
procedure Normalize(var V:TPoint3D);
function  AbleToFindClosestIntersectionPointOfLines(var Target,A1,A2,B1,B2:TPoint3D;
                                                   MaxError:Single):Boolean;
function  AbleToFindClosestIntersectionPointOfRays(const Ray1,Ray2:TRay;
                           MaxError:Single;var PtA,PtB,Target:TPoint3D):Boolean;
function  ExtendRay(Base,V:TPoint3D;Length:Single):TPoint3D;
function  TargetAlongRay(Ray:TRay;R:Single):TPoint3D;
function  NetAngle(Pan,Tilt:Single):Single;

implementation

uses
  Dialogs, SysUtils, Math, QMatrix, MathUnit, Main;

// returns true if the 2D line AB intersects 2D line CD
function LinesIntersectIn2D(var A,B,C,D:TPoint3D):Boolean;
var
  R,S : Single;
  Den : Single;
begin
  Den:=(B.X-A.X)*(D.Y-C.Y)-(B.Y-A.Y)*(D.X-C.X);

// if the denominator=0, AB and CD are parallel - return false for this
// (even though they may be colinear)
  Result:=(Den<>0);
  if not Result then Exit;

// find R and S - both must be between 0-1
  R:=((A.Y-C.Y)*(D.X-C.X)-(A.X-C.X)*(D.Y-C.Y))/Den;
  Result:=(R>0) and (R<1);
  if not Result then Exit;

  S:=((A.Y-C.Y)*(B.X-A.X)-(A.X-C.X)*(B.Y-A.Y))/Den;
  Result:=(S>0) and (S<1);
end;

// returns true if the 2D line AB intersects 2D line CD
function Lines2DIntersect(var A,B,C,D:TPoint2D):Boolean;
var
  R,S : Single;
  Den : Single;
begin
  Den:=(B.X-A.X)*(D.Y-C.Y)-(B.Y-A.Y)*(D.X-C.X);

// if the denominator=0, AB and CD are parallel - return false for this
// (even though they may be colinear)
  Result:=(Den<>0);
  if not Result then Exit;

// find R and S - both must be between 0-1
  R:=((A.Y-C.Y)*(D.X-C.X)-(A.X-C.X)*(D.Y-C.Y))/Den;
  Result:=(R>0) and (R<1);
  if not Result then Exit;

  S:=((A.Y-C.Y)*(B.X-A.X)-(A.X-C.X)*(B.Y-A.Y))/Den;
  Result:=(S>0) and (S<1);
end;

function AbleToFindTargetOnZPlane(var Pose:TPose;Pan,Tilt,Height,ZOffset:Single;
                                  var Target:TPoint3D):Boolean;
var
  RxMatrix,RyMatrix : TMatrix;
  RzMatrix          : TMatrix;
  T                 : Single;
  V,LaserOffset     : TPoint3D;
begin
  Result:=False;

// with no pan or tilt, the vector will point straight down
  V.X:=0; V.Y:=0; V.Z:=-1;

  LaserOffset.X:=0; LaserOffset.Y:=-ZOffset; LaserOffset.Z:=0;

  RxMatrix:=XRotationMatrix(Tilt);
  RyMatrix:=YRotationMatrix(Pan);

  V:=Point3DMultMatrix(V,RxMatrix);
  V:=Point3DMultMatrix(V,RyMatrix);

  LaserOffset:=Point3DMultMatrix(LaserOffset,RxMatrix);
  LaserOffset:=Point3DMultMatrix(LaserOffset,RyMatrix);

  RxMatrix:=XRotationMatrix(+Pose.Rx);
  RyMatrix:=YRotationMatrix(+Pose.Ry);
  RzMatrix:=ZRotationMatrix(-Pose.Rz);

  V:=Point3DMultMatrix(V,RyMatrix);
  V:=Point3DMultMatrix(V,RxMatrix);
  V:=Point3DMultMatrix(V,RzMatrix);

// if V.Z>=0, we're pointing horizontally or up so there will be no Z=0
// intersection point
  if V.Z>=0 then Exit;

  LaserOffset:=Point3DMultMatrix(LaserOffset,RyMatrix);
  LaserOffset:=Point3DMultMatrix(LaserOffset,RxMatrix);
  LaserOffset:=Point3DMultMatrix(LaserOffset,RzMatrix);

// recycle the LaserOffset var
  LaserOffset.X:=LaserOffset.X+Pose.X;
  LaserOffset.Y:=LaserOffset.Y+Pose.Y;
  LaserOffset.Z:=LaserOffset.Z+Pose.Z;

// find the parametric T variable
  T:=(LaserOffset.Z-Height)/V.Z;

// find the intersection point
  Target.X:=LaserOffset.X-T*V.X;
  Target.Y:=LaserOffset.Y-T*V.Y;
  Target.Z:=Height;
  Result:=True;
end;

procedure FindPanAndTiltToTarget(var Pose:TPose;Target:TPoint3D;var Pan,Tilt:Single);
var
  RxMatrix : TMatrix;
  RyMatrix : TMatrix;
  RzMatrix : TMatrix;
  L        : Single;
begin
// find the target relative to the source location
  Target.X:=Target.X-Pose.X;
  Target.Y:=Target.Y-Pose.Y;
  Target.Z:=Target.Z-Pose.Z;

// apply the fixture p,t,r
  RxMatrix:=XRotationMatrix(-Pose.Rx);
  RyMatrix:=YRotationMatrix(-Pose.Ry);
  RzMatrix:=ZRotationMatrix(+Pose.Rz);
  Target:=Point3DMultMatrix(Target,RzMatrix);
  Target:=Point3DMultMatrix(Target,RxMatrix);
  Target:=Point3DMultMatrix(Target,RyMatrix);

// pan
  if Target.Z<0 then Pan:=ArcTan(Target.X/Target.Z)
  else if Target.Z>0 then begin
    if Target.X>0 then Pan:=ArcTan(Target.X/Target.Z)-Pi
    else Pan:=ArcTan(Target.X/Target.Z)+Pi;
  end
  else if Target.X>0 then Pan:=-Pi/2
  else Pan:=+Pi/2;

// tilt
  L:=Sqrt(Sqr(Target.X)+Sqr(Target.Z));
  if L>0 then Tilt:=-ArcTan(Target.Y/L)
  else Tilt:=0;
end;

function DistanceBetween3DPoints(const Pt1,Pt2:TPoint3D):Single;
begin
  Result:=Sqrt(Sqr(Pt1.X-Pt2.X)+Sqr(Pt1.Y-Pt2.Y)+Sqr(Pt1.Z-Pt2.Z));
end;

function XYDistanceBetween3DPoints(const Pt1,Pt2:TPoint3D):Single;
begin
  Result:=Sqrt(Sqr(Pt1.X-Pt2.X)+Sqr(Pt1.Y-Pt2.Y));
end;

function CrossProduct(V1,V2:TPoint3D):TPoint3D;
begin
  Result.X:=(V1.Z*V2.Y)-(V1.Y*V2.Z);
  Result.Y:=(V1.X*V2.Z)-(V1.Z*V2.X);
  Result.Z:=(V1.Y*V2.X)-(V1.X*V2.Y);
end;

function PlaneNormal(Plane:TPlane):TPoint3D;
var
  V1,V2 : TPoint3D;
begin
// find two vectors
  with Plane do begin
    V1:=Vector(Point[2],Point[1]);  // 2---->1
    V2:=Vector(Point[2],Point[3]);  // 2---->3
  end;

// the normal is the CrossProduct between these two vectors
  Result:=CrossProduct(V1,V2);
end;

function LineBetweenPointsIntersectsPlane(P1,P2:TPoint3D;Plane:TPlane;
             var IPoint:TPoint3D):Boolean;
var
  E,F,G,T : Single;
  Denom   : Single;
  Length  : Single;
begin
  with Plane do begin

// The line (L) is defined by the 2 points as follows :
// L:  X=P1.X+(P2.X-P1.X)*T,Y=P1.Y+(P2.Y-P1.Y)*T,Z=P1.Z+(P2.Z-P1.Z)*T
// or  X=P1.X+E*T,Y=P1.Y+F*T,Z=P1.Z+G*T

// find the E,F,G multipliers for the "T" parameter
    try
      E:=P2.X-P1.X; F:=P2.Y-P1.Y; G:=P2.Z-P1.Z;

// solve for T...
      Denom:=A*E+B*F+C*G;
      if Denom=0 then begin
        Result:=False;
        Exit;
      end;
      T:=-(D+A*P1.X+B*P1.Y+C*P1.Z)/Denom;

// plug T into the line equation to find the X,Y,Z intersection point
      IPoint.X:=P1.X+E*T;
      IPoint.Y:=P1.Y+F*T;
      IPoint.Z:=P1.Z+G*T;

// make sure the intersection point lies on our finite line
      Length:=DistanceBetween3DPoints(P1,P2);
      Result:=(DistanceBetween3DPoints(P1,IPoint)<=Length) and
              (DistanceBetween3DPoints(P2,IPoint)<=Length);

// also make sure the intersection point is on our FINITE Plane
      if Result and Plane.Finite then Result:=PointIsOnPlane(IPoint,Plane);
    except
      Result:=False;
    end;
  end;
end;

//*****************************************************************************
// Converts P1,P2 into a vector
//      P1o----->P2
//*****************************************************************************
function Vector(P1,P2:TPoint3D):TPoint3D;
begin
  Result.X:=P2.X-P1.X;
  Result.Y:=P2.Y-P1.Y;
  Result.Z:=P2.Z-P1.Z;
end;

//*****************************************************************************
// Returns the magnitude of V. ( |V| )
//*****************************************************************************
function Magnitude(V:TPoint3D):Single;
begin
  Result:=Sqrt(Sqr(V.X)+Sqr(V.Y)+Sqr(V.Z));
end;

//*****************************************************************************
// Returns the dot product of two vectors
//*****************************************************************************
function DotProduct(V1,V2:TPoint3D):Single;
begin
  Result:=V1.X*V2.X+V1.Y*V2.Y+V1.Z*V2.Z;
end;

//*****************************************************************************
// Returns the angle between P1,P2,P3          P1
//                                            /
//                                           /
//                                         P2 ----P3
//*****************************************************************************
function AngleBetween3DPoints(P1,P2,P3:TPoint3D):Single;
begin
// find the vectors
  P1:=Vector(P2,P1);
  P3:=Vector(P2,P3);
  Result:=DotProduct(P1,P3)/(Magnitude(P1)*Magnitude(P3));

// clip the arccos to the valid range - sometimes it goes beyond +1/-1 due to
// round off error
  if Result>1 then Result:=0
  else if Result<-1 then Result:=Pi
  else Result:=ArcCos(Result);
end;

function PointIsOnPlane(Pt:TPoint3D;Plane:TPlane):Boolean;
var
  A1,A2,A3,A4 : Single;
begin
  with Plane do begin
    A1:=AngleBetween3DPoints(Point[1],Pt,Point[2]);
    A2:=AngleBetween3DPoints(Point[2],Pt,Point[3]);
    A3:=AngleBetween3DPoints(Point[3],Pt,Point[4]);
    A4:=AngleBetween3DPoints(Point[4],Pt,Point[1]);
  end;
  Result:=Abs(A1+A2+A3+A4-(2*Pi))<0.01;
end;

function OffsetPlane(var Plane:TPlane;Z:Single):TPlane;
var
  I : Integer;
begin
  Result:=Plane;
  for I:=1 to 4 do Result.Point[I].Z:=Result.Point[I].Z+Z;
end;

//******************************************************************************
// Returns Point rotated Rz about the Z axis
//******************************************************************************
function Rotated3DPoint(Point:TPoint3D;Rz:Single) : TPoint3D;
begin
  with Result do begin
    X:=Point.X*Cos(Rz)+Point.Y*Sin(Rz);
    Y:=Point.Y*Cos(Rz)-Point.X*Sin(Rz);
    Z:=Point.Z;
  end;
end;

function FindNormal(P1,P2,P3:TPoint3D):TPoint3D;
var
  V1,V2  : TPoint3D;
  Length : Single;
begin
  V1:=Vector(P1,P2);
  V2:=Vector(P1,P3);

// find the normal perpendicular to both - (cross product of the 2)
  Result.X:=-((V1.Y*V2.Z)-(V1.Z*V2.Y));
  Result.Y:=+((V1.X*V2.Z)-(V1.Z*V2.X));
  Result.Z:=-((V1.X*V2.Y)-(V1.Y*V2.X));

// scale the vector to be of unit length
  Length:=Sqrt(Sqr(Result.X)+Sqr(Result.Y)+Sqr(Result.Z));

// don't divide by zero...
  if Length>0 then begin
    Result.X:=Result.X/Length;
    Result.Y:=Result.Y/Length;
    Result.Z:=Result.Z/Length;
  end;
end;

function DistanceBetween2DPoints(const Pt1,Pt2:TPoint2D):Single;
begin
  Result:=Sqrt(Sqr(Pt1.X-Pt2.X)+Sqr(Pt1.Y-Pt2.Y));
end;

//      X1,X2         a = angle from X1,X2 to X Axis
//     /              Rz = angle of rotation (clockwise)
//  R / a \           R = distance from origin to X1,X2
//   / /   \          X1=RCos(a) Y1=RSin(a)
//  + ----- Rz--- X   X2=RCos(a-Rz) Y2=RSin(a-Rz)
//   \     /          Cos(a-Rz)=Cos(a)Cos(Rz)+Sin(a)Sin(Rz)
//  R \   /           Sin(a-Rz)=Sin(a)Cos(Rz)-Cos(a)Sin(Rz)
//     \              X2=R[Cos(a)Cos(Rz)+Sin(a)Sin(Rz)=X1Cos(Rz)+Y1Sin(Rz)
//     X2,Y2          Y2=R[Sin(a)Cos(Rz)-Cos(a)Sin(Rz)]=Y1Cos(Rz)-X1Sin(Rz)

procedure RotateXYPoint(var X,Y:Single;Rz:Single);
var
  Temp : Single;
begin
  Rz:=-Rz;
  Temp:=Y*Cos(Rz)-X*Sin(Rz);
  X:=X*Cos(Rz)+Y*Sin(Rz);
  Y:=Temp;
end;

procedure RotateYZPoint(var Y,Z:Single;Rx:Single);
var
  Temp : Single;
begin
  Rx:=-Rx;
  Temp:=Y*Cos(Rx)-Z*Sin(Rx);
  Y:=Y*Cos(Rx)+Z*Sin(Rx);
  Z:=Temp;
end;

procedure Rotate2DPoint(var Point:TPoint2D;Rz:Single);
var
  Temp : Single;
begin
  Rz:=-Rz;
  with Point do begin
    Temp:=Y*Cos(Rz)-X*Sin(Rz);
    X:=X*Cos(Rz)+Y*Sin(Rz);
    Y:=Temp;
  end;
end;

procedure Rotate2DPointAboutCtrPoint(var Point,Ctr:TPoint2D;Rz:Single);
begin
// find the point relative to the ctr point
  Point.X:=Point.X-Ctr.X;
  Point.Y:=Point.Y-Ctr.Y;

// rotate it
  Rotate2DPoint(Point,Rz);

// add the ctr offset back
  Point.X:=Point.X+Ctr.X;
  Point.Y:=Point.Y+Ctr.Y;
end;

procedure Rotate3DPoint(var Point:TPoint3D;Rz:Single);
var
  Temp : Single;
begin
  Rz:=-Rz;
  with Point do begin
    Temp:=Y*Cos(Rz)-X*Sin(Rz);
    X:=X*Cos(Rz)+Y*Sin(Rz);
    Y:=Temp;
  end;
end;

procedure Rotate3DPointsAboutCenter(var Pt1,Pt2:TPoint3D;Rz:Single);
var
  Ctr : TPoint3D;
begin
// find the ctr of the 2 points
  Ctr.X:=(Pt1.X+Pt2.X)/2;
  Ctr.Y:=(Pt1.Y+Pt2.Y)/2;
  Ctr.Z:=(Pt1.Z+Pt2.Z)/2;

// find the points relative to the center
  Pt1.X:=Pt1.X-Ctr.X;
  Pt1.Y:=Pt1.Y-Ctr.Y;
  Pt2.X:=Pt2.X-Ctr.X;
  Pt2.Y:=Pt2.Y-Ctr.Y;

// rotate them
  Rotate3DPoint(Pt1,Rz);
  Rotate3DPoint(Pt2,Rz);

// add the offsets back
  Pt1.X:=Pt1.X+Ctr.X;
  Pt1.Y:=Pt1.Y+Ctr.Y;
  Pt2.X:=Pt2.X+Ctr.X;
  Pt2.Y:=Pt2.Y+Ctr.Y;
end;

function ThreeDToTwoD(Point,Origin:TPoint3D):TPoint;
begin
  Result.X:=Round((Origin.X*Point.Z-Point.X*Origin.Z)/(Point.Z-Origin.Z));
  Result.Y:=Round((Origin.Y*Point.Z-Point.Y*Origin.Z)/(Point.Z-Origin.Z));
end;

procedure FindPlaneCoefficients(var Plane:TPlane);
begin
// find the plane equation vars
// A = y1 ( z2 - z3 ) + y2 ( z3 - z1 ) + y3 ( z1 - z2 )
// B = z1 ( x2 - x3 ) + z2 ( x3 - x1 ) + z3 ( x1 - x2 )
// C = x1 ( y2 - y3 ) + x2 ( y3 - y1 ) + x3 ( y1 - y2 )
// D = - x1 ( y2z3 - y3z2 ) - x2 ( y3z1 - y1z3 ) - x3 ( y1z2 - y2z1 )
  with Plane do begin
    A:=Point[1].Y*(Point[2].Z-Point[3].Z)+Point[2].Y*(Point[3].Z-Point[1].Z)+
       Point[3].Y*(Point[1].Z-Point[2].Z);
    B:=Point[1].Z*(Point[2].X-Point[3].X)+Point[2].Z*(Point[3].X-Point[1].X)+
       Point[3].Z*(Point[1].X-Point[2].X);
    C:=Point[1].X*(Point[2].Y-Point[3].Y)+Point[2].X*(Point[3].Y-Point[1].Y)+
       Point[3].X*(Point[1].Y-Point[2].Y);
    D:=-Point[1].X*(Point[2].Y*Point[3].Z-Point[3].Y*Point[2].Z)-
       Point[2].X*(Point[3].Y*Point[1].Z-Point[1].Y*Point[3].Z)-
       Point[3].X*(Point[1].Y*Point[2].Z-Point[2].Y*Point[1].Z);
  end;
end;

function AbleToFindTargetOnPlane(var Src,V:TPoint3D;var Plane:TPlane;
                                 var Target:TPoint3D):Boolean;
var
  T,Den : Single;
begin
  with Plane do begin

// find the denominator of the parametric variable equation
    Den:=A*V.X+B*V.Y+C*V.Z;

// if Den=0, the line is parallel to the plane so there's no intersection
    if Den=0 then begin
      Result:=False;
      Exit;
    end;

// find the parametric variable T
    T:=-(A*Src.X+B*Src.Y+C*Src.Z+D)/Den;
  end;

// if T<0, the plane is behind the vector and there's no intersection
  if T<=0 then begin
    Result:=False;
    Exit;
  end;

// find where on the plane the target is
  Target.X:=Src.X+T*V.X;
  Target.Y:=Src.Y+T*V.Y;
  Target.Z:=Src.Z+T*V.Z;

// if the plane is finite, make sure the target is on the plane
  if Plane.Finite then Result:=PointIsOnPlane(Target,Plane)
  else Result:=True;
end;

procedure Normalize(var V:TPoint3D);
var
  D : Single;
begin
  D:=Sqrt(Sqr(V.X)+Sqr(V.Y)+Sqr(V.Z));
  if D<>0 then begin
    V.X:=V.X/D;
    V.Y:=V.Y/D;
    V.Z:=V.Z/D;
  end;
end;

function PlaneFrom2VectorsAndPoint(const V1,V2,Pt:TPoint3D):TPlane;
var
  V3 : TPoint3D;
begin
  V3:=CrossProduct(V1,V2);
  Normalize(V3);
  Result.A:=V3.X;
  Result.B:=V3.Y;
  Result.C:=V3.Z;

// the plane must contain the point
  Result.D:=-(Result.A*Pt.X+Result.B*Pt.Y+Result.C*Pt.Z);
end;

function LineBetweenPointsIntersectsInfinitePlane(P1,P2:TPoint3D;Plane:TPlane;
                                                  var IPoint:TPoint3D):Boolean;
var
  E,F,G,T : Single;
  Denom   : Single;
begin
  with Plane do begin

// The line (L) is defined by the 2 points as follows :
// L:  X=P1.X+(P2.X-P1.X)*T,Y=P1.Y+(P2.Y-P1.Y)*T,Z=P1.Z+(P2.Z-P1.Z)*T
// or  X=P1.X+E*T,Y=P1.Y+F*T,Z=P1.Z+G*T

// find the E,F,G multipliers for the "T" parameter
    try
      E:=P2.X-P1.X; F:=P2.Y-P1.Y; G:=P2.Z-P1.Z;

// solve for T...
      Denom:=A*E+B*F+C*G;
      if Denom=0 then begin
        Result:=False;
        Exit;
      end;
      T:=-(D+A*P1.X+B*P1.Y+C*P1.Z)/Denom;

// plug T into the line equation to find the X,Y,Z intersection point
      IPoint.X:=P1.X+E*T;
      IPoint.Y:=P1.Y+F*T;
      IPoint.Z:=P1.Z+G*T;
      Result:=True;
    except
      Result:=False;
    end;
  end;
end;

function AbleToFindClosestIntersectionPointOfLines(var Target,A1,A2,B1,B2:TPoint3D;
                                                   MaxError:Single):Boolean;
var
  Va,Vb,Vc : TPoint3D;
  PtA,PtB  : TPoint3D;
  PlaneA   : TPlane;
  PlaneB   : TPlane;
  Mag      : Single;
begin
  Result:=False;
  try

// find the vectors of the 2 lines
    Va:=Vector(A1,A2);
    Vb:=Vector(B1,B2);

// normalize them
    Normalize(Va);
    Normalize(Vb);

// find the connecting line vector (perpendicular to both)
    Vc:=CrossProduct(Va,Vb);

// if the magnitude of the perpendicular vector is 0, the lines are parallel
    Mag:=Magnitude(Vc);
    if Mag<0.001 then Exit;

// normalize the perpendicular vector
    Vc.X:=Vc.X/Mag;
    Vc.Y:=Vc.Y/Mag;
    Vc.Z:=Vc.Z/Mag;

// form a plane containing line A1-A2, parallel to Vc, containing point A1
    PlaneA:=PlaneFrom2VectorsAndPoint(Vc,Va,A2);

// form a plane containing line B1-B2, parallel to Vc, containing point B1
    PlaneB:=PlaneFrom2VectorsAndPoint(Vc,Vb,B2);

// closest point on line A1-A2 is line A1-A2 intersection with PlaneB
// closest point on line B1-B2 is line B1-B2 intersection with PlaneA
    if LineBetweenPointsIntersectsInfinitePlane(A1,A2,PlaneB,PtA) and
       LineBetweenPointsIntersectsInfinitePlane(B1,B2,PlaneA,PtB) then
    begin
      if DistanceBetween3DPoints(PtA,PtB)<=MaxError then begin

// return the average of the 2 points
        Target.X:=(PtA.X+PtB.X)/2;
        Target.Y:=(PtA.Y+PtB.Y)/2;
        Target.Z:=(PtA.Z+PtB.Z)/2;
        Result:=True;
      end;
    end;
  except
    Result:=False;
  end;
end;

function RayIntersectsPlane(const Ray:TRay;var Plane:TPlane;var IPoint:TPoint3D):Boolean;
var
  T,Denom : Single;
begin
  with Plane do try

// solve for T...
    Denom:=A*Ray.Vector.X+B*Ray.Vector.Y+C*Ray.Vector.Z;
    if Denom=0 then begin
      Result:=False;
      Exit;
    end;
    T:=-(D+A*Ray.Base.X+B*Ray.Base.Y+C*Ray.Base.Z)/Denom;

// plug T into the line equation to find the X,Y,Z intersection point
    IPoint.X:=Ray.Base.X+Ray.Vector.X*T;
    IPoint.Y:=Ray.Base.Y+Ray.Vector.Y*T;
    IPoint.Z:=Ray.Base.Z+Ray.Vector.Z*T;
    Result:=True;
  except
    Result:=False;
  end;
end;

function AbleToFindClosestIntersectionPointOfRays(const Ray1,Ray2:TRay;
                          MaxError:Single;var PtA,PtB,Target:TPoint3D):Boolean;
var
  Mag           : Single;
  Vc            : TPoint3D;
  PlaneA,PlaneB : TPlane;
begin
  Result:=False;
  try

// find the connecting line vector (perpendicular to both rays)
    Vc:=CrossProduct(Ray1.Vector,Ray2.Vector);

// if the magnitude of the perpendicular vector is 0, the lines are parallel
    Mag:=Magnitude(Vc);
    if Mag<0.001 then Exit;

// form a plane from Ray1.Vector and Vc, containing point Ray1.Base
    PlaneA:=PlaneFrom2VectorsAndPoint(Ray1.Vector,Vc,Ray1.Base);

// form a plane from Ray2.Vector and Vc, containing point Ray2.Base
    PlaneB:=PlaneFrom2VectorsAndPoint(Ray2.Vector,Vc,Ray2.Base);

// closest point on line A1-A2 is line A1-A2 intersection with PlaneB
// closest point on line B1-B2 is line B1-B2 intersection with PlaneA
    if RayIntersectsPlane(Ray1,PlaneB,PtA) and
       RayIntersectsPlane(Ray2,PlaneA,PtB) then
    begin
      if DistanceBetween3DPoints(PtA,PtB)<=MaxError then begin

// return the average of the 2 points
        Target.X:=(PtA.X+PtB.X)/2;
        Target.Y:=(PtA.Y+PtB.Y)/2;
        Target.Z:=(PtA.Z+PtB.Z)/2;
        Result:=True;
      end;
    end;
  except
    Result:=False;
  end;
end;

function ExtendRay(Base,V:TPoint3D;Length:Single):TPoint3D;
begin
  Result.X:=Base.X+V.X*Length;
  Result.Y:=Base.Y+V.Y*Length;
  Result.Z:=Base.Z+V.Z*Length;
end;

function TargetAlongRay(Ray:TRay;R:Single):TPoint3D;
begin
  Normalize(Ray.Vector);
  Result.X:=Ray.Base.X+R*Ray.Vector.X;
  Result.Y:=Ray.Base.Y+R*Ray.Vector.Y;
  Result.Z:=Ray.Base.Z+R*Ray.Vector.Z;
end;

function NetAngle(Pan,Tilt:Single):Single;
var
  X,Y,B : Single;
  DistY : Single;
const
  R : Single = 1;
begin
  X:=R*Tan(Pan);
  DistY:=Sqrt(Sqr(R)+Sqr(X));
  Y:=DistY*Tan(Tilt);
  B:=Sqrt(Sqr(X)+Sqr(Y));
  Result:=ArcTan(B/R);
end;

end.


