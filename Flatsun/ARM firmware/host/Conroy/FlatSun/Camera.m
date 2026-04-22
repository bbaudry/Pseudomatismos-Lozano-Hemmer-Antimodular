#import "Camera.h"

#define kCameraBrightness @"kCameraBrightness"
#define kCameraExposure @"kCameraExposure"
#define kCameraGain @"kCameraGain"
#define kCameraShutter @"kCameraShutter"

#define kCameraBrightnessMode @"kCameraBrightnessMode"
#define kCameraExposureMode @"kCameraExposureMode"
#define kCameraGainMode @"kCameraGainMode"
#define kCameraShutterMode @"kCameraShutterMode"

#define kCameraFrameRateIndex @"kCameraFrameRateIndex"
#define kCameraDebayer @"kCameraDebayer"

#define kCameraMirrorTexture @"kCameraMirrorTexture"
#define kCameraFlipTexture @"kCameraFlipTexture"

static void FrameCallback(dc1394camera_t *c, void *data)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  
  dc1394video_frame_t * frame;
  
  int err = dc1394_capture_dequeue(c, DC1394_CAPTURE_POLICY_POLL, &frame);
  if (frame) {
  
    Camera *camera = (Camera *) data;
    
    [camera applyLock];
      [camera frameRx : frame];
      err = dc1394_capture_enqueue(c, frame);
      [camera processFrame];
    [camera removeLock];
  }
  
  [pool release];  
}

@implementation Camera

@synthesize threshold;
@synthesize viewType;

@synthesize imageW;
@synthesize imageH;

@synthesize frameRateIndex;

@synthesize tScale;
@synthesize debayer;

@synthesize brightness;
@synthesize exposure;
@synthesize gain;
@synthesize shutter;

@synthesize brightnessMode;
@synthesize exposureMode;
@synthesize gainMode;
@synthesize shutterMode;


@synthesize mirrorTexture;
@synthesize flipTexture;

+ (void) initialize
{
  [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
     
       [NSNumber numberWithInteger : 0], kCameraBrightness, 
       [NSNumber numberWithInteger : 100], kCameraExposure, 
       [NSNumber numberWithInteger : 20], kCameraGain, 
       [NSNumber numberWithInteger : 10], kCameraShutter, 
       [NSNumber numberWithInteger : 0], kCameraBrightnessMode, 
       [NSNumber numberWithInteger : 0], kCameraExposureMode, 
       [NSNumber numberWithInteger : 0], kCameraGainMode, 
       [NSNumber numberWithInteger : 0], kCameraShutterMode, 
       [NSNumber numberWithInteger : 0], kCameraFrameRateIndex,
       [NSNumber numberWithInteger : 1], kCameraDebayer,
       [NSNumber numberWithInteger : 1], kCameraFlipTexture,
       [NSNumber numberWithInteger : 1], kCameraMirrorTexture,
       
    nil]];
}

- (id) init 
{ 
  if (self = [super init]) {
  }
  return self;
}

- (void) dealloc
{
  [lock release];
  [super dealloc];
}

- (void) loadSettings
{
   NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
   
  self.brightness = [ud integerForKey : kCameraBrightness];
  self.exposure = [ud integerForKey : kCameraExposure];
  self.gain = [ud integerForKey : kCameraGain];
  self.shutter = [ud integerForKey : kCameraShutter];

  self.brightnessMode = [ud integerForKey : kCameraBrightnessMode];
  self.exposureMode = [ud integerForKey : kCameraExposureMode];
  self.gainMode = [ud integerForKey : kCameraGainMode];
  self.shutterMode = [ud integerForKey:kCameraShutterMode];
  
  self.frameRateIndex = [ud integerForKey : kCameraFrameRateIndex];
  self.debayer = [ud integerForKey : kCameraDebayer];
  
  self.flipTexture = (BOOL) [ud integerForKey : kCameraFlipTexture];
  self.mirrorTexture = (BOOL) [ud integerForKey : kCameraMirrorTexture];
}

- (void) saveSettings
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

  [ud setInteger : brightness forKey : kCameraBrightness];
  [ud setInteger : exposure forKey : kCameraExposure];
  [ud setInteger : gain forKey : kCameraGain];
  [ud setInteger : shutter forKey : kCameraShutter];
  
  [ud setInteger : brightnessMode forKey : kCameraBrightnessMode];
  [ud setInteger : exposureMode forKey : kCameraExposureMode];
  [ud setInteger : gainMode forKey : kCameraGainMode];
  [ud setInteger : shutterMode forKey : kCameraShutterMode];
  
  [ud setInteger : frameRateIndex forKey : kCameraFrameRateIndex];
  [ud setInteger : (int) debayer forKey : kCameraDebayer];

  [ud setInteger : (int) flipTexture forKey : kCameraFlipTexture];  
  [ud setInteger : (int) mirrorTexture forKey : kCameraMirrorTexture];
}

- (void) applyLock 
{ 
  [lock lock];
}

- (void) removeLock 
{ 
  [lock unlock];
}

- (void) setBrightnessMode : (int) mode
{
  brightnessMode = mode;
  if (!camera) return;
  
  err = dc1394_feature_set_mode(camera, DC1394_FEATURE_BRIGHTNESS, mode + DC1394_FEATURE_MODE_MIN);
  [self initMatrix : brightnessModeMatrix fromFeature : DC1394_FEATURE_BRIGHTNESS];  
}  

- (void) setExposureMode : (int) mode
{
  exposureMode = mode;
  if (!camera) return;
  
  err = dc1394_feature_set_mode(camera, DC1394_FEATURE_EXPOSURE, mode + DC1394_FEATURE_MODE_MIN);
  
  [self initMatrix : exposureModeMatrix fromFeature : DC1394_FEATURE_EXPOSURE];  
}  

- (void) setGainMode : (int) mode
{
  gainMode = mode;
  if (!camera) return;
  
  err = dc1394_feature_set_mode(camera, DC1394_FEATURE_GAIN, mode + DC1394_FEATURE_MODE_MIN);
  [self initMatrix : gainModeMatrix fromFeature : DC1394_FEATURE_GAIN];  
}  

- (void) setShutterMode : (int) mode
{
    shutterMode = mode;
    if (!camera) return;
    
    err = dc1394_feature_set_mode(camera, DC1394_FEATURE_SHUTTER, mode + DC1394_FEATURE_MODE_MIN);
    [self initMatrix : shutterModeMatrix fromFeature : DC1394_FEATURE_SHUTTER];  
}  

- (void) initMatrix : (NSMatrix *) matrix fromFeature : (dc1394feature_t) feature
{
  if (!camera) return;
  
  dc1394feature_modes_t modes; 
  err = dc1394_feature_get_modes(camera, feature, &modes);

  NSButtonCell *manualRB = [matrix cellAtRow : 0 column : 0];
  NSButtonCell *autoRB = [matrix cellAtRow : 0 column : 1];
  NSButtonCell *onePushRB = [matrix cellAtRow : 0 column : 2];
  
  
// hide non-applicable modes  
  if (!modes.modes[0]) [manualRB setTransparent : YES];
  if (!modes.modes[1]) [autoRB setTransparent : YES];
  if (!modes.modes[2]) [onePushRB setTransparent : YES];
  
// show the selected mode
  dc1394feature_info_t info = [self getFeatureInfo : feature];
  
  switch (info.current_mode) {
  
    case DC1394_FEATURE_MODE_MANUAL : 
      [manualRB setState : 1];
      [autoRB setState : 0];
      [onePushRB setState : 0];
      break;
      
    case DC1394_FEATURE_MODE_AUTO :
      [manualRB setState : 0];
      [autoRB setState : 1];
      [onePushRB setState : 0];
      break;
      
    case DC1394_FEATURE_MODE_ONE_PUSH_AUTO :
      [manualRB setState : 0];
      [autoRB setState : 0];
      [onePushRB setState : 1];
      break;
  }  
}
  
- (void) setBrightness : (int) v
{ 
  brightness = v;
 [self setFeature : DC1394_FEATURE_BRIGHTNESS to : brightness];
}

- (void) setExposure : (int) v
{
  exposure = v;
 [self setFeature : DC1394_FEATURE_EXPOSURE to : exposure];
}

- (void) setGain : (int) v
{
  gain = v;
 [self setFeature : DC1394_FEATURE_GAIN to : gain];
}

- (void) setShutter : (int) v
{
    gain = v;
    [self setFeature : DC1394_FEATURE_SHUTTER to : gain];
}

// called when a new frame comes in 
// just draw the color image and get out so the frame can be re-queued
- (void) frameRx  : (dc1394video_frame_t *) frame
{
//[stopWatch start : 0];  

  imageW = (*frame).size[0];
  imageH = (*frame).size[1];
  
  frameCount++;
  
  UInt8 *data = [self currentData];
  
  if (debayer) { 
    err = dc1394_bayer_Simple((*frame).image, data, imageW, imageH, DC1394_COLOR_FILTER_RGGB);
  }
  else memcpy(data, (*frame).image, imageW * imageH);
}

// frame is dequeued so no need to rush 
- (void) processFrame
{
  if (debayer) {
    [self findSubtractedData];
    [blobFinder findBlobsFromMonoData : &subtractedData[0] withWidth : imageW andHeight : imageH];
    
  }    
  else {
    [self findSubtractedMonoData];
    [blobFinder findBlobsFromMonoData : &subtractedData[0] withWidth : imageW andHeight : imageH];
  }  
  
  [camView setNeedsDisplay : YES];
}

- (UInt8 *) currentData
{
  UInt8 *data;
  
  if ([Routines odd : frameCount]) data = (UInt8 *) &oddData[0];
  else data = (UInt8 *) &evenData[0];
  return data;
}

- (void) awakeFromNib
{
  lock = [[NSRecursiveLock alloc] init];
  [lock retain];
  
  self.threshold = 100;
  self.viewType = NORMAL;
  self.tScale = 1.0;
  self.debayer = YES;
  
  [self buildTables];

  [self prep];
  [self useFirstDevice];
  [self loadSettings];
  
  [self showFeature : DC1394_FEATURE_BRIGHTNESS];
  [self showFeature : DC1394_FEATURE_EXPOSURE];
  [self showFeature : DC1394_FEATURE_GAIN];
  
  [self initSlider : brightnessSlider fromFeature : DC1394_FEATURE_BRIGHTNESS];
  [self initSlider : exposureSlider fromFeature : DC1394_FEATURE_EXPOSURE];
  [self initSlider : gainSlider fromFeature : DC1394_FEATURE_GAIN];
    
    [self initSlider : shutterSlider fromFeature : DC1394_FEATURE_SHUTTER];
  
  [self initMatrix : brightnessModeMatrix fromFeature : DC1394_FEATURE_BRIGHTNESS];  
  [self initMatrix : exposureModeMatrix fromFeature : DC1394_FEATURE_EXPOSURE];  
  [self initMatrix : gainModeMatrix fromFeature : DC1394_FEATURE_GAIN];  

    [self initMatrix : shutterModeMatrix fromFeature : DC1394_FEATURE_SHUTTER];  
}

- (void) initSlider : (NSSlider *) slider fromFeature : (dc1394feature_t) feature
{
  dc1394feature_info_t info = [self getFeatureInfo : feature];
  
  slider.minValue = info.min;
  slider.maxValue = info.max;
  [slider setIntValue : (int) info.value];
  slider.tag = (int) feature;
}  

- (IBAction) brightessSliderMoved : (id) sender
{ 
  brightness = [brightnessSlider intValue];
  
  [self setFeature : DC1394_FEATURE_BRIGHTNESS to : brightness];
}

- (IBAction) exposureSliderMoved : (id) sender
{
  exposure = [exposureSlider intValue];
  
  [self setFeature : DC1394_FEATURE_EXPOSURE to : exposure];
}

- (IBAction) gainSliderMoved : (id) sender
{
  gain = [gainSlider intValue];
  
  [self setFeature : DC1394_FEATURE_GAIN to : gain];
}

- (IBAction)shutterSliderMoved:(id)sender 
{
    shutter = [shutterSlider intValue];
    [self setFeature: DC1394_FEATURE_SHUTTER to:shutter];
}

- (void) setFeature : (dc1394feature_t) feature to : (uint32_t) v
{
  if (!camera) return;
    NSLog(@"setFeature: %d %d", feature, v);

  err = dc1394_feature_set_value(camera, feature, v);
}

- (void) prep
{
  context = dc1394_new();
  
 if (!context) return;
 
  err = dc1394_camera_enumerate(context, &list);  
  if (err != DC1394_SUCCESS) {
    NSLog(@"Failed to enumerate cameras");
    return;
  }  

// make sure there's at least 1 camera
  if (list->num == 0) { 
    NSLog(@"No cameras found");                                                 
    return;
  }

// take the first one
  camera = dc1394_camera_new(context, list->ids[0].guid);                     
  if (!camera) {
    NSLog(@"Failed to initialize camera with guid %llx", list->ids[0].guid);
    return;
  }
  dc1394_camera_free_list (list);
  
//  [self setFrameRateIndex : 0];
   err = dc1394_video_set_framerate(camera, DC1394_FRAMERATE_7_5);
  
  if (context) {
    if (camera)  dc1394_camera_free(camera);
    dc1394_free(context);
  }    
}

- (void) useFirstDevice
{
  camera = NULL;
  
  context = dc1394_new();
  
 if (!context) return;

  err=dc1394_camera_enumerate (context, &list);  
  if (err != DC1394_SUCCESS) {
    NSLog(@"Failed to enumerate cameras");
    return;
  }  

// verify that we have at least one camera 
  if (list->num == 0) { 
    NSLog(@"No cameras found");                                                 
    return;
  }

// take the first one
  camera = dc1394_camera_new(context, list->ids[0].guid);                     
  if (!camera) {
    NSLog(@"Failed to initialize camera with guid %llx", list->ids[0].guid);
    return;
  }
  NSLog(@"Using camera: %i",list->ids[0].guid);
  
  NSString *vendor = [NSString stringWithUTF8String : (*camera).vendor];
  NSString *model = [NSString stringWithUTF8String : (*camera).model];
  
  NSLog(@"%@ %@", vendor, model);
  
  dc1394_camera_free_list (list);

// set the frame rate  
//  [self setFrameRateIndex : 0];     
  [self applyFrameRateIndex];
//   err = dc1394_video_set_framerate(camera, DC1394_FRAMERATE_7_5);
   
  
// add our callback to the run loop
  err = dc1394_capture_schedule_with_runloop(camera, CFRunLoopGetCurrent (), kCFRunLoopDefaultMode);
  if (err != DC1394_SUCCESS) {
    NSLog(@"Error adding callback to run loop");
    return;
  }
  
  err=dc1394_capture_setup(camera, 4, DC1394_CAPTURE_FLAGS_DEFAULT);    
  if (err != DC1394_SUCCESS) {
    NSLog(@"Error setting up capture");
    return;
  }  
  
  err = dc1394_capture_set_callback(camera, FrameCallback, self);
  if (err != DC1394_SUCCESS) {
//    NSLog(@"Error setting camera callback");
 //   return;
  }  
  
// start the transmission 
  err = dc1394_video_set_transmission(camera, DC1394_ON); 
  if (err != DC1394_SUCCESS) {
    NSLog(@"Error starting video transmission");
    return;
  }    
}

- (CGImageRef) monoImage
{
  uint32_t w = imageW;
  uint32_t h = imageH;
  
  int bpp = 32;
  int bytesPerPixel = (int) (bpp / 8);
  int bpr = bytesPerPixel * w;
  
  CGSize size;
  size.width = (float) w;
  size.height = (float) h;
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *data = malloc(w * h * 4);
  
  NSUInteger bitsPerComponent = 8;
  CGContextRef ctx = CGBitmapContextCreate(data, w, h, bitsPerComponent, bpr, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
// get a pointer to the source image's data  
  UInt8 *rowPtr = data;
  UInt8 *pixelPtr;
  
  UInt8 *srcPtr = [self currentData];
  
  int x,y;
  
  for (y = 0; y < h; y++) {
    pixelPtr = rowPtr;
    for (x=0; x < w; x++) {
      *(pixelPtr+0) = *srcPtr;
      *(pixelPtr+1) = *srcPtr;
      *(pixelPtr+2) = *srcPtr++;
      *(pixelPtr+3) = 255;          // alpha
     
      pixelPtr += bytesPerPixel;
    }
    rowPtr += bpr;
  } 
  
  CGImageRef returnImage = CGBitmapContextCreateImage(ctx);
  
  CGContextRelease(ctx);
  
  if (data) free(data);
  
  return returnImage;
}  

- (CGImageRef) colorImage
{
  UInt8 *colorData;
  
  if ([Routines odd : frameCount]) colorData = (UInt8 *) &oddData;
  else colorData = (UInt8 *) &evenData;
  
  uint32_t w = imageW;
  uint32_t h = imageH;
  
  int bpp = 32;
  int bytesPerPixel = (int) (bpp / 8);
  int bpr = bytesPerPixel * w;
  
  CGSize size;
  size.width = (float) w;
  size.height = (float) h;
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *data = malloc(w * h * 4);
  
  NSUInteger bitsPerComponent = 8;
  CGContextRef ctx = CGBitmapContextCreate(data, w, h, bitsPerComponent, bpr, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  if (!ctx) {
    if (data) free(data);
    return nil;
  }
  
  CGColorSpaceRelease(colorSpace);
  
// get a pointer to the source image's data  
  UInt8 *rowPtr = data;
  UInt8 *pixelPtr;
  
  UInt8 *srcPtr = colorData;
  
  int x,y;
  
  for (y = 0; y < h; y++) {
    pixelPtr = rowPtr;
    for (x=0; x < w; x++) {
      *(pixelPtr+0) = *srcPtr++;
      *(pixelPtr+1) = *srcPtr++;
      *(pixelPtr+2) = *srcPtr++;
      *(pixelPtr+3) = 255;          // alpha
     
      pixelPtr += bytesPerPixel;
    }
    rowPtr += bpr;
//  srcPtr += (*frame.strib
  } 
  
  CGImageRef returnImage = CGBitmapContextCreateImage(ctx);
  
  CGContextRelease(ctx);
  
  if (data) free(data);
  
  return returnImage;
}  

// the subtracted image is mono
- (CGImageRef) subtractedImage
{
  UInt8 *srcPtr = (UInt8 *) &subtractedData;
  
  uint32_t w = imageW;
  uint32_t h = imageH;
  
  int bpp = 32;
  int bytesPerPixel = (int) (bpp / 8);
  int bpr = bytesPerPixel * w;
  
  CGSize size;
  size.width = (float) w;
  size.height = (float) h;
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *data = malloc(w * h * 4);
  
  NSUInteger bitsPerComponent = 8;
  CGContextRef ctx = CGBitmapContextCreate(data, w, h, bitsPerComponent, bpr, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
// get a pointer to the source image's data  
  UInt8 *rowPtr = data;
  UInt8 *pixelPtr;
  
  int x,y;
  
  for (y = 0; y < h; y++) {
    pixelPtr = rowPtr;
    for (x=0; x < w; x++) {
      *(pixelPtr+0) = *srcPtr;
      *(pixelPtr+1) = *srcPtr;
      *(pixelPtr+2) = *srcPtr++;
      *(pixelPtr+3) = 255;          // alpha
     
      pixelPtr += bytesPerPixel;
    }
    rowPtr += bpr;
  } 
  
  CGImageRef returnImage = CGBitmapContextCreateImage(ctx);
  
  CGContextRelease(ctx);
  
  if (data) free(data);
  
  return returnImage;
}  

- (CGImageRef) thresholdedImage
{
  UInt8 *srcPtr = (UInt8 *) &subtractedData;
  
  uint32_t w = imageW;
  uint32_t h = imageH;
  
  int bpp = 32;
  int bytesPerPixel = (int) (bpp / 8);
  int bpr = bytesPerPixel * w;
  
  CGSize size;
  size.width = (float) w;
  size.height = (float) h;
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *data = malloc(w * h * 4);
  
  NSUInteger bitsPerComponent = 8;
  CGContextRef ctx = CGBitmapContextCreate(data, w, h, bitsPerComponent, bpr, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
// get a pointer to the source image's data  
  UInt8 *rowPtr = data;
  UInt8 *pixelPtr;
  
  int x,y;
  
  UInt8 i;
  
  for (y = 0; y < h; y++) {
    pixelPtr = rowPtr;
    for (x=0; x < w; x++) {
      if ((*srcPtr++) >= threshold) i = 255;
      else i = 0;
      
      *(pixelPtr+0) = i;
      *(pixelPtr+1) = i;
      *(pixelPtr+2) = i;
      *(pixelPtr+3) = 255;          // alpha
     
      pixelPtr += bytesPerPixel;
    }
    rowPtr += bpr;
  } 
  
  CGImageRef returnImage = CGBitmapContextCreateImage(ctx);
  
  CGContextRelease(ctx);
  
  if (data) free(data);
  
  return returnImage;
}  

- (void) shutDown
{
  if (context) {
    if (camera) {
      err=dc1394_video_set_transmission(camera, DC1394_OFF);  // Stop transmission */
      err=dc1394_capture_stop(camera);                        // Stop capture
      dc1394_camera_free(camera);
    }
    dc1394_free(context);
  }   
  [blobFinder saveSettings];
  [self saveSettings];
}

- (void) showFeatureInfo : (dc1394feature_info_t) info
{
  if (!info.available) {
    NSLog(@"Not available");
    return;
  }
  NSLog(@"Min = %i Max = %i Value = %i",info.min,info.max,info.value);
}
 
- (dc1394feature_info_t) getFeatureInfo : (dc1394feature_t) feature
{ 
  dc1394feature_info_t featureInfo;
  featureInfo.available = DC1394_FALSE;
  
  if (!camera) return featureInfo;
   
  featureInfo.id = feature;
   
  err = dc1394_feature_get(camera, &featureInfo);
  
  return featureInfo;
}  

- (void) showFeature : (dc1394feature_t) feature
{
  dc1394feature_info_t info = [self getFeatureInfo : feature];
  [self showFeatureInfo : info];
}

- (void) fillSubtractTable
{
  for (int i1 = 0; i1 < 256; i1++) {
    for (int i2 = 0; i2 < 256; i2++) {
      subtractTable[i1][i2] = (int) (abs(i1 - i2) / 1);    
    }
  }
}

- (void) findSubtractedData
{
  UInt8 *oddPtr = (UInt8 *) &oddData;
  UInt8 *evenPtr = (UInt8 *) &evenData;
  
  UInt8 *destPtr = (UInt8 *) &subtractedData;
  
  for (int y = 0; y < IMAGE_H; y++) {
    for (int x = 0; x < IMAGE_W; x++) {
      *destPtr++ = subtractTable[*oddPtr++][*evenPtr++]; // red
      oddPtr += 2;
      evenPtr += 2;
    }
  }
}

- (void) findSubtractedMonoData
{
  UInt8 *oddPtr = (UInt8 *) &oddData;
  UInt8 *evenPtr = (UInt8 *) &evenData;
  
  UInt8 *destPtr = (UInt8 *) &subtractedData;
  
  for (int y = 0; y < IMAGE_H; y++) {
    for (int x = 0; x < IMAGE_W; x++) {
      *destPtr++ = subtractTable[*oddPtr++][*evenPtr++]; // red
    }
  }
}

- (CGImageRef) selectedImage
{
  CGImageRef result;
  
  [lock lock];
  
  switch (viewType) {
    
    case (NORMAL) :
      if (debayer) result = [self colorImage];
      else result = [self monoImage]; 
      break;
      
    case (SUBTRACTED) :
      result = [self subtractedImage];
      break;
      
    case (THRESHOLDED) :
      result = [blobFinder thresholdedImage];
      break;
  }
  
  [lock unlock];
  
  return result;
}

// only a square imageH x imageH section of the image is used 
// this is remapped to TEXTURE_W x TEXTURE_W
- (void) buildTables
{
//  float scale = TABLE_SIZE / IMAGE_H;
  float scale = IMAGE_H / TABLE_SIZE;
  
  int colOffset = (int) ((IMAGE_W - IMAGE_H) / 2);
  int v;
  
  for (int i = 0; i < TABLE_SIZE; i++) {
    v = (int) (i * scale);
    colTable[i] = colOffset + v;
    rowTable[i] = v;
  }
  [self fillSubtractTable];
}

- (void) syncReactDiffuse
{
  int i, count = 0;
  
  [reactDiffuse1 clearData];
  
  i = 0;
  for (int y = 0; y < TABLE_SIZE; y++) {
    for (int x = 0; x < TABLE_SIZE; x++) {
      if (subtractedData[i++] >= threshold) {
        [reactDiffuse1 smallDisturbAtX : x andY : y];
        count++;
      }  
    }  
  }
 if (count > 100) {
   reactDiffuse1.syncData = YES;
 }
}  

/*
  i = 0;
  for (int y = 0; y < TABLE_SIZE; y++) {
 //   r = rowTable[y];
     r= y;
    for (int x = 0; x < TABLE_SIZE; x++) {
//      c = colTable[x];
  c = x;
      i = r * imageW + c;

      if (subtractedData[i] >= threshold) {
        [reactDiffuse1 smallDisturbAtX : x andY : y];
        count++;
      }  
    }  
  }
*/

- (void) applyFrameRateIndex 
{
  if (!camera) return;
  
  switch (frameRateIndex) {
    case 0 :
      err = dc1394_video_set_framerate(camera, DC1394_FRAMERATE_7_5);
      break;
    case 1 :
      err = dc1394_video_set_framerate(camera, DC1394_FRAMERATE_15);
      break;
    case 2 :
      err = dc1394_video_set_framerate(camera, DC1394_FRAMERATE_30);
      break;
  }
}

- (void) setFrameRateIndex : (int) index
{
	frameRateIndex = index;
  
  if (camera) {
    err = dc1394_video_set_transmission(camera, DC1394_OFF); 
    err=dc1394_capture_stop(camera);                        // Stop capture
    [self applyFrameRateIndex]; 
    err = dc1394_video_set_transmission(camera, DC1394_ON); 
    err=dc1394_capture_setup(camera, 4, DC1394_CAPTURE_FLAGS_DEFAULT);    
  }      
}

- (UInt8 *) subtractedDataPtr
{
  return &subtractedData[0];
}
  
- (void) applyAsTexture
{
  [lock lock];
  
  UInt8 *data = [self currentData];
  
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  
  if (debayer) {
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, imageW, imageH, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
  }
  else {
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, imageW, imageH, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
  }
  
  [lock unlock];
  
  return;
}

- (void) applyAsTextureForMode : (CamMode) mode
{
  if ((mode == cmNormal) || (!debayer)) {
    [self applyAsTexture];
    return;
  }
  
  [lock lock];
  
  UInt8 *alphaData = malloc(imageW * imageH * 4);
  
  UInt8 *srcPtr = subtractedData;
  UInt8 *destPtr = alphaData;
  
  UInt8 i,a;
  
  if (mode == cmSubtracted) {
  
    for (int y = 0; y < imageH; y++) {
      for (int x = 0; x < imageW; x++) {
      
        if (*srcPtr++ > blobFinder.lowThreshold) a = 255;
        else a = 0;
      
        *destPtr++ = 255; // red
        *destPtr++ = 255; // green 
        *destPtr++ = 255; // blue 
        *destPtr++ = a; 
      }
    }
  }
  else if (mode == cmPosturized) {
    for (int y = 0; y < imageH; y++) {
      for (int x = 0; x < imageW; x++) {
        i = (*srcPtr++);
      
        *destPtr++ = 255; // red
        *destPtr++ = 255; // green 
        *destPtr++ = 255; // blue 
      
        if (i > 128) *destPtr++ = 255;
        else if (i > 96) *destPtr++ = 192;
        else if (i > 32) *destPtr++ = 128;
        else *destPtr++ = 0;
      }
    }
  }
  
// in blobs  
  else {
    
    memset(alphaData, imageW * imageH * 4, 0);
    for (i = 0; i < blobFinder.blobCount; i++) {
      Blob blob = [blobFinder blobAtIndex : i];
      if (blob.area >= blobFinder.minArea) {
        for (int y = blob.yMin; y <= blob.yMax; y++) {
        
            srcPtr = [self currentData];
            srcPtr += ((y * imageW) + blob.xMin) * 3;
            
            destPtr = alphaData;
            destPtr += ((y * imageW) + blob.xMin) * 4;

          for (int x = blob.xMin; x <= blob.xMax; x++) {
            *destPtr++ = *srcPtr++;
            *destPtr++ = *srcPtr++;
            *destPtr++ = *srcPtr++;
            *destPtr++ = 255;
          }
        }  
      }
    } 
  }   
  
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageW, imageH, 0, GL_RGBA, GL_UNSIGNED_BYTE, alphaData);
  
  [lock unlock];
  
  free(alphaData);
  
  return;
}

@end