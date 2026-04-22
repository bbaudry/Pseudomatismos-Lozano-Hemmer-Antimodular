#import "Shader.h"
#import "GLUtils.h"
#import "BlobFinder.h"
#import "GLView.h"
#import "Settings.h"

#define MAX_SPEED_AVGS (400)

@class BlobFinder;
@class GLView;

typedef struct PerlinSeasonStruct {
  float alpha;
  float hue;
  float intensity;
  float xSpeed;
  float zSpeed;
  float scale2;
  int averages;
  int accScale;
  float minSpeed;
  BOOL visible;
} PerlinSeason;

//typedef PerlinSeason PerlinSeasonArray[SEASONS+1];

@interface Perlin : Shader {

  IBOutlet Settings *settings;
  
  struct PerlinSeasonStruct season[SEASONS+1];
  
  Parameter scale;
  
  IBOutlet NSColorWell *colorWell;
  IBOutlet BlobFinder *blobFinder;
  IBOutlet GLView *glView;
  
	float scale2;
  float xSpeed;
  float zSpeed;
  
	GLuint noise_texture;
  
  float xOffset;
  float yOffset;
  float zOffset;
  
  float alpha;
  
  float hue;
  float intensity;
  
  float r, g, b;
  
  BOOL visible;
  
  float avgSpeed[MAX_SPEED_AVGS];
  int avgI;
  
  float avgSpd;  
  
  int averages;
  int accScale;
  
  float minSpeed;
}

- (id) init;
- (void) initLazy;
- (void) dealloc;
- (void) renderFrame;

- (void) apply;
- (void) remove;

- (void) setHue : (float) value;
- (void) setIntensity : (float) value;

- (void) syncColorWell;

- (void) render;

- (void) loadSettings;
- (void) saveSettings;

- (void) copyVarsFromSeason : (int) s;
- (void) copyVarsToSeason : (int) s;

- (void) updateSpeed;

- (float) scaledZSpeed;

- (void) applyDefaults;

@property float xOffset;
@property float yOffset;
@property float zOffset;

@property float alpha;

@property (nonatomic) float hue;
@property (nonatomic) float intensity;

@property BOOL visible;

@property float scale2;
@property float xSpeed;
@property float zSpeed;

@property int averages;
@property int accScale;

@property float avgSpd;
@property float minSpeed;

@end
