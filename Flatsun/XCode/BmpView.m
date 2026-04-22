#import "BmpView.h"

@implementation BmpView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect 
{
  [glView drawBmp : dirtyRect];
//  [ledPanel drawSourceRectangle];
}

@end
