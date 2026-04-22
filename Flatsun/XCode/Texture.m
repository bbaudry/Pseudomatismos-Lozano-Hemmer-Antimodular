#import "Texture.h"

#define kTextureVisible @"kTextureVisible"
#define kTextureAlpha @"kTextureAlpha"
#define kTextureTScale @"kTextureTScale"
#define kTextureSOffset @"kTextureSOffset"
#define kTextureTOffset @"kTextureTOffset"
#define kTextureIndex @"kTextureIndex"

@implementation Texture

//@synthesize data;
//@synthesize width;
//@synthesize height;
@synthesize alpha;
@synthesize visible;
@synthesize tScale;
@synthesize sOffset;
@synthesize tOffset;
@synthesize imageI;

- (id) init
{ 
  if (self = [super init]) {
  }
  return self;
}

- (void) awakeFromNib 
{
  bytesPerPixel = 4;    
  
  return;
}

- (void) dealloc
{
  for (int i = 0; i < MAX_IMAGES; i++) {
    if (data[i]) free(data[i]);
  }  
  [super dealloc];
}

- (void) applyDefaults
{ 
  for (int s = 0; s <= SEASONS; s++) {
    season[s].visible = NO;
    season[s].alpha = 0.5;
    season[s].tScale = 0.6;
    season[s].sOffset = -0.40;
    season[s].tOffset = -0.38;
    season[s].imageI = 0;
  }  
}

- (void) loadSettings
{
  for (int s = 0; s < SEASONS; s++) {
    season[s].tScale = [settings floatFromKey : kTextureTScale andSeason : s];
    season[s].visible = [settings intFromKey : kTextureVisible andSeason : s];
    season[s].alpha = [settings floatFromKey : kTextureAlpha andSeason : s];
    season[s].sOffset = [settings floatFromKey : kTextureSOffset andSeason : s];
    season[s].tOffset = [settings floatFromKey : kTextureTOffset andSeason : s];
    season[s].imageI = [settings intFromKey : kTextureIndex andSeason : s];
  }  
}  

- (void) saveSettings 
{
  for (int s = 0; s < SEASONS; s++) {
    [settings setInt : (int) season[s].visible forKey : kTextureVisible andSeason : s];
    [settings setFloat : season[s].alpha forKey : kTextureAlpha andSeason : s];
    [settings setFloat : season[s].tScale forKey : kTextureTScale andSeason : s];  
    [settings setFloat : season[s].sOffset forKey : kTextureSOffset andSeason : s];  
    [settings setFloat : season[s].tOffset forKey : kTextureTOffset andSeason : s];  
    [settings setInt : (int) season[s].imageI forKey : kTextureIndex andSeason : s];
  }  
}

- (void) copyVarsFromSeason : (int) s
{
  self.tScale = season[s].tScale;
  self.visible = season[s].visible;
  self.alpha = season[s].alpha;
  self.sOffset = season[s].sOffset;
  self.tOffset = season[s].tOffset;
  self.imageI = season[s].imageI;
}  

- (void) copyVarsToSeason : (int) s
{
  season[s].tScale = tScale;
  season[s].visible = visible;
  season[s].alpha = alpha;
  season[s].sOffset = sOffset;
  season[s].tOffset = tOffset;
  season[s].imageI = imageI;
}

- (void) loadImage : (NSString *) imageName intoIndex : (int) index
{

  NSImage *image = [NSImage imageNamed : imageName];
  
// copy the pixel data over
  NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
  
  unsigned char *imageData = [imageRep bitmapData];
  
  width[index] = [image size].width;
  height[index] = [image size].height;
  
//  NSLog(@"Image #%i loaded with %@ - width:%i height:%i", 
//        index, imageName, width[index], height[index]);
        
  int size = width[index] * height[index] * sizeof(RGBAPixel);
  data[index] = malloc(size);
  
  RGBPixel *srcPixel = (RGBPixel *) imageData;
  RGBAPixel *destPixel = (RGBAPixel *) data[index];
  
  for (int y = 0; y < height[index]; y++) {
    for (int x = 0; x < width[index]; x++) {
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
 // int size = width * height * sizeof(RGBAPixel);
//  data = malloc(size);
}

- (void) fillData
{
/*  int x,y;
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
  */
}

- (void) apply 
{
// set it to repeat in S and T
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

// set the filters
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width[imageI], height[imageI], 0, GL_RGBA,
               GL_UNSIGNED_BYTE, data[imageI]);
}

- (void) bind
{
  if (!name[imageI]) [self store];
  glBindTexture(GL_TEXTURE_2D, name[imageI]);  
}

- (void) unStore
{
  if (name[imageI]) glDeleteTextures(1, &name[imageI]);
}

- (void) store
{
  if (!name[imageI]) glGenTextures(1, &name[imageI]);

  glBindTexture(GL_TEXTURE_2D, name[imageI]);
  [self apply];
  glBindTexture(GL_TEXTURE_2D,0);
} 

- (void) render
{
  [self bind];
  [GLUtils Texture3DQuadWithSize : 1.0 sOffset : sOffset andTOffset : tOffset];
}

@end
