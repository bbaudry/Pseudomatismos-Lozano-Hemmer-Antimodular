#import <Cocoa/Cocoa.h>
#import "Types.h"
#import "ReactDiffuse.h"
#import "GLUtils.h"

@interface Texture : NSObject {
  int width, height;
  int bytesPerPixel;
  
  GLuint name;  
  
  RGBAPixel *data;
  
  BOOL visible;
  float alpha;
  
  float tScale;
  float sOffset;
  float tOffset;
}

- (void) initData;
- (void) fillData;
- (void) apply;
- (void) bind;

- (void) store;
- (void) unStore;

- (void) render;

- (void) loadImage : (NSString *) imageName;

- (void) applyDefaults;

- (void) loadSettings : (int) season;
- (void) saveSettings : (int) season;

@property RGBAPixel *data;

@property int width;
@property int height;

@property BOOL visible;
@property float alpha;
@property float tScale;

@property float sOffset;
@property float tOffset;

@end
