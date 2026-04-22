#import "Shader.h"
#import "Routines.h"
#import "BlobFinder.h"

#import "RDColor.h"
#import "GLView.h"

#define TW (256)
#define TH (256)

//#define TW (380)
//#define TH (380)

//#define TW (512)
//#define TH (512)

//#define TW (1024)
//#define TH (1024)

//#define TW (2048)
//#define TH (2048)

#define DATA_SIZE (TW * TH * 4 * sizeof(float))

#define MAX_SPD_AVGS (600)

typedef enum RDTypeEnum {rdSpots,rdWaves,rdPulsating,rdLabyrinth} RDType;

@class BlobFinder; 
@class RDColor;
@class GLView;

@interface ReactDiffuse : Shader {

  int tag;
  
  RDType rdType;
  
  int textureW;
  int textureH;
  
  float *data;
  
  float avgSpeed[MAX_SPD_AVGS];
  int avgI;
  int avgSpd;
    
  float alpha;
  
  float tScale;
  
  BOOL makeRandom;
  BOOL makeReset;
  BOOL makeSquares;
  BOOL readData;
  BOOL syncData;
  
  BOOL texturesInitialized;
  
  float f;
  float k;
  float h;
  
  float dt;
  
  GLuint fbo[2];
  GLuint pbo[2];
  GLuint texture[2];
  
  BOOL oddFrame;
  
  BOOL visible;
  
  BOOL applyColor;
  
  int speed;
  
  float sOffset;
  
  int averages;
  int accScale;
  
  int minSpeed; 
   
  float disturbScale;
  
  IBOutlet BlobFinder *blobFinder;
  
  IBOutlet RDColor *rdColor;
  IBOutlet GLView *glView;
  
  BOOL oneShotSpeedUp;
}

- (id) init;
- (void) initLazy;
- (void) dealloc;

- (void) initData;
- (void) disturbAtX : (int) x andY : (int) y;
- (void) randomize;
- (void) reset;

- (void) setAlpha : (float) value;

- (void) setF : (float) value;
- (void) setK : (float) value;
- (void) setH : (float) value;

- (void) setDt : (float) value;

- (void) textureQuad2D;
- (void) textureQuad3D;

- (void) createTextures;
- (void) freeTextures;

- (void) createPBOs;
- (void) freePBOs;

- (void) createFBOs;
- (void) freeFBOs;

- (void) renderToTexture;
- (void) renderToScreen2D;
- (void) renderToScreen3D;

- (void) clearData;
- (void) copyDataToTextures;

- (void) readDataFromTexture : (int) t;

- (void) addTwoSquares;

- (void) setDataFromRed : (float) r andGreen : (float) g;

- (CGImageRef) currentDataImage;

- (void) bindInputTexture;

- (void) smallDisturbAtX : (int) x andY : (int) y;

- (void) syncWithBlobFinder;

- (void) addCircleDisturbanceAtX : (int) x andY : (int) y withSize : (int) size;

- (void) addDisturbanceAtX : (int) x andY : (int) y withSize : (int) size;

- (void) initializeWithF : (float) newF andK : (float) newK andH : (float) newH;

- (void) loadSettings : (int) season;
- (void) saveSettings : (int) season;

- (float) scaledSpeed;

- (void) updateSpeed;

- (void) copyDataFromPBO : (int) i;

- (void) applyDefaults;

- (IBAction) randomBtnClicked : (id) sender;
- (IBAction) resetBtnClicked : (id) sender;
- (IBAction) addSquares : (id) sender;
- (IBAction) readBtnClicked : (id) sender;

- (IBAction) selectSpots : (id) sender;
- (IBAction) selectWaves : (id) sender;
- (IBAction) selectPulsating : (id) sender;
- (IBAction) selectLabyrinth : (id) sender;

@property int tag;

@property BOOL makeRandom;

@property float f;
@property float k;
@property float h;

@property float dt;

@property int textureW;
@property int textureH;

@property BOOL visible;

@property float alpha;

@property BOOL syncData;

@property int speed;

@property BOOL applyColor;

@property int averages;
@property int accScale;

@property int avgSpd;

@property RDType rdType;

@property float disturbScale;

@property float tScale;
@property int minSpeed;

@end
