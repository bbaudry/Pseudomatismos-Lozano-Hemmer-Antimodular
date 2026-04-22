#import <Cocoa/Cocoa.h>
#import "Types.h"
#import "Math2D.h"
#import "Texture.h"
#import "GLView.h"
#import "Settings.h"
#import "Camera.h"
#import "LedPanel.h"
#import "ReactDiffuse.h"
#import "RDColor.h"
#import "Perlin.h"


#define ROTATE_SCALE (4)

typedef enum ShowModeEnum {smWindow,smPrimary,smSecondary} ShowMode;

typedef enum SphereTypeEnum {ptSide=0,ptUnder} SphereType;

typedef struct SwingStruct {
  BOOL active;
  
  uint64_t startTime;

// OpenGL camera settings  
  float startSceneRx;
  float startSceneRz;
  float startCamZ;
  float startFov;  
  
  float endSceneRx;
  float endSceneRz;
  float endCamZ;
  float endFov;
  
// physical camera
  float startCameraRz;
  float endCameraRz;
  
// halo 
  float startHaloR;
  float startHaloY;   
  float startHaloMin;
  float startHaloMax;
  float startHaloGain;
  
  float endHaloR;
  float endHaloY;
  float endHaloMin;
  float endHaloMax;
  float endHaloGain;
  
// reaction diffusion
  float startF1;
  float startK1;
  float startH1;
  float startColorDivisor1;
  float startRDAlpha1;
  
  float startF2;
  float startK2;
  float startH2;
  float startColorDivisor2;
  float startRDAlpha2;

  float endF1;
  float endK1;
  float endH1;
  float endColorDivisor1;
  float endRDAlpha1;
  
  float endF2;
  float endK2;
  float endH2;
  float endColorDivisor2;
  float endRDAlpha2;
  
// perlin
  float startPerlinAlpha;
  float startPerlinHue;
  float startPerlinIntensity;
  float startPerlinSize;  
  
  float endPerlinAlpha;
  float endPerlinHue;
  float endPerlinIntensity;
  float endPerlinSize;  
  
// progress  
  float fraction;

} Swing;

typedef struct SphereSeasonStruct {
  float x,y,z;
  
  float rx,ry,rz;
 
  float camRz;
  float camZ;
  float fov;
  int slices;
  int stacks;
  float endAngle;
  float sliceAngle;
  BOOL camVisible;
  float camAlpha;
  
  float camSOffset;
  float camTOffset;
  
  float camTScale;
  
  float sphereR;
  SphereType type;
  float sceneRx;
  float sceneRz;
  CamMode camMode;
} SphereSeason;

//typedef SphereSeason SphereSeasonArray[SEASONS+1];

@class GLView;
@class ReactDiffuse;
@class RDColor;
@class Perlin;

@interface Sphere : NSObject {

  Swing swing;
  Vertex *vertex;
  
  struct SphereSeasonStruct season[SEASONS+1];
    
  IBOutlet Settings *settings;
  IBOutlet GLView *glView;
  IBOutlet Camera *camera;
  IBOutlet LedPanel *ledPanel;
  IBOutlet ReactDiffuse *reactDiffuse1;
  IBOutlet ReactDiffuse *reactDiffuse2;
  IBOutlet RDColor *rdColor1;
  IBOutlet RDColor *rdColor2;
  IBOutlet Perlin *perlin;
    
  float x,y,z;
  float rx,ry,rz;
  
  float camRz;
  float camZ;
  float fov;
  int slices;
  int stacks;
  float endAngle;
  float sliceAngle;
  BOOL camVisible;
  float camAlpha;
  
  float camSOffset;
  float camTOffset;
  
  float camTScale;
  
  float sphereR;
  SphereType type;
  float sceneRx;
  float sceneRz;
  CamMode camMode;
  
  float sOffset;
  float tOffset;
  
  GLuint dlIndex;
  
  BOOL wireFrame;
  float tScale;
	
  int seasonI;
  
  float swingTime;  
}

- (void) render;
- (void) renderPoints;
- (void) renderWireFrame;
- (void) renderSolid;
- (void) renderTextured;
- (void) renderTexturedForDisplayList;
- (void) renderTexturedForMovie;
- (void) renderTexturedForImage;

- (void) createVertices;
- (void) createSideVertices;
- (void) createUnderVertices;

- (void) placeCamera;

- (void) loadSettings;
- (void) saveSettings;

- (void) createDisplayList;
- (void) freeDisplayList; 

- (void) setSphereR : (float) r;

- (void) setSlices : (int) newSlices;
- (void) setStacks : (int) newStacks;

- (void) setEndAngle : (float) angle;

- (void) setType : (SphereType) newType;

- (void) setSliceAngle : (float) angle;

- (void) renderTexturedWithSRepeats : (float) sRepeats andTRepeats : (float) tRepeats;

- (void) renderTexturedWithScale : (float) scale;
- (void) renderTexturedWithScale : (float) scale sOffset : (float) sOff andTOffset : (float) tOff;

- (void) renderTexturedSidewaysWithScale : (float) scale; 
- (void) renderTexturedSidewaysWithScale : (float) scale andOffset : (float) offset;
- (void) renderTexturedSidewaysWithScale : (float) scale sOffset : (float) sOff andTOffset : (float) tOff;
- (void) renderTexturedSidewaysAndMirroredWithScale : (float) scale sOffset : (float) sOff andTOffset : (float) tOff;

- (void) renderTexturedSidewaysAndFlippedWithScale : (float) scale sOffset : (float) sOff andTOffset : (float) tOff;
- (void) renderTexturedSidewaysFlippedAndMirroredWithScale : (float) scale sOffset : (float) sOff andTOffset : (float) tOff;

- (void) applyDefaults;

- (void) setSeasonI : (int) s;

- (void) swingToSceneRx : (float) srx sceneRz : (float) srz z : (float) cz andFov : (float) cFov;

- (void) setSwingStartVars;
- (void) startSwing;
- (void) updateSwing;
- (void) endSwing;

- (IBAction) homeBtnClicked : (id) sender;

- (void) setCamMode : (CamMode) mode;

- (void) copyVarsFromSeason : (int) s;
- (void) copyVarsToSeason : (int) s;

- (void) setSceneRx : (float) v;
- (void) setSceneRz : (float) v;

- (void) setFov : (float) v;
- (void) setCamZ : (float) v;

- (BOOL) swingActive;
- (float) swingFraction;

@property float x;
@property float y;
@property float z;

@property float rx;
@property float ry;
@property float rz;

@property (nonatomic) float camRz;
@property (nonatomic) float camZ;
@property (nonatomic) float fov;
@property (nonatomic) int slices;
@property (nonatomic) int stacks;
@property (nonatomic) float endAngle;
@property (nonatomic) float sliceAngle;

@property (nonatomic) float sphereR;

@property float sOffset;
@property float tOffset;

//@property float offset;

@property (nonatomic) SphereType type;

@property BOOL wireFrame;

@property (nonatomic) float tScale;

@property float camAlpha;
@property BOOL camVisible;


@property (nonatomic) int seasonI;

@property float camSOffset;
@property float camTOffset;

@property float camTScale;

@property float sceneRx;
@property float sceneRz;

@property float swingTime;

@property CamMode camMode;

@end
