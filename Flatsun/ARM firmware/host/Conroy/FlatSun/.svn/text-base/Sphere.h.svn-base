#import <Cocoa/Cocoa.h>
#import "Types.h"
#import "Math2D.h"
#import "Texture.h"
#import "GLView.h"

#define ROTATE_SCALE (4)

typedef enum ShowModeEnum {smWindow,smPrimary,smSecondary} ShowMode;

typedef enum SphereTypeEnum {ptSide=0,ptUnder} SphereType;

typedef struct SwingStruct {
  BOOL active;
  
  uint64_t startTime;
  
  float startSceneRx;
  float startSceneRz;
  float startCamZ;
  float startFov;  
  
  float endSceneRx;
  float endSceneRz;
  float endCamZ;
  float endFov;

} Swing;

@class GLView;

@interface Sphere : NSObject {

  Swing swing;
  Vertex *vertex;
  
  float x,y,z;
  float rx,ry,rz;
  
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
  
  float sOffset;
  float tOffset;
  
 // float offset; // added to sOffset - 0, 0.25, 0.50, 0.75 
  
  IBOutlet GLView *glView;
  
  SphereType type;
  
  GLuint dlIndex;
  
  BOOL wireFrame;
  float tScale;
	
  int season;
  
  float sceneRx;
  float sceneRz;
  
  float swingTime;  
  
  CamMode camMode;
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

- (void) loadSettings : (int) s;
- (void) saveSettings : (int) s;

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

- (void) setSeason : (int) s;

- (void) swingToSceneRx : (float) srx sceneRz : (float) srz z : (float) cz andFov : (float) cFov;

- (void) setSwingStartVars;
- (void) startSwing;
- (void) updateSwing;
- (void) endSwing;

- (IBAction) homeBtnClicked : (id) sender;

- (void) setCamMode : (CamMode) mode;

@property float x;
@property float y;
@property float z;

@property float rx;
@property float ry;
@property float rz;

@property float camZ;
@property float fov;
@property int slices;
@property int stacks;
@property float endAngle;
@property float sliceAngle;

@property float sphereR;

@property float sOffset;
@property float tOffset;

//@property float offset;

@property SphereType type;

@property BOOL wireFrame;

@property float tScale;

@property float camAlpha;
@property BOOL camVisible;


@property int season;

@property float camSOffset;
@property float camTOffset;

@property float camTScale;

@property float sceneRx;
@property float sceneRz;

@property float swingTime;

@property CamMode camMode;

@end
