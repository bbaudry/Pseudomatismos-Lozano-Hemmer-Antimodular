#import "GLView.h"

@implementation GLView

@synthesize sOffset;
@synthesize fov;
@synthesize sceneRx;
@synthesize sceneRz;
@synthesize camZ;
@synthesize twoD;
@synthesize takeSnapShot;
@synthesize alphaFraction;

#define kRenderDelay @"RenderDelay"
#define kCamZ @"camZ"
#define kFOV @"FOV"

// pixel format definition
+ (NSOpenGLPixelFormat*) basicPixelFormat
{
  NSOpenGLPixelFormatAttribute attributes [] = {
    NSOpenGLPFAWindow,
    NSOpenGLPFADoubleBuffer,	                               // double buffered
    NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute) 16, // 16 bit depth buffer
    (NSOpenGLPixelFormatAttribute) 0
  };
  return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
}

+ (void) initialize
{
/*
  [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:

       [NSNumber numberWithFloat : 1.00f], kCamZ,
       [NSNumber numberWithFloat : 90.00f], kFOV,     
       
    nil]];
    */
}


- (id)initWithFrame:(NSRect)frame 
{
  if (self = [super initWithFrame:frame]) {
  }
  return self;
}

- init
{
  if ((self = [super init])) {
  }
  return self;
}

- (void) dealloc 
{
  [lock release];
  [super dealloc];
}

- (void) awakeFromNib 
{
  alphaFraction = 1.0;

  reactDiffuse1.tag = 1;
  reactDiffuse2.tag = 2;
  
  rdColor1.tag = 1;
  rdColor2.tag = 2;
  
  lock = [[NSRecursiveLock alloc] init];
  
//  [self startThread];
}

- (void) loadSettings 
{
  renderDelay = [settings intFromKey : kRenderDelay];
  [renderDelaySlider setIntValue : renderDelay];
  
  self.camZ = [settings floatFromKey : kCamZ];
  self.fov = [settings floatFromKey : kFOV];  
}  

- (void) saveSettings
{
  [settings setInt : renderDelay forKey : kRenderDelay];
  [settings setFloat : camZ forKey : kCamZ];
  [settings setFloat : fov forKey : kFOV];
 }

- (void) setupPixelFormat
{
// Pixel Format Attributes for the View-based (non-FullScreen) NSOpenGLContext
  NSOpenGLPixelFormatAttribute attrs[] = {

// Specifying "NoRecovery" gives us a context that cannot fall back to the
// software renderer.  This makes the View-based context compatible with the
// fullscreen context, enabling us to use the "shareContext" feature to share
// textures, display lists, and other OpenGL objects between the two.
    NSOpenGLPFANoRecovery,

// Attributes Common to FullScreen and non-FullScreen
    NSOpenGLPFAColorSize, 24,
    NSOpenGLPFADepthSize, 16,
//  NSOpenGLPFADoubleBuffer,
    NSOpenGLPFAAccelerated,
    0 
  };

// Create our non-fullScreen pixel format.
  NSOpenGLPixelFormat* pixelFormat =
    [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
  [self setPixelFormat:pixelFormat];
  
  NSLog(@"Pixel format set");
}

#define DIST_NEAR (0.1)
#define DIST_FAR (100)
- (void) prepareToRender3D
{
  int w = self.bounds.size.width;
  int h = self.bounds.size.height;

  glClearColor(0, 0, 0, 0);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  glViewport(0, 0, w, h);
  
// set up the projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  
  gluPerspective(sphere.fov, (float) w / (float) h, DIST_NEAR, DIST_FAR);

// model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();  
  
// place the camera  
  glTranslatef(0, 0, -sphere.camZ);
  
// rotate the entire scene
  glRotatef(sphere.sceneRx,1,0,0);
  glRotatef(sphere.sceneRz,0,0,1);  

  glDisable(GL_LIGHTING);  
  glDisable(GL_DEPTH_TEST);
}

- (void) prepareToRender2D
{
  int w = self.bounds.size.width;
  int h = self.bounds.size.height;

  glClearColor(0, 0, 0, 0);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  glViewport(0, 0, w, h);
  
// set up the projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  
// establish a 1/1 relationship between pixels and OpenGL units
  glOrtho(0, w, 0, h, -1, 1000);

// model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();  
}

- (void) drawTriangle
{
  glBegin(GL_TRIANGLES); 
    glVertex3f( 0.0, 0.6, 0.0); 
    glVertex3f( -0.2, -0.3, 0.0); 
    glVertex3f( 0.2, -0.3 ,0.0);
  glEnd(); 
  
  glBegin(GL_LINES);
    glVertex2f(-100,-100);
    glVertex2f(100,100);
  glEnd();
}

- (void) enableAlpha
{
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
 // glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_COLOR,GL_BLEND);
}
  
- (void) disableAlpha
{
  glDisable(GL_BLEND);
  glShadeModel(GL_SMOOTH);
}  

- (void)drawRect:(NSRect)bounds
{
 // [self render];
}

- (void) showTexture 
{
  int w = self.bounds.size.width;
  int h = self.bounds.size.height;

 // [texture apply];
 
 glColor3f(1.0,1.0,1.0);
    
 	glBegin(GL_QUADS);
  
// bottom left  
    glTexCoord2f(0, 1);
    glVertex2f(0, 0);
    
// top left    
    glTexCoord2f(1, 1); 
    glVertex2f(w, 0);
    
// top right    
    glTexCoord2f(1, 0);
    glVertex2f(w, h);
    
// bottom right    
    glTexCoord2f(0, 0);
    glVertex2f(0, h);
  glEnd();
}

- (void) renderCamera
{
  if (sphere.camVisible) {
  
    float alpha;
    if (alphaFraction < 1.0) alpha = alphaFraction * sphere.camAlpha;
    else alpha = sphere.camAlpha;
  
    glColor4f(1.0, 1.0, 1.0, alpha);
    glBindTexture(GL_TEXTURE_2D, 0);
    [camera applyAsTextureForMode : sphere.camMode];
    
      
    glPushMatrix();
      glRotatef(sphere.camRz, 0.0, 0.0, 1.0);
 
    
      if (twoD) {
        [GLUtils Texture3DQuadWithSize : 1.0];
      }  
      else {
        if (camera.mirrorTexture) {
          if (camera.flipTexture) {
            [sphere renderTexturedSidewaysFlippedAndMirroredWithScale : sphere.camTScale
                                                              sOffset : sphere.camSOffset
                                                          andTOffset : sphere.camTOffset];
          }
          else {
            [sphere renderTexturedSidewaysAndMirroredWithScale : sphere.camTScale
                                                       sOffset : sphere.camSOffset
                                                    andTOffset : sphere.camTOffset];
          }
                                                   
        }
        else { 
          if (camera.flipTexture) {                              
            [sphere renderTexturedSidewaysAndFlippedWithScale : sphere.camTScale
                                                      sOffset : sphere.camSOffset
                                                   andTOffset : sphere.camTOffset];
          }                               
          else {
            [sphere renderTexturedSidewaysWithScale : sphere.camTScale
                                            sOffset : sphere.camSOffset
                                         andTOffset : sphere.camTOffset];
          }                               
        }                             
      }
    glPopMatrix();  
  }  
}  

- (void) renderReactDiffuse1Texture
{
  if (reactDiffuse1.visible) {
  
// make the texture
    [reactDiffuse1 renderToTexture];  
  
// colorize it
    if (reactDiffuse1.applyColor) [rdColor1 renderToTexture];  
  }
}  

- (void) renderReactDiffuse2Texture
{
  if (reactDiffuse2.visible) {
  
// make the texture
    [reactDiffuse2 renderToTexture];  
  
// colorize it
    if (reactDiffuse2.applyColor) [rdColor2 renderToTexture];  
  }
}  

- (void) renderReactDiffuse1
{  
  if (reactDiffuse1.visible) {
  
    float alpha;
    if ([rdColor1 applyAlpha]) {
      if (alphaFraction < 1.0) alpha = alphaFraction;
      else alpha = 1.0;
    }  
    else {
      if (alphaFraction < 1.0) alpha = alphaFraction *reactDiffuse1.alpha;
      else alpha = reactDiffuse1.alpha;
    }  
    glColor4f(1.0, 1.0, 1.0, alpha); 
    
    [rdColor1 updateScroll];
    if (twoD) {
      if (reactDiffuse1.applyColor) [rdColor1 renderToScreen3D];
      else [reactDiffuse1 renderToScreen3D];
    }
    else {
      if (reactDiffuse1.applyColor) [rdColor1 bindTexture];
      else [reactDiffuse1 bindInputTexture];
      
      sphere.sOffset = rdColor1.sOffset;
      [sphere renderTexturedWithScale : reactDiffuse1.tScale];
    }
  }  
}

- (void) renderReactDiffuse2
{  
  if (reactDiffuse2.visible) {  
  
    float alpha;
    if ([rdColor2 applyAlpha]) {
      if (alphaFraction < 1.0) alpha = alphaFraction;
      else alpha = 1.0;
    }  
    else {
      if (alphaFraction < 1.0) alpha = alphaFraction *reactDiffuse2.alpha;
      else alpha = reactDiffuse2.alpha;
    }  
    glColor4f(1.0, 1.0, 1.0, alpha); 
  
    [rdColor2 updateScroll];
    
    if (twoD) {
      if (reactDiffuse2.applyColor) [rdColor2 renderToScreen3D];  
      else [reactDiffuse2 renderToScreen3D];
    }
    else {
      if (reactDiffuse2.applyColor) [rdColor2 bindTexture];
      else [reactDiffuse2 bindInputTexture];
      
      sphere.sOffset = rdColor2.sOffset;
      [sphere renderTexturedWithScale : reactDiffuse2.tScale];
    }
  }
}  

- (void) renderImage
{
  if (texture.visible) {
    float alpha;
    if (alphaFraction < 1.0) alpha = alphaFraction * texture.alpha;
    else alpha = texture.alpha;
    
    glColor4f(1.0, 1.0, 1.0, alpha);  
    [texture bind];
    if (twoD) [GLUtils Texture3DQuadWithSize : 1];
    else [sphere renderTexturedWithScale : texture.tScale 
                                 sOffset : texture.sOffset
                              andTOffset : texture.tOffset];
  }
}

- (void) renderPerlin 
{  
  if (perlin.visible) {
    glDisable(GL_TEXTURE_2D);  
    glColor4f(1.0, 1.0, 1.0, alphaFraction);
    if (twoD) {
      [perlin render];
    }  
    else {
      [perlin apply];
      [sphere renderTextured];
      [perlin remove];
    }
  }
}  

- (void) render
{
// make the GL context the current context
  NSOpenGLContext *ctx = [self openGLContext];
  [ctx makeCurrentContext];
  
  glDisable(GL_LIGHTING);
  glDisable(GL_DEPTH_TEST);
  
  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);
  
  
  glColor4f(1.0, 1.0, 1.0, 1.0);
  
  if ((!twoD) && (sphere.wireFrame)) {
    [self prepareToRender3D];
    [sphere renderWireFrame];
    glFlush();
    return;
  }
  
  glEnable(GL_TEXTURE_2D);
  
  [self renderReactDiffuse1Texture];
  [self renderReactDiffuse2Texture];
 
  [self enableAlpha];
  
// draw to the screen  
  [self prepareToRender3D];
  
  [self renderImage];  
  [self renderCamera];  
  
// static RD  
  glPushMatrix();
    glRotatef(reactDiffuse2.rz, 0.0, 0.0, 1.0);
    [self renderReactDiffuse2];  
  glPopMatrix();
  
// interactive RD      
  [self renderReactDiffuse1];  
  [self renderPerlin];
  
  glFlush();
}

- (void) mouseDown : (NSEvent *) event
{
  startPt = [event locationInWindow];
}

- (void) mouseDragged : (NSEvent *) event
{
  NSPoint mousePt = [event locationInWindow];
  
  float rx, rz;
  [lock lock];
    rx = sphere.sceneRx;
    rz = sphere.sceneRz;
  [lock unlock];
  
  sphere.sceneRx = rx + 180 * (mousePt.y - startPt.y) / self.bounds.size.height;
  sphere.sceneRz = rz - 180 * (mousePt.x - startPt.x) / self.bounds.size.width;
  
  startPt = mousePt;
}

- (void) drawOnBmp // : (NSBitmapImageRep *) bmp
{
  int w = self.bounds.size.width;
  int h = self.bounds.size.height;
  if (!bmp) {
    bmp = [ImageUtils CreateBmpWithWidth : (int) w andHeight : (int) h];
  }

  UInt8 *srcPtr;
  UInt8 *destPtr;
  
//  [self prepareToRender];
//  [self render];
  glPixelStoref(GL_PACK_ALIGNMENT, 1);

  int size = w * h * 3;
  srcPtr = malloc(size);
  
  glReadPixels(0, 0, w, h, GL_RGB, GL_UNSIGNED_BYTE, srcPtr);
  
  destPtr = [bmp bitmapData];
  memcpy(destPtr, srcPtr, size);
  free(srcPtr);
}

- (void) drawBmp : (NSRect) rect
{
  [bmp drawInRect : rect];
}

- (NSBitmapImageRep *) bmp
{
  return bmp;
}

- (void) startThread
{
  thread = [[NSThread alloc] init];
  [thread initWithTarget : self selector:@selector(threadLoop:) object : nil];
  [thread start];
  stopped = NO;
}

- (void) stopThread
{
  [thread cancel];
  BOOL done = NO;
  while (!done) {
    [lock lock];
      done = stopped;
    [lock unlock];  
  }
}

- (void) initShaders
{
  NSOpenGLContext *ctx = [self openGLContext];
  [ctx makeCurrentContext];

  [reactDiffuse1 initLazy];
  [reactDiffuse2 initLazy];
  
  [NSOpenGLContext clearCurrentContext];
}

- (void) copyBmpToLastSeasonTexture
{
  [lastSeasonTexture copyFromBmp : bmp];
}

- (void) threadLoop : (NSObject *) object
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  double startTime;
  UInt32 elapsedUS;
  
  [self setupPixelFormat];
  [self initShaders];
  
  BOOL running = YES;
  
  while (running) {
    NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
 
    startTime = [StopWatch currentSeconds];
 
    [lock lock]; 
    [sphere updateSwing];
    [self render]; 
    [self drawOnBmp];

    [NSOpenGLContext clearCurrentContext];
    
// sync the LED panel    
    [ledPanel applyLock];
      [ledPanel syncFromBmp : bmp];
      [ledPanel syncHaloFromBmp : bmp];
      [ledPanel syncPanel];
    [ledPanel removeLock];
    
// update the panel and halo displays    
    [ledPanelView setNeedsDisplay : YES];
    [haloView setNeedsDisplay : YES];
    
// free the lock    
    [lock unlock];
    
    if ([[NSThread currentThread] isCancelled]) {
      running = NO;
    }  
    else {
      elapsedUS = (UInt32) ([StopWatch currentSeconds] - startTime) * 1000000;
      if (elapsedUS < renderDelay) usleep(renderDelay - elapsedUS);
    }  
    [pool2 release];
  }
  [pool release];
  stopped = YES;
}

- (void) shutDown
{  
  [self storeSeason];
  
  [self saveAll];
  
  [self saveSettings];
}

- (IBAction) twoDBtnClicked : (id) sender
{
  NSButton *btn = (NSButton *) sender;
  twoD = btn.state;
}

- (IBAction) defaultsBtnClicked : (id) sender
{
  NSAlert *alert = [[NSAlert alloc] init];
  alert.alertStyle = NSWarningAlertStyle;
  alert.messageText = @"Please confirm";
  alert.informativeText = @"Set all to default losing all previous settings?";
  [alert addButtonWithTitle : @"Ok"];
  [alert addButtonWithTitle : @"Cancel"];
  
  if  ([alert runModal] == NSAlertFirstButtonReturn) { 
    [lock lock];
      [settings loadDictionary : YES];
      [self loadAll];
      
      [sphere setSeasonI : sphere.seasonI];
    [lock unlock];
  }  
}

- (void) saveAll
{
  [sphere saveSettings];
  [reactDiffuse1 saveSettings];
  [reactDiffuse2 saveSettings];
  [rdColor1 saveSettings];
  [rdColor2 saveSettings];
  [perlin saveSettings];
  [ledPanel saveSettings];
  [texture saveSettings];
}

- (void) loadAll
{
  [self loadSettings];
  
  [sphere loadSettings];
  [reactDiffuse1 loadSettings];
  [reactDiffuse2 loadSettings];
  [rdColor1 loadSettings];
  [rdColor2 loadSettings];
  [perlin loadSettings];
  [ledPanel loadSettings];
  [texture loadSettings];

  [self assertSeason];
}

- (void) storeSeason
{
  [sphere copyVarsToSeason : sphere.seasonI];
  
  [reactDiffuse1 copyVarsToSeason : sphere.seasonI];
  [reactDiffuse2 copyVarsToSeason : sphere.seasonI];
  
  [rdColor1 copyVarsToSeason : sphere.seasonI];
  [rdColor2 copyVarsToSeason : sphere.seasonI];
  
  [perlin copyVarsToSeason : sphere.seasonI];
  [ledPanel copyVarsToSeason : sphere.seasonI];
  [texture copyVarsToSeason : sphere.seasonI];
}

- (void) assertSeason
{
  [sphere copyVarsFromSeason : sphere.seasonI];
  
  [reactDiffuse1 copyVarsFromSeason : sphere.seasonI];
  [reactDiffuse2 copyVarsFromSeason : sphere.seasonI];
  
  [rdColor1 copyVarsFromSeason : sphere.seasonI];
  [rdColor2 copyVarsFromSeason : sphere.seasonI];
  
  [perlin copyVarsFromSeason : sphere.seasonI];
  [ledPanel copyVarsFromSeason : sphere.seasonI];
  [texture copyVarsFromSeason : sphere.seasonI];
  
  [reactDiffuse1 reset];
  [reactDiffuse1 randomize];

  [reactDiffuse2 reset];
  [reactDiffuse2 randomize];
}

- (void) applyLock
{
  [lock lock];
}

- (void) removeLock
{
  [lock unlock];
}

- (IBAction) homeBtnClicked : (id) sender
{
  [sphere setSwingStartVars];
  sphere.sceneRx = 0.0;
  sphere.sceneRz = 0.0;
  [sphere startSwing];  
}

- (IBAction) renderDelaySliderMoved : (id) sender
{
  NSSlider *slider = (NSSlider *) sender;
  int v = [slider intValue];
  NSLog(@"delay = %i",v);
  [lock lock];
    renderDelay = v;
  [lock unlock];
} 

// called from the main thread when seasons change
- (void) setTakeSnapShot
{
  [lock lock];
    takeSnapShot = YES;
  [lock unlock];
}  

- (void) setAlphaFraction : (float) value
{
  [lock lock];
    alphaFraction = value;
    if (alphaFraction > 1.0) alphaFraction = 1.0;
  [lock unlock];
}



  
@end
