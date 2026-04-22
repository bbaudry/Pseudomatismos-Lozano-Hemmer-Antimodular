#import <Cocoa/Cocoa.h>

#include "Camera.h"

@class Camera;
@class BlobFinder;

@interface CamView : NSView 
{
  CGImageRef *cgImage;
  
  IBOutlet Camera *camera;
  IBOutlet BlobFinder *blobFinder;
}

@end
