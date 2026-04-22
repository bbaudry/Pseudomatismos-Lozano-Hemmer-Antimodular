#import <Cocoa/Cocoa.h>

#include <dc1394/dc1394.h>

#include "CamView.h"
#include "Global.h"
#include "Routines.h"

#include "RDView.h"

#include "LedPanelView.h"
#include "GLView.h"

#include "LedPanel.h"

#include "StopWatch.h"
#include "BlobFinder.h"

#include "types.h"

#include "Settings.h"

#include "ITable.h"

#define NORMAL (0)
#define SUBTRACTED (1)
#define THRESHOLDED (2)

#define TABLE_SIZE (256)

@class CamView;
@class LedPanelView;
@class GLView;
@class BlobFinder;
@class ITable;

typedef UInt8 DebayeredData[MAX_IMAGE_W * MAX_IMAGE_H * 3];

typedef UInt8 MonoData[MAX_IMAGE_W * MAX_IMAGE_H];

typedef UInt32 Table[TABLE_SIZE];

dc1394error_t dc1394_bayer_Simple(const uint8_t *restrict bayer, uint8_t *restrict rgb, int sx, int sy, int tile);
dc1394error_t dc1394_capture_schedule_with_runloop (dc1394camera_t * camera, CFRunLoopRef run_loop, CFStringRef run_loop_mode);

typedef void (*dc1394capture_callback_t)(dc1394camera_t *, void *);

dc1394error_t dc1394_capture_set_callback (dc1394camera_t * camera, dc1394capture_callback_t callback, void * user_data);

@interface Camera : NSObject {

  dc1394camera_t *camera;
  dc1394error_t err;
  
  dc1394_t *context;
  dc1394camera_list_t *list;
  
  IBOutlet CamView *camView;
  IBOutlet GLView *glView;
  IBOutlet LedPanelView *ledPanelView;
  
  IBOutlet NSSlider *brightnessSlider;
  IBOutlet NSSlider *exposureSlider;
  IBOutlet NSSlider *gainSlider;
  IBOutlet NSSlider *shutterSlider;
  
  IBOutlet NSMatrix *brightnessModeMatrix;
  IBOutlet NSMatrix *exposureModeMatrix;
  IBOutlet NSMatrix *gainModeMatrix;
  IBOutlet NSMatrix *shutterModeMatrix;
 
  IBOutlet LedPanel *ledPanel;
  
  IBOutlet ReactDiffuse *reactDiffuse1;
  IBOutlet ReactDiffuse *reactDiffuse2;
  
  IBOutlet StopWatch *stopWatch;
  IBOutlet BlobFinder *blobFinder;
  
  IBOutlet Settings *settings;
  
  IBOutlet ITable *iTable;
  
// the debayered frame data  
  DebayeredData oddData;
  DebayeredData evenData;
  MonoData subtractedData;
  
  NSRecursiveLock *lock;
  
  int frameCount;
  int threshold;
  int viewType;
  
  int imageW;
  int imageH;
  
  Table colTable;
  Table rowTable;
  
  UInt8 subtractTable[256][256];
  
  int frameRateIndex;
  
  float tScale;
  BOOL debayer;
  
  int brightness;
  int exposure;
  int gain;
  int shutter;

  int brightnessMode;
  int exposureMode;
  int gainMode;
  int shutterMode;
  
  BOOL flipTexture;
  BOOL mirrorTexture;
  
  BOOL useITable;
  
  float rz;
}

- (void) useFirstDevice;

- (void) fillSubtractTable;


- (CGImageRef) colorImage;
- (CGImageRef) subtractedImage;
- (CGImageRef) thresholdedImage;

- (CGImageRef) selectedImage;

//- (void) start;
//- (void) stop;

- (void) showFeatureInfo : (dc1394feature_info_t) info;
- (dc1394feature_info_t) getFeatureInfo : (dc1394feature_t) feature;

- (void) showFeature : (dc1394feature_t) feature;

- (void) initSlider : (NSSlider *) slider fromFeature : (dc1394feature_t) feature;
- (void) initMatrix : (NSMatrix *) matrix fromFeature : (dc1394feature_t) feature;

- (IBAction) brightessSliderMoved : (id) sender;
- (IBAction) exposureSliderMoved : (id) sender;
- (IBAction) gainSliderMoved : (id) sender;
- (IBAction) shutterSliderMoved:(id)sender;

- (IBAction) calibrateIntensityBtnClicked : (id) sender;

- (void) setFeature : (dc1394feature_t) feature to : (uint32_t) v;

- (void) setBrightnessMode : (int) mode;
- (void) setExposureMode : (int) mode;
- (void) setGainMode : (int) mode;
- (void) setShutterMode: (int) mode;

- (void) findSubtractedData;

- (void) buildTables;
- (void) syncReactDiffuse;

- (void) frameRx  : (dc1394video_frame_t *) frame;
- (void) processFrame;

- (void) shutDown;
- (void) prep;

- (UInt8 *) subtractedDataPtr;

- (void) setFrameRateIndex : (int) index;

- (UInt8 *) currentData;

- (void) findSubtractedMonoData;

- (void) applyFrameRateIndex;
- (void) applyAsTexture;

- (void) loadSettings;
- (void) saveSettings;

- (void) applyLock;
- (void) removeLock;

- (void) applyAsTextureForMode : (CamMode) mode;

@property int threshold;
@property int viewType;

@property int imageW;
@property int imageH;

@property (nonatomic) int frameRateIndex;
@property float tScale;
@property BOOL debayer;

@property (nonatomic) int brightness;
@property (nonatomic) int exposure;
@property (nonatomic) int gain;
@property (nonatomic) int shutter;

@property (nonatomic) int brightnessMode;
@property (nonatomic) int exposureMode;
@property (nonatomic) int gainMode;
@property (nonatomic) int shutterMode;

@property (nonatomic) BOOL useITable;

@property BOOL mirrorTexture;
@property BOOL flipTexture;

@property float rz;

@end
