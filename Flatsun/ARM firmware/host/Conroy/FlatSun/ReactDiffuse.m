#import "ReactDiffuse.h"

#define kReactDiffuseAlpha @"reactDiffuseAlpha"
#define kReactDiffuseSpeed @"reactDiffuseSpeed"
#define kReactDiffuseAverages @"reactDiffuseAverages"
#define kReactDiffuseAccScale @"reactDiffuseAccScale"
#define kReactDiffuseType @"reactDiffuseType"
#define kReactDiffuseDisturbScale @"reactDiffuseDisturbScale"
#define kReactDiffuseTScale @"reactDiffuseTScale"
#define kReactDiffuseMinSpeed @"reactDiffuseMinSpeed"
#define kReactDiffuseVisible @"reactDiffuseVisible"

@implementation ReactDiffuse

@synthesize tag;

@synthesize f;
@synthesize k;
@synthesize h;

@synthesize dt;

@synthesize makeRandom;
@synthesize textureW;
@synthesize textureH;

@synthesize visible;

@synthesize alpha;

@synthesize syncData;

@synthesize speed;

@synthesize applyColor;

@synthesize averages;
@synthesize accScale;

@synthesize avgSpd;

@synthesize rdType;

@synthesize disturbScale;

@synthesize tScale;
@synthesize minSpeed;

+ (void) initialize
{
  [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
     
       [NSNumber numberWithInt : 0], kReactDiffuseType,
       [NSNumber numberWithFloat:0.50f], kReactDiffuseAlpha,
       [NSNumber numberWithInt : 3], kReactDiffuseSpeed,
       [NSNumber numberWithInt : 100], kReactDiffuseAverages,
       [NSNumber numberWithInt : 5], kReactDiffuseAccScale,
       [NSNumber numberWithFloat:1.0f], kReactDiffuseDisturbScale,
       [NSNumber numberWithFloat:1.0f], kReactDiffuseTScale,
      
    nil]];
}

- (void) setRdType : (RDType) newType
{
  [glView applyLock];
  rdType = newType;
  switch (rdType) {
  
    case (rdSpots) :
      [self selectSpots : nil];
      break;
      
    case (rdWaves) :
      [self selectWaves : nil];
      break;
      
    case (rdPulsating) :
      [self selectPulsating : nil];
      break;
      
    case (rdLabyrinth) :
      [self selectLabyrinth : nil];
      break;
  }
  [glView removeLock];
}  

- (void) applyDefaults
{  
  if (tag == 1) {
    self.alpha = 1.0;
    self.averages = 100;
    self.accScale = 5;
    self.rdType = rdSpots;
  }
  else {
    self.alpha = 2.0;
    self.rdType = rdWaves;
  }
  self.visible = YES;
  self.speed = 25;
  self.tScale = 1.0;
  self.minSpeed = 1;
  [self reset];
  [self randomize];
}

- (void) loadSettings : (int) season 
{
//return;
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  self.rdType = [ud integerForKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseType, tag, season]];
  
  self.alpha = [ud floatForKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseAlpha, tag, season]];
  self.speed = [ud integerForKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseSpeed, tag, season]];
  
  self.averages = [ud integerForKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseAverages, tag, season]];
  if (self.averages == 0) self.averages = 1;
  
  self.accScale = [ud integerForKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseAccScale, tag, season]];
  if (self.accScale == 0) self.accScale = 1;

  self.disturbScale = [ud floatForKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseDisturbScale, tag, season]];
  self.tScale = [ud floatForKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseTScale, tag, season]];
  self.minSpeed = [ud integerForKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseMinSpeed, tag, season]];
  self.visible = [ud integerForKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseVisible, tag, season]];
  
  oneShotSpeedUp = YES;
}  

- (void) saveSettings : (int) season
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  [ud setInteger : rdType forKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseType, tag, season]];
    
  [ud setFloat : alpha forKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseAlpha, tag, season]];
  [ud setInteger : speed forKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseSpeed, tag, season]];
  
  [ud setInteger : averages forKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseAverages, tag, season]];
  [ud setInteger : accScale forKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseAccScale, tag, season]];
  
  [ud setFloat : disturbScale forKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseDisturbScale, tag, season]];
  [ud setFloat : tScale forKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseTScale, tag, season]];
  [ud setInteger : minSpeed forKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseMinSpeed, tag, season]];
  [ud setInteger : (int) visible forKey : [NSString stringWithFormat : @"%@%i-%i", kReactDiffuseVisible, tag, season]];
}

- (id) init
{
  [super init];
  
  texturesInitialized = NO;
	
  return self;
}

- (void) awakeFromNib
{
  sOffset = 0.0;
  oneShotSpeedUp = NO;
  self.visible = YES;
  self.applyColor = YES;
}

- (void) setAlpha : (float) value
{  
  [glView applyLock];
  alpha = value;
  rdColor.alphaScale = alpha;
  [glView removeLock];
}

- (void) setF : (float) value
{  
  f = value;
  
  if (!programObject) return;
  
  glUseProgramObjectARB(programObject);
 
  glUniform1fARB(glGetUniformLocationARB(programObject, "f"), f / 1000.0);
  glUseProgramObjectARB(NULL);
}
  
- (void) setK : (float) value
{  
  k = value;
  
  if (!programObject) return;
  
  glUseProgramObjectARB(programObject);
  glUniform1fARB(glGetUniformLocationARB(programObject, "k"), k / 1000.0);
  glUseProgramObjectARB(NULL);

}

#define DU (2E-5)
#define DV (1E-5)
- (void) setH : (float) value
{
  h = value;
  
  if (!programObject) return;
  
  float hs = h / 1000.0;
  
  float duDivH2 = DU / (hs * hs);
  float dvDivH2 = DV / (hs * hs);
  glUseProgramObjectARB(programObject);
  
  glUniform1fARB(glGetUniformLocationARB(programObject, "duDivH2"), duDivH2);
  glUniform1fARB(glGetUniformLocationARB(programObject, "dvDivH2"), dvDivH2);
  glUseProgramObjectARB(NULL);
}

- (void) setDt : (float) value
{  
  dt = value;
  
  if (!programObject) return;
  
  glUseProgramObjectARB(programObject);
  glUniform1fARB(glGetUniformLocationARB(programObject, "dt"), dt);
  glUseProgramObjectARB(NULL);
}

- (void) clearData
{
  if (!data) return;
  
  float *dataPtr = data;

// clear the r,g,b - set the alpha to 1  
  for (int y = 0; y < TH; y++) {
    for (int x = 0; x < TW; x++) {
      *dataPtr++ = 0.0;//255;
      *dataPtr++ = 0.0;
      *dataPtr++ = 0.0;
      *dataPtr++ = 1.0;//255;
    }
  } 
}  

- (void) setDataFromRed : (float) r andGreen : (float) g
{
  float *dataPtr = data;

// clear the r,g,b - set the alpha to 1
  for (int y = 0; y < TH; y++) {
    for (int x = 0; x < TW; x++) {
      *dataPtr++ = r;
      *dataPtr++ = g;
      *dataPtr++ = 0.0;
      *dataPtr++ = 1.0;
    }
  }   
}  

- (void) initData
{
  data = malloc(TW * TW * 4 * sizeof(float)); // rgba
}

- (void) disturbAtX : (int) x andY : (int) y
{
  int width = textureW;
  int height = textureH;
  
// disturb in a square of size*size centered on x,y 
  const int size = 13;
  int c,r;
  
// find the limits of the square  
  int minX = x - size;
  if (minX < 0) minX = 0;

  int maxX = x + size;
  if (maxX >= width) maxX = width - 1;
  
  int minY = y - size;
  if (minY < 0) minY = 0;
  
  int maxY = y + size;
  if (maxY >= height) maxY = height-1;

// set the data
  float *dataPtr;
  for (r = minY; r <= maxY; r++) {
    dataPtr = data;
    dataPtr += ((r * width) + minX) * 4;
    for (c = minX; c <= maxX; c++) {
      *dataPtr++ = 0.50; // red
      *dataPtr++ = 0.25; // green
      *dataPtr++ = 0.00; // blue
      *dataPtr++ = 1.00; // alpha
    }  
  }
 // [self copyDataToTextures]; 
}

- (void) smallDisturbAtX : (int) x andY : (int) y
{
  int width = textureW;

// set the data
  float *dataPtr = data;
  dataPtr += ((y * width) + x) * 4;
 
//  *dataPtr++ = 0.50; // red
//  *dataPtr++ = 0.25; // green
   
  *dataPtr++ = 0.90; // red
  *dataPtr++ = 0.10; // green
  *dataPtr++ = 0.00; // blue
  *dataPtr++ = 1.00; // alpha
}

- (void) copyDataToTextures
{
  if (!data) return;
  for (int i = 0; i < 2; i++) {
  	glBindTexture(GL_TEXTURE_2D, texture[i]);  
  	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, textureW, textureH, 0, 
                 GL_RGBA, GL_FLOAT, data);
  }  
  glBindTexture(GL_TEXTURE_2D, 0);   
}

- (void) reset 
{
  [self clearData];
  [self copyDataToTextures];
}  
  
- (void) randomize
{
  if (!data) return;
  
  int i,x,y;
  
//  [self clearData];
  
  [self setDataFromRed : 1.0 andGreen : 0.0];

    
  for (i = 0; i < 50; i++) {
    x = [Routines randomInt : textureW];
    y = [Routines randomInt : textureH];
      
    [self disturbAtX : x andY : y];
  } 
  
  [self copyDataToTextures];
}

- (IBAction) randomBtnClicked : (id) sender
{
  [glView applyLock];
    makeRandom = YES;
  [glView removeLock];    
}

- (IBAction) resetBtnClicked : (id) sender
{
  [glView applyLock];
    makeReset = YES;
  [glView removeLock];
}

- (void) initLazy
{
  [super initLazy];
  
  [self initData];

  [self createTextures];
  [self createFBOs];
  
 // if (tag == 1)
  [self createPBOs];
  
  oddFrame = YES;
  makeReset = NO;
  makeRandom = YES;
  makeSquares = NO;
  readData = NO;

  NSBundle *bundle;
  NSString *fragment_string;
  NSString *vertex_string;

  bundle = [NSBundle bundleForClass: [self class]];
  
// Load the vertex and fragment shaders 
  vertex_string = [bundle pathForResource: @"ReactDiffuse" ofType: @"vert"];
  vertex_string = [NSString stringWithContentsOfFile: vertex_string];
  fragment_string = [bundle pathForResource: @"ReactDiffuse" ofType: @"frag"];
  fragment_string = [NSString stringWithContentsOfFile: fragment_string];
  [self loadVertexShader: vertex_string andFragmentShader: fragment_string];
    
// make sure it worked    
  if (!programObject) {
    NSLog(@"Failed to load shaders");
    return;
  }	
  	
// Setup uniforms 
  glUseProgramObjectARB(programObject);
  glUniform1iARB(glGetUniformLocationARB(programObject, "inTexture"), 0);
    
  glUniform4fARB(glGetUniformLocationARB(programObject, "pixelDimension"), 
                 1.0/textureW, -1.0/textureW, 
                 1.0/textureH, -1.0/textureH);
  
  glUseProgramObjectARB(NULL);
  
  self.f = f;//20.0;
  self.k = k;//70.0;
  self.h = h;//10.0;
  self.dt = 1.00;
}

- (void) dealloc
{
  [self freeFBOs];
  [self freePBOs];
  [self freeTextures];

  [super dealloc];
}

- (void) textureQuad2D
{
  glBegin(GL_QUADS);
  
// bottom left  
    glTexCoord2f(0, 0);
    glVertex2f(0, 0);
    
// top left    
    glTexCoord2f(1, 0); 
    glVertex2f(textureW, 0);
    
// top right    
    glTexCoord2f(1, 1);
    glVertex2f(textureW, textureH);
    
// bottom right    
    glTexCoord2f(0, 1);
    glVertex2f(0, textureH);
  glEnd();
}

- (void) textureQuad3D
{
  const float size = 1.0;
//  glColor4f(1,0.8,0.75,1);
  
 	glBegin(GL_QUADS);
  
// bottom left  
    glTexCoord2f(0, 0);
    glVertex2f(-size, -size);
    
// top left    
    glTexCoord2f(1, 0); 
    glVertex2f(size, -size);
    
// top right    
    glTexCoord2f(1, 1);
    glVertex2f(size, size);
    
// bottom right    
    glTexCoord2f(0, 1);
    glVertex2f(-size, size);
  glEnd();
}

- (void) updateSpeed
{
  int count;
  [blobFinder applyLock];
  if (blobFinder.blobCount > 0) count = accScale;
  else count = 1;
  
  float spd = [self scaledSpeed];
  
  [blobFinder removeLock];
  
  for (int i = 0; i < count; i++) {
    avgSpeed[avgI] = spd;
    if (avgI < averages-1) avgI++;
    else avgI = 0;
  }
  
  avgSpd = 0.0;
  
  for (int i = 0; i < averages; i++) {
    avgSpd = avgSpd + avgSpeed[i];
  }
  avgSpd = avgSpd / averages;
  if (avgSpd < minSpeed) avgSpd = minSpeed;
  
  self.avgSpd = avgSpd;
  
 // if (tag == 1) NSLog(@"Avg speed = %i", (int) avgSpd);
}

- (float) scaledSpeed
{
  float result = (speed * blobFinder.blobCount / MAX_BLOBS);
  
  result = result * 2.0;
  
  if (result < 1) result = 1;
  return result;
}

- (void) renderToTexture
{
	if (!initialized) [self initLazy];

  if (makeRandom) {
    [self randomize];
    makeRandom = NO;
  }
  
  if (makeReset) {
    [self reset];
    [rdColor reset];
  //  makeReset = NO;
  }
   
  if (makeSquares) {
    [self addTwoSquares];
    makeSquares = NO;
  }
  
  if (syncData) {
    [self copyDataToTextures];
    syncData = NO;
  }
  else [self copyDataToTextures];
  
// enable the shaders  
  glUseProgramObjectARB(programObject);
  
// set the viewport to the size of the texture  
  glViewport(0, 0, textureW, textureH);
    
  glClearColor(0.0, 0.0, 1.0, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);
  
// set up the projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  
// establish a 1/1 relationship between pixels and OpenGL units
  glOrtho(0, textureW, 0, textureH, -1, 1000);

// model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();  
  
  int spd;
  if (oneShotSpeedUp) {
    spd = 250;
    oneShotSpeedUp = NO;
  }   
  else if (tag == 1) {
    [self updateSpeed];
    spd = (int) avgSpd; //[self scaledSpeed];
  }
  else spd = speed; 
  
  for (int i = 0; i < spd; i++) {
    oddFrame = !oddFrame;
  
    if (oddFrame) {
      glBindTexture(GL_TEXTURE_2D, texture[0]);         // texture[0] is input
      glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo[1]); // draw on texture[1] 
 //     if (tag == 1) [self syncWithBlobFinder];
    }
    else {
      glBindTexture(GL_TEXTURE_2D, texture[1]);         // texture[1] is input
      glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo[0]); // draw on texture[0] 
    } 
    [self textureQuad2D];
  }
  
//  if (tag == 1) {
    if (!makeReset) {
      [self copyDataFromPBO : 0];
      if (tag == 1) [self syncWithBlobFinder];
    }  
//  } 
  
  glBindTexture(GL_TEXTURE_2D, 0);
  
  glUseProgramObjectARB(NULL);    
  
// set the screen as the drawing target again  
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0); 
  
  makeReset = NO;
}

//- (void) fixColors 
//{
//  [self bindInputTexture];
//  [rdColor filterTexture];
//}

- (void) bindInputTexture
{
  if (oddFrame) glBindTexture(GL_TEXTURE_2D, texture[1]);
  else glBindTexture(GL_TEXTURE_2D, texture[0]);
} 

- (void) renderToScreen2D
{
  if (oddFrame) {
    glBindTexture(GL_TEXTURE_2D, texture[1]);
  }
  else glBindTexture(GL_TEXTURE_2D, texture[0]);
  
  [self textureQuad2D];
  glBindTexture(GL_TEXTURE_2D, 0);
    
  oddFrame = !oddFrame;
}

- (void) renderToScreen3D
{
  if (oddFrame) {
    glBindTexture(GL_TEXTURE_2D, texture[1]);
  }
  else glBindTexture(GL_TEXTURE_2D, texture[0]);
  
  [self textureQuad3D];
  glBindTexture(GL_TEXTURE_2D, 0);
    
 // oddFrame = !oddFrame;
}

- (void) createTextures
{
  textureW = TW;
  textureH = TW;

  glGenTextures(2, &texture[0]);
  
  for (int i = 0; i < 2; i++) {
  	glBindTexture(GL_TEXTURE_2D, texture[i]);
 
// set it to repeat in S and T
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  
  	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, textureW, textureH, 0, GL_RGBA, GL_FLOAT, 0);// data

    glBindTexture(GL_TEXTURE_2D, 0);
  }
  texturesInitialized = YES;
}

- (void) freeTextures 
{
  glDeleteTextures(2, &texture[0]);
}

- (void) createFBOs
{
// create the frame buffer objects
  glGenFramebuffersEXT(2, &fbo[0]);
  
  for (int i = 0; i < 2; i++) {
    glBindTexture(GL_TEXTURE_2D, texture[i]);
        
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo[i]);
  
// add the texture as a color attachment to the FBO  
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
                              GL_TEXTURE_2D, texture[i], 0);
                             
// unbind the texture
    glBindTexture(GL_TEXTURE_2D,0);
                             
    GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);  
  
    if (status != GL_FRAMEBUFFER_COMPLETE_EXT) {
      NSAlert* alert = [NSAlert new];
      [alert setMessageText : @"Error creating FBOs"];
      [alert runModal];
    } 
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
  }  
}

- (void) freeFBOs
{
  glDeleteFramebuffersEXT(2, &fbo[0]);
}

- (void) createPBOs
{
// create the pixel buffer objects
  glGenBuffersARB(2, &pbo[0]);
  
  glBindBufferARB(GL_PIXEL_PACK_BUFFER_ARB, pbo[0]);
  glBufferDataARB(GL_PIXEL_PACK_BUFFER_ARB, DATA_SIZE, 0, GL_STREAM_READ_ARB);
  
  glBindBufferARB(GL_PIXEL_PACK_BUFFER_ARB, pbo[1]);
  glBufferDataARB(GL_PIXEL_PACK_BUFFER_ARB, DATA_SIZE, 0, GL_STREAM_READ_ARB);

  glBindBufferARB(GL_PIXEL_PACK_BUFFER_ARB, 0);  
  
  glPixelStorei(GL_UNPACK_ALIGNMENT, 4);      // 4-byte pixel alignment
  
  return;
  
  for (int i = 0; i < 2; i++) {
    glBindTexture(GL_TEXTURE_2D, texture[i]);
        
    glBindBuffer(GL_FRAMEBUFFER_EXT, pbo[i]);
  
// add the texture as a color attachment to the FBO  
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
                              GL_TEXTURE_2D, texture[i], 0);
                             
// unbind the texture
    glBindTexture(GL_TEXTURE_2D,0);
                             
    GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);  
  
    if (status != GL_FRAMEBUFFER_COMPLETE_EXT) {
      NSAlert* alert = [NSAlert new];
      [alert setMessageText : @"wtf?"];
      [alert runModal];
    } 
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
  }
  
}

- (void) freePBOs
{
  glDeleteBuffers(2, &pbo[0]);
}

- (IBAction) addSquares : (id) sender
{
  [glView applyLock];
    makeSquares = YES;
  [glView removeLock];  
}

- (void) addTwoSquares
{
  [self setDataFromRed : 1.0 andGreen : 0.0];
  
  int x,y;  
  int firstX, firstY;
  int lastX,lastY;
  
  int width = textureW;
  int height = textureH;

  firstX = (int) (width / 3);
  firstY = (int) (height / 3);
  
  lastX = firstX + (int) (width / 3) - 1;
  lastY = firstY + (int) (height / 3) - 1;
  
  float *dataPtr;
  for (y = firstY; y <= lastY; y++) {
    dataPtr = data;
    dataPtr += ((y * width) + firstX) * 4;
    for (x = firstX; x <= lastX; x++) {
      *dataPtr++ = 0.5;  // red
      *dataPtr++ = 0.25; // green
      *dataPtr++ = 0.0;  // blue
      *dataPtr++ = 1.0;  // alpha
    }
  }
 
  firstX = (int) (width * 5 / 7);
  firstY = (int) (height * 3 / 5);
  
  lastX = firstX + (int) (width / 7) - 1;
  lastY = firstY + (int) (height / 5) - 1;
  
  for (y = firstY; y <= lastY; y++) {
    dataPtr = data;
    dataPtr += ((y * width) + firstX) * 4;
    for (x = firstX; x <= lastX; x++) {
      *dataPtr++ = 0.5;  // red
      *dataPtr++ = 0.25; // green
      *dataPtr++ = 0.0;  // blue
      *dataPtr++ = 1.0;  // alpha
    }
  }
  
  [self copyDataToTextures];
}

- (void) readDataFromTexture : (int) t
{
  glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_FLOAT, data);
  return; 
}

- (IBAction) readBtnClicked : (id) sender
{
  readData = YES;
}

- (CGImageRef) currentDataImage
{
  int width = TW;
  int height = TH;
  
  int bpp = 32;
  int bytesPerPixel = (int) (bpp / 8);
  int bpr = bytesPerPixel * width;
  
  CGSize size;
  size.width = (float) width;
  size.height = (float) height;
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *imgData = malloc(height * width * 4);
  
  NSUInteger bitsPerComponent = 8;
  CGContextRef context = CGBitmapContextCreate(imgData, width, height, bitsPerComponent, bpr, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGColorSpaceRelease(colorSpace);
  
// get a pointer to the source image's data  
  UInt8 *rowPtr = imgData;
  UInt8 *pixelPtr;
  
  int x,y;//,i;
  
  float *dataPtr = data;
  
// scale the intensity of the pixels  
  for (y = 0; y < height; y++) {
    pixelPtr = rowPtr;
    for (x=0; x < width; x++) {
   //   i = (int) ((RDCOLORS-1) * u[x][y] / 0.4);
      UInt8 r = [Routines clipToByte : *dataPtr++ * 255.0];
      UInt8 g = [Routines clipToByte : *dataPtr++ * 255.0];
      dataPtr++; // b
      dataPtr++; // a
      
      *(pixelPtr+0) = r;
      *(pixelPtr+1) = g;
      *(pixelPtr+2) = 0;             // blue
      *(pixelPtr+3) = 255;          // alpha
     
      pixelPtr += bytesPerPixel;
    }
    rowPtr += bpr;
  } 
  
  CGImageRef returnImage = CGBitmapContextCreateImage(context);
  
  CGContextRelease(context);
  if (imgData) free(imgData);
  
  return returnImage;
} 

- (void) syncWithBlobFinder
{
//  if (blobFinder.blobCount == 0) return;
   float xScale = (float) TW / 640.0f;//camera.imageW;
   float yScale = (float) TH / 480.0f;//camera.imageH;
  
//  [self readDataFromTexture : 0];
  [blobFinder applyLock];
  for (int i = 0; i < blobFinder.blobCount; i++) {
    Blob blob = [blobFinder blobAtIndex : i];
    
    int size = (int) (disturbScale * (float) blob.area / 200.0);
    if (size < 3) size = 3;
    else if (size > 10) size = 10;
    
// convert from the blobs 640x480 to the simulations 256x256    
    int y = (int) (blob.xc * xScale);
    int x = TW - (int) (blob.yc * yScale);
    
//    NSLog(@"Xc: %i Yc: %i", blob.xc, blob.yc);
     
    [self addCircleDisturbanceAtX : x andY : y withSize : size];    
    
//    [self addDisturbanceAtX : x andY : y withSize : size];    
    syncData = YES;
  }
  [blobFinder removeLock];

// copy it back to the texture  
//  [self copyDataToTextures];
//	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, textureW, textureH, 0, GL_RGBA, GL_FLOAT, data);
}

- (void) addDisturbanceAtX : (int) x andY : (int) y withSize : (int) size
{
// disturb in a square of size*size centered on x,y 
  int c,r;
  
// find the limits of the square  
  int minX = x - size;
  if (minX < 0) minX = 0;

  int maxX = x + size;
  if (maxX >= TW) maxX = TW - 1;
  
  int minY = y - size;
  if (minY < 0) minY = 0;
  
  int maxY = y + size;
  if (maxY >= TH) maxY = TH - 1;

// set the data
  float *dataPtr;
  for (r = minY; r <= maxY; r++) {
    dataPtr = data;
    dataPtr += ((r * TW) + minX) * 4;
    for (c = minX; c <= maxX; c++) {
      *dataPtr++ = 0.50; // red
      *dataPtr++ = 0.25; // green
      *dataPtr++ = 0.00; // blue
      *dataPtr++ = 1.00; // alpha
    }  
  }
}  

- (void) addCircleDisturbanceAtX : (int) x andY : (int) y withSize : (int) size
{
// disturb in a square of size*size centered on x,y 
  int c,r;
  
// find the limits of the square  
  int minX = x - size;
  if (minX < 0) minX = 0;

  int maxX = x + size;
  if (maxX >= TW) maxX = TW - 1;
  
  int minY = y - size;
  if (minY < 0) minY = 0;
  
  int maxY = y + size;
  if (maxY >= TH) maxY = TH - 1;

// set the data
  float *dataPtr;
  for (r = minY; r <= maxY; r++) {
    dataPtr = data;
    dataPtr += ((r * TW) + minX) * 4;
    for (c = minX; c <= maxX; c++) {
      float d = sqrt( (r-y) * (r-y) + (c-x) * (c-x) );
      if (d <= size) {
        *dataPtr++ = 0.50; // red
        *dataPtr++ = 0.25; // green
        *dataPtr++ = 0.00; // blue
        *dataPtr++ = 1.00; // alpha
      }
      else dataPtr += 4;  
    }  
  }
}  

- (void) initializeWithF : (float) newF andK : (float) newK andH : (float) newH;
{
  self.f = newF;
  self.h = newH;
  self.k = newK;
}

- (IBAction) selectSpots : (id) sender
{
  [self initializeWithF : 20.0f andK : 79.0f andH : 10.0f];
} 
 
- (IBAction) selectWaves : (id) sender
{
  [self initializeWithF : 20.0f andK : 73.5f andH : 10.0f];
}

- (IBAction) selectPulsating : (id) sender
{
  [self initializeWithF : 19.5f andK : 66.0f andH : 10.0f];
}

- (IBAction) selectLabyrinth : (id) sender
{
  [self initializeWithF : 24.0f andK : 78.0f andH : 10.0f];
}

- (void) copyDataFromPBO : (int) i
{
  glReadBuffer(GL_FRONT);   

  glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, pbo[i]);
  
  glReadPixels(0, 0, TW, TH, GL_RGBA, GL_FLOAT, NULL);

// map the PBO 
  glBindBuffer(GL_PIXEL_PACK_BUFFER_ARB, pbo[i]);
  
  float *src = (float *) glMapBufferARB(GL_PIXEL_PACK_BUFFER_ARB, GL_READ_ONLY_ARB);
  
  if (src) {
    memcpy(data, src, DATA_SIZE);
    
// release pointer to the mapped buffer
    glUnmapBufferARB(GL_PIXEL_PACK_BUFFER_ARB);       
  }  
  glBindBufferARB(GL_PIXEL_PACK_BUFFER_ARB, 0);
}

 
@end  
