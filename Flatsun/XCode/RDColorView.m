#import "RDColorView.h"

@implementation RDColorView

@synthesize colorDivider;

- (id)initWithFrame:(NSRect)frame 
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setColorDivider : 0.50];
  }
  return self;
}

- (void) showColorsWithHeight : (int) viewHeight
{
  float r,g;
  for (int x=0; x < RDCOLORS; x++) {
    NSBezierPath *path = [NSBezierPath bezierPath];
    r = (float) (rdColor[x].r / 255.0f);
    g = (float) (rdColor[x].g / 255.0f);
    
    [[NSColor colorWithDeviceRed:r green:g blue:0.0f alpha:1.0f] set];
    
    [path moveToPoint : NSMakePoint(x,0)];
    [path lineToPoint : NSMakePoint(x,viewHeight)];
    
    [path stroke];
  }
}

- (void) setupColors
{
  int c;
  float frac;

// rdColor[] from 0 -> redI 
  int redI = (int) (colorDivider * RDCOLORS);
  for (c = 0; c < redI; c++) {
    if (redI == 0) rdColor[c].r = 255;
    else rdColor[c].r = (int) (255 * c / redI);
    rdColor[c].g = 0;
  }
  
// next 1/2 goes from red to red + green (yellow)
  int count = (RDCOLORS - 1) - (redI + 1);
  
  for (c = redI; c < RDCOLORS; c++) {
    rdColor[c].r = 255;
    
    if (count == 0) frac = 0;
    else frac = ( (float) c - (float) redI) / (float) count;
    
    rdColor[c].g = (int) (255 * frac);
  }
  rdColor[RDCOLORS-1].g = 255;
}

- (void)drawRect:(NSRect)dirtyRect
{
  [self showColorsWithHeight : self.bounds.size.height];
}

- (void) setColorDivider : (float) fraction
{
  colorDivider = fraction;
  [self setupColors];
  [self setNeedsDisplay:YES];
}

- (IBAction) colorSliderMoved : (id) sender
{
  float v = [(NSSlider *) sender floatValue];
  [self setColorDivider : v];
}

@end
