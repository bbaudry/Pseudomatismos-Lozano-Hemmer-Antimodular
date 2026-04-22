#import <Cocoa/Cocoa.h>

#import <sys/time.h>

@interface Routines : NSObject {

}

+ (float) randomFraction;
+ (long) randomLong : (long) max;
+ (int) randomInt : (int) max;

+ (NSString *) twoDigitIntStr : (int) value;

+ (NSString *) appPath;
+ (NSString *) videoPath;

+ (uint64_t) currentMicroseconds;

+ (NSString *) timeStr : (int) secs;

+ (BOOL) odd : (int) v;

+ (UInt8) clipToByte : (float) value;

+ (int) minIntOf : (int) v1 and : (int) v2;

+ (float) degToRad : (float) degs;
+ (int) randomUInt64 : (uint64_t) max;

@end
