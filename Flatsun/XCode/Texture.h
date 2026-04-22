#import <Cocoa/Cocoa.h>
#import "Types.h"
#import "ReactDiffuse.h"
#import "GLUtils.h"
#import "Settings.h"

#define MAX_IMAGES (9)

typedef struct TextureSeasonStruct {
  float tScale;
  BOOL visible;
  float alpha;
  
  float sOffset;
  float tOffset;
  
  int imageI;
} TextureSeason;

@interface Texture : NSObject {

  IBOutlet Settings *settings;
  
  struct TextureSeasonStruct season[SEASONS+1];

  int width[MAX_IMAGES];
  int height[MAX_IMAGES];
  int bytesPerPixel;
  
  GLuint name[MAX_IMAGES];  
  
  RGBAPixel *data[MAX_IMAGES];
  
  BOOL visible;
  float alpha;
  
  float tScale;
  float sOffset;
  float tOffset;
  
  int imageI;
}

- (void) initData;
- (void) fillData;
- (void) apply;
- (void) bind;

- (void) store;
- (void) unStore;

- (void) render;

- (void) loadImage : (NSString *) imageName intoIndex : (int) index;

- (void) applyDefaults;

- (void) loadSettings;
- (void) saveSettings;

- (void) copyVarsFromSeason : (int) s;
- (void) copyVarsToSeason : (int) s;

//@property RGBAPixel *data;

//@property int width;
//@property int height;

@property BOOL visible;
@property float alpha;
@property float tScale;

@property float sOffset;
@property float tOffset;

@property int imageI;

@end
