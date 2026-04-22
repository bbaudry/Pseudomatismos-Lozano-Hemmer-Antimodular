#import <Foundation/Foundation.h>

#import "Shader.h"
#import "ReactDiffuse.h"
#import "GLUtils.h"

#import "GLView.h"

#define RDCOLORS (200)

typedef struct RgbColorStruct {
  UInt8 r;
   UInt8 g;
  UInt8 b;
} RgbColor;

typedef RgbColor RDColorTable[RDCOLORS];

@class ReactDiffuse;
@class GLView;

@interface RDColor : Shader
{
  int tag;
  GLuint fbo;
  GLuint texture;
  
  GLuint tableTexture;
  
  RDColorTable colorTable;
  
  BOOL syncColorTable;
  
  BOOL syncVars;
  
  float colorDivider;
  float scale;
  
  float sOffset;
  int scrollV;
  
  IBOutlet ReactDiffuse *reactDiffuse;
  IBOutlet GLView *glView;
  
  BOOL fix;
  
  BOOL applyAlpha;
  
  float alphaScale;
  
  BOOL makeReset;
}

- (void) initLazy;
- (void) dealloc;

- (void) loadShaders;

- (void) createTexture;
- (void) freeTexture;

- (void) createFBO;
- (void) freeFBO;

- (void) renderToTexture;

- (void) renderToScreen2D;
- (void) renderToScreen3D;

- (void) setupColors;
- (void) copyColorTableToGPU;

- (void) initUniformVars;

- (void) setColorDivider : (float) v;
- (void) setScale : (float) v;

- (void) updateScroll;

- (void) loadSettings : (int) season;
- (void) saveSettings : (int) season;

- (void) bindTexture;

- (IBAction) copyColorTableBtnClicked : (id) sender;

- (void) setApplyAlpha : (BOOL) apply;

- (void) applyDefaults;

- (void) reset;

@property int tag;

@property float colorDivider;
@property float scale;
@property int scrollV;
@property BOOL applyAlpha;
@property float sOffset;

@property float alphaScale;

@end
