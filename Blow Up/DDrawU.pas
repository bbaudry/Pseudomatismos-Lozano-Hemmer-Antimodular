unit DDrawU;

interface

uses
  DirectDraw, Windows, ActiveX, Classes;

type
  TDirectDraw = class(TObject)
  private
    lpDD             : IDirectDraw7;
    PrimarySurface   : IDirectDrawSurface7;
    SecondarySurface : IDirectDrawSurface7;

  public
    constructor Create;
    destructor  Destroy; override;

    procedure EnumDisplayModes(List:TStringList);
    procedure SetDisplayMode(H,V:Integer);
    procedure CreatePrimarySurface;
    procedure CreateSecondarySurface;

  end;

var
  DDraw : TDirectDraw;

implementation

uses
  Dialogs;

constructor TDirectDraw.Create;
var
  HR : HResult;
begin
  inherited;
  HR:=DirectDrawCreateEx(nil,lpDD,IID_IDirectDraw7,nil);
  if HR<>S_OK then begin
    ShowMessage('Error creating Direct Draw object');
  end;
end;

destructor TDirectDraw.Destroy;
begin
// clean up
  PrimarySurface:=nil;
  SecondarySurface:=nil;
  lpDD:=nil;
  CoUninitialize;
  inherited;
end;

// free the result in the calling routine
procedure TDirectDraw.EnumDisplayModes(List:TStringList);
begin
//lpDD.EnumDisplayModes(DDEDM_0,nil,
end;

procedure TDirectDraw.SetDisplayMode(H,V:Integer);
begin
  lpDD.SetDisplayMode(H,V,32,60,0);
end;

procedure TDirectDraw.CreatePrimarySurface;
var
  ddSD : TDDSurfaceDesc2;
  HR   : HResult;
begin
// prepare the surface description
  FillChar(ddSD,SizeOf(ddSD),0);
  ddSD.dwSize:=SizeOf(ddSD);
  ddSD.dwFlags:=DDSD_CAPS; // ddsCaps is valid
  ddSD.ddsCaps.dwCaps:=DDSCAPS_PRIMARYSURFACE;

// create the surface
  HR:=lpDD.CreateSurface(ddSD,PrimarySurface,nil);
  if HR<>S_OK then ShowMessage('Error creating primary surface.');
end;

procedure TDirectDraw.CreateSecondarySurface;
var
  ddSD : TDDSurfaceDesc2;
  HR   : HResult;
begin
// prepare the surface description
  FillChar(ddSD,SizeOf(ddSD),0);
  ddSD.dwSize:=SizeOf(ddSD);
  ddSD.dwFlags:=DDSD_CAPS or DDSD_WIDTH or DDSD_Height; // ddsCaps, dwWidth, dwHeight are all valid
  ddSD.ddsCaps.dwCaps:=DDSCAPS_OFFSCREENPLAIN;
  ddsd.dwWidth:=100;
  ddsd.dwHeight:=100;

// create the surface
  HR:=lpDD.CreateSurface(ddSD,SecondarySurface,nil);
  if HR<>S_OK then ShowMessage('Error creating secondary surface.');
end;

end.

    function CreateSurface (var lpDDSurfaceDesc: TDDSurfaceDesc;
        out lplpDDSurface: IDirectDrawSurface;
  TDDSurfaceDesc2 = packed record
    dwSize: DWORD;                 // size of the TDDSurfaceDesc structure
    dwFlags: DWORD;                // determines what fields are valid
    dwHeight: DWORD;               // height of surface to be created
    dwWidth: DWORD;                // width of input surface
    case Integer of
    0: (
      lPitch : LongInt;                  // distance to start of next line (return value only)
     );
    1: (
      dwLinearSize : DWORD;              // Formless late-allocated optimized surface size
      dwBackBufferCount: DWORD;          // number of back buffers requested
      case Integer of
      0: (
        dwMipMapCount: DWORD;            // number of mip-map levels requested
        dwAlphaBitDepth: DWORD;          // depth of alpha buffer requested
        dwReserved: DWORD;               // reserved
        lpSurface: Pointer;              // pointer to the associated surface memory
        ddckCKDestOverlay: TDDColorKey;  // color key for destination overlay use
        ddckCKDestBlt: TDDColorKey;      // color key for destination blt use
        ddckCKSrcOverlay: TDDColorKey;   // color key for source overlay use
        ddckCKSrcBlt: TDDColorKey;       // color key for source blt use
        ddpfPixelFormat: TDDPixelFormat; // pixel format description of the surface
        ddsCaps: TDDSCaps2;              // direct draw surface capabilities
        dwTextureStage: DWORD;           // stage in multitexture cascade
       );
      1: (
        dwRefreshRate: DWORD;          // refresh rate (used when display mode is described)
       );
     );
  end;

