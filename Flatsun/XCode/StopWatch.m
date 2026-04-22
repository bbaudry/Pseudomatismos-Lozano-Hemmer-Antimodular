#import "StopWatch.h"
#include <sys/time.h>

@implementation StopWatch

- (id) init
{
	if (self = [super init]) {
    [self reset];
	}
	return self;
}

- (void) reset
{
  int c;
  for (c=0; c < SWChannels; c++) {
    channel[c].minTime = -1; 
    channel[c].maxTime = 0;
    channel[c].avgTime = 0;
    channel[c].startTime = 0;
    channel[c].stopTime = 0;
    channel[c].time = 0;
    channel[c].avgSum = 0;
    channel[c].samples = 0;  
  }
}

+ (double) currentSeconds
{
  struct timeval time;
  gettimeofday(&time,nil);
  double seconds =  time.tv_sec + (double) (time.tv_usec)/1000000;
  return seconds;
}

- (void) start:(int)ch;
{
  channel[ch].startTime = [StopWatch currentSeconds]; 
}

- (void) stop:(int)ch;
{
// make sure we've started 
  if (channel[ch].startTime == 0) return;
  
// record the stop time
  channel[ch].stopTime = [StopWatch currentSeconds];

// calculate the time for this sample of this channel
  channel[ch].time = channel[ch].stopTime - channel[ch].startTime;
  
// update min  
  if ((channel[ch].time < channel[ch].minTime) || (channel[ch].minTime == -1)) {
    channel[ch].minTime = channel[ch].time;
  }  
  
// update max  
  if (channel[ch].time > channel[ch].maxTime) {
    channel[ch].maxTime = channel[ch].time;
  }
  
// update average  
  channel[ch].avgSum = channel[ch].avgSum + channel[ch].time;
  channel[ch].samples++;
  channel[ch].avgTime = channel[ch].avgSum / channel[ch].samples;
}

- (double) minTime : (int) ch
{
  return (channel[ch].minTime);
}
  
- (double) maxTime : (int) ch
{
  return (channel[ch].maxTime);
}

- (double) avgTime : (int) ch
{
  return (channel[ch].avgTime);
}

- (double) lastTime : (int) ch
{
  return (channel[ch].time);
}

- (NSString *) channelStr : (int) ch
{
  return [NSString stringWithFormat : @"Avg: %f Last: %f", channel[ch].avgTime, channel[ch].time];
}  

@end
