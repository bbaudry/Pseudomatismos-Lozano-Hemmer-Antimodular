#import "LedPanel.h"

#define kLedPanelGain @"ledPanelGain"
#define kLedPanelRedGain @"ledPanelRedGain"
#define kLedPanelYellowGain @"ledPanelYellowGain"
#define kLedPanelHaloGain @"ledPanelHaloGain"
#define kLedPanelMinHaloI @"ledPanelMinHaloI"
#define kLedPanelMaxHaloI @"ledPanelMaxHaloI"
#define kLedPanelColorMode @"ledPanelColorMode"
#define kLedPanelMasterGain @"ledPanelMasterGain"
#define kLedPanelHaloR @"ledPanelHaloR"

@implementation LedPanel

@synthesize intensity;

@synthesize xOffset;
@synthesize yOffset;
@synthesize pixelsPerLed;

@synthesize gain;
@synthesize redGain;
@synthesize yellowGain;
@synthesize haloGain;
@synthesize masterGain;

@synthesize minHaloI;
@synthesize maxHaloI;

@synthesize colorMode;

@synthesize haloR;

+ (void) initialize
{
  [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
     
       [NSNumber numberWithFloat : 1.0], kLedPanelGain,
       [NSNumber numberWithFloat : 1.0], kLedPanelRedGain,
       [NSNumber numberWithFloat : 1.0], kLedPanelYellowGain,
       [NSNumber numberWithInt : 0], kLedPanelMinHaloI,
       [NSNumber numberWithInt : 255], kLedPanelMaxHaloI,
       [NSNumber numberWithInt : 0], kLedPanelColorMode,
       [NSNumber numberWithInt : 1], kLedPanelMasterGain,
       [NSNumber numberWithFloat : 100.0], kLedPanelHaloR,
      
    nil]];
}

- (void) applyDefaults
{
  self.gain = 1.0;
  self.redGain = 1.0;
  self.yellowGain = 1.0;
  self.haloGain = 1.0;
  self.minHaloI = 0;
  self.maxHaloI = 255;
  self.colorMode = cmCombined;
  self.masterGain = 1;
  self.haloR = 100.0;
}

- (void) setGain : (float) v
{
  [lock lock];
  gain = v;
  [lock unlock];
}

- (void) setRedGain : (float) v
{
  [lock lock];
  redGain = v;
  [lock unlock];
}
- (void) setYellowGain : (float) v
{
  [lock lock];
  yellowGain = v;
  [lock unlock];
}

- (void) setHaloGain : (float) v
{
  [lock lock];
    haloGain = v;
  [lock unlock];
}

- (void) setMasterGain : (int) v
{ 
  [lock lock];
    masterGain = v;
  [lock unlock];
}

- (void) setHaloR : (float) v
{ 
  [lock lock];
    haloR = v;
    [self placeHaloLeds];
  [lock unlock];
}

- (void) loadSettings : (int) season
{
//return;
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  self.gain = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kLedPanelGain, season]];
  self.redGain = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kLedPanelRedGain, season]];
  self.yellowGain = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kLedPanelYellowGain, season]];
  self.haloGain = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kLedPanelHaloGain, season]];
  
  self.minHaloI = [ud integerForKey : [NSString stringWithFormat : @"%@-%i", kLedPanelMinHaloI, season]];
  self.maxHaloI = [ud integerForKey : [NSString stringWithFormat : @"%@-%i", kLedPanelMaxHaloI, season]];
  
  self.colorMode = [ud integerForKey : [NSString stringWithFormat : @"%@-%i", kLedPanelColorMode, season]];
  
  self.masterGain = [ud integerForKey : kLedPanelMasterGain];
  self.haloR = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kLedPanelHaloR, season]];
}  

- (void) saveSettings : (int) season
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  [ud setFloat : gain forKey : [NSString stringWithFormat : @"%@-%i", kLedPanelGain, season]];
  [ud setFloat : redGain forKey : [NSString stringWithFormat : @"%@-%i", kLedPanelRedGain, season]];
  [ud setFloat : yellowGain forKey : [NSString stringWithFormat : @"%@-%i", kLedPanelYellowGain, season]];
  [ud setFloat : haloGain forKey : [NSString stringWithFormat : @"%@-%i", kLedPanelHaloGain, season]];
  
  [ud setInteger : minHaloI forKey : [NSString stringWithFormat : @"%@-%i", kLedPanelMinHaloI, season]];
  [ud setInteger : maxHaloI forKey : [NSString stringWithFormat : @"%@-%i", kLedPanelMaxHaloI, season]];

  [ud setInteger : colorMode forKey : [NSString stringWithFormat : @"%@-%i", kLedPanelColorMode, season]];
  [ud setInteger : masterGain forKey : kLedPanelMasterGain];
  
  [ud setFloat : haloR forKey : [NSString stringWithFormat : @"%@-%i", kLedPanelHaloR, season]];  
}

- (void) awakeFromNib
{
  self.xOffset = 50;
  self.yOffset = 50;
  self.pixelsPerLed = 3;
  
  intensity = 256.0;
  modMode = mmFilter;
  lock = [[NSRecursiveLock alloc] init];
  [lock retain];
  
  fsInterface = [[FSInterface alloc] init];
  [fsInterface open];
  
  BOOL red = YES;//NO;
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {  
     ledOn[c][r] = NO;
     led[c][r].red = red;
     led[c][r].intensity = 0;
     red = !red;
    }    
    red = !red;
  }    
  
  
  red = NO;
  for (int i = 0; i < HALO_LEDS; i++) {  
    halo[i].intensity = 0;
    halo[i].red = red;
    red = !red;
  }    
  [self placeHaloLeds];

  [self syncPanel];
}

- (void) placeHaloLeds
{
  float xc = (float) COLS / 2.0;
  float yc = (float) ROWS / 2.0;
  
  for (int i = 0; i < HALO_LEDS; i++) {  
    float angle = 2.0 * M_PI * (float) i / (float) HALO_LEDS;
    
    halo[i].srcX = (int) (xc + haloR * cos(angle));
    halo[i].srcY = (int) (yc + haloR * sin(angle));
  }    
}

- (void) open
{
  fsInterface = [[FSInterface alloc] init];
  [fsInterface open];
  [self syncPanel];
}


- (void) dealloc
{
  [fsInterface release];
  [lock release];
  [super dealloc];
}

- (void) drawInRect : (NSRect) rect
{
// clear it
  [[NSColor grayColor] set];
  NSRectFill(rect);
  
  int w = rect.size.width;
  int ledW = (int) (w / COLS) - 1;
  int startX = (int) ((w - (ledW + 1) * COLS) / 2);

  int h = rect.size.height;
  int ledH = (int) (h / ROWS) - 1;
  int y = (int) ((h - (ledH + 1) * ROWS) / 2);
  
  BOOL red = NO;
  for (int r = 0; r < ROWS; r++) {
    int x = startX;
    for (int c = 0; c < COLS; c++) {
      led[c][r].red = red;
      
      float rd = led[c][r].intensity / 255.0;
      float g;
      
      if (red) g = 0.0;
      else g = rd;
      
      [[NSColor colorWithDeviceRed : rd green : g blue : 0.0 alpha : 1.0] set];
      
      NSRect ledRect = NSMakeRect(x, y, ledW, ledH);
      NSRectFill(ledRect);
      red = !red;
      x += ledW + 1;
    }
    red = !red;  
    y += ledH + 1;
  }
}

- (IBAction) onBtnPressed : (id) sender
{
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {  
     ledOn[c][r] = YES;
    }    
  }    
 // [self setNeedsDisplay : YES];
  [self syncPanel];
}

      
- (IBAction) offBtnPressed : (id) sender
{ 
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {  
     ledOn[c][r] = NO;
    }    
  }    
 // [self setNeedsDisplay : YES];
  [self syncPanel];
}

- (IBAction) invertBtnPressed : (id) sender
{
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {  
     ledOn[c][r] = !ledOn[c][r];
    }    
  }    
//  [self setNeedsDisplay : YES];
  [self syncPanel];
}

- (IBAction) intensitySliderMoved : (id) sender
{  
  NSSlider *slider = (NSSlider *) sender;
  intensity = [slider floatValue];
//  [self setNeedsDisplay : YES];
  [self syncPanel];
}

- (void) syncPanel
{
//return;
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
		[fsInterface setPixelVal : led[c][r].intensity atX : c atY : r];//31-r];
    }
  }
  
  for (int i = 0; i < HALO_LEDS; i++) {
    [fsInterface setHaloVal : halo[i].intensity at : i];
  }
  
  [fsInterface update];
}

- (void) drawSourceRectangle
{
  [[NSColor whiteColor] set];
  NSRect rect = NSMakeRect(xOffset, yOffset, COLS * pixelsPerLed, ROWS * pixelsPerLed);
  NSFrameRect(rect);
}

- (void) initFromBmp : (NSBitmapImageRep *) bmp
{
  NSSize size = [bmp size];
  
  int w = size.width;
  int h = size.height;
 
  int bpr = [bmp bytesPerRow];
  int bpp = 3;
  
  int cellSize = pixelsPerLed * pixelsPerLed;

// loop through the leds  
  int y = yOffset;
  for (int r = 0; r < ROWS; r++) {
    int x = xOffset;
    for (int c = 0; c < COLS; c++) {
      int redSum = 0;
      int greenSum = 0;
      
      int maxY = [Routines minIntOf : (h - 1) and : (y + pixelsPerLed)];

// loop through x,y of the rectangular region of the bmp this LED uses as its source      
      for (int yb = y; yb <= maxY; yb++) {
        UInt8 *bmpPtr = [bmp bitmapData];
        bmpPtr += yb * bpr + x * bpp;
        int maxX = [Routines minIntOf : (w - 1) and : (x + pixelsPerLed)];
        for (int xb = x; xb < maxX; xb++) {
          redSum += *bmpPtr++;
          greenSum += *bmpPtr++;
          bmpPtr += bpp - 2; // skip the blue (and alpha if there is one)
        }
      } 
      float redF = redSum / cellSize;
      float greenF = greenSum / cellSize; 
      
// calculate the intensity
      switch (modMode) {
      
        case mmRed : 
          led[c][r].intensity = [Routines clipToByte : (redF - greenF)]; 
          break;
          
        case mmYellow : 
          led[c][r].intensity = [Routines clipToByte : (redF + greenF) / 2.0];
          break;
          
        case mmFilter :
          if (led[c][r].red) {
            led[c][r].intensity = [Routines clipToByte : gain * redGain * (redF - greenF)];
          }
          else {
            led[c][r].intensity = [Routines clipToByte : gain * yellowGain * (redF * greenF) / 255.0];  
          }  
          break;
      }
      x += pixelsPerLed;
    }
    y += pixelsPerLed;
  }
//  [self syncPanel];
}

- (void) syncFromBmp : (NSBitmapImageRep *) bmp
{
  UInt8 r,g,yl;
  NSSize size = [bmp size];
  
  int w = size.width;
  int h = size.height;
 
//  int bpr = [bmp bytesPerRow];
  int bpp = (bmp.bitsPerPixel >> 3);
  
// loop through the leds  
  UInt8 *bmpPtr = [bmp bitmapData];
  
  if (colorMode == cmCombined) {
    for (int y = h-1; y >= 0; y--) {
      for (int x = 0; x < w; x++) {
        r = (*bmpPtr++);
        g = (*bmpPtr++);
        bmpPtr += bpp - 2; // skip the blue (and alpha if there is one)
        if (led[x][y].red) {
          led[x][y].intensity = [Routines clipToByte : (float) masterGain * gain * redGain * (r + g) / 2.0];
       }
        else {
          led[x][y].intensity = [Routines clipToByte : (float) masterGain * gain * yellowGain * (r * g) / 255.0];  
        }  
      }  
    }
  }
  else {
    for (int y = h-1; y >=0; y--) {
      for (int x = 0; x < w; x++) {
        r = (*bmpPtr++);
        g = (*bmpPtr++);
        bmpPtr += bpp - 2; // skip the blue (and alpha if there is one)

// red is the difference
        if (led[x][y].red) {
          led[x][y].intensity = [Routines clipToByte : (float) masterGain * gain * redGain * (r-g)];
        }
        
// yellow is the min        
        else {
          if (r < g) yl = r;
          else yl = g;
          led[x][y].intensity = [Routines clipToByte : (float) masterGain * gain * yellowGain * yl]; 
        }  
      }  
    }
  }
}

- (void) syncHaloFromBmp : (NSBitmapImageRep *) bmp
{
  UInt8 r,g;
  
  int bpp = (bmp.bitsPerPixel >> 3);
  
  int i;
  
// loop through the leds  
  UInt8 *bmpPtr;// = [bmp bitmapData];
  
  
  for (int x = 0; x < HALO_LEDS; x++) {
    bmpPtr = [bmp bitmapData];
    bmpPtr += (halo[x].srcY * bmp.bytesPerRow);
    bmpPtr += (halo[x].srcX * bpp);
    
    r = *bmpPtr++;
    g = *bmpPtr;
    i = [Routines clipToByte : (float) masterGain * haloGain * (r + g) / 2.0];
    
    if (i < minHaloI) i = minHaloI;
    else if (i > maxHaloI) i = maxHaloI;
    
  //  float scaledV = minHaloI + (maxHaloI - minHaloI) * i / 255;

    halo[x].intensity = i;// [Routines clipToByte : haloGain * scaledV]; //gain * scaledV];
    
//    if (halo[x].red) halo[x].intensity = 0;
//    else halo[x].intensity = 255;
    
//    halo[x].intensity = 128;
  }
}

- (void) syncFromRGArray : (RGArray *) rgArray
{
  UInt8 r,g;
  for (int y = 0; y < ROWS; y++) {
    for (int x = 0; x < COLS; x++) {
      r = (*rgArray)[x][y].r;
      g = (*rgArray)[x][y].g;
      
// calculate the intensity
      switch (modMode) {
      
        case mmRed : 
          led[x][y].intensity = r - g ;
          break;
          
        case mmYellow : 
          led[x][y].intensity = [Routines clipToByte : (r + g) / 2.0];
          break;
          
        case mmFilter :
          if (led[x][y].red) {
            led[x][y].intensity = [Routines clipToByte : gain * redGain * (r - g)];
          }
          else {
            led[x][y].intensity = [Routines clipToByte : gain * yellowGain * (r * g) / 255.0];  
          }  
          break;
      }
    }
  } 
//  [self syncPanel];
}  

- (CGImageRef) image
{
  uint32_t w = COLS;
  uint32_t h = ROWS;
  
  int bpp = 32;
  int bytesPerPixel = (int) (bpp / 8);
  int bpr = bytesPerPixel * w;
  
  CGSize size;
  size.width = w; 
  size.height = h;
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *data = malloc(w * h * 4);
  
  NSUInteger bitsPerComponent = 8;
  CGContextRef ctx = CGBitmapContextCreate(data, w, h, bitsPerComponent, bpr, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
// get a pointer to the source image's data  
  UInt8 *rowPtr = data;
  UInt8 *pixelPtr;
  
  [lock lock];
  
  int x,y,i;
  
  for (y = 0; y < h; y++) {
    pixelPtr = rowPtr;
    for (x=0; x < w; x++) {
      if (led[x][y].red) {
        *(pixelPtr+0) = led[x][y].intensity; // red
        *(pixelPtr+1) = 0;                   // green
        *(pixelPtr+2) = 0;                   // blue
        *(pixelPtr+3) = 255;                 // alpha
      }
      else {
        i = led[x][y].intensity;
        *(pixelPtr+0) = i;   // red
        *(pixelPtr+1) = i;   // green
        *(pixelPtr+2) = 0;   // blue
        *(pixelPtr+3) = 255; // alpha
      }     
     
      pixelPtr += bytesPerPixel;
    }
    rowPtr += bpr;
  } 
  
  [lock unlock];
  
  CGImageRef returnImage = CGBitmapContextCreateImage(ctx);
  
  CGContextRelease(ctx);
  
  if (data) free(data);
  
  return returnImage;
}  

- (CGImageRef) haloImage
{
  uint32_t w = HALO_LEDS;
  uint32_t h = 1;
  
  int bpp = 32;
  int bytesPerPixel = (int) (bpp / 8);
  int bpr = w * bytesPerPixel;
  
  CGSize size;
  size.width = HALO_LEDS; 
  size.height = 1;
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *data = malloc(w * h * 4);
  
  NSUInteger bitsPerComponent = 8;
  CGContextRef ctx = CGBitmapContextCreate(data, w, h, bitsPerComponent, bpr, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
// get a pointer to the source image's data  
  UInt8 *pixelPtr;
  
  int x;
  
  pixelPtr = data;
  for (x = 0; x < w; x++) {
    *pixelPtr++ = halo[x].intensity; // red
    *pixelPtr++ = 0;                   // green
    *pixelPtr++ = 0;                   // blue
    *pixelPtr++ = 255;                 // alpha
  }
  
  CGImageRef returnImage = CGBitmapContextCreateImage(ctx);
  
  CGContextRelease(ctx);
  
  if (data) free(data);
  
  return returnImage;
}  

- (void) applyLock
{ 
  [lock lock];
}

- (void) removeLock 
{ 
  [lock unlock];
}

@end
