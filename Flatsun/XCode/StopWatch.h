#import <Cocoa/Cocoa.h>
#include <sys/time.h>

#define SWAverages 10
#define SWChannels 10

typedef struct SWChannelStruct {
  double startTime; 
  double stopTime;
  double time;
  double minTime;
  double maxTime;
  double avgTime;
  double avgSum;
  int samples;
} SWChannel;

typedef SWChannel SWChannelArray[SWChannels];

@interface StopWatch : NSObject {
  SWChannelArray channel;   
}

- (void) reset;
- (void) start:(int)channel;
- (void) stop:(int)channel;

- (double) minTime : (int) ch;
- (double) maxTime : (int) ch;
- (double) avgTime : (int) ch;
- (double) lastTime : (int) ch;

- (NSString *) channelStr : (int) ch;


+ (double) currentSeconds;

@end