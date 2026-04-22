#import <Cocoa/Cocoa.h>

#include "Camera.h"

@class Camera;
@class BlobFinder;

@interface CamView : NSView 
{
  CGImageRef *cgImage;
  float xScale;
  float yScale;
  
  IBOutlet Camera *camera;
  IBOutlet BlobFinder *blobFinder;
}

- (void) setScale;

@end
