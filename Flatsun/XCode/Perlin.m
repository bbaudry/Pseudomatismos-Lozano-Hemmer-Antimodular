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

- (id) init
{ 
  if (self = [super init]) {
//    season = malloc(sizeof(PerlinSeason)*(SEASONS+1));
  }
  return self;
}

- (void) dealloc
{	
  [super dealloc];
	glDeleteTextures(1, &noise_texture);
  free(season);
}

- (void) applyDefaults
{
  for (int s = 0; s < SEASONS; s++) {
    season[s].visible = YES;
    season[s].alpha = 0.90;
    season[s].hue = 0.514;
    season[s].xSpeed = 0;
    season[s].zSpeed = 100;
    season[s].scale2 = 0.5;
    season[s].intensity = 1.0;
    season[s].minSpeed = 10.0;
  }  
}

- (void) loadSettings
{
  for (int s = 0; s <= SEASONS; s++) {
    season[s].alpha = [settings floatFromKey : kPerlinAlpha andSeason : s];
    season[s].hue = [settings floatFromKey : kPerlinHue andSeason : s];
    season[s].intensity = [settings floatFromKey : kPerlinIntensity andSeason : s];
    season[s].xSpeed = [settings floatFromKey : kPerlinXSpeed andSeason : s];
    season[s].zSpeed = [settings floatFromKey : kPerlinZSpeed andSeason : s];
    season[s].scale2 = [settings floatFromKey : kPerlinScale2 andSeason : s];
    season[s].averages = [settings floatFromKey : kPerlinAverages andSeason : s];  
  
    season[s].accScale = [settings floatFromKey : kPerlinAccScale andSeason : s];
 
    season[s].minSpeed = [settings floatFromKey : kPerlinMinSpeed andSeason : s];
    season[s].visible = [settings intFromKey : kPerlinVisible andSeason : s];
  }  
}  

- (void) saveSettings
{
  float v;
  for (int s = 0; s <= SEASONS; s++) {
    v = season[s].alpha;
    [settings setFloat : v forKey : kPerlinAlpha andSeason : s];

    [settings setFloat : season[s].alpha forKey : kPerlinAlpha andSeason : s];
    [settings setFloat : season[s].hue forKey : kPerlinHue andSeason : s];
    [settings setFloat : season[s].intensity forKey : kPerlinIntensity andSeason : s];
    [settings setFloat : season[s].xSpeed forKey : kPerlinXSpeed andSeason : s];
    [settings setFloat : season[s].zSpeed forKey : kPerlinZSpeed andSeason : s];
    [settings setFloat : season[s].scale2 forKey : kPerlinScale2 andSeason : s];
  
    [settings setInt : season[s].averages forKey : kPerlinAverages andSeason : s];
    [settings setInt : season[s].accScale forKey : kPerlinAccScale andSeason : s];
  
    [settings setFloat : season[s].minSpeed forKey : kPerlinMinSpeed andSeason : s];
    [settings setInt : (int) season[s].visible forKey : kPerlinVisible andSeason : s];
  }  
}

- (void) copyVarsFromSeason : (int) s
{
  self.alpha = season[s].alpha;
  self.hue = season[s].hue;
  self.intensity = season[s].intensity;
  self.xSpeed = season[s].xSpeed;
  self.zSpeed = season[s].zSpeed;
  self.scale2 = season[s].scale2;
  
  self.averages = season[s].averages;
  if (self.averages == 0) self.averages = 1;
  
  self.accScale = season[s].accScale;  
  self.minSpeed = season[s].minSpeed;
  self.visible = season[s].visible;
}  

- (void) copyVarsToSeason : (int) s
{
  season[s].alpha = alpha;
  season[s].hue = hue;
  season[s].intensity = intensity;
  season[s].xSpeed = xSpeed;
  season[s].zSpeed = zSpeed;
  season[s].scale2 = scale2;
  season[s].averages = averages;
  season[s].accScale = accScale;  
  season[s].minSpeed = minSpeed;
  season[s].visible = visible;
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
