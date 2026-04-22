#import "HaloView.h"

@implementation HaloView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  CGImageRef img = [ledPanel haloImage];
  if (!img) return;
  
  CGRect rect;
  
  rect.origin.x = dirtyRect.origin.x;
  rect.origin.y = dirtyRect.origin.y;
  rect.size.width = dirtyRect.size.width;
  rect.size.height = dirtyRect.size.height;

  CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
  CGContextDrawImage(context, rect, img);
  
  CFRelease(img);
}

@end
