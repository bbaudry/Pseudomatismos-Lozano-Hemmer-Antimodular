#import "RDView.h"


@implementation RDView

- (id)initWithFrame:(NSRect)frame 
{
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void) awakeFromNib
{
//  [[self window] makeFirstResponder: self];
 // [[self window] setAcceptsMouseMovedEvents: YES];
}

/*
- (BOOL) acceptsFirstResponder 
{
  return YES;
}*/

- (void)drawRect:(NSRect)dirtyRect
{
  CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
  
  CGImageRef img;
  
  if (reactDiffuse) img = [reactDiffuse currentImage];
  else img = [ledPanel image];
  
  if (!img) return;
  
  CGRect rect;
  
  rect.origin.x = dirtyRect.origin.x;
  rect.origin.y = dirtyRect.origin.y;
  rect.size.width = dirtyRect.size.width;
  rect.size.height = dirtyRect.size.height;
  
  CGContextDrawImage(context, rect, img);
  
  CFRelease(img);
  
//  [ledPanel drawSourceRectangle];
}

- (void) setReactDiffuse : (ReactDiffuse *) rd
{
  reactDiffuse = rd;
}

/*- (void) mouseMoved : (NSEvent *) event
{
  NSPoint eventPt = [event locationInWindow];
  NSPoint mousePt = [self convertPoint : eventPt fromView : nil];
  mousePt.y = (self.bounds.size.height - 1) - mousePt.y;
  [reactDiffuse disturbAtX : mousePt.x andY : mousePt.y];
}*/

@end
