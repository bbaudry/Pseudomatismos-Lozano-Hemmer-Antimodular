#import "ColorView.h"

@implementation ColorView

- (id)initWithFrame:(NSRect)frame 
{
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  [reactDiffuse showColorsWithHeight : self.bounds.size.height];
}

- (IBAction) colorDividerSliderMoved : (id) sender
{
  NSSlider *slider = (NSSlider *) sender;
  reactDiffuse.colorDivider = [slider floatValue];
  [reactDiffuse setupColors];
  [self setNeedsDisplay:YES];
}

@end
