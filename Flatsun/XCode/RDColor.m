#import "RDColor.h"

#define kRDColorColorDivider @"rdColorColorDivider"
#define kRDColorScale @"rdColorScale"
#define kRDColorScrollV @"rdColorScrollV"
#define kRDColorApplyAlpha @"rdColorApplyAlpha"

@implementation RDColor

@synthesize tag;

@synthesize colorDivider;
@synthesize scale;
@synthesize scrollV;

@synthesize applyAlpha;

@synthesize sOffset;

@synthesize alphaScale;

- (id) init
{
  if (self = [super init]) {
  }
  return self;
}

- (void) dealloc
{
  [self freeFBO];
  [self freeTexture];

  [super dealloc];
}

- (void) applyDefaults
{  
  float cDivider;
  float cScale;
  
  if (tag == 1) {
    cDivider = 0.561;
    cScale = 2.199;
  }
  else {
    cDivider = 1.0;
    cScale = 2.017;
  }
  
  for (int s=0; s <= SEASONS; s++) {
    season[s].scrollV = 0;
    season[s].applyAlpha = YES;
    season[s].colorDivider = cDivider;
    season[s].scale = cScale;
  }
}

- (void) loadSettings 
{
  for (int s = 0; s <= SEASONS; s++) {
    season[s].colorDivider = [settings floatFromKey : kRDColorColorDivider andTag : tag andSeason : s];
    season[s].scale = [settings floatFromKey : kRDColorScale andTag : tag andSeason : s];
    season[s].scrollV = [settings intFromKey : kRDColorScrollV andTag : tag andSeason : s];
    season[s].applyAlpha = [settings intFromKey : kRDColorApplyAlpha andTag : tag andSeason : s];
  }  
}  

- (void) saveSettings
{
  for (int s = 0; s <= SEASONS; s++) {
    [settings setFloat : season[s].colorDivider forKey : kRDColorColorDivider andTag : tag andSeason : s];
    [settings setFloat : season[s].scale forKey : kRDColorScale andTag : tag andSeason : s];
    [settings setInt : season[s].scrollV forKey : kRDColorScrollV andTag : tag andSeason : s];
    [settings setInt : season[s].applyAlpha forKey : kRDColorApplyAlpha andTag : tag andSeason : s];
  }  
}

- (void) copyVarsFromSeason : (int) s
{
  self.colorDivider = season[s].colorDivider;
  self.scale = season[s].scale;
  self.scrollV = season[s].scrollV;
  self.applyAlpha = season[s].applyAlpha;
}

- (void) copyVarsToSeason : (int) s
{
  season[s].colorDivider = colorDivider;
  season[s].scale = scale;
  season[s].scrollV = scrollV;
  season[s].applyAlpha = applyAlpha;
}

- (void) awakeFromNib
{
  sOffset = 0.0;
  makeReset = NO;
}

- (void) reset
{
  [glView applyLock];
    makeReset = YES;
  [glView removeLock];
}

- (void) loadShaders
{
  NSBundle *bundle;
  NSString *fragment_string;
  NSString *vertex_string;

  bundle = [NSBundle bundleForClass: [self class]];
  
// Load the vertex and fragment shaders 
  vertex_string = [bundle pathForResource: @"Color" ofType: @"vert"];
  vertex_string = [NSString stringWithContentsOfFile: vertex_string];
  fragment_string = [bundle pathForResource: @"Color" ofType: @"frag"];
  fragment_string = [NSString stringWithContentsOfFile: fragment_string];
  
  [self loadVertexShader: vertex_string andFragmentShader: fragment_string];
    
// make sure it worked    
  if (!programObject) NSLog(@"Failed to load shaders");
}	

- (void) initLazy
{
  [super initLazy];
  
  [self createTexture];
  [self createFBO];
  
  [self loadShaders];
  [self initUniformVars];
}  

- (void) initUniformVars
{
  if (!programObject) return;
  GLuint varLoc;
  
  glUseProgramObjectARB(programObject);
  glUniform1iARB(glGetUniformLocationARB(programObject, "inTexture"), 0);

  glUniform1fARB(glGetUniformLocationARB(programObject, "divider"), colorDivider);
  glUniform1fARB(glGetUniformLocationARB(programObject, "scale"), scale);
  
  varLoc = glGetUniformLocationARB(programObject, "applyAlpha");
  glUniform1iARB(varLoc, applyAlpha);
  
  varLoc = glGetUniformLocationARB(programObject, "alphaScale");
  glUniform1fARB(varLoc, alphaScale);
  
  glUseProgramObjectARB(NULL);
}

- (IBAction) copyColorTableBtnClicked : (id) sender
{
//  syncColorTable = YES;
  fix = YES;
}

- (void) setAlphaScale : (float) v
{
  [glView applyLock];
    alphaScale = v;
    syncVars = YES;
  [glView removeLock];  
}

- (void) renderToTexture
{
	if (!initialized) {
    [self initLazy];
  }
  
  if (fix) {
    [self freeFBO];
    [self freeTexture];

    [self createTexture];
  
    [self createFBO];

    fix = NO;
  }

  if (syncColorTable) {
    [self copyColorTableToGPU];
    syncColorTable = NO;
  }
  
  if (syncVars) {
    [self initUniformVars];
    syncVars = NO;
  }
  
  BOOL oldApplyAlpha;
  if (makeReset) {
    oldApplyAlpha = applyAlpha;
    applyAlpha = NO;
    [self initUniformVars];
  }

// enable the shaders  
  glUseProgramObjectARB(programObject);
  
// set the viewport to the size of the texture  
  glViewport(0, 0, TW, TH);
    
// set up the projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  
// establish a 1/1 relationship between pixels and OpenGL units
  glOrtho(0, TW, 0, TH, -1, 1000);

// model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();  
  
// activate the latest RD texture
  [reactDiffuse bindInputTexture];
  
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo); // draw on the texture 
  
  [GLUtils Texture2DQuadWithWidth : TW andHeight : TH];
  
  glBindTexture(GL_TEXTURE_2D, 0);
 // glBindTexture(GL_TEXTURE_1D, 0);
  
  glUseProgramObjectARB(NULL);    
  
// set the screen as the drawing target again  
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);  
  
  if (makeReset) {
    applyAlpha = oldApplyAlpha;
    makeReset = NO;
  }  
}

- (void) renderToScreen2D
{
  glBindTexture(GL_TEXTURE_2D, texture);
  
  [GLUtils Texture2DQuadWithWidth : TW andHeight : TH];
  glBindTexture(GL_TEXTURE_2D, 0);
    
}

- (void) renderToScreen3D
{
  glBindTexture(GL_TEXTURE_2D, texture);
  
  [GLUtils Texture3DQuadWithSize : 1.0 andSOffset : sOffset];
  glBindTexture(GL_TEXTURE_2D, 0);
}

- (void) createTexture
{
  glGenTextures(1, &texture);
  
 	glBindTexture(GL_TEXTURE_2D, texture);
 
// set it to repeat in S and T
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
 	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  
 	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, TW, TH, 0, GL_RGBA, GL_FLOAT, 0);// data

  glBindTexture(GL_TEXTURE_2D, 0);
  
  // create and init the 1D lookup table "texture"
/*  glGenTextures(1, &tableTexture);
glBindTexture(GL_TEXTURE_1D, tableTexture);
  glTexImage1D(GL_TEXTURE_1D, 0, GL_RGBA, RDCOLORS, 0, GL_RGBA, GL_BYTE, 0);// data
  glBindTexture(GL_TEXTURE_1D, 0);
  */

}

- (void) bindTexture
{
 	glBindTexture(GL_TEXTURE_2D, texture);
}

- (void) freeTexture 
{
  glDeleteTextures(1, &texture);
}

- (void) createFBO
{
// create the frame buffer objects
  glGenFramebuffersEXT(1, &fbo);
  
  glBindTexture(GL_TEXTURE_2D, texture);
        
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo);
  
// add the texture as a color attachment to the FBO  
  glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
                            GL_TEXTURE_2D, texture, 0);
                             
// unbind the texture
  glBindTexture(GL_TEXTURE_2D,0);
                            
  GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);  
  
  if (status != GL_FRAMEBUFFER_COMPLETE_EXT) {
    NSAlert* alert = [NSAlert new];
    [alert setMessageText : @"Error creating frame buffer object"];
    [alert runModal];
  } 
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
}

- (void) freeFBO
{
  glDeleteFramebuffersEXT(1, &fbo);
}

- (void) setupColors
{
  int c;
  float frac;

// rdColor[] from 0 -> redI 
  int redI = (int) (colorDivider * RDCOLORS);
  for (c = 0; c < redI; c++) {
    if (redI == 0) colorTable[c].r = 255;
    else colorTable[c].r = (int) (255 * c / redI);
    colorTable[c].g = 0;
  }
  
// next 1/2 goes from red to red + green (yellow)
  int count = (RDCOLORS - 1) - (redI + 1);
  
  for (c = redI; c < RDCOLORS; c++) {
    colorTable[c].r = 255;
    
    if (count == 0) frac = 0;
    else frac = ( (float) c - (float) redI) / (float) count;
    
    colorTable[c].g = (int) (255 * frac);
  }
  colorTable[RDCOLORS-1].g = 255;
  
  syncColorTable = YES;
}

- (void) copyColorTableToGPU
{
  glTexImage1D(GL_TEXTURE_2D, 0, GL_RGB, RDCOLORS, 0, GL_RGB, GL_BYTE, &colorTable); 
  glBindTexture(GL_TEXTURE_1D, 0);
}  

- (void) setColorDivider : (float) v
{
  [glView applyLock];
    colorDivider = v;
    syncVars = YES;
  [glView removeLock];  
}

- (void) setScale : (float) v
{
  [glView applyLock];
    scale = v;
    syncVars = YES;
  [glView removeLock];    
}

- (void) updateScroll
{
  sOffset = sOffset + (float) scrollV / 100000.0f;
  if (sOffset > 1.0) sOffset = sOffset - 1.0;
}  

- (void) setApplyAlpha : (BOOL) apply
{
  [glView applyLock];
    applyAlpha = apply;
    syncVars = YES;
  [glView removeLock];  
}

@end
