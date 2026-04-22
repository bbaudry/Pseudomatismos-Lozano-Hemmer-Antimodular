#import "CamView.h"


@implementation CamView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void) drawRect : (NSRect) rect
{
  CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
  CGImageRef img = [camera selectedImage];

  if (!img) return;
  
  CGRect cgRect;
  
  cgRect.origin.x = rect.origin.x;
  cgRect.origin.y = rect.origin.y;
  cgRect.size.width = rect.size.width;
  cgRect.size.height = rect.size.height;
  
  CGContextDrawImage(context, cgRect, img);
  
  CFRelease(img);
  [blobFinder draw];
}

@end
