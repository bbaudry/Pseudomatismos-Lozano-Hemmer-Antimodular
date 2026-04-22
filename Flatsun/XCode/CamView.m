#import "CamView.h"


@implementation CamView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    xScale = 0;
  }
  return self;
}

- (void) awakeFromNib 
{
//  [self setScale];
}

- (void) setScale
{
  xScale = self.frame.size.width / camera.imageW;
  yScale = self.frame.size.height / camera.imageH;
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
  
  if (xScale == 0) [self setScale];
  
  [blobFinder drawWithXScale : xScale andYScale : yScale];
}

@end
