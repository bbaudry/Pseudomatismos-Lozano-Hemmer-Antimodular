#import <Cocoa/Cocoa.h>
#import "Types.h"

#import "GLUtils.h"

#define BASE_TEXTURE_W (1024)
#define BASE_TEXTURE_H (1024)

@interface BaseTexture : NSObject {

  int width, height;
  int bytesPerPixel;
  
  GLuint name;  
  
  RGBAPixel *data;
  
  BOOL visible;
  float alpha;
}

- (void) initData;
- (void) fillData;

- (void) apply;
- (void) bind;

- (void) store;
- (void) unStore;

- (void) render;

- (void) copyFromBmp : (NSBitmapImageRep *) bmp;

@property RGBAPixel *data;

@property int width;
@property int height;

@property BOOL visible;
@property float alpha;

@end
