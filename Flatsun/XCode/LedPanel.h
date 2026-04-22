#import <Cocoa/Cocoa.h>

#import "FlatSun/FSInterface.h"
#import "Routines.h"

#import "Global.h"

#import "Settings.h"

#define COLS (256)
#define ROWS (256)

#define HALO_LEDS (128)

#define PANELS_16 (32)
#define PANELS_8 (24)

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

typedef struct LedTableEntryStruct {
  int x;
  int y;
  float scale;
} LedTableEntry;

typedef LedTableEntry LedTable[COLS][ROWS];

typedef struct PanelStruct {
  int x;
  int y;
} Panel;

typedef Panel Panel16Array[PANELS_16];
typedef Panel Panel8Array[PANELS_8];

typedef struct LedPanelSeasonStruct {
  float gain;
  float redGain;
  float yellowGain;
  float haloGain;
  int minHaloI;
  int maxHaloI;
  ColorMode colorMode;
  int masterGain;
  float haloR;
  float haloY;
} LedPanelSeason;  

//typedef LedPanelSeason LedPanelSeasonArray[SEASONS+1];

@interface LedPanel : NSObject {

  IBOutlet Settings *settings;
  
  struct LedPanelSeasonStruct season[SEASONS+1];
  
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
  float haloY;
  
  ColorMode colorMode;
  NSRecursiveLock *lock;
  
  LedTable ledTable;
  
  Panel16Array panel16;
  Panel8Array panel8;  
}

- (void) drawInRect : (NSRect) rect;
//- (void) doDrag : (NSEvent *) event turnOn : (BOOL) setting;
- (void) syncPanel;
- (void) initFromBmp : (NSBitmapImageRep *) bmp;
- (void) drawSourceRectangle;

- (void) syncFromRGArray : (RGArray *) rgArray;

- (void) syncFromBmp : (NSBitmapImageRep *) bmp;
- (void) syncHaloFromBmp : (NSBitmapImageRep *) bmp;

- (void) loadSettings;
- (void) saveSettings;

- (void) copyVarsFromSeason : (int) s;
- (void) copyVarsToSeason : (int) s;

- (void) applyDefaults;

- (CGImageRef) image;
- (CGImageRef) haloImage;

- (float) getGain;

- (void) setGain : (float) v;
- (void) setRedGain : (float) v;
- (void) setYellowGain : (float) v;

- (void) applyLock;
- (void) removeLock;

- (void) open;

- (void) placeHaloLeds;

- (void) setDimmer : (UInt8) dimmer;

- (IBAction) onBtnPressed : (id) sender;
- (IBAction) offBtnPressed : (id) sender;
- (IBAction) invertBtnPressed : (id) sender;
- (IBAction) intensitySliderMoved : (id) sender;

@property float intensity;

@property int xOffset;
@property int yOffset;
@property int pixelsPerLed;

@property (nonatomic) int masterGain;
@property (nonatomic) float gain;
@property (nonatomic) float redGain;
@property (nonatomic) float yellowGain;

@property (nonatomic) float haloGain;
@property (nonatomic) float haloR;
@property (nonatomic) float haloY;

@property int minHaloI;
@property int maxHaloI;

@property ColorMode colorMode;

@end


