#import "Dimmer.h"

@implementation Dimmer

@synthesize value;

- (void) awakeFromNib
{
  fade.active = NO;
  fade.endValue = 0;
  value = 0;
  boost.active = NO;
  boost.armed = YES;
  [self startTimer];
}

- (void) dealloc
{
  [timer invalidate];
  [timer release];
  [super dealloc];
}

- (void) update : (UInt8) newValue
{
// see if we're above the boost trigger level
  if (newValue >= BOOST_TRIGGER_VALUE) {
  
// going into boost mode
    if (boost.armed & (!boost.active)) {
      boost.active = YES;
      boost.armed = NO;
      boost.startTime = [StopWatch currentSeconds];
      boost.remaining = BOOST_SECONDS;
      [self fadeTo : BOOST_VALUE withDuration : BOOST_UP_SECONDS];
    }
  }
  
// if we're not above the trigger level, see if we should turn off the boost
  else if (boost.active) {
    UInt8 fadeValue;
    
    if (newValue == 1) fadeValue = 1;
    else fadeValue = (UInt8) (newValue >> 1);
    
    boost.active = NO;
    [self fadeTo : fadeValue withDuration : STATIC_SECONDS];
  }
  
// if we're below the trigger level or if the boost isn't armed (or active) - go to 50%  
  if ((newValue < BOOST_TRIGGER_VALUE) | !(boost.armed | boost.active)) {
    UInt8 fadeValue;
    if (newValue == 1) fadeValue = 1;
    else fadeValue = (UInt8) (newValue >> 1);
    
    if (fadeValue != fade.endValue) {
      [self fadeTo : fadeValue withDuration : STATIC_SECONDS];
    }
  }  
  
  
// see if we're below the boost arm level
  if (newValue <= BOOST_ARM_VALUE) {
    boost.armed = YES;
  }
}

- (void) startTimer
{
  timer = [NSTimer scheduledTimerWithTimeInterval : 0.050
                                                 target : self
                                               selector : @selector(timerCallBack)
                        									     userInfo : nil
                                                repeats : YES];
  [timer retain];
}

- (void) syncTF
{
// boost
  if (boost.active) {
    [boostTF setStringValue : [NSString stringWithFormat : @"Boost: %3.1f", boost.remaining]];
  }
  else [boostTF setStringValue : @"Boost: NO"];
    
// fade    
  if (fade.active) {
    [fadeTF setStringValue : [NSString stringWithFormat : @"Fade: %3.1f", fade.fraction * 100]];
  }
  else [fadeTF setStringValue : @"Fade: NO"];
  
// value    
  [valueTF setStringValue : [NSString stringWithFormat : @"Value: %i", value]];
}

- (void) fadeTo : (UInt8) fadeValue withDuration : (float) duration;
{
  fade.startTime = [StopWatch currentSeconds];
  fade.startValue = value;
  fade.endValue = fadeValue;
  fade.duration = duration;
  fade.active = YES;
}  

-(void) jumpTo : (UInt8) newValue
{
  fade.active = NO;
  value = newValue;
}

- (void) updateFade
{
// find how much time has gone by
  double time = [StopWatch currentSeconds];
  double elapsed = time - fade.startTime;
 
// convert it to a fraction of its duration  
  fade.fraction = elapsed / fade.duration;
  
// we're done if the duration >= 1.0
  if (fade.fraction >= 1.0) {
    value = fade.endValue;
    fade.active = NO;
  }
  
// otherwise, linearly interpolate our value from the start and end values
  else {
    value = (UInt8) (fade.startValue + (fade.endValue - fade.startValue) * fade.fraction);
  }
  [self syncTF];
}

- (void) updateBoost
{
  double time = [StopWatch currentSeconds];
  boost.remaining = BOOST_SECONDS - (time - boost.startTime);
  if (boost.remaining <= 0.0) {
    boost.active = NO;
    [self fadeTo : MAX_STATIC_VALUE withDuration : BOOST_DOWN_SECONDS];
  }
  [self syncTF];
}

- (void) timerCallBack
{
  if (fade.active) [self updateFade];
  if (boost.active) [self updateBoost];
  
//  double time = [StopWatch currentSeconds];
  
//  float fraction;
  
}

@end
