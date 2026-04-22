#import <Cocoa/Cocoa.h>
#import "Global.h"
#import "Camera.h"

#define MaxStripsPerRow (MAX_IMAGE_W >> 1)
#define MaxBlobs (25)

#define MAX_BLOBS (5)

typedef int XAtYArray[IMAGE_H*2];
typedef int YAtXArray[IMAGE_W*2];

typedef struct BlobStruct {
  int xMin,xMax;
  int yMin,yMax;
  int xc,yc,area;
  XAtYArray minXAtY;
  XAtYArray maxXAtY;
  YAtXArray minYAtX;
  YAtXArray maxYAtX;
  void *prevBlob;
  void *nextBlob;
} Blob;

typedef Blob BlobArray[MaxBlobs];

typedef Blob *PBlob;

typedef struct StripStruct {
	int xMin;
	int xMax;
  int blobI;
	PBlob pBlob;
} Strip;

typedef Strip StripArray[MAX_IMAGE_H][MaxStripsPerRow];

typedef int StripCountArray[MAX_IMAGE_H];

typedef enum ScanModeEnum {	SMLooking = 0, SMTracing, SMJumping } ScanMode;

typedef struct BlobFinderInfoStruct {
	int lowThreshold;
  int highThreshold;
	int jumpD, minArea;
  char reserved[256];
} BlobFinderInfo;

@class Camera;

@interface BlobFinder : NSObject
{
	StripArray strip;
	StripCountArray stripCount;
  
	BlobArray blob;
	int blobCount;
	
	int lowThreshold, highThreshold;
	int jumpD, minArea;
  
  NSRecursiveLock *lock;
  
  BOOL showStrips;
  BOOL showBlobs;
  BOOL showTargets;
  
  IBOutlet Camera *camera;
}

+ (BlobFinderInfo) defaultInfo;

- (IBAction) setLowThreshold:(int)newValue;
- (IBAction) setHighThreshold:(int)newValue;
- (IBAction) setJumpD:(int)newValue;
- (IBAction) setMinArea:(int)newValue;

- (int) lowThreshold;
- (int) highThreshold;
- (int) jumpD;
- (int) minArea;

- (void) findBlobsFromMonoData : (UInt8 *) monoData withWidth : (int) w andHeight : (int) h;
- (void) findBlobsFromColorData : (UInt8 *) data withWidth : (int) w andHeight : (int) h;
- (void) findBlobs:(NSBitmapImageRep *)bmpImage;

- (void) findStripsFromMonoData : (UInt8 *) monoData withWidth : (int) w andHeight : (int) h;
- (void) findStripsFromColorData : (UInt8 *) colorData withWidth : (int) w andHeight : (int) h;
- (void) findStrips:(NSBitmapImageRep *)bmpImage;

- (void) findBlobsFromStrips;
- (void) findBlobCenters;

- (Blob *) removeBlob:(Blob *)xBlob;

- (void) drawStrips;
- (void) drawBlobs;
- (void) drawTargets;

- (void) draw;

- (void) mergeBlob:(Blob *)blob1 withBlob:(Blob *)blob2;
- (void) mergeBlobs;

- (BOOL) strip : (Strip) strip1 overlapsStrip : (Strip) strip2;

- (BOOL) pixelAtX:(int)x Y:(int) y insideBlobAtIndex:(int)i;
- (BOOL) hLineFromX1:(int)x1 X2:(int)x2 Y:(int)y insideBlob:(Blob *)testBlob;
- (BOOL) vLineFromY1:(int)y1 Y2:(int)y2 X:(int) x insideBlob:(Blob *)testBlob;
- (BOOL) blob:(Blob *)blob1 overlapsBlob:(Blob *)blob2;

- (BlobFinderInfo) getInfo;
- (void) setInfo:(BlobFinderInfo)newInfo; 

- (void) applyDefaults;

- (Blob *) firstBlob;
- (int) blobCount;

- (CGImageRef) thresholdedImage;

- (Blob) blobAtIndex : (int) i;

- (void) applyLock;
- (void) removeLock;

- (void) loadSettings;
- (void) saveSettings;

@property int lowThreshold;
@property int highThreshold;

@property int jumpD;
@property int minArea;

@property BOOL showStrips;
@property BOOL showBlobs;
@property BOOL showTargets;

@property int blobCount;

@end
