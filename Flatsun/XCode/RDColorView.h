#import <Cocoa/Cocoa.h>

#define RDCOLORS (200)

typedef struct RGColorStruct {
  UInt8 r;
  UInt8 g;
} RGColor;

typedef RGColor RDColor[RDCOLORS];

@interface RDColorView : NSView 
{
  float colorDivider;
  RDColor rdColor;
}

- (void) setColorDivider : (float) fraction;

- (IBAction) colorSliderMoved : (id) sender;

@property float colorDivider;

@end
