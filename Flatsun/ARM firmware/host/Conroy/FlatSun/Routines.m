#import "Routines.h"

@implementation Routines

+ (float) randomFraction
{
  long maxRnd = 0x7fffffff;
  float result = (float) random()/maxRnd;
  return result;  
}

+ (long) randomLong : (long) max
{
  float fraction = [self randomFraction];
  long result = (long) (fraction * max);
  return result;
}

+ (int) randomInt : (int) max
{
  float fraction = [self randomFraction];
  return (int) (fraction * max);
}

+ (int) randomUInt64 : (uint64_t) max
{
  float fraction = [self randomFraction];
  return (uint64_t) (fraction * max);
}

+ (NSString *) twoDigitIntStr : (int) value
{
  NSString *result;
  if (value < 10) result = [NSString stringWithFormat:@"0%i",value];
  else result = [NSString stringWithFormat:@"%i",value];
  return result;
}

+ (NSString *) appPath
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *appName = [bundle bundlePath];
  NSString *result = [appName stringByDeletingLastPathComponent];
  return result;
}

+ (NSString *) videoPath
{
  NSString *result = [NSString stringWithString:@"/SolarEquation/Videos"];
  return result;
}

+ (uint64_t) currentMicroseconds
{
  struct timeval time;
  gettimeofday(&time, NULL);
  return ( (time.tv_sec*1000000) + time.tv_usec);
}

+ (NSString *) timeStr : (int) secs
{
  int mins = (int) (secs / 60.0);
  int rSecs = secs - 60 * mins;
  
  NSString *result = [NSString stringWithFormat:@"%@:%@",[Routines twoDigitIntStr:mins],
                        [Routines twoDigitIntStr:rSecs]];
  return result;                        
}

+ (BOOL) odd : (int) v
{
  return  (v & 1);
}

+ (UInt8) clipToByte : (float) value
{
  if (value < 0) return 0;
  if (value > 255) return 255;
  
  return (UInt8) value;
}

+ (int) minIntOf : (int) v1 and : (int) v2
{
  if (v1 <= v2) return v1;
  else return v2; 
}
  
+ (float) degToRad : (float) degs
{
  return (degs / 180.0f) * M_PI;
}
  
@end
