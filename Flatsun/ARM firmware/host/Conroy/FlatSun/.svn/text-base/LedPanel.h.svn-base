#import <Cocoa/Cocoa.h>

#import "FlatSun/FSInterface.h"
#import "Routines.h"

#define COLS (256)
#define ROWS (256)

#define HALO_LEDS (128)

typedef struct rgStruct {
  unsigned char r;
  unsigned char g;
} RGStruct;

typedef RGStruct RGArray[COLS][ROWS];

typedef struct LedStruct {
  unsigned char intensity;
  BOOL red;
} Led;

typedef struct HaloLedStruct {
  int srcX;
  int srcY;
  unsigned char intensity;
  BOOL red;
} HaloLed;

typedef Led LedArray[COLS][ROWS];

typedef HaloLed Halo[HALO_LEDS];

typedef enum ModModeEnum {mmRed = 0, mmYellow, mmFilter} ModMode;

typedef enum ColorModeEnum {cmSplit,cmCombined} ColorMode;

@interface LedPanel : NSObject {
  BOOL ledOn[COLS][ROWS];  
  
  FSInterface *fsInterface;
  
  float intensity;
  
  Halo halo;
  LedArray led;
  ModMode modMode;
  
  int xOffset;
  int yOffset;
  int pixelsPerLed;
  
  float gain;
  float redGain;
  float yellowGain;
  
  float haloGain;
  
  int minHaloI;
  int maxHaloI;
  
  int masterGain;
  
  float haloR;
  
  ColorMode colorMode;
  NSRecursiveLock *lock;
}

- (void) drawInRect : (NSRect) rect;
//- (void) doDrag : (NSEvent *) event turnOn : (BOOL) setting;
- (void) syncPanel;
- (void) initFromBmp : (NSBitmapImageRep *) bmp;
- (void) drawSourceRectangle;

- (void) syncFromRGArray : (RGArray *) rgArray;

- (void) syncFromBmp : (NSBitmapImageRep *) bmp;
- (void) syncHaloFromBmp : (NSBitmapImageRep *) bmp;

- (void) loadSettings : (int) season;
- (void) saveSettings : (int) season;

- (void) applyDefaults;

- (CGImageRef) image;
- (CGImageRef) haloImage;

- (void) setGain : (float) v;
- (void) setRedGain : (float) v;
- (void) setYellowGain : (float) v;

- (void) applyLock;
- (void) removeLock;

- (void) open;

- (void) placeHaloLeds;

- (IBAction) onBtnPressed : (id) sender;
- (IBAction) offBtnPressed : (id) sender;
- (IBAction) invertBtnPressed : (id) sender;
- (IBAction) intensitySliderMoved : (id) sender;

@property float intensity;

@property int xOffset;
@property int yOffset;
@property int pixelsPerLed;

@property int masterGain;
@property float gain;
@property float redGain;
@property float yellowGain;

@property float haloGain;
@property float haloR;


@property int minHaloI;
@property int maxHaloI;

@property ColorMode colorMode;

@end


