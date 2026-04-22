#import "Perlin.h"

#define kPerlinAlpha @"kPerlinAlpha"
#define kPerlinHue @"kPerlinHue"
#define kPerlinIntensity @"kPerlinIntensity"
#define kPerlinXSpeed @"kPerlinXSpeed"
#define kPerlinZSpeed @"kPerlinZSpeed"
#define kPerlinScale2 @"kPerlinScale2"

#define kPerlinAverages @"kPerlinAverages"
#define kPerlinAccScale @"kPerlinAccScale"
#define kPerlinMinSpeed @"kPerlinMinSpeed"

#define kPerlinVisible @"kPerlinVisible"

@implementation Perlin

@synthesize xOffset;
@synthesize yOffset;
@synthesize zOffset;

@synthesize alpha;

@synthesize hue;
@synthesize intensity;

@synthesize visible;

@synthesize scale2;
@synthesize xSpeed;
@synthesize zSpeed;

@synthesize averages;
@synthesize accScale;

@synthesize avgSpd;

@synthesize minSpeed;

+ (void) initialize
{
  [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
     
       [NSNumber numberWithFloat:1.0f], kPerlinAlpha, 
       [NSNumber numberWithFloat:0.0f], kPerlinHue,
       [NSNumber numberWithFloat:0.0f], kPerlinIntensity,
       [NSNumber numberWithFloat:5.0f], kPerlinXSpeed,
       [NSNumber numberWithFloat:5.0f], kPerlinZSpeed,
       [NSNumber numberWithFloat:0.6f], kPerlinScale2,
       [NSNumber numberWithInt:100], kPerlinAverages,
       [NSNumber numberWithInt:2], kPerlinAccScale,
       [NSNumber numberWithFloat:10.0f], kPerlinMinSpeed,
       
    nil]];
}

- (void) applyDefaults
{
  self.visible = YES;
  self.alpha = 0.90;
  self.hue = 0.514;
  self.xSpeed = 0;
  self.zSpeed = 100;
  self.scale2 = 0.5;
  self.intensity = 1.0;
  self.minSpeed = 10.0;
}

- (void) loadSettings : (int) season
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  self.alpha = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kPerlinAlpha, season]];
  self.hue = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kPerlinHue, season]];
  self.intensity = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kPerlinIntensity, season]];
  self.xSpeed = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kPerlinXSpeed, season]];
  self.zSpeed = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kPerlinZSpeed, season]];
  self.scale2 = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kPerlinScale2, season]];
  
  float v = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kPerlinAverages, season]];  
  if (v == 0) self.averages = 1;
  else self.averages = v;
  
  v = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kPerlinAccScale, season]];
  if (v == 0) self.accScale = 1;
  else self.accScale = v;
 
  self.minSpeed = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kPerlinMinSpeed, season]];
  self.visible = [ud integerForKey : [NSString stringWithFormat : @"%@-%i", kPerlinVisible, season]];
}  

- (void) saveSettings : (int) season
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

  [ud setFloat : alpha forKey : [NSString stringWithFormat : @"%@-%i", kPerlinAlpha, season]];
  [ud setFloat : hue forKey : [NSString stringWithFormat : @"%@-%i", kPerlinHue, season]];
  [ud setFloat : intensity forKey : [NSString stringWithFormat : @"%@-%i", kPerlinIntensity, season]];
  [ud setFloat : xSpeed forKey : [NSString stringWithFormat : @"%@-%i", kPerlinXSpeed, season]];
  [ud setFloat : zSpeed forKey : [NSString stringWithFormat : @"%@-%i", kPerlinZSpeed, season]];
  [ud setFloat : scale2 forKey : [NSString stringWithFormat : @"%@-%i", kPerlinScale2, season]];
  
  [ud setInteger : averages forKey : [NSString stringWithFormat : @"%@-%i", kPerlinAverages, season]];
  [ud setInteger : accScale forKey : [NSString stringWithFormat : @"%@-%i", kPerlinAccScale, season]];
  
  [ud setFloat : minSpeed forKey : [NSString stringWithFormat : @"%@-%i", kPerlinMinSpeed, season]];
  [ud setInteger : (int) visible forKey : [NSString stringWithFormat : @"%@-%i", kPerlinVisible, season]];
}

- (id) init
{
//  self.alpha = 1.00;
//  self.xSpeed = 5;
//  self.zSpeed = 5;
//  self.scale2 = 0.6;
  
	[super init];
	
	return self;
}

- (void) awakeFromNib 
{
  self.visible = YES;
  zOffset = 0;
}

- (void) initLazy
{
	[super initLazy];
  
  r = 0.8;
  g = 0.8;
  b = 0.0;
  
	scale.current[0] = 0.6;
	scale.max[0]     = 0.9;
	scale.min[0]     = 0.3;
	scale.delta[0]   = 0.002; 
	
// Setup GLSL 
  NSBundle *bundle;
  NSString *vertex_string, *fragment_string;

  bundle = [NSBundle bundleForClass: [self class]];

// noise texture 
  glGenTextures(1, &noise_texture);
  glBindTexture(GL_TEXTURE_3D, noise_texture);
 	CreateNoise3D();

  vertex_string   = [bundle pathForResource: @"Perlin" ofType: @"vert"];
  vertex_string   = [NSString stringWithContentsOfFile: vertex_string];
  
  fragment_string = [bundle pathForResource: @"Perlin" ofType: @"frag"];
  fragment_string = [NSString stringWithContentsOfFile: fragment_string];

// Load the vertex and fragment shaders 
  [self loadVertexShader: vertex_string andFragmentShader: fragment_string];
			
// Setup uniforms 
	glUseProgramObjectARB(programObject);
	glUniform3fARB(glGetUniformLocationARB(programObject, "LightPos"), 0.0, 0.0, 4.0);
	glUniform1fvARB(glGetUniformLocationARB(programObject, "Scale"), 1, PARAMETER_CURRENT(scale));
	glUniform4fARB(glGetUniformLocationARB(programObject, "BackColor"), 0.8, 0.0, 0.0, 0.0);
	glUniform4fARB(glGetUniformLocationARB(programObject, "FrontColor"), 0.8, 0.8, 0.0, 1.0);
	glUniform1iARB(glGetUniformLocationARB(programObject, "Noise"), 0);
  
//  self.scale = 0.6;
//  self.visible = NO;//YES;//FALSE;
//  self.alpha = 1.0;//0.50;
}

- (void) dealloc
{
	[super dealloc];
	glDeleteTextures(1, &noise_texture);
}

- (void) renderFrame
{
//	[super renderFrame];
	
	glUseProgramObjectARB(programObject);

//	PARAMETER_ANIMATE(scale);
//	glUniform1fvARB(glGetUniformLocationARB(programObject, "Scale"), 1, PARAMETER_CURRENT(scale));

	glBindTexture(GL_TEXTURE_3D, noise_texture);
	
//	gluSphere(quadric, 0.5, 30, 30);
	glUseProgramObjectARB(NULL);
}

- (void) updateSpeed
{
  int count;
  [blobFinder applyLock];
    if (blobFinder.blobCount > 0) count = accScale;
    else count = 1;
  
    float spd = [self scaledZSpeed];
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
}


- (float) scaledZSpeed 
{
  [blobFinder applyLock];
  float result = (zSpeed * (float) blobFinder.blobCount / MAX_BLOBS);//(float) MaxBlobs);
  [blobFinder removeLock];
  
  if (result < minSpeed) result = minSpeed;
  
  return result;
}

- (void) apply
{
  if (!initialized) [self initLazy];
  
	glUseProgramObjectARB(programObject);	
  
  for (int i = 0; i < 4; i++) {
    scale.current[i] = scale2;
  }  
    
	glUniform1fvARB(glGetUniformLocationARB(programObject, "Scale"), 1, PARAMETER_CURRENT(scale));

  xOffset = xOffset + xSpeed / 10000; 
  
  [self updateSpeed];
  
  zOffset = zOffset + avgSpd / 10000;
 
  glUniform3fARB(glGetUniformLocationARB(programObject, "Offset"), xOffset, yOffset, zOffset);
	glUniform4fARB(glGetUniformLocationARB(programObject, "FrontColor"), r, g, b, alpha);

  glEnable(GL_TEXTURE_3D);
	glBindTexture(GL_TEXTURE_3D, noise_texture);
}

- (void) remove
{
	glUseProgramObjectARB(NULL);
  glDisable(GL_TEXTURE_3D);
}

- (void) setHue : (float) value
{
  [glView applyLock];
    hue = value;
    [self syncColorWell];
  [glView removeLock];  
}

- (void) setIntensity : (float) value
{
  [glView applyLock];
    intensity = value;
    [self syncColorWell];  
  [glView removeLock];  
}

- (void) syncColorWell
{
  r = 1.0;
  g = hue + intensity;
  if (g > 1) g = 1.0;
  b = intensity;
  
  NSColor *color = [NSColor colorWithDeviceRed:r green:g blue:b alpha:1.0];
  [colorWell setColor : color];
}

- (void) render
{
  [self apply]; 
  [GLUtils Render3DQuadWithSize : 1.0];
//  [GLUtils Render2DQuadWithWidth : 256 andHeight : 256];
  [self remove];
}

@end
