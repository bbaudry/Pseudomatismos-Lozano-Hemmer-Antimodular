#import "BlobFinder.h"
#import "Global.h"
#import "Routines.h"
#import "ImageUtils.h"

#define kLowThreshold @"kLowThreshold"
#define kHighThreshold @"kHighThreshold"

#define kJumpD @"kJumpD"
#define kMinArea @"kMinArea"

@implementation BlobFinder

@synthesize lowThreshold;
@synthesize highThreshold;

@synthesize jumpD;
@synthesize minArea;

@synthesize showBlobs;
@synthesize showStrips;
@synthesize showTargets;

@synthesize blobCount;

- (void) loadSettings 
{
  self.lowThreshold = [settings intFromKey : kLowThreshold];
  self.highThreshold = [settings intFromKey : kHighThreshold];

  self.jumpD = [settings intFromKey : kJumpD];
  self.minArea = [settings intFromKey : kMinArea];
}  

- (void) saveSettings
{
  [settings setInt : (int) lowThreshold forKey : kLowThreshold];
  [settings setInt : (int) highThreshold forKey : kHighThreshold];

  [settings setInt : (int) jumpD forKey : kJumpD];
  [settings setInt : (int) minArea forKey : kMinArea];
}

//- (id) init:(id)sender
- init
{
	if (self = [super init]) {
    blob[0].prevBlob = NULL;
    lock = [[NSRecursiveLock alloc] init];
    [lock retain];
    [self loadSettings];
	}
  return self;
}

- (void) awakeFromNib
{
  self.lowThreshold = 20;
  self.highThreshold = 40;
  self.minArea = 200;
  self.jumpD = 8;
}

- (void) dealloc
{
	[lock release];
	[super dealloc];
}

- (IBAction) setLowThreshold:(int)newValue
{ 
  lowThreshold = newValue;
}

- (IBAction) setHighThreshold:(int)newValue
{
	highThreshold = newValue;
}

- (IBAction) setJumpD:(int)newValue
{
	jumpD = newValue;
}

- (IBAction) setMinArea:(int)newValue
{
	minArea = newValue;
}

- (int) lowThreshold { return lowThreshold; }

- (int) highThreshold {	return highThreshold; }

- (int) jumpD { return jumpD; }

- (int) minArea { return minArea; }
	
- (void) drawStrips
{
  int y,i,count;
	NSBezierPath *path;
	path = [[NSBezierPath alloc] init];
	[[NSColor redColor] set];
	NSPoint point;
	for (y=0; y < camera.imageH; y++) {
		count = stripCount[y];
		point.y = y;
		for (i=0; i < count; i++) {
			point.x = strip[y][i].xMin;
			[path moveToPoint:point];
			point.x = strip[y][i].xMax;
			[path lineToPoint:point];
		}
	}
	[path stroke];
	[path release];
}

- (void) drawBlobs
{
  [lock lock];
  if (blobCount > 0) {  
    int x, y, w, h;
    NSRect blobRect;

    [[NSColor blueColor] set];
    Blob *currentBlob = &blob[0];
    while (currentBlob != NULL) {
      x = (*currentBlob).xMin;
      y = (*currentBlob).yMin;
      w = (*currentBlob).xMax - x + 1;
      h = (*currentBlob).yMax - y + 1;
      blobRect = NSMakeRect(x, y, w, h);
      [NSBezierPath strokeRect:blobRect]; 
      currentBlob = (Blob *) (*currentBlob).nextBlob;
    }  
  }
  [lock unlock];
}

- (void) drawStripsWithXScale : (float) xScale andYScale : (float) yScale
{
  int y,i,count;
	NSBezierPath *path;
	path = [[NSBezierPath alloc] init];
	[[NSColor redColor] set];
	NSPoint point;
	for (y=0; y < camera.imageH; y++) {
		count = stripCount[y];
		point.y = round(y * yScale);
		for (i=0; i < count; i++) {
			point.x = round(strip[y][i].xMin * xScale);
			[path moveToPoint:point];
			point.x = round(strip[y][i].xMax * xScale);
			[path lineToPoint:point];
		}
	}
	[path stroke];
	[path release];
}

- (void) drawBlobsWithXScale : (float) xScale andYScale : (float) yScale
{
  [lock lock];
  if (blobCount > 0) {  
    int x, y, w, h;
    NSRect blobRect;

    [[NSColor blueColor] set];
    Blob *currentBlob = &blob[0];
    while (currentBlob != NULL) {
      x = round((*currentBlob).xMin * xScale);
      y = round((*currentBlob).yMin * yScale);
      w = round((*currentBlob).xMax * xScale) - x + 1;
      h = round((*currentBlob).yMax * yScale) - y + 1;
      blobRect = NSMakeRect(x, y, w, h);
      [NSBezierPath strokeRect:blobRect]; 
      currentBlob = (Blob *) (*currentBlob).nextBlob;
    }  
  }
  [lock unlock];
}

- (void) applyLock
{ 
  [lock lock];
}

- (void) removeLock 
{ 
  [lock unlock];
}

- (void) drawTargets
{
}

- (void) findStrips : (NSBitmapImageRep *) bmpImage
{
  unsigned char v;
	int x, y;
	int offset;
	int jumpCount;
	int stripI;
	int bpr = [bmpImage bytesPerRow];
  int bmpWidth = [bmpImage pixelsWide];
  int bmpHeight = [bmpImage pixelsHigh];
	ScanMode scanMode;
	
// clear the strip count array
	for (y = 0; y < bmpHeight; y++) {
		stripCount[y] = 0;
	} 
	
// loop through the lines looking for strips (lines of bright intensity)	
	unsigned char *data = [bmpImage bitmapData];
	for (y = 0; y < bmpHeight; y++) {
		scanMode = SMLooking;
		offset = (bmpHeight - 1 - y) * bpr;
		for (x = 0; x < bmpWidth; x++) {
			v = *(data + offset);
      offset = offset + 3; // next pixel
			switch (scanMode) {
				
// if we're looking and this pixel's intensity>HiT, make a new strip
				case SMLooking :
          if (v >= highThreshold) {
						stripI = stripCount[y];
 						stripCount[y]++;
						strip[y][stripI].xMin = x;
						strip[y][stripI].xMax = x;
						scanMode = SMTracing;
					} 
					break;
					
// tracing - if we've hit a dark patch start jumping					
				case SMTracing :
					if (v<lowThreshold) {
						scanMode = SMJumping;
						jumpCount = 1;
					}
					else strip[y][stripI].xMax = x;
					break;
					
// jumping across dim pixels					
				case SMJumping :
					if (v>=lowThreshold) {
						scanMode = SMTracing;
						strip[y][stripI].xMax = x;
					}
					else {
						if (jumpCount<jumpD) {
							jumpCount++;
						}
						else {
							scanMode = SMLooking;
						}	
					}
					break;
			}
		}
	}
}

- (void) findStripsFromColorData : (UInt8 *) colorData withWidth : (int) w andHeight : (int) h
{
  unsigned char v;
	int x, y;
	int offset;
	int jumpCount;
	int stripI;
	int bpr = w * 3;
	ScanMode scanMode;
	
// clear the strip count array
	for (y = 0; y < h; y++) {
		stripCount[y] = 0;
	} 
	
// loop through the lines looking for strips (lines of bright intensity)	
	UInt8 *data = colorData;
	for (y = 0; y < h; y++) {
		scanMode = SMLooking;
		offset = (h - 1 - y) * bpr;
		for (x = 0; x < w; x++) {
			v = *(data + offset);
      offset += 3; // next pixel
      
			switch (scanMode) {
				
// if we're looking and this pixel's intensity>HiT, make a new strip
				case SMLooking :
          if (v >= highThreshold) {
						stripI = stripCount[y];
 						stripCount[y]++;
						strip[y][stripI].xMin = x;
						strip[y][stripI].xMax = x;
						scanMode = SMTracing;
					} 
					break;
					
// tracing - if we've hit a dark patch start jumping					
				case SMTracing :
					if (v<lowThreshold) {
						scanMode = SMJumping;
						jumpCount = 1;
					}
					else strip[y][stripI].xMax = x;
					break;
					
// jumping across dim pixels					
				case SMJumping :
					if (v>=lowThreshold) {
						scanMode = SMTracing;
						strip[y][stripI].xMax = x;
					}
					else {
						if (jumpCount<jumpD) {
							jumpCount++;
						}
						else {
							scanMode = SMLooking;
						}	
					}
					break;
			}
		}
	}
}
- (void) findStripsFromMonoData : (UInt8 *) monoData withWidth : (int) w andHeight : (int) h
{
  unsigned char v;
	int x, y;
	int offset;
	int jumpCount;
	int stripI;
	ScanMode scanMode;
	
// clear the strip count array
	for (y = 0; y < h; y++) {
		stripCount[y] = 0;
	} 
	
// loop through the lines looking for strips (lines of bright intensity)	
	UInt8 *data = monoData;
	for (y = 0; y < h; y++) {
		scanMode = SMLooking;
		offset = (h - 1 - y) * w;
		for (x = 0; x < w; x++) {
			v = *(data + offset);
      offset += 1; // next pixel
      
			switch (scanMode) {
				
// if we're looking and this pixel's intensity>HiT, make a new strip
				case SMLooking :
          if (v >= highThreshold) {
						stripI = stripCount[y];
 						stripCount[y]++;
						strip[y][stripI].xMin = x;
						strip[y][stripI].xMax = x;
						scanMode = SMTracing;
					} 
					break;
					
// tracing - if we've hit a dark patch start jumping					
				case SMTracing :
					if (v<lowThreshold) {
						scanMode = SMJumping;
						jumpCount = 1;
					}
					else strip[y][stripI].xMax = x;
					break;
					
// jumping across dim pixels					
				case SMJumping :
					if (v>=lowThreshold) {
						scanMode = SMTracing;
						strip[y][stripI].xMax = x;
					}
					else {
						if (jumpCount<jumpD) {
							jumpCount++;
						}
						else {
							scanMode = SMLooking;
						}	
					}
					break;
			}
		}
	}
}


- (void) findBlobsFromStrips
{
  int i, y, y2, b;
  int i2, x, maxY;
    
// reset the count and BlobI vars
  blobCount = 0;
  for (y = 0; y < camera.imageH; y++) {
    for (i = 0; i < stripCount[y]; i++) {
      strip[y][i].blobI = -1;
    }  
  }  
 
// look through the strip array in Y
  for (y = 0; y < camera.imageH; y++) {
    for (i = 0; i < stripCount[y]; i++) {
      
// if this strip doesn't belong to a blob, create a new blob   
      b =  strip[y][i].blobI;  
      if ((b < 0) && (blobCount < MaxBlobs)) { 
        strip[y][i].blobI = blobCount;
 //     strip[y[[i].pBlob = &blob[BlobCount];

// bounding box and area
        blob[blobCount].xMin = strip[y][i].xMin;
        blob[blobCount].xMax = strip[y][i].xMax;
        blob[blobCount].yMin = y;
        blob[blobCount].yMax = y;
        blob[blobCount].area = strip[y][i].xMax - strip[y][i].xMin + 1;

// clear the limits
        for (i2 = 0; i2 < camera.imageW; i2++) {
          blob[blobCount].minYAtX[i2] = camera.imageH - 1;
          blob[blobCount].maxYAtX[i2] = 0;
        };
        for (i2 = 0; i2 < camera.imageH; i2++) {
          blob[blobCount].minXAtY[i2] = camera.imageW-1;
          blob[blobCount].maxXAtY[i2] = 0;
        }  
      
// init the limits
        blob[blobCount].minXAtY[y] = strip[y][i].xMin;
        blob[blobCount].maxXAtY[y] = strip[y][i].xMax;
        for (x = strip[y][i].xMin; x <= strip[y][i].xMax; x++) {
          blob[blobCount].minYAtX[x] = y;
          blob[blobCount].maxYAtX[x] = y;
          blob[blobCount].minYAtX[x] = y;
          blob[blobCount].maxYAtX[x] = y;
        };
        blobCount++;
      };
      b = strip[y][i].blobI;
      if (b >= 0) {

// check all the strips up to jumpD below this one for overlaps 
        if ((camera.imageH - 1) > (y + jumpD)) {
          maxY = y + jumpD;
        }
        else maxY = camera.imageH - 1;
//        maxY = minInt(bmpHeight - 1, y + jumpD);
        for (y2 = y+1; y2 <= maxY; y2++) {
          for (i2 = 0; i2 < stripCount[y2]; i2++) {
            if ((strip[y2][i2].blobI < 0) && 
                [self strip:strip[y][i] overlapsStrip:strip[y2][i2]])
            {    
              strip[y2][i2].blobI = b;
              blob[b].area += strip[y2][i2].xMax - strip[y2][i2].xMin + 1;

// update the bounding box
              if (strip[y2][i2].xMin < blob[b].xMin) {
                blob[b].xMin = strip[y2][i2].xMin;
              }  
              if (strip[y2][i2].xMax > blob[b].xMax) {
                blob[b].xMax = strip[y2][i2].xMax;
              }  
              if (y2 > blob[b].yMax) blob[b].yMax = y2;

// update the limits
              if (strip[y2][i2].xMin < blob[b].minXAtY[y2]) {
                blob[b].minXAtY[y2] = strip[y2][i2].xMin;
              }  
              if (strip[y2][i2].xMax > blob[b].maxXAtY[y2]) {
                blob[b].maxXAtY[y2] = strip[y2][i2].xMax;
              }  
              for (x = strip[y2][i2].xMin; x <= strip[y2][i2].xMax; x++) {
                if (y2 < blob[b].minYAtX[x]) blob[b].minYAtX[x] = y2;
                if (y2 > blob[b].maxYAtX[x]) blob[b].maxYAtX[x] = y2;
              }  
            } 
          }
        }
      }
    }
  }  
  [self findBlobCenters];     
}

// creates a linked list from the used blobs in the blob array
// ie blob[0] -> blob[blobCount-1] form a linked list with their 
// prevBlob and nextBlob fields - this makes it easy and fast to removed blobs
// from the list while keeping it in order
- (void) initBlobLinkedList
{
  int i = 0;
  for (i = 0; i < MaxBlobs; i++) {
    if (i == 0) {
      blob[i].prevBlob = NULL;
    }  
    else {
      blob[i].prevBlob = (void *) &blob[i-1];
    }  
    if (i < (blobCount-1)) {
      blob[i].nextBlob = (void *) &blob[i+1];
    }  
    else {
      blob[i].nextBlob = NULL;
    }  
  }
}

// removes a blob from our linked list - returns the one that ends up in this spot
- (Blob *) removeBlob:(Blob *)xBlob
{
  Blob *prevBlob = (*xBlob).prevBlob;
  Blob *nextBlob = (*xBlob).nextBlob;
  if (prevBlob != NULL) {
    (*prevBlob).nextBlob = (void *) nextBlob;
  }  
  if (nextBlob != NULL) {
    (*nextBlob).prevBlob = (void *) prevBlob;
  }  
  blobCount--; 
  return nextBlob;
}

// check the area of the blobs - remove any that are too small
- (void) cullSmallBlobs
{ 
  if (blobCount>0) {
    Blob *currBlob = &blob[0];
    while (currBlob != NULL) {
    
// if this one's too small - remove it     
      if ((*currBlob).area < minArea) {
        currBlob = [self removeBlob:currBlob];
      }

// otherwise check the next one
      else currBlob = (Blob *) (*currBlob).nextBlob;
    }
  }
}

- (BOOL) strip : (Strip) strip1 overlapsStrip : (Strip) strip2
{
  BOOL outside = ((strip1.xMin > strip2.xMax) || (strip1.xMax < strip2.xMin));
  return (!outside);
}

// blob2 is absorbed into blob1
- (void) mergeBlob:(Blob *) blob1 withBlob:(Blob *) blob2
{
  int x,y;

  if ((*blob2).xMin < (*blob1).xMin) (*blob1).xMin = (*blob2).xMin;
  if ((*blob2).xMax > (*blob1).xMax) (*blob1).xMax = (*blob2).xMax;
  if ((*blob2).yMin < (*blob1).yMin) (*blob1).yMin = (*blob2).yMin;
  if ((*blob2).yMax > (*blob1).yMax) (*blob1).yMax = (*blob2).yMax;
  for (x = (*blob2).xMin; x <= (*blob2).xMax; x++) {
    if ((*blob2).minYAtX[x] < (*blob1).minYAtX[x]) {
      (*blob1).minYAtX[x] = (*blob2).minYAtX[x];
    };  
    if ((*blob2).maxYAtX[x] > (*blob1).maxYAtX[x]) {
      (*blob1).maxYAtX[x] = (*blob2).maxYAtX[x];
    };  
  };
  for (y = (*blob2).yMin; y < (*blob2).yMax; y++) {
    if ((*blob2).minXAtY[y] < (*blob1).minXAtY[y]) {
      (*blob1).minXAtY[y] = (*blob2).minXAtY[y];
    }  
    if ((*blob2).maxXAtY[y] > (*blob1).maxXAtY[y]) {
      (*blob1).maxXAtY[y] = (*blob2).maxXAtY[y];
    }  
  };
  (*blob1).area = (*blob1).area + (*blob2).area;

// axe blob2 now that it's been absorbed
  [self removeBlob:blob2];
};

- (void) mergeBlobs
{
  Blob *currBlob = &blob[0];
  Blob *nextBlob = (Blob *) blob[0].nextBlob;
  while (nextBlob != NULL) {
    if ([self blob:currBlob overlapsBlob:nextBlob] ||
        [self blob:nextBlob overlapsBlob:currBlob])
    {
      [self mergeBlob:currBlob withBlob:nextBlob];
      nextBlob = (Blob *) (*currBlob).nextBlob;
    }
    
// check the next one    
    else {
      currBlob = nextBlob;
      nextBlob = (Blob *) (*currBlob).nextBlob;
    }    
  }  
};

- (void) findBlobCenters
{
  Blob *currBlob = (Blob *) &blob[0];
  while (currBlob != NULL) {
    (*currBlob).xc = ((*currBlob).xMin + (*currBlob).xMax) / 2;
    (*currBlob).yc = ((*currBlob).yMin + (*currBlob).yMax) / 2;
    currBlob = (Blob *) (*currBlob).nextBlob;
  }
}

- (void) findBlobs:(NSBitmapImageRep *)bmpImage
{
	[self findStrips:bmpImage];
 	[self findBlobsFromStrips];
	if (blobCount > 0) {
    [self initBlobLinkedList];
		[self mergeBlobs];
    [self cullSmallBlobs];
		[self findBlobCenters];
	}
}

- (void) findBlobsFromColorData : (UInt8 *) colorData withWidth : (int) w andHeight : (int) h
{
	[self findStripsFromColorData : colorData withWidth : w andHeight : h];
  [lock lock];
 	[self findBlobsFromStrips];
	if (blobCount > 0) {
    [self initBlobLinkedList];
		[self mergeBlobs];
    [self cullSmallBlobs];
		[self findBlobCenters];
	}
  [lock unlock];
}

- (void) findBlobsFromMonoData : (UInt8 *) monoData withWidth : (int) w andHeight : (int) h
{
	[self findStripsFromMonoData : monoData withWidth : w andHeight : h];
  [lock lock];
 	[self findBlobsFromStrips];
	if (blobCount > 0) {
    [self initBlobLinkedList];
		[self mergeBlobs];
    [self cullSmallBlobs];
		[self findBlobCenters];
	}
  [lock unlock];
}


- (BOOL) pixelAtX:(int)x Y:(int) y insideBlobAtIndex:(int) i
{
  BOOL result;
  result = (x >= blob[i].xMin) && (x <= blob[i].xMax) && 
           (y >= blob[i].yMin) && (y <= blob[i].yMax);
  return result;
}  

- (BOOL) hLineFromX1:(int)x1 X2:(int)x2 Y:(int)y insideBlob:(Blob *)testBlob
{
  BOOL result = (y >= (*testBlob).yMin) && (y <= (*testBlob).yMax) &&
                (((x1 >= (*testBlob).xMin) && (x1 <= (*testBlob).xMax)) ||
                ((x2 >= (*testBlob).xMin) && (x2 <= (*testBlob).xMax)) ||
                ((x1 <= (*testBlob).xMin) && (x2 >= (*testBlob).xMax)));
  return result;
}

- (BOOL) vLineFromY1:(int)y1 Y2:(int)y2 X:(int) x insideBlob:(Blob *)testBlob
{
  BOOL result = (x >= (*testBlob).xMin) && (x <= (*testBlob).xMax) &&
                (((y1 >= (*testBlob).yMin) && (y1 <= (*testBlob).yMax)) ||
                ((y2 >= (*testBlob).yMin) && (y2 <= (*testBlob).yMax)) ||
                ((y1 <= (*testBlob).yMin) && (y2 >= (*testBlob).yMax)));
  return result;              
}

- (BOOL) blob:(Blob *)blob1 overlapsBlob:(Blob *)blob2
{
  BOOL result;
  int x1 = (*blob2).xMin;
  int x2 = (*blob2).xMax;
  int y1 = (*blob2).yMin;
  int y2 = (*blob2).yMax;
  
  result = [self hLineFromX1:x1 X2:x2 Y:y1 insideBlob:blob1] ||
           [self hLineFromX1:x1 X2:x2 Y:y2 insideBlob:blob1] ||
           [self vLineFromY1:y1 Y2:y2 X:x1 insideBlob:blob1] ||
           [self vLineFromY1:y1 Y2:y2 X:x2 insideBlob:blob1];
  return result;         
}

- (BlobFinderInfo) getInfo
{
  BlobFinderInfo result;
  result.lowThreshold = lowThreshold;
  result.highThreshold = highThreshold;
  result.jumpD = jumpD;
  result.minArea = minArea;
  memset(result.reserved, 0, sizeof(result.reserved));
  return result;
}

- (void) setInfo:(BlobFinderInfo)newInfo; 
{
  lowThreshold = newInfo.lowThreshold;
  highThreshold = newInfo.highThreshold;
  jumpD = newInfo.jumpD;
  minArea = newInfo.minArea;
}

+ (BlobFinderInfo) defaultInfo
{
  BlobFinderInfo result;
  result.lowThreshold = 20; 
  result.highThreshold = 50; 
  result.jumpD = 10; 
  result.minArea = 1000;
  memset(result.reserved, 0, sizeof(result.reserved));
  return result;
}

- (void) applyDefaults
{  
  BlobFinderInfo info = [BlobFinder defaultInfo];
  [self setInfo:info];
}

- (Blob *) firstBlob
{
  return &blob[0];
}

- (int) blobCount
{
  return blobCount;
}

- (void) draw
{
  if (showStrips) [self drawStrips];
  if (showBlobs) [self drawBlobs];
  if (showTargets) [self drawTargets];
}

- (void) drawWithXScale : (float) xScale andYScale : (float) yScale
{
  if (showStrips) [self drawStripsWithXScale : xScale andYScale : yScale];
  if (showBlobs) [self drawBlobsWithXScale : xScale andYScale : yScale];
//  if (showTargets) [self drawTargets];
}

- (CGImageRef) thresholdedImage
{
  UInt8 *srcPtr = [camera subtractedDataPtr];
  
  uint32_t w = camera.imageW;
  uint32_t h = camera.imageH;
  
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
      if ((*srcPtr) >= highThreshold) i = 255;
      else if ((*srcPtr) >=lowThreshold) i = 128;
      else i = 0;
      
      *(pixelPtr+0) = i;
      *(pixelPtr+1) = i;
      *(pixelPtr+2) = i;
      *(pixelPtr+3) = 255;          // alpha
     
      pixelPtr += bytesPerPixel;
      srcPtr++;
    }
    rowPtr += bpr;
  } 
  
  CGImageRef returnImage = CGBitmapContextCreateImage(ctx);
  
  CGContextRelease(ctx);
  
  if (data) free(data);
  
  return returnImage;
}  


- (Blob) blobAtIndex : (int) i
{
  return blob[i];
}

@end
 