#import <Cocoa/Cocoa.h>

#import "CamView.h"
#import "GLView.h"

#import "Sphere.h"
#import "Camera.h"
#import "LedPanel.h"

#define MAX_HISTORY (6) 
#define MAX_SEASONS (11)

@class Sphere;
@class LedPanel;

@interface FlatSunAppDelegate : NSObject <NSApplicationDelegate>
{
  NSWindow *window;
  
  IBOutlet CamView *camView;
  IBOutlet GLView *glView;
  IBOutlet Sphere *sphere;
  IBOutlet Camera *camera;
  IBOutlet LedPanel *ledPanel;
  
  BOOL autoChangeSeasons;
  int minSeasonSeconds;
  int maxSeasonSeconds;
  int transitionPercent;
  
  NSTimer *timer;
  
  uint64_t seasonChangeTime;
  
  int seasonHistory[MAX_HISTORY];
  int historyI;
  
  BOOL transitioning;
}

- (void) loadSettings;
- (void) saveSettings;
- (void) pickNextSeasonChangeTime;
- (void) changeSeason;

- (void) timerCallBack;

@property (assign) IBOutlet NSWindow *window;

@property BOOL autoChangeSeasons;
@property int minSeasonSeconds;
@property int maxSeasonSeconds;
@property int transitionPercent;

@end
