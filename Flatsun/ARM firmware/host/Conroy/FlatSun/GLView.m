#import "GLView.h"

@implementation GLView

@synthesize sOffset;
@synthesize fov;
@synthesize sceneRx;
@synthesize sceneRz;
@synthesize camZ;
@synthesize twoD;
//@synthesize season;

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
  [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:

       [NSNumber numberWithFloat : 1.00f], kCamZ,
       [NSNumber numberWithFloat : 90.00f], kFOV,     
       
    nil]];
}


- (id)initWithFrame:(NSRect)frame 
{
  self = [super initWithFrame:frame];
  if (self) {
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
  [self loadSettings];

  reactDiffuse1.tag = 1;
  reactDiffuse2.tag = 2;
  
  rdColor1.tag = 1;
  rdColor2.tag = 2;
  
  lock = [[NSRecursiveLock alloc] init];
  
//  [self startThread];
}

- (void) loadSettings 
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  self.camZ = [ud floatForKey : kCamZ];
  self.fov = [ud floatForKey : kFOV];  
 }  

- (void) saveSettings
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

  [ud setFloat : camZ forKey : kCamZ];
  [ud setFloat : fov forKey : kFOV];
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
    glColor4f(1.0, 1.0, 1.0, sphere.camAlpha);
    glBindTexture(GL_TEXTURE_2D, 0);
    [camera applyAsTextureForMode : sphere.camMode];
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
    if ([rdColor1 applyAlpha]) glColor4f(1.0, 1.0, 1.0, 1.0); 
    else glColor4f(1.0, 1.0, 1.0, reactDiffuse1.alpha);
    
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
  
    if ([rdColor2 applyAlpha]) glColor4f(1.0, 1.0, 1.0, 1.0);
    else glColor4f(1.0, 1.0, 1.0, reactDiffuse2.alpha);
    
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
    glColor4f(1.0, 1.0, 1.0, texture.alpha);  
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
    glColor4f(1.0, 1.0, 1.0, 1.0);
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
  [self renderReactDiffuse2];  
  [self renderReactDiffuse1];  
  [self renderPerlin];
  
  glFlush();
  
//  [NSOpenGLContext clearCurrentContext];
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
}

- (void) stopThread
{
  [thread cancel];
}

- (void) initShaders
{
  NSOpenGLContext *ctx = [self openGLContext];
  [ctx makeCurrentContext];

 // [rdColor1 initLazy];
  [reactDiffuse1 initLazy];
 // [rdColor2 initLazy];
  [reactDiffuse2 initLazy];
  
  [NSOpenGLContext clearCurrentContext];
}

#define RENDER_DELAY (40000) // 25 fps
- (void) threadLoop : (NSObject *) object
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  double startTime;
  UInt32 elapsedUS;
  
  [self setupPixelFormat];
  [self initShaders];
//  [stopWatch start : 1];
  
  BOOL running = YES;
  
  while (running) {
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
    
    [ledPanelView setNeedsDisplay : YES];
    [haloView setNeedsDisplay : YES];
    [lock unlock];
    
    if ([[NSThread currentThread] isCancelled]) running = NO;
    else {
      elapsedUS = (UInt32) ([StopWatch currentSeconds] - startTime) * 1000000;
      if (elapsedUS < RENDER_DELAY) usleep(RENDER_DELAY - elapsedUS);
    }  
  }
  [pool release];
}

- (void) shutDown
{  
  [reactDiffuse1 saveSettings : sphere.season];
  [reactDiffuse2 saveSettings : sphere.season];
  
  [rdColor1 saveSettings : sphere.season];
  [rdColor2 saveSettings : sphere.season];
  
  [perlin saveSettings : sphere.season];
  
  [sphere saveSettings : sphere.season];
  [texture saveSettings : sphere.season];
  
  [self saveSettings];
}

- (IBAction) twoDBtnClicked : (id) sender
{
  NSButton *btn = (NSButton *) sender;
  twoD = btn.state;
}

- (IBAction) defaultsBtnClicked : (id) sender
{
  [lock lock];
  [sphere applyDefaults];
  [reactDiffuse1 applyDefaults];
  [reactDiffuse2 applyDefaults];
  [rdColor1 applyDefaults];
  [rdColor2 applyDefaults];
  [perlin applyDefaults];
  [ledPanel applyDefaults];
  [texture applyDefaults];
  [lock unlock];
}

- (void) saveAll
{
  [sphere saveSettings : sphere.season];
  [reactDiffuse1 saveSettings : sphere.season];
  [reactDiffuse2 saveSettings : sphere.season];
  [rdColor1 saveSettings : sphere.season];
  [rdColor2 saveSettings : sphere.season];
  [perlin saveSettings : sphere.season];
  [ledPanel saveSettings : sphere.season];
  [texture saveSettings : sphere.season];
}

- (void) loadAll
{
  [sphere loadSettings : sphere.season];
  [reactDiffuse1 loadSettings : sphere.season];
  [reactDiffuse2 loadSettings : sphere.season];
  [rdColor1 loadSettings : sphere.season];
  [rdColor2 loadSettings : sphere.season];
  [perlin loadSettings : sphere.season];
  [ledPanel loadSettings : sphere.season];
  [texture loadSettings : sphere.season];
  
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

@end
