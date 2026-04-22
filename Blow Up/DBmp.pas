unit DBmp;

interface

uses
  Windows, Graphics, DirectDraw, DDUtil;

procedure DrawBmpOnSurface(Bmp:TBitmap;Surface:TSurface);

implementation

procedure DrawBmpOnSurface(Bmp:TBitmap;Surface:TSurface);
var
  HBmp : THandle;
  HR   : HResult;
begin
  HBmp:=Bmp.Handle;

// draw the bitmap on the surface
  HR:=Surface.DrawBitmap(HBMP,0,0,0,0);
  if HR<>0 then begin
  end;
end;

end.
 