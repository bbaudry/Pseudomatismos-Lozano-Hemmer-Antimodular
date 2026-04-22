#import "Texture.h"

#define kTextureVisible @"kTextureVisible"
#define kTextureAlpha @"kTextureAlpha"
#define kTextureTScale @"kTextureTScale"
#define kTextureSOffset @"kTextureSOffset"
#define kTextureTOffset @"kTextureTOffset"

@implementation Texture

@synthesize data;
@synthesize width;
@synthesize height;
@synthesize alpha;
@synthesize visible;
@synthesize tScale;
@synthesize sOffset;
@synthesize tOffset;

- (void) awakeFromNib 
{
//  width = 640;
//  height = 480;
  bytesPerPixel = 4;    
  [self loadImage : @"sun.gif"];
  
  return;
  
  [self initData];
  [self fillData];
}

- (void) dealloc
{
  if (data) free(data);
  [super dealloc];
}

- (void) applyDefaults
{ 
  self.visible = NO;
  self.alpha = 0.5;
  self.tScale = 0.6;
  self.sOffset = -0.40;
  self.tOffset = -0.38;
}

- (void) loadSettings : (int) season
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  float v = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kTextureTScale, season]];
  if (v == 0) [self applyDefaults];
  else {
    self.tScale = v;
    self.visible = [ud integerForKey : [NSString stringWithFormat : @"%@-%i", kTextureVisible, season]];
    self.alpha = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kTextureAlpha, season]];
    self.sOffset = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kTextureSOffset, season]];
    self.tOffset = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kTextureTOffset, season]];
  }  
}  

- (void) saveSettings : (int) season
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

  [ud setInteger : (int) visible forKey : [NSString stringWithFormat : @"%@-%i", kTextureVisible, season]];
  [ud setFloat : alpha forKey : [NSString stringWithFormat : @"%@-%i", kTextureAlpha, season]];
  [ud setFloat : tScale forKey : [NSString stringWithFormat : @"%@-%i", kTextureTScale, season]];  
  [ud setFloat : sOffset forKey : [NSString stringWithFormat : @"%@-%i", kTextureSOffset, season]];  
  [ud setFloat : tOffset forKey : [NSString stringWithFormat : @"%@-%i", kTextureTOffset, season]];  
}

- (void) loadImage : (NSString *) imageName
{

  NSImage *image = [NSImage imageNamed : imageName];
  
// copy the pixel data over
  NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
  
  unsigned char *imageData = [imageRep bitmapData];
  
  width = [image size].width;
  height = [image size].height;
  int size = width * height * sizeof(RGBAPixel);
  data = malloc(size);
  
  RGBPixel *srcPixel = (RGBPixel *) imageData;
  RGBAPixel *destPixel = (RGBAPixel *) data;
  
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      (*destPixel).r = (*srcPixel).r;
      (*destPixel).g = (*srcPixel).g;
      (*destPixel).b = (*srcPixel).b;
      (*destPixel).a = 255;
      
      srcPixel++;
      destPixel++;
    }
  }  
}

- (void) initData
{
  int size = width * height * sizeof(RGBAPixel);
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
  [GLUtils Texture3DQuadWithSize : 1.0 sOffset : sOffset andTOffset : tOffset];
}

@end
