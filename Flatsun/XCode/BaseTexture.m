#import "BaseTexture.h"

@implementation BaseTexture

@synthesize data;
@synthesize width;
@synthesize height;
@synthesize alpha;
@synthesize visible;

- (id) init
{ 
  if (self = [super init]) {
    width = 0; 
    height = 0;
    bytesPerPixel = 3;    
    data = nil;
  }
  return self;
}

- (void) awakeFromNib 
{
}

- (void) dealloc
{
  if (data) free(data);
  [super dealloc];
}

- (void) initData
{
  if (data) free(data);
  int size = width * height * bytesPerPixel;
  data = malloc(size);
}

- (void) fillData
{
  int x,y;
  RGBAPixel *pixelPtr = data;
  
  for (y = 0; y < height; y++) {
    for (x = 0; x < width; x++) {
      (*pixelPtr).r = x;
      (*pixelPtr).g = y;
      (*pixelPtr).b = 0;
      (*pixelPtr).a = 255;
      pixelPtr++;
    }
  }
}

- (void) apply 
{
// set it to repeat in S and T
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

// set the filters
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA,GL_UNSIGNED_BYTE, data);
}

- (void) bind
{
  if (!name) [self store];
  glBindTexture(GL_TEXTURE_2D, name);  
}

- (void) unStore
{
  if (name) glDeleteTextures(1, &name);
}

- (void) store
{
  if (!name) glGenTextures(1, &name);

  glBindTexture(GL_TEXTURE_2D, name);
  [self apply];
  glBindTexture(GL_TEXTURE_2D,0);
} 

- (void) render
{
  [self bind];
  [GLUtils Texture3DQuadWithSize : 1.0 sOffset : 0.0 andTOffset : 0.0];
}

- (void) copyFromBmp : (NSBitmapImageRep *) bmp
{
  UInt8 *imageData = [bmp bitmapData];

  NSSize size = [bmp size];
  
  width = size.width;
  height = size.height;
  bytesPerPixel = 3;

  [self initData];
  
  RGBPixel *srcPixel = (RGBPixel *) imageData;
  RGBPixel *destPixel = (RGBPixel *) data;
  
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      (*destPixel).r = (*srcPixel).r;
      (*destPixel).g = (*srcPixel).g;
      (*destPixel).b = (*srcPixel).b;
      
      srcPixel++;
      destPixel++;
    }
  }  
}

@end

