unit SuperCellU;

interface

type
  TSuperCell = class(TObject)
  private

  public
    X,Y,W,H : Integer;
    X1,X2   : Integer;
    Y1,Y2   : Integer;
    TX1,TX2 : Single;
    TY1,TY2 : Single;
    Placed  : Boolean;
  end;
  TSuperCellArray = array[1..MaxSuperCells] of TSuperCell;

implementation

end.
