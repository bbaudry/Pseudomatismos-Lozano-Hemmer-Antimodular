unit CvTypes;

interface

uses
  Global;

const
  CV_TERMCRIT_ITER = 1;
  CV_TERMCRIT_NUMB = 1;
  CV_TERMCRIT_EPS  = 2;

// rodrigues types
  CV_RODRIGUES_M2V = 0;
  CV_RODRIGUES_V2M = 1;

  CV_8U       = 0;
  CV_8S       = 1;
  CV_16S      = 2;
  CV_32S      = 3;
  CV_32F      = 4;
  CV_64F      = 5;
  CV_USRTYPE1 = 6;
  CV_USRTYPE2 = 7;

  CV_8UC1 = CV_8U + 0*8;
  CV_8UC2 = CV_8U + 1*8;
  CV_8UC3 = CV_8U + 2*8;
  CV_8UC4 = CV_8U + 3*8;

  CV_8SC1 = CV_8S + 0*8;
  CV_8SC2 = CV_8S + 1*8;
  CV_8SC3 = CV_8S + 2*8;
  CV_8SC4 = CV_8S + 3*8;

  CV_16SC1 = CV_16S + 0*8;
  CV_16SC2 = CV_16S + 1*8;
  CV_16SC3 = CV_16S + 2*8;
  CV_16SC4 = CV_16S + 3*8;

  CV_32SC1 = CV_32S + 0*8;
  CV_32SC2 = CV_32S + 1*8;
  CV_32SC3 = CV_32S + 2*8;
  CV_32SC4 = CV_32S + 3*8;

  CV_32FC1 = CV_32F + 0*8;
  CV_32FC2 = CV_32F + 1*8;
  CV_32FC3 = CV_32F + 2*8;
  CV_32FC4 = CV_32F + 3*8;

  CV_64FC1 = CV_64F + 0*8;
  CV_64FC2 = CV_64F + 1*8;
  CV_64FC3 = CV_64F + 2*8;
  CV_64FC4 = CV_64F + 3*8;

  CV_MAT_CN_MASK    = 3 shl 3;
  CV_MAT_DEPTH_MASK = 7;
  CV_MAGIC_MASK     = $FFFF0000;
  CV_MAT_MAGIC_VAL  = $42420000;
  CV_MAT_TYPE_MASK  = 31;

  CV_MAT_CONT_FLAG_SHIFT = 9;
  CV_MAT_CONT_FLAG       = 1 shl CV_MAT_CONT_FLAG_SHIFT;

type
  TCvArr = Byte;
  PCvArr = ^TCvArr;

  TCvRodriguesType = Integer;

  TCv32F = Single;
  PCv32F = ^TCv32F;

  TCv32FArray = array[0..High(Word)] of TCv32F;
  PCv32FArray = ^TCv32FArray;

  TCv64F = Double;
  PCv64F = ^TCv64F;

  TCv64FArray = array[0..High(Word)] of TCv64F;
  PCv64FArray = ^TCv64FArray;

  TCvIntArray = array[0..High(Word)] of Integer;
  PCvIntArray = ^TCvIntArray;

  TCharPtr = ^Char;
  PCharPtr = ^TCharPtr;

  TCvSize = record
    Width,Height : Integer;
  end;

  TCvPoint = record
    X,Y : Integer;
  end;
  PCvPoint = ^TCvPoint;

  TCvPoint2D32F = record
    X,Y : Single;
  end;
  PCvPoint2D32F = ^TCvPoint2D32F;

  TCvPoint2D32FArray = array[0..High(Word)] of TCvPoint2D32F;
  PCvPoint2D32FArray = ^TCvPoint2D32FArray;

  TCvPoint3D32F = record
    X,Y,Z : Single;
  end;
  PCvPoint3D32F = ^TCvPoint3D32F;

  TCvPoint3D32FArray = array[0..High(Word)] of TCvPoint3D32F;
  PCvPoint3D32FArray = ^TCvPoint3D32FArray;

  TCvVect32F = ^Single;
  TCvMatr32F = ^Single;

  TCvVect64D = ^Double;
  TCvMatr64D = ^Double;

  PCvMemBlock = ^TCvMemBlock;
  TCvMemBlock = record
    Prev : PCvMemBlock;
    Next : PCvMemBlock;
  end;

  PCvMemStorage = ^TCvMemStorage;
  TCvMemStorage = record
    Signature : Integer;
    Bottom    : PCvMemBlock;   // first allocated block
    Top       : PCvMemBlock;   // current memory block - top of the stack
    Parent    : PCvMemStorage; // borrows new blocks from
    BlockSize : Integer;       // block size
    FreeSpace : Integer;       // free space in the current block
  end;

  TCvTermCriteria = record
    TermType : Integer; // may be combination of CV_TERMCRIT_ITER, CV_TERMCRIT_EPS
    MaxIter  : Integer;
    Epsilon  : Double;
  end;

  TCvMatrix3 = array[1..3,1..3] of Single;
  PCvMatrix3 = ^TCvMatrix3;

  TCvMat = record
    mType    : Integer;
    Step     : Integer;
    RefCount : Integer; // PCvIntArray;
{    Case Integer of
      0: (Ptr : ^Byte);
      1: (S   : ^ShortInt);
      2: (I   : ^Integer);
      3: (Fl  : ^Single);
      4: (Db  : ^Double);  }
    Data     : ^Single;//Pointer;//Cv64FArray;
    Rows     : Integer;
    Cols     : Integer;
  end;
  PCvMat = ^TCvMat;

function CvMat(Rows,Cols,mType:Integer;Data:Pointer):TCvMat;
function CV_IS_MAT(Mat:PCvMat):Boolean;

implementation

function CV_MAT_CN(Flags:Integer):Integer;
begin
  Result:=((Flags and CV_MAT_CN_MASK) shr 3)+1;
end;

function CV_MAT_DEPTH(Flags:Integer):Integer;
begin
  Result:=(Flags and CV_MAT_DEPTH_MASK);
end;

function CV_ELEM_SIZE(mType:Integer):Integer;
begin
  Result:=CV_MAT_CN(mType) shl (($E90 shr CV_MAT_DEPTH(mType)*2) and 3);
end;

function CV_IS_MAT_HDR(Mat:PCvMat):Boolean;
begin
  Result:=Assigned(Mat) and ((Mat^.mType and CV_MAGIC_MASK)=CV_MAT_MAGIC_VAL);
end;

function CV_MAT_TYPE(Flags:Integer):Integer;
begin
  Result:=Flags and CV_MAT_TYPE_MASK;
end;

// define CV_IS_MAT(mat) \
// (CV_IS_MAT_HDR(mat) && ((const CvMat*)(mat))->data.ptr != NULL)
function CV_IS_MAT(Mat:PCvMat):Boolean;
begin
  Result:=CV_IS_MAT_HDR(Mat) and (Assigned(Mat^.Data));
end;

function CvMat(Rows,Cols,mType:Integer;Data:Pointer):TCvMat;
begin
  Result.mType:=CV_MAT_MAGIC_VAL or CV_MAT_CONT_FLAG or CV_MAT_TYPE(mType);
  Result.Rows:=Rows;
  Result.Cols:=Cols;
  Result.Step:=Cols*CV_ELEM_SIZE(mType);
  Result.Data:=Data;
 // Result.RefCount:=nil;
end;

end.

#define CV_MAT_TYPE_MASK        31
#define CV_MAT_TYPE(flags)      ((flags) & CV_MAT_TYPE_MASK)


CV_INLINE CvMat cvMat( int rows, int cols, int type, void* data CV_DEFAULT(NULL));
CV_INLINE CvMat cvMat( int rows, int cols, int type, void* data )
{
    CvMat m;

    assert( (unsigned)CV_MAT_DEPTH(type) <= CV_64F );
    type = CV_MAT_TYPE(type);
    m.type = CV_MAT_MAGIC_VAL | CV_MAT_CONT_FLAG | type;
    m.cols = cols;
    m.rows = rows;
    m.step = m.cols*CV_ELEM_SIZE(type);
    m.data.ptr = (uchar*)data;
    m.refcount = NULL;

    return m;
}

#define CV_ELEM_SIZE(type) \
    (CV_MAT_CN(type) << ((0xe90 >> CV_MAT_DEPTH(type)*2) & 3))

#define CV_MAT_CN(flags)        ((((flags) & CV_MAT_CN_MASK) >> 3) + 1)

#define CV_MAT_CN_MASK          (3 << 3)


#define CV_MAT_DEPTH(flags)     ((flags) & CV_MAT_DEPTH_MASK)




