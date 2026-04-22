unit FiCommon;

interface

uses
  FireI, DirectShow9, SysUtils;

function FiIsScalableFormat(var ConfigCaps:TVideoStreamConfigCaps):Boolean;

implementation

function FiIsScalableFormat(var ConfigCaps:TVideoStreamConfigCaps):Boolean;
begin
  with ConfigCaps do begin
    Result:=(MinOutputSize.Cx<>MaxOutputSize.Cx) or
            (MinOutputSize.Cy<>MaxOutputSize.Cy) or
            (CropGranularityX=MaxOutputSize.Cx) or
            (CropGranularityY=MaxOutputSize.Cy);
  end;
end;

end.



