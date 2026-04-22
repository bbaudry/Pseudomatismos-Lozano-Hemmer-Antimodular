#import "FlatSunAppDelegate.h"

#define kAutoChangeSeasons @"AutoChangeSeasons"
#define kMinSeasonSeconds @"MinSeasonSeconds"
#define kMaxSeasonSeconds @"MaxSeasonSeconds"

#define kSwingTime @"SwingTime"

#define kTransitionPercent @"TransitionPercent"

@implementation FlatSunAppDelegate

@synthesize window;

@synthesize autoChangeSeasons;
@synthesize minSeasonSeconds;
@synthesize maxSeasonSeconds;
@synthesize transitionPercent;

+ (void) initialize
{
  [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:

       [NSNumber numberWithInteger : (int) YES], kAutoChangeSeasons,
       [NSNumber numberWithInteger : 10], kMinSeasonSeconds,
       [NSNumber numberWithInteger : 120], kMaxSeasonSeconds,   
       [NSNumber numberWithFloat : 1.5], kSwingTime,   
       [NSNumber numberWithFloat : 0.90], kTransitionPercent,   
       
    nil]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  transitioning = NO;
  
  memset(&seasonHistory, sizeof(seasonHistory), 0);
  historyI = 0;
  [self loadSettings];
  
  if (self.autoChangeSeasons) {
    [self changeSeason];
  }
  else sphere.season = 1;
  
  [glView startThread];
 // [ledPanel open];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *) app
{
  return YES;
}

- (void) applicationWillTerminate:(NSNotification *)notification
{
  [glView shutDown];
  [camera shutDown];
  if (timer) {
    [timer invalidate];
    [timer release];  
  }  
  [self saveSettings];
}

- (void) loadSettings
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  self.autoChangeSeasons = [ud integerForKey : kAutoChangeSeasons];
  self.minSeasonSeconds = [ud integerForKey : kMinSeasonSeconds];
  self.maxSeasonSeconds = [ud integerForKey : kMaxSeasonSeconds];
  self.transitionPercent = [ud integerForKey : kTransitionPercent];
  
  sphere.swingTime = [ud floatForKey : kSwingTime];
}  

- (void) saveSettings 
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

  [ud setInteger : (int) autoChangeSeasons forKey : kAutoChangeSeasons];
  [ud setInteger : minSeasonSeconds forKey : kMinSeasonSeconds];
  [ud setInteger : maxSeasonSeconds forKey : kMaxSeasonSeconds];
  [ud setInteger: transitionPercent forKey : kTransitionPercent];
  [ud setFloat : sphere.swingTime forKey : kSwingTime];
}

- (void) pickNextSeasonChangeTime
{
  float interval = (float) minSeasonSeconds + (float) [Routines randomInt : (maxSeasonSeconds - minSeasonSeconds)];
  
  [timer invalidate];
  [timer release];  
  
  timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerCallBack) userInfo:nil repeats:NO];
  [timer retain];
}  

- (void) setAutoChangeSeasons : (BOOL) autoChange
{
  autoChangeSeasons = autoChange;
  if (autoChange) {
    [self pickNextSeasonChangeTime];
  }    
  else {
    if (timer) {
      [timer invalidate];
      [timer release];
      timer = nil;
    }  
  }
}

- (BOOL) seasonInHistory : (int) s
{
  BOOL result = NO;
  int i = 0;
  
  while ((!result) && (i < MAX_HISTORY)) {
    if (seasonHistory[i] == s) result = YES;
    i++;
  }
  return result;
}

- (void) changeSeason
{
  int s = 1 + [Routines randomInt : 10];
  
  while ([self seasonInHistory : s]) {
    if (s < MAX_SEASONS) s++;
    else s = 1;
  }
  
  sphere.season = s;
  
  seasonHistory[historyI++] = s;
  if (historyI == MAX_HISTORY) historyI = 0;
}

- (void) gotoTransitionSeason
{
  sphere.season = 0;
}

- (void) timerCallBack
{
  if (transitioning) transitioning = NO;
  else {
    int dice = [Routines randomInt : 100];
    transitioning = (dice < transitionPercent);
  }   
  if (transitioning) [self gotoTransitionSeason];
  else [self changeSeason];
  [self pickNextSeasonChangeTime];
}

@end
