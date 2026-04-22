unit VCellU;

interface

uses
  Windows, Classes, Global, Jpeg, Graphics, SysUtils;

const
  DefaultA       = 40;
  MinV           = 6;
  MaxV           = 50;
  MinScrubFrames = 12;

type
  TScrubMode = (smNone,smIntro,smEyeContact,smExtro);

  TVideoCell = class(TObject)
  private
    DrawnScrubMode : TScrubMode;

    function RandomV:Single;
    procedure FindAccAndDecVars;

  public
    X,Y,W,H : Integer;
    VideoI  : Integer;

// frame
    Frame        : Single;
    FrameI       : Integer;
    TgtFrame     : Integer;
    FirstFrame   : Integer;
    LastFrame    : Integer;

// velocity and acceleration
    Velocity     : Single;
    StartV       : Single;
    TgtVelocity  : Single;
    Acceleration : Single;

// times
    Time           : Single;
    AccEndTime     : Single;
    DecStartTime   : Single;
    ScrubTime      : Single;
    ScrubStartTime : DWord;

    ScrubMode  : TScrubMode;
    Video      : PVideo;
    DrawnFrame : Integer;

    constructor Create;

    procedure ScrubIntro;
    procedure ScrubEyeContact;
    procedure ScrubExtro;
    procedure UpdateScrubbing(SysTime:DWord);

    procedure InitForTracking;

    procedure DrawOnBmp(Bmp:TBitmap);
    procedure DrawCenter(Bmp:TBitmap);
    procedure DrawFrameBmp(Bmp:TBitmap);
    procedure DrawVelocityBmp(Bmp:TBitmap);
    procedure ShowDetails(Lines:TStrings);
  end;

implementation

uses
  BmpUtils, Routines, TilerU;

constructor TVideoCell.Create;
begin
  inherited;
end;

procedure TVideoCell.InitForTracking;
begin
  ScrubMode:=smIntro;
  FirstFrame:=Video^.IntroStart;
  LastFrame:=Video^.IntroEnd;
  Frame:=FirstFrame;
  FrameI:=FirstFrame;
  TgtFrame:=LastFrame;
  Velocity:=VideoFPS;
  TgtVelocity:=Velocity;
  FindAccAndDecVars;
  DrawnFrame:=0;
  DrawnScrubMode:=smNone;
end;

procedure TVideoCell.DrawFrameBmp(Bmp:TBitmap);
const
  Border = 10;
var
  PixelsPerFrame : Single;
  ZoneRect       : TRect;
  X              : Integer;

function FramesToXPixels(F:Integer):Integer;
begin
  Result:=Round((F-1)*PixelsPerFrame);
end;

begin
  PixelsPerFrame:=Bmp.Width/Video^.Duration;
  ZoneRect.Top:=Border;
  ZoneRect.Bottom:=Bmp.Height-Border;
  with Bmp.Canvas do begin
    ClearBmp(Bmp,clBlack);

// intro
    ZoneRect.Left:=FramesToXPixels(Video^.IntroStart);
    ZoneRect.Right:=FramesToXPixels(Video^.IntroEnd);
    Brush.Color:=clRed;
    FillRect(ZoneRect);

// eye contact
    ZoneRect.Left:=FramesToXPixels(Video^.EyeContactStart);
    ZoneRect.Right:=FramesToXPixels(Video^.EyeContactEnd);
    Brush.Color:=clGreen;
    FillRect(ZoneRect);

// extro
    ZoneRect.Left:=FramesToXPixels(Video^.ExtroStart);
    ZoneRect.Right:=FramesToXPixels(Video^.ExtroEnd);
    Brush.Color:=clBlue;
    FillRect(ZoneRect);

// current frame
    Pen.Color:=clYellow;
    X:=FramesToXPixels(Round(Frame));
    MoveTo(X,0);
    LineTo(X,Bmp.Height);
  end;
end;

procedure TVideoCell.DrawVelocityBmp(Bmp:TBitmap);
var
  X,Y,MidY        : Integer;
  PixelsPerSecond : Single;
  PixelsPerV      : Single;
begin
  PixelsPerSecond:=Bmp.Width/ScrubTime;

  MidY:=Bmp.Height div 2;
  PixelsPerV:=MidY/MaxV;

  ClearBmp(Bmp,$ABCDEF);
  with Bmp.Canvas do begin

// center line
    Pen.Color:=clBlack;
    Pen.Style:=psDash;
    MoveTo(0,MidY);
    LineTo(Bmp.Width,MidY);

// the graph
    Pen.Color:=clRed;
    Pen.Style:=psSolid;
    Y:=MidY-Round(PixelsPerV*StartV);
    MoveTo(0,Y);
    X:=Round(AccEndTime*PixelsPerSecond);
    Y:=MidY-Round(PixelsPerV*TgtVelocity);
    LineTo(X,Y);
    X:=Round(DecStartTime*PixelsPerSecond);
    LineTo(X,Y);
    LineTo(Bmp.Width-1,MidY);

    Pen.Color:=clFuchsia;
    X:=Round(Time*PixelsPerSecond);
    MoveTo(X,0);
    LineTo(X,Bmp.Height);
  end;
end;

function TVideoCell.RandomV:Single;
begin
  if Random(100)<50 then Result:=VideoFPS
  else Result:=MinV+RandomFraction*(MaxV-MinV);
//Result:=VideoFPS;
end;

// always going from the eye to the intro but we might have not made it out of
// the intro yet
procedure TVideoCell.ScrubIntro;
begin
  FirstFrame:=Video^.IntroEnd-VideoFPS;
  if FirstFrame<Video^.IntroStart then FirstFrame:=Video^.IntroStart;
  LastFrame:=Video^.IntroEnd;
  TgtFrame:=FirstFrame;
  TgtVelocity:=-VideoFPS;
  ScrubMode:=smIntro;
  FindAccAndDecVars;
end;

procedure TVideoCell.ScrubEyeContact;
begin
  FirstFrame:=Video^.EyeContactStart;
  LastFrame:=Video^.EyeContactEnd;
  if ScrubMode=smIntro then begin
    TgtFrame:=LastFrame;
    TgtVelocity:=+VideoFPS;
  end
  else begin
    TgtFrame:=FirstFrame;
    TgtVelocity:=-VideoFPS;
  end;
  ScrubMode:=smEyeContact;
  FindAccAndDecVars;
end;

procedure TVideoCell.ScrubExtro;
begin
  FirstFrame:=Video^.ExtroStart;
  LastFrame:=FirstFrame+VideoFPS;
  if LastFrame>Video^.ExtroEnd then LastFrame:=Video^.ExtroEnd;
  TgtFrame:=LastFrame;
  TgtVelocity:=+VideoFPS;
  ScrubMode:=smExtro;
  FindAccAndDecVars;
end;

procedure TVideoCell.UpdateScrubbing(SysTime:DWord);
var
  LastTime    : Single;
  TimeElapsed : Single;
begin
  LastTime:=Time;
  Time:=(SysTime-ScrubStartTime)/1000;
  TimeElapsed:=Time-LastTime;

// update the velocity
  if Time<=AccEndTime then Velocity:=Velocity+Acceleration*TimeElapsed
  else if Time>=DecStartTime then Velocity:=Velocity-Acceleration*TimeElapsed;

// update the position if we're still scrubbing
  if Time<ScrubTime then begin
    Frame:=Frame+Velocity*TimeElapsed;
  end

// automatically re-scrub in the other direction if we're done
  else begin

// set the frame to the target frame
    Frame:=TgtFrame;
    Velocity:=0;

// pick a new velocity in the other direction
    if TgtVelocity>0 then TgtVelocity:=-RandomV
    else TgtVelocity:=+RandomV;

// pick a new target frame
    if TgtVelocity>0 then begin
      TgtFrame:=Round(Frame+MinScrubFrames);
      if TgtFrame>LastFrame then TgtFrame:=LastFrame
      else TgtFrame:=TgtFrame+Random(LastFrame-TgtFrame);
    end
    else begin
      TgtFrame:=Round(Frame-MinScrubFrames);
      if TgtFrame<FirstFrame then TgtFrame:=FirstFrame
      else TgtFrame:=TgtFrame-Random(TgtFrame-FirstFrame);
    end;
    FindAccAndDecVars;
  end;
end;

procedure TVideoCell.ShowDetails(Lines:TStrings);
begin
  with Lines do begin
    Add('Time: '+TimeStr(Time));
    Add('End acceleration time: '+TimeStr(AccEndTime));
    Add('Start deceleration time: '+TimeStr(DecStartTime));
    Add('End time: '+TimeStr(ScrubTime));
    Add('Frame: '+FloatToStrF(Frame,ffFixed,9,1));
    Add('Target frame: '+IntToStr(TgtFrame));
    Add('Velocity: '+VelocityStr(Velocity));
    Add('Target velocity: '+VelocityStr(TgtVelocity));
    Add('');
  end;
end;

procedure TVideoCell.FindAccAndDecVars;
var
  Vi,Vi2,Vf,Vf2      : Single;
  Dv,D,MinA      : Single;
  DistA,DistTv,DistD : Single;
  TimeD,TimeTv       : Single;
begin
  StartV:=Velocity;
  Time:=0;
  ScrubStartTime:=GetTickCount;

// intermediate vars
  Vi:=Velocity;       // initial V
  Vf:=TgtVelocity;    // target V
  Dv:=Vf-Vi;          // change in V
  Vf2:=Vf*Vf;
  Vi2:=Vi*Vi;
  D:=TgtFrame-Frame;

// find the mininum acceleration so that we reach the target V and then get back
// down to zero by the time we reach the target frame
  if D=0 then begin
    ScrubTime:=0;
    Exit;
  end
  else MinA:=(2*Vf2-Vi2)/(2*D);

// go with the default if we're lower - the V will remain at a peak before
// decelerating
  if MinA>0 then begin
    if MinA<DefaultA then Acceleration:=DefaultA
    else Acceleration:=MinA;
  end
  else begin
    if Abs(MinA)<DefaultA then Acceleration:=-DefaultA
    else Acceleration:=MinA;
  end;

// find the time when we stop accelerating
  if Acceleration=0 then begin
    AccEndTime:=0;
    ScrubTime:=0;
    Exit;
  end
  else AccEndTime:=Dv/Acceleration;

// find the distance travelled while accelerating
  DistA:=(Vf2-Vi2)/(2*Acceleration);

// find the distance travelled while decelerating
  DistD:=Vf2/(2*Acceleration);

// find the time spent decelerating
  TimeD:=Vf/Acceleration;

// the rest of the distance is covered at target speed
  DistTv:=D-(DistA+DistD);

// find the time spend at target speed
  TimeTv:=DistTv/Vf;

// find the time to start decelerating
  DecStartTime:=AccEndTime+TimeTv;

// find the total scrub time
  ScrubTime:=DecStartTime+TimeD;
end;

procedure TVideoCell.DrawOnBmp(Bmp:TBitmap);
begin
  if (not Assigned(Video)) or (Video^.Number=0) then Exit;
  FrameI:=Round(Frame);
  if FrameI<Video^.IntroStart then FrameI:=Video^.IntroStart
  else if FrameI>Video^.ExtroEnd then FrameI:=Video^.ExtroEnd;
  if ((FrameI<>DrawnFrame) or (ScrubMode<>DrawnScrubMode)) then begin
    if Assigned(Video^.BmpData[FrameI]) then begin
      if ScrubMode=smEyeContact then begin
        CopyBmpDataToBmpAsm(Video^.BmpData[FrameI],Bmp,Video^.Palette,X,Y);
      end
      else CopyBmpDataToBmpAsm(Video^.BmpData[FrameI],Bmp,Video^.DimPalette,X,Y);
    end;
    DrawnFrame:=FrameI;
    DrawnScrubMode:=ScrubMode;
  end;
end;

procedure TVideoCell.DrawCenter(Bmp:TBitmap);
const
  R = 4;
var
  Xc,Yc : Integer;
begin
  with Bmp.Canvas do begin
    Xc:=X+(W div 2);
    Yc:=Y+(H div 2);
    Ellipse(Xc-R,Yc-R,Xc+R,Yc+R);
  end;
end;

end.
