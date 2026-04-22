#import "Image.h"

@implementation Image

@synthesize texture;

- (void) awakeFromNib 
{
  texture = [[Texture alloc] init];
  [self loadTexture];
}

- (void) dealloc
{
  [texture release];
  [super dealloc];
}

- (void) loadTexture
{
  NSImage *image = [NSImage imageNamed : @"sun1.jpg"];
  
// copy the pixel data over
  NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
  
  unsigned char *imageData = [imageRep bitmapData];
  
  texture.width = [image size].width;
  texture.height = [image size].height;
  [texture initData];
  
  RGBPixel *srcPixel = (RGBPixel *) imageData;
  RGBAPixel *destPixel = (RGBAPixel *) texture.data;
  
  for (int y = 0; y < texture.height; y++) {
    for (int x = 0; x < texture.width; x++) {
      (*destPixel).r = (*srcPixel).r;
      (*destPixel).g = (*srcPixel).g;
      (*destPixel).b = (*srcPixel).b;
      (*destPixel).a = 255;
      
      srcPixel++;
      destPixel++;
    }
  }  
}

- (void) render
{
  [texture bind];
 // [projector renderTextured];
}

- (void) apply
{
  [texture bind];
//  [texture apply];
}

- (void) textureQuad
{
  [texture apply];
 	glBegin(GL_QUADS);
  
// bottom left  
    glTexCoord2f(0, 1);
    glVertex2f(0, 0);
    
// top left    
    glTexCoord2f(1, 1); 
    glVertex2f(texture.width, 0);
    
// top right    
    glTexCoord2f(1, 0);
    glVertex2f(texture.width, texture.height);
    
// bottom right    
    glTexCoord2f(0, 0);
    glVertex2f(0, texture.height);
  glEnd();
}

@end
