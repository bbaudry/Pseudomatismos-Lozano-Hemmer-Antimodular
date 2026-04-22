unit MatrixU;

interface

uses
  Classes, Global, OpenCV_CXCORE, OpenCV, OpenCV1;

const
  MaxSize = 20;

type
  TVector = array[1..MaxSize] of Single;
  TVectorArray = array[1..MaxSize] of TVector;

  TMatrixUpdateEvent = procedure(Sender:TObject;Msg:String) of Object;

  TMatrix = class(TObject)
  private
    function  RowStr(RowI:Integer):String;
    procedure ReduceToEchelon;
    procedure InitSubMatrix(var SubMatrix:TMatrix;xR,xC:Integer);
    function  ClosestMatchOfTwo(BaseV,V1,V2:Single):Integer;
    function  ClosestMatchOfFour(BaseV,V1,V2,V3,V4:Single):Integer;
    function  AngleFromSinAndCos(SinA,CosA:Single):Single;
    function  CellStr(R,C:Integer):String;

  public
    Cell     : TVectorArray; // stored as [Row,Column]
    RowCount : Integer;
    ColCount : Integer;
    OnUpdate : TMatrixUpdateEvent;

    constructor Create(Rows,Columns:Integer);

    procedure MultiplyRowByScalar(RowI:Integer;Scalar:Single);
    function  AbleToSolveWithGaussJordanReduction:Boolean;
    procedure SwapRows(R1,R2:Integer);
    procedure SubtractRows(R1,R2:Integer);

    procedure DisplayInLines(Lines:TStrings;Txt:String);
    function  PunctuatedRowStr(RowI:Integer):String;
    procedure DisplayInLinesWithPunctuation(Lines:TStrings;Txt:String);

    procedure InitFromProduct(M1,M2:TMatrix);
    procedure Invert;
    procedure PseudoInvert;
    function  Determinant:Single;
    function  AbleToExtractCameraPose(var Pose:TPose):Boolean;
    procedure Transpose;
    procedure FindEigenValues;
    procedure SVD(var W:TVector;V:TMatrix);
    procedure Scale(V:Single);
    procedure SetAsIdentity(Size:Integer);
    procedure InitFromPosition(X,Y,Z:Single);

    procedure InitAsRx(Rx:Single);
    procedure InitAsRy(Ry:Single);
    procedure InitAsRz(Rz:Single);

    procedure InitAsRx4x4(Rx:Single);
    procedure InitAsRy4x4(Ry:Single);
    procedure InitAsRz4x4(Rz:Single);

    procedure InitFromPose(Pose:TPose);
    procedure InitFromPose2(Pose:TPose);
    procedure InitFromPose3(Pose:TPose);
    procedure InitAsSimiliarity(Angle,S,Tx,Ty:Single);

    procedure Multiply(M:TMatrix);
    function  MultiplyPoint3D(Point:TPoint3D):TPoint3D;
    procedure Normalize;
    function  MultiplyVector(V:TVector):TVector;
    procedure SolveWithSVD;
    procedure Equals(M:TMatrix);
    procedure InitAsRotation(Rx,Ry,Rz:Single);
    procedure MultiplyByScalar(S:Single);

// K parameters extraction routines
    function  ExtractKInfoFromBVector:TKInfo;
    function  ExtractKInfoFromIAC:TKInfo;

    procedure SetAsIACFromKInfo(Params:TKInfo);
    procedure SetAsIACFromBVector(B:TMatrix);

    function  ColumnVector(C:Integer):TVector;
    function  MultiplyByColumnVector(V:TVector):TVector;
    function  Norm:Single;
    procedure FixRotationMatrix;
    procedure SetAsEFromKAndF(K,F:TMatrix);
    procedure FindRxRyRz(var Rx,Ry,Rz:Single);
    procedure InitAsRFromR1AndR2(R1,R2:TPoint3D);

    procedure InitFromKInfo3x3(KInfo:TKInfo);
    procedure InitFromKInfo4x4(KInfo:TKInfo);
    procedure SetAsHFromKInfoAndPose(KInfo:TKInfo;Pose:TPose);

    procedure InitFromData3x3(Data:TMatrixData3x3);
    function  GetData3x3:TMatrixData3x3;

    procedure InitFromData3x4(Data:TMatrixData3x4);
    function  GetData3x4:TMatrixData3x4;
  end;

var
  FMatrix : TMatrix;

function VectorStr(V:TVector;Length:Integer):String;

implementation

uses
  SysUtils, Dialogs, Math, Main, OpenCV_CV;

function VectorStr(V:TVector;Length:Integer):String;
var
  I : Integer;
begin
  Result:='{';
  for I:=1 to Length do begin
    if I>1 then Result:=Result+', ';
    Result:=Result+FloatToStrF(V[I],ffFixed,9,6);
  end;  
  Result:=Result+'}';
end;

constructor TMatrix.Create(Rows,Columns:Integer);
begin
  inherited Create;
  OnUpdate:=nil;
  ColCount:=Columns;
  RowCount:=Rows;
  FillChar(Cell,SizeOf(Cell),0);
end;

procedure TMatrix.MultiplyRowByScalar(RowI:Integer;Scalar:Single);
var
  C : Integer;
begin
  for C:=1 to ColCount do Cell[RowI,C]:=Cell[RowI,C]*Scalar;
end;

procedure TMatrix.MultiplyByScalar(S:Single);
var
  R,C : Integer;
begin
  for R:=1 to RowCount do for C:=1 to ColCount do Cell[R,C]:=Cell[R,C]*S;
end;

procedure TMatrix.SwapRows(R1,R2:Integer);
var
  Temp : TVector;
  C    : Integer;
begin
  for C:=1 to ColCount do begin
    Temp[C]:=Cell[R1,C];
    Cell[R1,C]:=Cell[R2,C];
    Cell[R2,C]:=Temp[C];
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Row[R1] = Row[R1] - Row[R2]
////////////////////////////////////////////////////////////////////////////////
procedure TMatrix.SubtractRows(R1,R2:Integer);
var
  C : Integer;
begin
  for C:=1 to ColCount do Cell[R1,C]:=Cell[R1,C]-Cell[R2,C];
end;

function TMatrix.CellStr(R,C:Integer):String;
begin
  Result:=FloatToStrF(Abs(Cell[R,C]),ffFixed,9,6);
  if Cell[R,C]<=-1000 then Result:='-'+Result
  else if Cell[R,C]<=-0100 then Result:=' -'+Result
  else if Cell[R,C]<=-0010 then Result:='  -'+Result
  else if Cell[R,C]<=-0000 then Result:='   -'+Result
  else if Cell[R,C]< +0010 then Result:='    '+Result
  else if Cell[R,C]< +0100 then Result:='   '+Result
  else if Cell[R,C]< +1000 then Result:='  '+Result
  else Result:=' '+Result
end;

function TMatrix.RowStr(RowI:Integer):String;
var
  C : Integer;
begin
  Result:='';
  for C:=1 to ColCount do begin
    Result:=Result+' '+CellStr(RowI,C);
  end;
end;

procedure TMatrix.DisplayInLines(Lines:TStrings;Txt:String);
var
  R : Integer;
begin
  Lines.Add('');
  Lines.Add(Txt);
  for R:=1 to RowCount do Lines.Add(RowStr(R));
end;

function TMatrix.PunctuatedRowStr(RowI:Integer):String;
var
  C : Integer;
begin
  Result:='{';
  for C:=1 to ColCount do begin
    Result:=Result+FloatToStrF(Cell[RowI,C],ffFixed,9,6);
    if C<ColCount then Result:=Result+',';
  end;
  Result:=Result+'}';
end;

procedure TMatrix.DisplayInLinesWithPunctuation(Lines:TStrings;Txt:String);
var
  R : Integer;
begin
  Lines.Add('');
  Lines.Add(Txt);
  if RowCount=0 then Lines.Add('{Empty}')
  else if RowCount=1 then Lines.Add('{{'+PunctuatedRowStr(1)+'}}')
  else begin
    Lines.Add('{'+PunctuatedRowStr(1)+',');
    for R:=2 to RowCount-1 do Lines.Add(PunctuatedRowStr(R)+',');
    Lines.Add(PunctuatedRowStr(RowCount)+'}');
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Reduces the matrix by GJR
////////////////////////////////////////////////////////////////////////////////
function TMatrix.AbleToSolveWithGaussJordanReduction:Boolean;
var
  R,C1,C2 : Integer;
  Scale   : Single;
begin
  if Assigned(OnUpdate) then OnUpdate(Self,'Original matrix');
  Result:=False;

// must have 1 more column than rows for this to work
  Assert(ColCount=RowCount+1,'TMatrix.AbleToSolveWithGJR:Wrong size for GJR');

// first put the matrix in echelon form
// ie : 1 x x x
//      0 1 x x
//      0 0 1 x
  ReduceToEchelon;

// for debugging
  if Assigned(OnUpdate) then OnUpdate(Self,'Echelon form');

// now put the matrix in reduced echelon form
// ie x 0 0 x
//    0 x 0 x
//    0 0 x x

// loop through the rows
  for R:=1 to RowCount-1 do begin

// make all the elements to the right of the leading 1 (at Cell[R,R]) = 0
     for C1:=R+1 to RowCount do begin
       Scale:=Cell[R,C1];
       for C2:=C1 to ColCount do begin
         Cell[R,C2]:=Cell[R,C2]-Cell[C1,C2]*Scale;
       end;
     end;
  end;
  if Assigned(OnUpdate) then OnUpdate(Self,'Reduced echelon');

// we're done
  Result:=True;
end;

procedure TMatrix.InitFromProduct(M1,M2:TMatrix);
var
  I,R,C : Integer;
begin
// for this to work, the # of columns of M1 must = the  * of rows of M2
  Assert(M1.ColCount=M2.RowCount,'TMatrix.InitFromProduct: Wrong size');

// RowCount = M1's row count, ColCount = M2's column count
  ColCount:=M2.ColCount;
  RowCount:=M1.RowCount;
  for C:=1 to ColCount do for R:=1 to RowCount do begin
    Cell[R,C]:=0;
    for I:=1 to M2.RowCount do begin
      Cell[R,C]:=Cell[R,C]+M1.Cell[R,I]*M2.Cell[I,C];
    end;
  end;
end;

procedure TMatrix.Multiply(M:TMatrix);
var
  I,R,C        : Integer;
  OriginalCell : TVectorArray;
begin
  OriginalCell:=Cell;

// for this to work, the # of columns must = the  * of rows of M
  Assert(ColCount=M.RowCount,'TMatrix.Multiply: Wrong size');

// RowCount = our row count, ColCount = M's column count
  ColCount:=M.ColCount;
  RowCount:=RowCount;
  for C:=1 to ColCount do for R:=1 to RowCount do begin
    Cell[R,C]:=0;
    for I:=1 to M.RowCount do begin
      Cell[R,C]:=Cell[R,C]+OriginalCell[R,I]*M.Cell[I,C];
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Reduces the matrix to :
//   1 x x x x
//   0 1 x x x
//   0 0 1 x x
////////////////////////////////////////////////////////////////////////////////
procedure TMatrix.ReduceToEchelon;
var
  D,R,C : Integer;
  Found : Boolean;
  Scale : Single;
begin
  D:=0;
  repeat
    Inc(D);

// if this cell is a zero, swap this row with the next one
    if Cell[D,D]=0 then begin

// make sure we're not on the last row
      if D<RowCount then begin

// look for the next row with a non-zero element at Cell[D,D]
        R:=D;
        repeat
          Inc(R);
          Found:=(Cell[R,D]<>0);
        until Found or (R=RowCount);

// if we can't find a non-zero element the matrix can't be reduced
        if not Found then Exit

// if we found one, swap the rows
        else SwapRows(D,R);
      end;
    end;

// make Cell[D,D] = 1
    Scale:=1/Cell[D,D];
    for C:=D to ColCount do Cell[D,C]:=Cell[D,C]*Scale;

// make Cell[D+1..RowCount,D] = 0
    if D<RowCount then for R:=D+1 to RowCount do begin
      Scale:=Cell[R,D];
      for C:=1 to ColCount do begin
        Cell[R,C]:=Cell[R,C]-Cell[D,C]*Scale;
      end;
    end;
  until (D>=RowCount);
end;

procedure TMatrix.Invert;
var
  M     : TMatrix;
  R,C,I : Integer;
  Scale : Single;
begin
// the matrix must be square
  if RowCount<>ColCount then begin
    ShowMessage('Can''t invert a non-square matrix');
    Exit;
  end;

// M = Self | [ I ]
  M:=TMatrix.Create(RowCount,ColCount*2);
  try
    for R:=1 to RowCount do for C:=1 to ColCount do begin
      M.Cell[R,C]:=Cell[R,C];
      if R=C then M.Cell[R,ColCount+C]:=1
      else M.Cell[R,ColCount+C]:=0;
    end;

// Row reduce M to this (3x3 ex):
//   1 0 0 x x x
//   0 1 0 x x x
//   0 0 1 x x x
// if we can do this Self^-1 = the x's

// Reduce to Echelon
//   1 x x x x x
//   0 1 x x x x
//   0 0 1 x x x
    M.ReduceToEchelon;

// make the left side the identity matrix
    for R:=1 to RowCount-1 do begin
      for I:=R+1 to ColCount do begin
        Scale:=M.Cell[R,I];
        for C:=I to M.ColCount do begin
          M.Cell[R,C]:=M.Cell[R,C]-M.Cell[I,C]*Scale;
        end;
      end;
    end;

// copy the inverse over
    for R:=1 to RowCount do for C:=1 to ColCount do begin
      Cell[R,C]:=M.Cell[R,ColCount+C];
    end;
  finally
    M.Free;
  end;
end;

procedure TMatrix.InitSubMatrix(var SubMatrix:TMatrix;xR,xC:Integer);
var
  I1,I2,R,C : Integer;
begin
  SubMatrix.RowCount:=RowCount-1;
  SubMatrix.ColCount:=ColCount-1;
  R:=0;
  for I1:=1 to RowCount do if I1<>xR then begin
    Inc(R);
    C:=0;
    for I2:=1 to ColCount do if I2<>xC then begin
      Inc(C);
      SubMatrix.Cell[R,C]:=Cell[I1,I2];
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Returns the determinant of a square matrix.
// Calls itself recursively until the submatrix gets down to 2x2.
////////////////////////////////////////////////////////////////////////////////
function TMatrix.Determinant:Single;
var
  SubMatrix : TMatrix;
  Mult      : Single;
  R,C       : Integer;
begin
// the matrix must be square
  if ColCount<>RowCount then begin
    ShowMessage('Attempt to find determinant of a non-square matrix');
    Exit;
  end;
  if ColCount=1 then Result:=0
  else if ColCount=2 then Result:=Cell[1,1]*Cell[2,2]-Cell[1,2]*Cell[2,1]
  else begin

// set the row fixed at 1 and loop through the columns
    Result:=0;
    R:=1;
    SubMatrix:=TMatrix.Create(RowCount-1,ColCount-1);
    try
      for C:=1 to ColCount do begin
        if Odd(R+C) then Mult:=-Cell[R,C]
        else Mult:=+Cell[R,C];
        InitSubMatrix(SubMatrix,R,C);
        Result:=Result+Mult*SubMatrix.Determinant;
      end;
    finally
      SubMatrix.Free;
    end;
  end;
end;

function TMatrix.ClosestMatchOfTwo(BaseV,V1,V2:Single):Integer;
var
  E1,E2 : Single;
begin
// find the errors
  E1:=Abs(BaseV-V1); E2:=Abs(BaseV-V2);

// return the one with the smallest error
  if E1<E2 then Result:=1
  else Result:=2;
end;

function TMatrix.ClosestMatchOfFour(BaseV,V1,V2,V3,V4:Single):Integer;
var
  E1,E2,E3,E4 : Single;
begin
// find the errors
  E1:=Abs(BaseV-V1); E2:=Abs(BaseV-V2); E3:=Abs(BaseV-V3); E4:=Abs(BaseV-V4);

// return the one with the smallest error
  if (E1<E2) and (E1<E3) and (E1<E4) then Result:=1
  else if (E2<E1) and (E2<E3) and (E2<E4) then Result:=2
  else if (E3<E1) and (E3<E2) and (E3<E4) then Result:=3
  else Result:=4;
end;

function TMatrix.AngleFromSinAndCos(SinA,CosA:Single):Single;
begin
// put the angle between 0 and Pi/2 at first
  Result:=ArcTan(Abs(SinA)/Abs(CosA));

// set the quadrant
  if (CosA<0) and (SinA>0) then Result:=Pi-Result
  else if (CosA<0) and (SinA<0) then Result:=-Pi+Result
  else if (CosA>0) and (SinA<0) then Result:=-Result;
end;

////////////////////////////////////////////////////////////////////////////////
// Decomposes the transform (3x4) matrix to find the camera parameters and
// camera Pose.
// Algorithm taken from :
//   Decomposition of Transformation Matrices for Robot Vision
//   Proceedin gs of the International Conference on Robotics : 1984 p.130-139
//   Sunduram Ganapathy  (U of A Cameron SciTech - TJ211I59)
////////////////////////////////////////////////////////////////////////////////
function TMatrix.AbleToExtractCameraPose(var Pose:TPose):Boolean;
var
  Q,QSqr                  : Single;
  A,B,C,D,E,F,G,H,I,P,R   : Single;
  Ap,Bp,Cp,Gp,Hp,Ip       : Single;
  L11,L12,L13             : Single;
  L21,L22,L23             : Single;
  L31,L32,L33             : Single;
  K1,K2,K2Mag,K1Sqr,K2Sqr : Single;
  U0,V0,U0Mag,V0Mag,Skew  : Single;
  V1,V2,V3,V4,SinA,CosA   : Single;
  BestV                   : Integer;
  K,RT,T                  : TMatrix;
begin
// make sure the matrix is the right size
  if (RowCount<>3) or (ColCount<>4) then begin
    ShowMessage('Matrix must be 3x4 to extract Pose');
    Exit;
  end;
  try

// find Q
    QSqr:=1/(Sqr(Cell[3,1])+Sqr(Cell[3,2])+Sqr(Cell[3,3]));
    Q:=Sqrt(QSqr);

// find the lambdas
    L31:=Cell[3,1]*QSqr;
    L32:=Cell[3,2]*QSqr;
    L33:=Cell[3,3]*QSqr;
    L11:=Cell[1,1]*L32-Cell[1,2]*L31;
    L12:=Cell[1,2]*L33-Cell[1,3]*L32;
    L13:=Cell[1,3]*L31-Cell[1,1]*L33;
    L21:=Cell[2,1]*L32-Cell[2,2]*L31;
    L22:=Cell[2,2]*L33-Cell[2,3]*L32;
    L23:=Cell[2,3]*L31-Cell[2,1]*L33;

// find K1Sqr, K1 and K2Sqr
    K1Sqr:=Sqr(L11)+Sqr(L12)+Sqr(L13);
    K1:=Sqrt(K1Sqr); // K1 must be positive
    K2Sqr:=Sqr(L21)+Sqr(L22)+Sqr(L23);
    K2Mag:=Sqrt(K2Sqr);

// find the magnitudes of U0 and V0
    U0Mag:=Q*(Sqrt(Sqr(Cell[1,1])+Sqr(Cell[1,2])+Sqr(Cell[1,3])-K1Sqr/QSqr));
    V0Mag:=Q*(Sqrt(Sqr(Cell[2,1])+Sqr(Cell[2,2])+Sqr(Cell[2,3])-K2Sqr/QSqr));

// find D,E,F
    D:=Q*Cell[3,1];
    E:=Q*Cell[3,2];
    F:=Q*Cell[3,3];

// find G',H',I' which should be very close to G,H,I
    Gp:=L12/K1;
    Hp:=L13/K1;
    Ip:=L11/K1;

// |G'| is largest
    if (Abs(Gp)>Abs(Hp)) and (Abs(Gp)>Abs(Ip)) then begin
      V1:=(Q*Cell[2,1]-(-V0Mag)*D)/(-K2Mag);
      V2:=(Q*Cell[2,1]-(-V0Mag)*D)/(+K2Mag);
      V3:=(Q*Cell[2,1]-(+V0Mag)*D)/(-K2Mag);
      V4:=(Q*Cell[2,1]-(+V0Mag)*D)/(+K2Mag);

// find the closest match of G' (L12/K1) to the 4 candidates of G
      BestV:=ClosestMatchOfFour(Gp,V1,V2,V3,V4);
    end

// |H'| is largest
    else if (Abs(Hp)>Abs(Gp)) and (Abs(Hp)>Abs(Ip)) then begin
      V1:=(Q*Cell[2,2]-(-V0Mag)*E)/(-K2Mag);
      V2:=(Q*Cell[2,2]-(-V0Mag)*E)/(+K2Mag);
      V3:=(Q*Cell[2,2]-(+V0Mag)*E)/(-K2Mag);
      V4:=(Q*Cell[2,2]-(+V0Mag)*E)/(+K2Mag);

// find the closest match of H' (L13/K1) to the 4 candidates of H
      BestV:=ClosestMatchOfFour(Hp,V1,V2,V3,V4);
    end

// |I'| is largest
    else begin
      V1:=(Q*Cell[2,3]-(-V0Mag)*F)/(-K2Mag);
      V2:=(Q*Cell[2,3]-(-V0Mag)*F)/(+K2Mag);
      V3:=(Q*Cell[2,3]-(+V0Mag)*F)/(-K2Mag);
      V4:=(Q*Cell[2,3]-(+V0Mag)*F)/(+K2Mag);

// find the closest match of I' (L12/K1) to the 4 candidates of I
      BestV:=ClosestMatchOfFour(Ip,V1,V2,V3,V4);
    end;

// find V0 and K2
    Case BestV of
      1:begin
          V0:=-V0Mag;
          K2:=-K2Mag;
        end;
      2:begin
          V0:=-V0Mag;
          K2:=+K2Mag;
        end;
      3:begin
          V0:=+V0Mag;
          K2:=-K2Mag;
        end;
      4:begin
          V0:=+V0Mag;
          K2:=+K2Mag;
        end;
    end;

// do the same thing with A',B',C' to find the sign of U0
    Ap:=-L22/K2;
    Bp:=-L23/K2;
    Cp:=-L21/K2;

// |A'| is larget
    if (Abs(Ap)>Abs(Bp)) and (Abs(Ap)>Abs(Cp)) then begin
      V1:=(Q*Cell[1,1]-(-U0Mag)*D)/K1;
      V2:=(Q*Cell[1,1]-(+U0Mag)*D)/K1;
      BestV:=ClosestMatchOfTwo(Ap,V1,V2);
    end

// |B'| is larget
    else if (Abs(Bp)>Abs(Ap)) and (Abs(Bp)>Abs(Cp)) then begin
      V1:=(Q*Cell[1,2]-(-U0Mag)*E)/K1;
      V2:=(Q*Cell[1,2]-(+U0Mag)*E)/K1;
      BestV:=ClosestMatchOfTwo(Bp,V1,V2);
    end

// |C'| is larget
    else begin
      V1:=(Q*Cell[1,3]-(-U0Mag)*F)/K1;
      V2:=(Q*Cell[1,3]-(+U0Mag)*F)/K1;
      BestV:=ClosestMatchOfTwo(Cp,V1,V2);
    end;

// set the sign of U0
    Case BestV of
      1: U0:=-U0Mag;
      2: U0:=+U0Mag;
    end;

// find P and R
    P:=(Q*Cell[1,4]-U0*Q)/K1;
    R:=(Q*Cell[2,4]-V0*Q)/K2;

// find the exact values of A,B,C,G,H,I
    A:=(Q*Cell[1,1]-U0*D)/K1;
    B:=(Q*Cell[1,2]-U0*E)/K1;
    C:=(Q*Cell[1,3]-U0*F)/K1;
    G:=(Q*Cell[2,1]-V0*D)/K2;
    H:=(Q*Cell[2,2]-V0*E)/K2;
    I:=(Q*Cell[2,3]-V0*F)/K2;

// find the Pose
    with Pose do begin
      X:=-A*P-D*Q-G*R;
      Y:=-B*P-E*Q-H*R;
      Z:=-C*P-F*Q-I*R;
      Rx:=ArcSin(F); // if Rx = 90.00000 degrees we won't succeed

// find SinRy and CosRy
      SinA:=-C/Cos(Rx);
      CosA:=I/Cos(Rx);
      Ry:=AngleFromSinAndCos(SinA,CosA);

// find SinRz and CosRz
      SinA:=-D/Cos(Rx);
      CosA:=E/Cos(Rx);
      Rz:=AngleFromSinAndCos(SinA,CosA);
    end;

// find the skew of the camera X and Y optical axis
    Skew:=ArcSin(A*G+B*H+C*I);

// if we made it this far we've succeeded
    Result:=True;
  except
    Result:=False;
  end;

// regenerate K
  K:=TMatrix.Create(3,4);
  K.Cell[1,1]:=K1; K.Cell[1,2]:=U0; K.Cell[1,3]:=00; K.Cell[1,4]:=0;
  K.Cell[2,1]:=00; K.Cell[2,2]:=V0; K.Cell[2,3]:=K2; K.Cell[2,4]:=0;
  K.Cell[3,1]:=00; K.Cell[3,2]:=01; K.Cell[3,3]:=00; K.Cell[3,4]:=0;

// regenerate RT
  RT:=TMatrix.Create(4,4);
  RT.Cell[1,1]:=A; RT.Cell[1,2]:=B; RT.Cell[1,3]:=C; RT.Cell[1,4]:=P;
  RT.Cell[2,1]:=D; RT.Cell[2,2]:=E; RT.Cell[2,3]:=F; RT.Cell[2,4]:=Q;
  RT.Cell[3,1]:=G; RT.Cell[3,2]:=H; RT.Cell[3,3]:=I; RT.Cell[3,4]:=R;
  RT.Cell[4,1]:=0; RT.Cell[4,2]:=0; RT.Cell[4,3]:=0; RT.Cell[4,4]:=1;

// combine them
  T:=TMatrix.Create(3,4);
  T.InitFromProduct(K,RT);

// clean up
  T.Free;
  K.Free;
  RT.Free;
end;

procedure TMatrix.Transpose;
var
  R,C,T        : Integer;
  OriginalCell : TVectorArray;
begin
  OriginalCell:=Cell;
  for R:=1 to RowCount do for C:=1 to ColCount do begin
    Cell[C,R]:=OriginalCell[R,C];
  end;
  T:=RowCount;
  RowCount:=ColCount;
  ColCount:=T;
end;

procedure TMatrix.FindEigenValues;
begin
//
end;

// returns Sqrt(Sqr(A)+Sqr(B) without destructive underflow or overflow
function Pythag(A,B:Single):Single;
var
  AbsA,AbsB : Single;
begin
  AbsA:=Abs(A);
  AbsB:=Abs(B);
  if AbsA>AbsB then Result:=AbsA*Sqrt(1+Sqr(AbsB/AbsA))
  else if AbsB=0 then Result:=0
  else Result:=AbsB*Sqrt(1+Sqr(AbsA/AbsB));
end;

function Sign(S,F:Single):Single;
begin
  if F>=0 then Result:=S
  else Result:=-S;
end;

procedure TMatrix.SVD(var W:TVector;V:TMatrix);
var
	Flag,I,ITS,J,JJ,K,L,NM,M,N  : Integer;
	ANorm,C,F,G,H,S,Scale,X,Y,Z : Single;
  RV1                         : TVector;
begin
  M:=RowCount; N:=ColCount;
	G:=0; Scale:=0; ANorm:=0;
  FillChar(RV1,SizeOf(RV1),0);
	for I:=1 to N do begin
		L:=I+1;
		RV1[I]:=Scale*G;
    G:=0;
    S:=0;
    Scale:=0;
    if I<=M then begin
    	for K:=I to M do Scale:=Scale+Abs(Cell[K,I]);
    	if Scale<>0 then begin
   	  	for K:=I to M do begin
	   	  	Cell[K,I]:=Cell[K,I]/Scale;
  		 		S:=S+Cell[K,I]*Cell[K,I];
	  	 	end;
		   	F:=Cell[I,I];
  		 	G:=-Sign(Sqrt(S),F);
	  	 	H:=F*G-S;
  		 	Cell[I,I]:=F-G;
  		 	for J:=L to N do begin
          S:=0;
		   		for K:=I to M do S:=S+Cell[K,I]*Cell[K,J];
  		 		F:=S/H;
  		 		for K:=I to M do Cell[K,J]:=Cell[K,J]+F*Cell[K,I];
  		 	end;
	  		for K:=I to M do Cell[K,I]:=Cell[K,I]*Scale;
  		end;
    end;
  	W[I]:=Scale*G;
    G:=0; S:=0; Scale:=0;
    if (I<=M) and (I<>N) then begin
	  	for K:=L to N do Scale:=Scale+Abs(Cell[I,K]);
  		if Scale<>0 then begin
	  		for K:=L to N do begin
		   		Cell[I,K]:=Cell[I,K]/Scale;
			   	S:=S+Cell[I,K]*Cell[I,K];
  			end;
  			F:=Cell[I,L];
  			G:=-Sign(Sqrt(S),F);
  			H:=F*G-S;
		  	Cell[I,L]:=F-G;
  			for K:=L to N do RV1[K]:=Cell[I,K]/H;
	  		for J:=L to M do begin
          S:=0;
  		  	for K:=L to N do S:=S+Cell[J,K]*Cell[I,K];
  				for K:=L to N do Cell[J,K]:=Cell[J,K]+S*RV1[K];
	  		end;
		  	for K:=L to N do Cell[I,K]:=Cell[I,K]*Scale;
  		end;
  	end;
    ANorm:=Max(ANorm,Abs(W[I])+Abs(RV1[I]));
  end;

	for I:=N downto 1 do begin
		if I<N then begin
			if G<>0 then begin
				for J:=L to N do V.Cell[J,I]:=(Cell[I,J]/Cell[I,L])/G;
				for J:=L to N do begin
          S:=0;
					for K:=L to N do S:=S+Cell[I,K]*V.Cell[K,J];
  				for K:=L to N do V.Cell[K,J]:=V.Cell[K,J]+S*V.Cell[K,I];
        end;
  		end;
  		for J:=L to N do begin
        V.Cell[I,J]:=0;
        V.Cell[J,I]:=0.0;
      end;
 		end;
  	V.Cell[I,I]:=1;
 		G:=RV1[I];
 		L:=I;
  end;
	for I:=Min(M,N) downto 1 do begin
		L:=I+1;
		G:=W[I];
		for J:=L to N do Cell[I,J]:=0;
		if G<>0 then begin
			G:=1/G;
			for J:=L to N do begin
        S:=0;
				for K:=L to M do S:=S+Cell[K,I]*Cell[K,J];
				F:=(S/Cell[I,I])*G;
				for K:=I to M do Cell[K,J]:=Cell[K,J]+F*Cell[K,I];
			end;
			for J:=I to M do Cell[J,I]:=Cell[J,I]*G;
		end
    else for J:=I to M do Cell[J,I]:=0;
		Cell[I,I]:=Cell[I,I]+1;
	end;
	for K:=N downto 1 do begin
		for ITS:=1 to 30 do begin
			Flag:=1;
			for L:=K downto 1 do begin
				NM:=L-1;
				if (Abs(RV1[L])+ANorm)=ANorm then begin
					Flag:=0;
					Break;
				end;
				if (Abs(W[NM])+ANorm)=ANorm then Break;
			end;
			if Flag<>0 then begin
				C:=0;
				S:=1.0;
				for I:=L to K do begin
					F:=S*RV1[I];
					RV1[I]:=C*RV1[I];
					if (Abs(F)+ANorm)=ANorm then Break;
          G:=W[I];
					H:=Pythag(F,G);
					W[I]:=H;
					H:=1/H;
					C:=G*H;
					S:=-F*H;
					for J:=1 to M do begin
						Y:=Cell[J,NM];
						Z:=Cell[J,I];
						Cell[J,NM]:=Y*C+Z*S;
						Cell[J,I]:=Z*C-Y*S;
					end;
				end;
			end;
			Z:=W[K];
			if L=K then begin
				if Z<0 then begin
					W[K]:=-Z;
					for J:=1 to N do V.Cell[J,K]:=-V.Cell[J,K];
				end;
				Break;
			end;
			if ITS=30 then ShowMessage('No SVD convergence in 30 iterations');
			X:=W[L];
			NM:=K-1;
			Y:=W[NM];
			G:=RV1[NM];
			H:=RV1[K];
			F:=((Y-Z)*(Y+Z)+(G-H)*(G+H))/(2*H*Y);
			G:=Pythag(F,1);
			F:=((X-Z)*(X+Z)+H*((Y/(F+Sign(G,F)))-H))/X;
			C:=1; S:=1;
			for J:=L to NM do begin
				I:=J+1;
				G:=RV1[I];
				Y:=W[I];
				H:=S*G;
				G:=C*G;
				Z:=Pythag(F,H);
				RV1[J]:=Z;
				C:=F/Z;
				S:=H/Z;
				F:=X*C+G*S;
				G:=G*C-X*S;
				H:=Y*S;
				Y:=Y*C;
				for JJ:=1 to N do begin
					X:=V.Cell[JJ,J];
					Z:=V.Cell[JJ,I];
					V.Cell[JJ,J]:=X*C+Z*S;
					V.Cell[JJ,I]:=Z*C-X*S;
				end;
				Z:=Pythag(F,H);
				W[J]:=Z;
				if Z<>0 then begin
					Z:=1/Z;
          C:=F*Z;
          S:=H*Z;
				end;
				F:=C*G+S*Y;
				X:=C*Y-S*G;
				for JJ:=1 to M do begin
          Y:=Cell[JJ,J];
					Z:=Cell[JJ,I];
					Cell[JJ,J]:=Y*C+Z*S;
					Cell[JJ,I]:=Z*C-Y*S;
				end;
			end;
			RV1[L]:=0;
			RV1[K]:=F;
			W[K]:=X;
		end;
	end;
end;

procedure TMatrix.Scale(V:Single);
var
  R,C : Integer;
begin
  for R:=1 to RowCount do for C:=1 to ColCount do begin
    Cell[R,C]:=Cell[R,C]*V;
  end;
end;

procedure TMatrix.SetAsIdentity(Size:Integer);
var
  R,C : Integer;
begin
  RowCount:=Size;
  ColCount:=Size;
  for R:=1 to RowCount do for C:=1 to ColCount do begin
    if R=C then Cell[R,C]:=1
    else Cell[R,C]:=0;
  end;
end;

procedure TMatrix.InitFromPosition(X,Y,Z:Single);
begin
  SetAsIdentity(4);
  Cell[1,4]:=-X;
  Cell[2,4]:=-Y;
  Cell[3,4]:=-Z;
end;

procedure TMatrix.InitAsRx(Rx:Single);
begin
  RowCount:=3; ColCount:=3;
  Cell[1,1]:=1; Cell[1,2]:=0;        Cell[1,3]:=0;
  Cell[2,1]:=0; Cell[2,2]:=Cos(Rx);  Cell[2,3]:=Sin(Rx);
  Cell[3,1]:=0; Cell[3,2]:=-Sin(Rx); Cell[3,3]:=Cos(Rx);
end;

procedure TMatrix.InitAsRy(Ry:Single);
begin
  RowCount:=3; ColCount:=3;
  Cell[1,1]:=Cos(Ry); Cell[1,2]:=0; Cell[1,3]:=-Sin(Ry);
  Cell[2,1]:=0;       Cell[2,2]:=1; Cell[2,3]:=0;
  Cell[3,1]:=Sin(Ry); Cell[3,2]:=0; Cell[3,3]:=Cos(Ry);
end;

procedure TMatrix.InitAsRz(Rz:Single);
begin
  RowCount:=3; ColCount:=3;
  Cell[1,1]:=Cos(Rz);  Cell[1,2]:=Sin(Rz); Cell[1,3]:=0;
  Cell[2,1]:=-Sin(Rz); Cell[2,2]:=Cos(Rz); Cell[2,3]:=0;
  Cell[3,1]:=0;        Cell[3,2]:=0;       Cell[3,3]:=1;
end;

procedure TMatrix.InitFromKInfo3x3(KInfo:TKInfo);
begin
  RowCount:=3; ColCount:=3;
  with KInfo do begin
    Cell[1,1]:=K1; Cell[1,2]:=Skew; Cell[1,3]:=Px;
    Cell[2,1]:=0;  Cell[2,2]:=K2;   Cell[2,3]:=Py;
    Cell[3,1]:=0;  Cell[3,2]:=0;    Cell[3,3]:=1;
  end;
end;

procedure TMatrix.InitFromKInfo4x4(KInfo:TKInfo);
begin
  RowCount:=3;
  ColCount:=4;
  with KInfo do begin
    Cell[1,1]:=K1; Cell[1,2]:=Px; Cell[1,3]:=00; Cell[1,4]:=0;
    Cell[2,1]:=00; Cell[2,2]:=Py; Cell[2,3]:=K2; Cell[2,4]:=0;
    Cell[3,1]:=00; Cell[3,2]:=01; Cell[3,3]:=00; Cell[3,4]:=0;
  end;
end;

procedure TMatrix.InitFromPose(Pose:TPose);
var
  A,B,C : Single;
  D,E,F : Single;
  G,H,I : Single;
  P,Q,R : Single;
begin
  with Pose do begin
    A:=Cos(Ry)*Cos(Rz)-Sin(Rz)*Sin(Rx)*Sin(Ry);
    B:=Cos(Ry)*Sin(Rz)+Cos(Rz)*Sin(Rx)*Sin(Ry);
    C:=-Cos(Rx)*Sin(Ry);
    D:=-Sin(Rz)*Cos(Rx);
    E:=Cos(Rz)*Cos(Rx);
    F:=Sin(Rx);
    G:=Cos(Rz)*Sin(Ry)+Sin(Rz)*Sin(Rx)*Cos(Ry);
    H:=Sin(Rz)*Sin(Ry)-Cos(Rz)*Sin(Rx)*Cos(Ry);
    I:=Cos(Rx)*Cos(Ry);
    P:=-(A*X)-(B*Y)-(C*Z);
    Q:=-(D*X)-(E*Y)-(F*Z);
    R:=-(G*X)-(H*Y)-(I*Z);
  end;
  RowCount:=4;
  ColCount:=4;
  Cell[1,1]:=A; Cell[1,2]:=B; Cell[1,3]:=C; Cell[1,4]:=P;
  Cell[2,1]:=D; Cell[2,2]:=E; Cell[2,3]:=F; Cell[2,4]:=Q;
  Cell[3,1]:=G; Cell[3,2]:=H; Cell[3,3]:=I; Cell[3,4]:=R;
  Cell[4,1]:=0; Cell[4,2]:=0; Cell[4,3]:=0; Cell[4,4]:=1;
end;

procedure TMatrix.InitFromPose2(Pose:TPose);
var
  R      : TMatrix;
  nC,nRC : TPoint3D;
begin
  R:=TMatrix.Create(3,3);
  try
    with Pose do R.InitAsRotation(Rx,Ry,Rz);
    Self.Equals(R);

// find -RC
    with Pose do begin
      nC.X:=-X; nC.Y:=-Y; nC.Z:=-Z;
    end;
    nRC:=R.MultiplyPoint3D(nC);

// add this column to form the augmented matrix [R | -RC]
    ColCount:=4;
    Cell[1,4]:=nRC.X;
    Cell[2,4]:=nRC.Y;
    Cell[3,4]:=nRC.Z;
  finally
    R.Free;
  end;
end;

procedure TMatrix.InitAsRx4x4(Rx:Single);
begin
  SetAsIdentity(4);
  Cell[2,2]:=Cos(Rx);  Cell[2,3]:=Sin(Rx);
  Cell[3,2]:=-Sin(Rx); Cell[3,3]:=Cos(Rx);
end;

procedure TMatrix.InitAsRy4x4(Ry:Single);
begin
  SetAsIdentity(4);
  Cell[1,1]:=Cos(Ry); Cell[1,3]:=-Sin(Ry);
  Cell[3,1]:=Sin(Ry); Cell[3,3]:=Cos(Ry);
end;

procedure TMatrix.InitAsRz4x4(Rz:Single);
begin
  SetAsIdentity(4);
  Cell[1,1]:=Cos(Rz);  Cell[1,2]:=Sin(Rz);
  Cell[2,1]:=-Sin(Rz); Cell[2,2]:=Cos(Rz);
end;

procedure TMatrix.InitFromPose3(Pose:TPose);
var
  RxMatrix,RyMatrix : TMatrix;
  RzMatrix,DMatrix  : TMatrix;
begin
  RxMatrix:=TMatrix.Create(4,4);
  RyMatrix:=TMatrix.Create(4,4);
  RzMatrix:=TMatrix.Create(4,4);
  DMatrix:=TMatrix.Create(4,4);
  try
    with Pose do begin
      RxMatrix.InitAsRx4x4(Rx);
      RyMatrix.InitAsRy4x4(Ry);
      RzMatrix.InitAsRz4x4(Rz);
      DMatrix.InitFromPosition(X,Y,Z);
      InitFromProduct(RxMatrix,RyMatrix);
      Multiply(RzMatrix);
      Multiply(DMatrix);
    end;
  finally
    RxMatrix.Free;
    RyMatrix.Free;
    RzMatrix.Free;
    DMatrix.Free;
  end;
end;

// matrix must be 3x4
function TMatrix.MultiplyPoint3D(Point:TPoint3D):TPoint3D;
begin
  Result.X:=Point.X*Cell[1,1]+Point.Y*Cell[2,1]+Point.Z*Cell[3,1]+1*Cell[4,1];
  Result.Y:=Point.X*Cell[1,2]+Point.Y*Cell[2,2]+Point.Z*Cell[3,2]+1*Cell[4,2];
  Result.Z:=Point.X*Cell[1,3]+Point.Y*Cell[2,3]+Point.Z*Cell[3,3]+1*Cell[4,3];
//Result.X:=Point.X*M[0]+Point.Y*M[4]+Point.Z*M[8]+1*M[12];
//Result.Y:=Point.X*M[1]+Point.Y*M[5]+Point.Z*M[9]+1*M[13];
//Result.Z:=Point.X*M[2]+Point.Y*M[6]+Point.Z*M[10]+1*M[14];
end;

procedure TMatrix.Normalize;
var
  R,C : Integer;
  Den : Single;
begin
  Den:=Cell[RowCount,ColCount];
  if Den<>0 then for R:=1 to RowCount do for C:=1 to ColCount do begin
    Cell[R,C]:=Cell[R,C]/Den;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Result = [Self][V] Size of V should be = ColCount
////////////////////////////////////////////////////////////////////////////////
function TMatrix.MultiplyVector(V:TVector):TVector;
var
  R,C : Integer;
begin
  for R:=1 to RowCount do begin
    Result[R]:=0;
    for C:=1 to ColCount do Result[R]:=Result[R]+V[C]*Cell[R,C];
  end;
end;

procedure TMatrix.SolveWithSVD;
var
  W      : TVector;
  V      : TMatrix;
  LowV   : Single;
  I,LowI : Integer;
begin
  V:=TMatrix.Create(ColCount,ColCount);
  try
    SVD(W,V);

    RowCount:=ColCount;
    ColCount:=1;

// find the lowest singular value in W
    LowV:=W[1];
    LowI:=1;
    for I:=2 to RowCount do if (W[I]>0.00001) and (W[I]<LowV) then begin
      LowV:=W[I];
      LowI:=I;
    end;
    for I:=1 to RowCount do Cell[I,1]:=V.Cell[I,LowI];///V.Cell[RowCount,LowI];
  finally
    V.Free;
  end;
end;

procedure TMatrix.Equals(M:TMatrix);
var
  R,C : Integer;
begin
  ColCount:=M.ColCount;
  RowCount:=M.RowCount;
  for R:=1 to RowCount do for C:=1 to ColCount do Cell[R,C]:=M.Cell[R,C];
end;

////////////////////////////////////////////////////////////////////////////////
// From "A Flexible New Technique for Camera Calibration" - Zhengyou Zhang pg.5
////////////////////////////////////////////////////////////////////////////////
procedure TMatrix.SetAsIACFromKInfo(Params:TKInfo);
var
  B11,B12,B13 : Single;
  B22,B23,B33 : Single;
begin
  with Params do begin
// 6 vars define the skew symetric matrix
    B11:=1/Sqr(K1);
    B12:=-Skew/(Sqr(K1)*K2);
    B13:=(Py*Skew-Px*K2)/(K2*Sqr(K1));
    B22:=Sqr(Skew)/(Sqr(K1)+Sqr(K2))+1/Sqr(K2);
    B23:=-Skew/(Sqr(K1)+Sqr(K2))*(Py*Skew-Px*K2)-(Py/Sqr(K2));
    B33:=Sqr(Py*Skew-Px*K2)/(Sqr(K1)+Sqr(K2))+Sqr(Py)/Sqr(K2)+1;

// set the matrix
    Cell[1,1]:=B11; Cell[1,2]:=B12; Cell[1,3]:=B13;
    Cell[2,1]:=B12; Cell[2,2]:=B22; Cell[2,3]:=B23;
    Cell[3,1]:=B13; Cell[3,2]:=B23; Cell[3,3]:=B33;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Matrix should be a 3x3 matrix representing the image of the absolute
// conic. ie Transform([K]^-1) x [K]^-1
////////////////////////////////////////////////////////////////////////////////
function TMatrix.ExtractKInfoFromIAC:TKInfo;
var
  B11,B12,B13 : Single;
  B22,B23,B33 : Single;
begin
// init our B vars
  B11:=Cell[1,1]; B12:=Cell[1,2]; B22:=Cell[2,2];
  B13:=Cell[1,3]; B23:=Cell[2,3]; B33:=Cell[3,3];

// extract our intrinsic parameters
  with Result do begin
    K1:=1/Sqrt(B11);
    K2:=K1/Sqrt((B22*Sqr(K1))-Sqr(B12/B11));
    Skew:=(-B12/B11)*K2;
    Py:=B13*K2-Sqr(K2)*B23;
    Px:=Py*Skew/K2-B13*Sqr(K1);
    K2:=-K2;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Self should be a column matrix containing B11,B12,B22,B13,B23,B33 in that
// order.
////////////////////////////////////////////////////////////////////////////////
function TMatrix.ExtractKInfoFromBVector:TKInfo;
var
  B11,B12,B13 : Single;
  B22,B23,B33 : Single;
  Scale       : Single;
begin
// init our B vars
  B11:=Cell[1,1];
  B12:=Cell[2,1];
  B22:=Cell[3,1];
  B13:=Cell[4,1];
  B23:=Cell[5,1];
  B33:=Cell[6,1];
  with Result do begin
    Py:=(B12*B13-B11*B23)/(B11*B22-B12*B12);
    Scale:=B33-(B13*B13+Py*(B12*B13-B11*B23))/B11;
    K1:=Sqrt(Scale/B11);
    K2:=Sqrt((Scale*B11)/(B11*B22-B12*B12));
    Skew:=-B12*K1*K1*K2/Scale;
    Px:=(Skew*Py/K2)-(B13*K1*K1/Scale);
  end;
end;

procedure TMatrix.SetAsIACFromBVector(B:TMatrix);
var
  B11,B12,B13 : Single;
  B22,B23,B33 : Single;
begin
// copy the B vars from the B vector
  B11:=B.Cell[1,1];
  B12:=B.Cell[2,1];
  B22:=B.Cell[3,1];
  B13:=B.Cell[4,1];
  B23:=B.Cell[5,1];
  B33:=B.Cell[6,1];

// init the matrix
  RowCount:=3;
  ColCount:=3;
  Cell[1,1]:=B11; Cell[1,2]:=B12; Cell[1,3]:=B13;
  Cell[2,1]:=B12; Cell[2,2]:=B22; Cell[2,3]:=B23;
  Cell[3,1]:=B13; Cell[3,2]:=B23; Cell[3,3]:=B33;
end;

procedure TMatrix.InitAsSimiliarity(Angle,S,Tx,Ty:Single);
var
  SinA,CosA : Single;
begin
  RowCount:=3;
  ColCount:=3;
  SinA:=Sin(Angle);
  CosA:=Cos(Angle);
  Cell[1,1]:=S*CosA; Cell[1,2]:=-S*SinA; Cell[1,3]:=Tx;
  Cell[2,1]:=S*SinA; Cell[2,2]:=+S*CosA; Cell[2,3]:=Ty;
  Cell[3,1]:=0;      Cell[3,2]:=0;       Cell[3,3]:=1;
end;

function TMatrix.ColumnVector(C:Integer):TVector;
var
  R : Integer;
begin
  for R:=1 to RowCount do Result[R]:=Cell[R,C];
end;

function TMatrix.MultiplyByColumnVector(V:TVector):TVector;
var
  R,C : Integer;
begin
  for R:=1 to RowCount do begin
    Result[R]:=0;
    for C:=1 to ColCount do begin
      Result[R]:=Result[R]+Cell[R,C]*V[C];
    end;
  end;
end;

function TMatrix.Norm:Single;
var
  C,R : Integer;
begin
  Result:=0;
  for R:=1 to RowCount do for C:=1 to ColCount do Result:=Result+Sqr(Cell[R,C]);
end;

////////////////////////////////////////////////////////////////////////////////
// Self is a 3x3 rotation matrix.
// Algorithm from "A Flexible New Technique for Camera Calibration" - Zhang
// Appendix C.
////////////////////////////////////////////////////////////////////////////////
procedure TMatrix.FixRotationMatrix;
var
  U,V : TMatrix;
  S   : TVector;
begin
  U:=TMatrix.Create(RowCount,ColCount);
  V:=TMatrix.Create(ColCount,ColCount);
  try
    U.Equals(Self);
    U.SVD(S,V);
    V.Transpose;
    InitFromProduct(U,V);
  finally
    U.Free;
    V.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Self is initialized as the essential matrix determined from the intrinsic
// camera matrix K and the fundamental matrix F.
////////////////////////////////////////////////////////////////////////////////
procedure TMatrix.SetAsEFromKAndF(K,F:TMatrix);
var
  KT : TMatrix;
begin
  KT:=TMatrix.Create(3,3);
  try
    KT.Equals(K);
    KT.Transpose;
    Self.InitFromProduct(KT,K);
    Self.Multiply(F);
    Self.Multiply(K);
  finally
    KT.Free;
  end;
end;

procedure TMatrix.InitAsRFromR1AndR2(R1,R2:TPoint3D);
var
  Rx,Ry,Rz : Single;
begin
  Cell[1,1]:=R1.X; Cell[1,2]:=R2.X;
  Cell[2,1]:=R1.Y; Cell[2,2]:=R2.Y;
  Cell[3,1]:=R1.Z; Cell[3,2]:=R2.Z;
  Rz:=ArcTan(-Cell[2,1]/Cell[2,2]);
  Rx:=ArcCos(Cell[2,1]/-Sin(Rz));
  Ry:=ArcSin(-Cell[1,3]/-Cos(Rx));
//  InitFromRxRyRz2(Rx,Ry,Rz);
end;

// Matrix should be a 3x3 rotation matrix
procedure TMatrix.FindRxRyRz(var Rx,Ry,Rz:Single);
var
  RotMatr : PCvMat1;
  RotVect : PCvMat1;
  I,R,C   : Integer;
begin
  Assert(RowCount=3,'');
  Assert(ColCount=3,'');
  RotMatr:=cvCreateMat(3,3,CV_32FC1);
  RotVect:=cvCreateMat(3,1,CV_32FC1);
  try
    I:=0;
    for R:=1 to 3 do for C:=1 to 3 do begin
      PCv32FArray(RotMatr.Data)^[I]:=Cell[R,C];
      Inc(I);
    end;
    OpenCV1.cvRodrigues(RotMatr,RotVect,nil,CV_RODRIGUES_M2V);
    Rx:=PCv32FArray(RotVect.Data)^[0];
    Ry:=PCv32FArray(RotVect.Data)^[1];
    Rz:=PCv32FArray(RotVect.Data)^[2];
  finally
    OpenCV1.cvReleaseMat(RotMatr);
    OpenCV1.cvReleaseMat(RotVect);
  end;
end;

procedure TMatrix.InitAsRotation(Rx,Ry,Rz:Single);
var
  RotMatr : PCvMat1;
  RotVect : PCvMat1;
  I,R,C   : Integer;
begin
  RowCount:=3; ColCount:=3;
  RotMatr:=OpenCV1.cvCreateMat(3,3,CV_32FC1);
  RotVect:=OpenCV1.cvCreateMat(3,1,CV_32FC1);
  try
    PCv32FArray(RotVect.Data)^[0]:=Rx;
    PCv32FArray(RotVect.Data)^[1]:=Ry;
    PCv32FArray(RotVect.Data)^[2]:=Rz;
    OpenCV1.cvRodrigues(RotMatr,RotVect,nil,CV_RODRIGUES_V2M);
    I:=0;
    for R:=1 to 3 do for C:=1 to 3 do begin
      Cell[R,C]:=PCv32FArray(RotMatr.Data)^[I];
      Inc(I);
    end;
  finally
    OpenCV1.cvReleaseMat(RotMatr);
    OpenCV1.cvReleaseMat(RotVect);
  end;
end;

// P*P+ = I; P+ = PT(P*PT)^-1 where PT = Transpose(P)
procedure TMatrix.PseudoInvert;
var
  PT : TMatrix;
begin
  PT:=TMatrix.Create(RowCount,ColCount);
  try
    PT.Equals(Self);
    PT.Transpose;
    Self.Multiply(PT);
    Self.Invert;
    PT.Multiply(Self);
    Self.Equals(PT);
  finally
    PT.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Calculates the H matrix from the plane's R matrix and pose.
//   H = K[R1 R2 T] where T = -R(Pose.XYZ);
////////////////////////////////////////////////////////////////////////////////
procedure TMatrix.SetAsHFromKInfoAndPose(KInfo:TKInfo;Pose:TPose);
var
  RMatrix : TMatrix;
  KMatrix : TMatrix;
  RRT,C,T : TMatrix;
  R       : Integer;
begin
  T:=TMatrix.Create(3,1);
  C:=TMatrix.Create(3,1);
  RRT:=TMatrix.Create(3,3);
  RMatrix:=TMatrix.Create(3,3);
  KMatrix:=TMatrix.Create(3,3);
  try
    with Pose do RMatrix.InitAsRotation(Rx,Ry,Rz);
    RMatrix.FixRotationMatrix;
    KMatrix.InitFromKInfo3x3(KInfo);

// set the camera center
    C.Cell[1,1]:=Pose.X;
    C.Cell[2,1]:=Pose.Y;
    C.Cell[3,1]:=Pose.Z;

// find T = - RC
    T.InitFromProduct(RMatrix,C);
    T.MultiplyByScalar(-1);

// built RRT = [ R1 R2 T ]
    for R:=1 to 3 do begin
      RRT.Cell[R,1]:=RMatrix.Cell[R,1];
      RRT.Cell[R,2]:=RMatrix.Cell[R,2];
      RRT.Cell[R,3]:=T.Cell[R,1];
    end;

// find H
    Self.InitFromProduct(KMatrix,RRT);
    Self.Normalize;
  finally
    T.Free;
    C.Free;
    RRT.Free;
    RMatrix.Free;
    KMatrix.Free;
  end;
end;

procedure TMatrix.InitFromData3x3(Data:TMatrixData3x3);
var
  R,C : Integer;
begin
  for R:=1 to 3 do for C:=1 to 3 do begin
    Cell[R,C]:=Data[R,C];
  end;
end;

function TMatrix.GetData3x3:TMatrixData3x3;
var
  R,C : Integer;
begin
  for R:=1 to 3 do for C:=1 to 3 do begin
    Result[R,C]:=Cell[R,C];
  end;
end;

procedure TMatrix.InitFromData3x4(Data:TMatrixData3x4);
var
  R,C : Integer;
begin
  for R:=1 to 3 do for C:=1 to 4 do begin
    Cell[R,C]:=Data[R,C];
  end;
end;

function TMatrix.GetData3x4:TMatrixData3x4;
var
  R,C : Integer;
begin
  for R:=1 to 3 do for C:=1 to 4 do begin
    Result[R,C]:=Cell[R,C];
  end;
end;

end.


