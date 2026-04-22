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
#define kLedPanelHaloY @"ledPanelHaloY"

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
@synthesize haloY;

- (id) init
{
  if (self = [super init]) {
//    season = malloc(sizeof(LedPanelSeason)*(SEASONS+1));
  }
  return self;
}

- (void) applyDefaults
{
  for (int s = 0; s <= SEASONS; s++) {
    season[s].gain = 1.0;
    season[s].redGain = 1.0;
    season[s].yellowGain = 1.0;
    season[s].haloGain = 1.0;
    season[s].minHaloI = 0;
    season[s].maxHaloI = 255;
    season[s].colorMode = cmCombined;
    season[s].masterGain = 1;
    season[s].haloR = 100.0;
    season[s].haloY = 128.0;
  }  
}

- (float) getGain
{
  return gain;
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

- (void) setHaloY : (float) v
{
    [lock lock];
    haloY = v;
    [self placeHaloLeds];
    [lock unlock];
}

- (void) loadSettings
{
  for (int s = 0; s <= SEASONS; s++) {
    season[s].gain = [settings floatFromKey : kLedPanelGain andSeason : s];
    season[s].redGain = [settings floatFromKey : kLedPanelRedGain andSeason : s];
    season[s].yellowGain = [settings floatFromKey : kLedPanelYellowGain andSeason : s];
    season[s].haloGain = [settings floatFromKey : kLedPanelHaloGain andSeason : s];
  
    season[s].minHaloI = [settings intFromKey : kLedPanelMinHaloI andSeason : s];
    season[s].maxHaloI = [settings intFromKey : kLedPanelMaxHaloI andSeason : s];
  
    season[s].colorMode = [settings intFromKey : kLedPanelColorMode andSeason : s];
  
    season[s].masterGain = [settings intFromKey : kLedPanelMasterGain andSeason : s];
    season[s].haloR = [settings floatFromKey : kLedPanelHaloR andSeason : s];
    season[s].haloY = [settings floatFromKey : kLedPanelHaloY andSeason : s];
  }
}  

- (void) saveSettings
{
  for (int s = 0; s <= SEASONS; s++) {
 
    [settings setFloat : season[s].gain forKey : kLedPanelGain andSeason : s];
    [settings setFloat : season[s].redGain forKey : kLedPanelRedGain andSeason : s];
    [settings setFloat : season[s].yellowGain forKey : kLedPanelYellowGain andSeason : s];
    [settings setFloat : season[s].haloGain forKey : kLedPanelHaloGain andSeason : s];
  
    [settings setInt : season[s].minHaloI forKey : kLedPanelMinHaloI andSeason : s];
    [settings setInt : season[s].maxHaloI forKey : kLedPanelMaxHaloI andSeason : s];

    [settings setInt : season[s].colorMode forKey : kLedPanelColorMode andSeason : s];
    [settings setInt : season[s].masterGain forKey : kLedPanelMasterGain andSeason : s];
  
    [settings setFloat : season[s].haloR forKey : kLedPanelHaloR andSeason : s];  
    [settings setFloat : season[s].haloY forKey : kLedPanelHaloY andSeason : s];
  }
}

- (void) copyVarsFromSeason : (int) s
{
  self.gain = season[s].gain;
  self.redGain = season[s].redGain;
  self.yellowGain = season[s].yellowGain;
  self.haloGain = season[s].haloGain;
  
  self.minHaloI = season[s].minHaloI;
  self.maxHaloI = season[s].maxHaloI;
  
  self.colorMode = season[s].colorMode;
  
  if (season[s].masterGain == 0) self.masterGain = 1;
  else self.masterGain = season[s].masterGain;
  
  self.haloR = season[s].haloR;
  self.haloY = season[s].haloY;
}

- (void) copyVarsToSeason : (int) s
{
  season[s].gain = gain;
  season[s].redGain = redGain;
  season[s].yellowGain = yellowGain;
  season[s].haloGain = haloGain;
  
  season[s].minHaloI = minHaloI;
  season[s].maxHaloI = maxHaloI;
  
  season[s].colorMode = colorMode;
  
  season[s].masterGain = masterGain;
  season[s].haloR = haloR;
  season[s].haloY = haloY;
}

- (void) awakeFromNib
{
  self.xOffset = 50;
  self.yOffset = 50;
  self.pixelsPerLed = 3;
  
  [self buildLedTable];  
  
  intensity = 256.0;
  modMode = mmFilter;
  lock = [[NSRecursiveLock alloc] init];
  [lock retain];
  
  fsInterface = [[FSInterface alloc] init];
  [fsInterface open];
  
  [fsInterface setBaud : 2];
  
  [fsInterface setPolarity : 1];
  
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
  
  for (int i = 0; i < HALO_LEDS; i++) {  
    float angle = 2.0 * M_PI * (float) i / (float) HALO_LEDS;
    
    halo[i].srcX = (int) (xc + haloR * cos(angle));
    if (halo[i].srcX < 0) halo[i].srcX = 0;
    else if (halo[i].srcX > (COLS-1)) halo[i].srcX = COLS-1;
    
    halo[i].srcY = (int) (haloY + haloR * sin(angle));
    if (halo[i].srcY < 0) halo[i].srcY = 0;
    else if (halo[i].srcY > (ROWS-1)) halo[i].srcY = ROWS-1;
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
  int x, y;
  unsigned char i;
  
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      x = ledTable[c][r].x;
      y = ledTable[c][r].y;
      i = (unsigned char) (led[x][y].intensity * ledTable[c][r].scale);
      [fsInterface setPixelVal : i atX : c atY : r];
    }
  }
  
  for (int i = 0; i < HALO_LEDS; i++) {
    [fsInterface setHaloVal : halo[i].intensity at : i];
  }
  
  [fsInterface update];
//  fprintf(stderr, ".");
}

/*

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
//  fprintf(stderr, ".");
} */

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

- (void) setDimmer : (UInt8) dimmer
{
  static int16_t oldBrightness = -1;
  uint16_t wordValue = (uint16_t) dimmer;
  if (wordValue != oldBrightness) {
    oldBrightness = wordValue;
  
//    fprintf(stderr, "Bright : %d\n", dimmer); 
  
    [fsInterface setBrightnessForPixels : wordValue ForHalo : wordValue];
  }
}

- (void) place8x8Panels
{ 
  panel8[0].x = 64;
  panel8[0].y = 8;
  
  panel8[1].x = 72;
  panel8[1].y = 8;
  
  panel8[2].x = 176;
  panel8[2].y = 8;
  
  panel8[3].x = 182;
  panel8[3].y = 8;
  
  panel8[4].x = 40;
  panel8[4].y = 24;
  
  panel8[5].x = 208;
  panel8[5].y = 24;
  
  panel8[6].x = 24;
  panel8[6].y = 40;
  
  panel8[7].x = 8;
  panel8[7].y = 64;
  
  panel8[8].x = 8;
  panel8[8].y = 72;  
  
  panel8[9].x = 224;
  panel8[9].y = 40;
  
  panel8[10].x = 240;
  panel8[10].y = 64;
  
  panel8[11].x = 240;
  panel8[11].y = 72;
  
  panel8[12].x = 8;
  panel8[12].y = 176;
  
  panel8[13].x = 8;
  panel8[13].y = 182;
  
  panel8[14].x = 240;
  panel8[14].y = 176;
  
  panel8[15].x = 240;
  panel8[15].y = 182;
  
  panel8[16].x = 24;
  panel8[16].y = 208;
  
  panel8[17].x = 224;
  panel8[17].y = 208;
  
  panel8[18].x = 40;
  panel8[18].y = 240;
  
  panel8[19].x = 208;
  panel8[19].y = 224;
  
  panel8[20].x = 64;
  panel8[20].y = 240;
  
  panel8[21].x = 72;
  panel8[21].y = 240;
  
  panel8[22].x = 176;
  panel8[22].y = 240;
  
  panel8[23].x = 182;
  panel8[23].y = 240;
}  
  
- (void) place16x16Panels
{ 
  panel16[0].x = 16;
  panel16[0].y = 48;
  
  panel16[1].x = 16;
  panel16[1].y = 64;
  
  panel16[2].x = 16;
  panel16[2].y = 80;
  
  panel16[3].x = 0;
  panel16[3].y = 80;
  
  panel16[4].x = 0;
  panel16[4].y = 160;
  
  panel16[5].x = 16;
  panel16[5].y = 160;
  
  panel16[6].x = 16;
  panel16[6].y = 176;
  
  panel16[7].x = 16;
  panel16[7].y = 192;
  
  panel16[8].x = 48;
  panel16[8].y = 16;  
  
  panel16[9].x = 48;
  panel16[9].y = 224;
  
  panel16[10].x = 80;
  panel16[10].y = 0;
  
  panel16[11].x = 64;
  panel16[11].y = 16;
  
  panel16[12].x = 80;
  panel16[12].y = 16;
  
  panel16[13].x = 64;
  panel16[13].y = 224;
  
  panel16[14].x = 80;
  panel16[14].y = 224;
  
  panel16[15].x = 80;
  panel16[15].y = 240;
  
  panel16[16].x = 160;
  panel16[16].y = 0;
  
  panel16[17].x = 160;
  panel16[17].y = 16;
  
  panel16[18].x = 176;
  panel16[18].y = 16;
  
  panel16[19].x = 192;
  panel16[19].y = 16;
  
  panel16[20].x = 160;
  panel16[20].y = 224;
  
  panel16[21].x = 176;
  panel16[21].y = 224;
  
  panel16[22].x = 192;
  panel16[22].y = 224;
  
  panel16[23].x = 160;
  panel16[23].y = 240;
  
  panel16[24].x = 224;
  panel16[24].y = 48;
  
  panel16[25].x = 224;
  panel16[25].y = 64;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
  
  panel16[26].x = 224;
  panel16[26].y = 80;
  
  panel16[27].x = 240;
  panel16[27].y = 80;
  
  panel16[28].x = 224;
  panel16[28].y = 160;
  
  panel16[29].x = 240;
  panel16[29].y = 160;  
  
  panel16[30].x = 224;
  panel16[30].y = 176;
  
  panel16[31].x = 224;
  panel16[31].y = 192;  
}

- (bool) panelIs16x16AtX : (int *) xm andY : (int *) ym
{
  int x1, y1;
  int x2, y2;
  int x = *xm;
  int y = *ym;
  
  for (int i = 0; i < PANELS_16; i++) {
    x1 = panel16[i].x;
    y1 = panel16[i].y;
    
    x2 = x1 + 15;
    y2 = y1 + 15;
    
// see if this pixel is inside    
    if ((x >= x1) && (x <= x2) && (y >=y1) && (y <= y2)) {
    
// if so remap it
      *xm = x1 + (y - y1);
      *ym = y1 + (x - x1); 
      
      return YES;   
    }
  }
  return NO;
}  

- (bool) panelIs8x8AtX : (int) x andY : (int) y
{
  int x1, y1;
  int x2, y2;
  
  for (int i = 0; i < PANELS_8; i++) {
    x1 = panel8[i].x;
    y1 = panel8[i].y;
    
    x2 = x1 + 7;
    y2 = y1 + 7;
    
// see if this pixel is inside    
    if ((x >= x1) && (x <= x2) && (y >=y1) && (y <= y2)) {
      return YES;   
    }
  }
  return NO;
}

- (void) buildLedTable
{
  int x, y;
  int xm, ym;
  
  [self place8x8Panels];
  [self place16x16Panels];
  
// set all to default  
  for (y = 0; y < ROWS; y++) {
    for (x = 0; x < COLS; x++) {
      xm = x;
      ym = y;
      if ([self panelIs16x16AtX : &xm andY : &ym]) {
        ledTable[x][y].x = xm;
        ledTable[x][y].y = ym;
        ledTable[x][y].scale = 0.30;
      }
      else if ([self panelIs8x8AtX : x andY : y]) {
        ledTable[x][y].x = 0;
        ledTable[x][y].y = 0;
        ledTable[x][y].scale = 0.0;    
      }
      else {
        ledTable[x][y].x = x;
        ledTable[x][y].y = y;
        ledTable[x][y].scale = 1.0;
      }  
    }
  }
}

@end
