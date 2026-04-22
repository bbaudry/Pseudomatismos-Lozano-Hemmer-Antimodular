#import <Cocoa/Cocoa.h>

#import "CamView.h"
#import "GLView.h"

#import "Sphere.h"
#import "Camera.h"
#import "LedPanel.h"

#import "Settings.h"

#import "UdpSocket.h"

#import "Serial.h"
#import "Dimmer.h"

#import "Texture.h"

#define MAX_HISTORY (6) 
#define MAX_SEASONS (11)

@class Sphere;
@class LedPanel;
@class UdpSocket;
@class Dimmer;

@interface FlatSunAppDelegate : NSObject <NSApplicationDelegate>
{
  NSWindow *window;

  NSTimer *serialTimer;
  NSTimer *udpTimer;
  NSTimer *timer;
  
  IBOutlet CamView *camView;
  IBOutlet GLView *glView;
  IBOutlet Sphere *sphere;
  IBOutlet Camera *camera;
  IBOutlet LedPanel *ledPanel;
  IBOutlet Settings *settings;
  IBOutlet UdpSocket *udpSocket;
  IBOutlet Serial *serial;
//  IBOutlet Dimmer *dimmer;
  IBOutlet Dimmer *dim;
  IBOutlet Texture *sunTexture;
  
  IBOutlet NSTextField *dimmerInTF;
  
  IBOutlet NSSlider *dimmerSlider;
  IBOutlet NSSlider *overideSlider;
  
  BOOL autoChangeSeasons;
  int minSeasonSeconds;
  int maxSeasonSeconds;
  int transitionPercent;
  
  
  uint64_t seasonChangeTime;
  
  int seasonHistory[MAX_HISTORY];
  int historyI;
  
  BOOL transitioning;
}

- (void) loadSettings;
- (void) saveSettings;
- (void) pickNextSeasonChangeTime;
- (void) changeSeason;

- (void) setDimmer : (UInt8) value;

- (void) playSound : (NSString *) name;

- (void) startUdpTimer;
- (void) startSerialTimer;

- (void) setDimmerFromUdp : (UInt8) value;
- (void) setDimmerBoostFromUdp;

- (IBAction) defaultsBtnClicked : (id) sender;

- (IBAction) overrideSliderMoved : (id) sender;

- (IBAction) shutDownBtnPressed : (id) sender;

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic) BOOL autoChangeSeasons;
@property int minSeasonSeconds;
@property int maxSeasonSeconds;
@property int transitionPercent;

@end
