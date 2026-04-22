#import "Sphere.h"

#define kSphereX @"sphereX"
#define kSphereY @"sphereY"
#define kSphereZ @"sphereZ"

#define kSphereRx @"sphereRx"
#define kSphereRy @"sphereRy"
#define kSphereRz @"sphereRz"

#define kSphereCamZ @"sphereCamZ"
#define kSphereFov @"sphereFov"
#define kSphereSlices @"sphereSlices"
#define kSphereStacks @"sphereStacks"
#define kSphereEndAngle @"sphereEndAngle"
#define kSphereSliceAngle @"sphereSliceAngle"
#define kSphereSphereR @"sphereSphereR"
#define kSphereType @"sphereType"

#define kSphereOffset @"sphereOffset"

#define kSphereCamAlpha @"sphereCamAlpha"
#define kSphereCamVisible @"sphereCamVisible"
#define kSphereCamSOffset @"sphereCamSOffset"
#define kSphereCamTOffset @"sphereCamTOffset"
#define kSphereCamTScale @"sphereCamTScale"
#define kSphereCamMode @"sphereCamMode"

#define kSphereSceneRx @"SphereSceneRx"
#define kSphereSceneRz @"SphereSceneRz"

@implementation Sphere

@synthesize x;
@synthesize y;
@synthesize z;

@synthesize rx;
@synthesize ry;
@synthesize rz;

@synthesize camZ;
@synthesize fov;
@synthesize slices;
@synthesize stacks;
@synthesize endAngle;
@synthesize sliceAngle;

@synthesize sphereR;

@synthesize sOffset;
@synthesize tOffset;

//@synthesize offset;

@synthesize type;

@synthesize wireFrame;

@synthesize tScale;

@synthesize camAlpha;
@synthesize camVisible;
@synthesize camTScale;
@synthesize camSOffset;
@synthesize camTOffset;
@synthesize camMode;

@synthesize season;

@synthesize swingTime;

+ (Window) defaultWindow
{
  Window result;
  result.x = 0;
  result.y = 0;
  result.w = 1024;
  result.h = 768;
  return result;
}

+ (void) initialize
{
  [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:

       [NSNumber numberWithFloat:0.00f], kSphereX,
       [NSNumber numberWithFloat:0.00f], kSphereY,     
       [NSNumber numberWithFloat:3.57f], kSphereZ,

       [NSNumber numberWithFloat:0.00f], kSphereRx,
       [NSNumber numberWithFloat:0.00f], kSphereRy,
       [NSNumber numberWithFloat:0.00f], kSphereRz,

       [NSNumber numberWithFloat:90.0f], kSphereFov,
       [NSNumber numberWithFloat:90.0f], kSphereCamZ,
       [NSNumber numberWithFloat:0.0f], kSphereCamSOffset,       
       [NSNumber numberWithFloat:0.0f], kSphereCamTOffset,       
       
       [NSNumber numberWithInt:10],     kSphereSlices,
       [NSNumber numberWithInt:10],     kSphereStacks,
       
       [NSNumber numberWithFloat:1.5f], kSphereEndAngle,
       [NSNumber numberWithFloat:0.0f], kSphereSliceAngle,
       [NSNumber numberWithFloat:1.0f], kSphereSphereR,
       [NSNumber numberWithInt:0], kSphereType,
       [NSNumber numberWithFloat:1.0f], kSphereOffset,
       
    nil]];
}

- (void) applyDefaults
{
  self.x = 0.0;
  self.y = 0.0;
  self.z = 3.57;

  self.rx = 0.0;
  self.ry = 0.0;
  self.rz = 0.0;

  self.camZ = 0.4;
  self.fov = 90.0;
  self.slices = 25;
  self.stacks = 25;

  self.endAngle = 30;
  self.sliceAngle = 0;
  self.sphereR = 1.0;
  
  self.type = 0;
 // self.offset = 1.0;
  
  self.camVisible = NO;
  self.camAlpha = 0.5;
  self.camTScale = 0.6;  
  self.camSOffset = -0.50;
  self.camTOffset = -0.55;
  self.camMode = cmNormal;
  
  self.sceneRx = 0;
  self.sceneRz = 0;
}
  
- init
{
  if ((self = [super init])) {
    vertex = nil;
    season = -1;
//    renderMode = rmTextured;
  }
  return self;
}

- (void) awakeFromNib
{
  self.wireFrame = NO;
  self.tScale = 3.0;
  swing.active = NO;
}

- (void) dealloc 
{
  if (vertex) free(vertex);
  [super dealloc];
}

- (void) loadSettings : (int) s
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  x = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereX, s]];
  y = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereY, s]];  
  z = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereZ, s]];
  
  rx = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereRx, s]];
  ry = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereRy, s]];  
  rz = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereRz, s]];

  float v = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereCamZ, s]];
  if (v == 0.0) self.camZ = 1.0;
  else self.camZ = v;
  
  self.camSOffset = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereCamSOffset, s]];
  self.camTOffset = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereCamTOffset, s]];
  
  v = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereCamTScale, s]];
  if (v == 0) self.camTScale = 1.0;
  else self.camTScale = v;
    
  v = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereFov, s]];
  if (v == 0.0) self.fov = 90.0;
  else self.fov = v; 
  
  int vi = [ud integerForKey : [NSString stringWithFormat : @"%@-%i", kSphereSlices, s]];
  if (vi == 0) self.slices = 25;
  else self.slices = vi; 
  
  vi = [ud integerForKey : [NSString stringWithFormat : @"%@-%i", kSphereStacks, s]];
  if (vi == 0) self.stacks = 25;
  else self.stacks = vi; 

  v = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereEndAngle, s]];
  if (v == 0.0) self.endAngle = 30.0;
  else self.endAngle = v; 

  self.sliceAngle = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereSliceAngle, s]];
  
  v = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereSphereR, s]];
  if (v == 0.0) self.sphereR = 1.0;
  else self.sphereR = v; 
  
  
  type = (SphereType) [ud integerForKey : [NSString stringWithFormat : @"%@-%i", kSphereType, s]];
  
  self.camAlpha = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereCamAlpha, s]];  
  self.camVisible = (BOOL) [ud integerForKey : [NSString stringWithFormat : @"%@-%i", kSphereCamVisible, s]];

  self.sceneRx = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereSceneRx, s]];  
  self.sceneRz = [ud floatForKey : [NSString stringWithFormat : @"%@-%i", kSphereSceneRz, s]];  
 
  self.camMode = (CamMode) [ud integerForKey : [NSString stringWithFormat : @"%@-%i", kSphereCamMode, s]];
 
  [self createVertices];
}  

- (void) saveSettings : (int) s
{
  if (swing.active) [self endSwing];
  
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

  [ud setFloat : x forKey : [NSString stringWithFormat : @"%@-%i", kSphereX, season]];
  [ud setFloat : y forKey : [NSString stringWithFormat : @"%@-%i", kSphereY, season]];
  [ud setFloat : z forKey : [NSString stringWithFormat : @"%@-%i", kSphereZ, season]];
  
  [ud setFloat : rx forKey : [NSString stringWithFormat : @"%@-%i", kSphereRx, season]];
  [ud setFloat : ry forKey : [NSString stringWithFormat : @"%@-%i", kSphereRy, season]];
  [ud setFloat : rz forKey : [NSString stringWithFormat : @"%@-%i", kSphereRz, season]];
  
  [ud setFloat : camZ forKey : [NSString stringWithFormat : @"%@-%i", kSphereCamZ, season]];
  [ud setFloat : fov forKey : [NSString stringWithFormat : @"%@-%i", kSphereFov, season]];
  [ud setInteger : slices forKey : [NSString stringWithFormat : @"%@-%i", kSphereSlices, season]];
  [ud setInteger : stacks forKey : [NSString stringWithFormat : @"%@-%i", kSphereStacks, season]];
  [ud setFloat : endAngle forKey : [NSString stringWithFormat : @"%@-%i", kSphereEndAngle, season]];
  [ud setFloat : sliceAngle forKey : [NSString stringWithFormat : @"%@-%i", kSphereSliceAngle, season]];
  [ud setFloat : sphereR forKey : [NSString stringWithFormat : @"%@-%i", kSphereSphereR, season]];
  [ud setInteger : (int) type forKey : [NSString stringWithFormat : @"%@-%i", kSphereType, season]];
 // [ud setFloat : offset forKey : [NSString stringWithFormat : @"%@-%i", kSphereOffset, season]];  
  [ud setFloat : camAlpha forKey : [NSString stringWithFormat : @"%@-%i", kSphereCamAlpha, season]];  
  [ud setInteger : (int) camVisible forKey : [NSString stringWithFormat : @"%@-%i", kSphereCamVisible, season]];
  [ud setFloat : camSOffset forKey : [NSString stringWithFormat : @"%@-%i", kSphereCamSOffset, season]];  
  [ud setFloat : camTOffset forKey : [NSString stringWithFormat : @"%@-%i", kSphereCamTOffset, season]];  
  [ud setFloat : camTScale forKey : [NSString stringWithFormat : @"%@-%i", kSphereCamTScale, season]];  
  
  [ud setFloat : sceneRx forKey : [NSString stringWithFormat : @"%@-%i", kSphereSceneRx, season]];  
  [ud setFloat : sceneRz forKey : [NSString stringWithFormat : @"%@-%i", kSphereSceneRz, season]];  
  
  [ud setInteger : (int) camMode forKey : [NSString stringWithFormat : @"%@-%i", kSphereCamMode, season]];
}

- (void) placeCamera
{
  glTranslatef(0.0f, 0.0f, -z);
}

- (void) logVertices
{
  Vertex *vtx = vertex;
  int stack;
  int slice;
  
  for (stack = 0; stack < stacks; stack++) {
    for (slice = 0; slice < slices; slice++) {
      NSLog(@"Stack: %i Slice: %i X: %f",stack,slice,(*vtx).point.x);
      vtx++;
    }
  }
}

- (void) render
{
  [self placeCamera];  
  [self renderTextured];
}

- (void) renderPoints
{
  int stack;
  int slice;
  
  Vertex *vtx = vertex;

  glColor3f(1,1,1);
  glPointSize(3);
  glBegin(GL_POINTS);
  for (stack = 0; stack < (stacks-1); stack++) {
    for (slice = 0; slice < slices; slice++) {
      glVertex3f((*vtx).point.x, (*vtx).point.y, (*vtx).point.z);
      vtx++;
    }
  }    
  glEnd();
}

- (void) setTScale : (float) scale
{ 
  tScale = scale;
  [self createVertices];
}

- (void) setEndAngle : (float) angle
{
  endAngle = angle;
  [self createVertices];
}

- (void) setStacks : (int) newStacks
{
  stacks = newStacks;
  [self createVertices];
}

- (void) setSlices : (int) newSlices
{
  slices = newSlices;
  [self createVertices];
}

- (void) setType : (SphereType) newType
{ 
  type = newType;
  [self createVertices];
}

- (void) renderWireFrame
{
  int stack;
  int slice;
  int i;
  Vertex *vtx;

  glColor3f(1,1,1);
  glLineWidth(1);
  
// do the horizontal loops of the bowl
  vtx = vertex;
  for (stack = 0; stack < stacks; stack++) {
  
    if (stack == stacks - 3) {
      glColor3f(0.0, 1.0, 0.0);
      glLineWidth(3);
    }
    else if (stack == stacks - 2) glColor3f(1.0, 1.0, 0.0);
    else if (stack == stacks - 1) glColor3f(1.0, 0.0, 0.0);
      
    glBegin(GL_LINE_LOOP);
      for (slice = 0; slice < slices; slice++) {
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
        vtx++;
      }  
    glEnd();
  }  
  glLineWidth(1);
  glColor3f(1.0, 1.0, 1.0);

// do the radial beams of the bowl
 for (slice = 0; slice < slices; slice++) {
    glBegin(GL_LINE_STRIP);
      for (stack = 0; stack < stacks; stack++) {
        i = stack * slices + slice;
        vtx = vertex;
        vtx += i; // + (i * sizeof(Vertex));
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
      }
    glEnd();  
  }
}

- (void) renderSolid
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  glColor3f(1,1,1);
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        vtx++;
        vtx2++;
      }
    }
    
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
   
  glEnd();

  glPointSize(10);
  glColor3f(0,0,1);
  glBegin(GL_POINTS);
      glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

  glEnd();  
  glPointSize(1);
}

- (void) renderTextured
{
  [self renderTexturedForDisplayList];
}

- (void) renderTexturedForDisplayList 
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  if (type == ptUnder) {
    glPushMatrix();
    glRotatef(-ROTATE_SCALE*sOffset*360, 0, 0, 1);
    sOffset = 0;
    tOffset = 0;
  }
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {
        glTexCoord2f((*vtx).sf+sOffset,(*vtx).tf+tOffset);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).sf+sOffset,(*vtx2).tf+tOffset);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).sf+sOffset,(*vtx).tf+tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).sf+sOffset,(*vtx).tf+tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
  
  if (type == ptUnder) glPopMatrix();  
}

- (void) renderTexturedWithScale : (float) scale 
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  if (type == ptUnder) {
    glPushMatrix();
    glRotatef(-ROTATE_SCALE*sOffset*360, 0, 0, 1);
    sOffset = 0;
    tOffset = 0;
  }
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {
        glTexCoord2f((*vtx).sf * scale + sOffset, (*vtx).tf * scale + tOffset);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).sf * scale +sOffset, (*vtx2).tf * scale + tOffset);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).sf * scale + sOffset, (*vtx).tf * scale + tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).sf * scale + sOffset, (*vtx).tf * scale + tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
  
  if (type == ptUnder) glPopMatrix();  
}

- (void) renderTexturedWithScale : (float) scale sOffset : (float) sOff andTOffset : (float) tOff
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {
        glTexCoord2f((*vtx).sf * scale + sOff, (*vtx).tf * scale + tOff);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).sf * scale +sOff, (*vtx2).tf * scale + tOff);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).sf * scale + sOff, (*vtx).tf * scale + tOff);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).sf * scale + sOff, (*vtx).tf * scale + tOff);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
}

- (void) renderTexturedSidewaysWithScale : (float) scale 
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  glPushMatrix();
  glRotatef(90, 0, 0, 1);
  sOffset = 0;
  tOffset = 0;
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {
        glTexCoord2f((*vtx).sf * scale + sOffset, (*vtx).tf * scale + tOffset);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).sf * scale +sOffset, (*vtx2).tf * scale + tOffset);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).sf * scale + sOffset, (*vtx).tf * scale + tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).sf * scale + sOffset, (*vtx).tf * scale + tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
  
  glPopMatrix();  
}

- (void) renderTexturedSidewaysWithScale : (float) scale andOffset : (float) offset
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  scale = - scale;
  
  glPushMatrix();
  glRotatef(-90, 0, 0, 1);
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {
        glTexCoord2f((*vtx).sf * scale + offset, (*vtx).tf * scale + offset);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).sf * scale + offset, (*vtx2).tf * scale + offset);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).sf * scale + offset, (*vtx).tf * scale + offset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).sf * scale + offset, (*vtx).tf * scale + offset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
  
  glPopMatrix();  
}

- (void) renderTexturedSidewaysWithScale : (float) scale sOffset : (float) sOff andTOffset : (float) tOff
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  scale = - scale;
  
  glPushMatrix();
  glRotatef(-90, 0, 0, 1);
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {
        glTexCoord2f((*vtx).sf * scale + sOff, (*vtx).tf * scale + tOff);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).sf * scale + sOff, (*vtx2).tf * scale + tOff);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).sf * scale + sOff, (*vtx).tf * scale + tOff);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).sf * scale + sOff, (*vtx).tf * scale + tOff);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
  
  glPopMatrix();  
}

- (void) renderTexturedSidewaysAndFlippedWithScale : (float) scale sOffset : (float) sOff andTOffset : (float) tOff
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  scale = - scale;
  
  glPushMatrix();
  glRotatef(+90, 0, 0, 1);
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {
        glTexCoord2f((*vtx).sf * scale + sOff, (*vtx).tf * scale + tOff);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).sf * scale + sOff, (*vtx2).tf * scale + tOff);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).sf * scale + sOff, (*vtx).tf * scale + tOff);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).sf * scale + sOff, (*vtx).tf * scale + tOff);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
  
  glPopMatrix();  
}

- (void) renderTexturedSidewaysAndMirroredWithScale : (float) scale sOffset : (float) sOff andTOffset : (float) tOff
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  scale = - scale;
  
  glPushMatrix();
  glRotatef(90, 0, 0, 1);
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {

        glTexCoord2f((*vtx).sfm * scale + sOff, (*vtx).tfm * scale + tOff);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).sfm * scale + sOff, (*vtx2).tfm * scale + tOff);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).sfm * scale + sOff, (*vtx).tfm * scale + tOff);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).sfm * scale + sOff, (*vtx).tfm * scale + tOff);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
  
  glPopMatrix();  
}

- (void) renderTexturedSidewaysFlippedAndMirroredWithScale : (float) scale sOffset : (float) sOff andTOffset : (float) tOff
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  scale = - scale;
  
  glPushMatrix();
  glRotatef(-90, 0, 0, 1);
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {

        glTexCoord2f((*vtx).sfm * scale + sOff, (*vtx).tfm * scale + tOff);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).sfm * scale + sOff, (*vtx2).tfm * scale + tOff);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).sfm * scale + sOff, (*vtx).tfm * scale + tOff);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).sfm * scale + sOff, (*vtx).tfm * scale + tOff);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
  
  glPopMatrix();  
}

- (void) renderTexturedForImage
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  if (type == ptUnder) {
    glPushMatrix();
    glRotatef(-ROTATE_SCALE*sOffset*360, 0, 0, 1);
    sOffset = 0;
    tOffset = 0;
  }
//  else sOffset += offset;
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {
        glTexCoord2f((*vtx).si+sOffset,(*vtx).ti+tOffset);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).si+sOffset,(*vtx2).ti+tOffset);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).si+sOffset,(*vtx).ti+tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).si+sOffset,(*vtx).ti+tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
  
  if (type == ptUnder) glPopMatrix();  
}


- (void) renderTexturedWithSRepeats : (float) sRepeats andTRepeats : (float) tRepeats
{
  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;
  
  if (type == ptUnder) {
    glPushMatrix();
    glRotatef(ROTATE_SCALE*sOffset*360, 0, 0, 1);
    sOffset = 0;
    tOffset = 0;
  }
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {
        glTexCoord2f((*vtx).sf*sRepeats+sOffset,(*vtx).tf*tRepeats+tOffset);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).sf*sRepeats+sOffset,(*vtx2).tf*tRepeats+tOffset);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).sf*sRepeats+sOffset,(*vtx).tf*tRepeats+tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).sf*sRepeats+sOffset,(*vtx).tf*tRepeats+tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
  
  if (type == ptUnder) glPopMatrix();  
}


- (void) renderTexturedForMovie {

  int stack;
  int slice;
  Vertex *vtx = vertex;
  Vertex *vtx2;

  if (type == ptUnder) {  
    glPushMatrix();
    glRotatef(ROTATE_SCALE*sOffset*360, 0, 0, 1);
  }
  
  glBegin(GL_QUAD_STRIP);
    for (stack = 0; stack < stacks-1; stack++) {
      vtx2 = vtx;
      vtx2 += slices;
      for (slice = 0; slice < slices; slice++) {
        glTexCoord2f((*vtx).s+sOffset,(*vtx).t+tOffset);
        glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);

        glTexCoord2f((*vtx2).s+sOffset,(*vtx2).t+tOffset);
        glVertex3f((*vtx2).point.x,(*vtx2).point.y,(*vtx2).point.z);
        
        vtx++;
        vtx2++;
      }
    }
    vtx = vertex;
    vtx += (stacks - 2) * slices;
    glTexCoord2f((*vtx).s+sOffset,(*vtx).t+tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
    
    vtx += slices;
    glTexCoord2f((*vtx).s+sOffset,(*vtx).t+tOffset);
    glVertex3f((*vtx).point.x,(*vtx).point.y,(*vtx).point.z);
  glEnd();
  
  if (type == ptUnder) glPopMatrix();  
}

- (void) createVertices
{
  switch (type) {
  
    case ptUnder :
      [self createUnderVertices];
      break;
      
    case ptSide :
//    [self createSideVertices];
      [self createUnderVertices];      
      break;
  }
}

- (void) createUnderVertices
{
  float sliceA;
  float sliceAngleInc;
  float stackAngle;
  float stackAngleInc;
  float zm,r,xm,ym;
  
  int stack;
  int slice;
  
  Vertex *vtx;
  
  sliceAngleInc = (2 * M_PI) / slices;

  stackAngleInc = [Routines degToRad : endAngle] / stacks;
  
  if (vertex) free(vertex);
  int size = slices * stacks * sizeof(Vertex);
  vertex = malloc(size);
  vtx = vertex;

  stackAngle = 0;
  
  for (stack = 0; stack < stacks; stack++) {
    zm = -sphereR * (1 - cos(stackAngle));
    r = sphereR * sin(stackAngle);

    sliceA = 0;
    
    for (slice = 0; slice < slices; slice++) {

// set the X,Y,Z location
      xm = r * cos(sliceA);
      ym = r * sin(sliceA);
      
      (*vtx).point.x = xm;
      (*vtx).point.y = ym;
      (*vtx).point.z = zm;

// set the texture S,T
      (*vtx).sf = 0.5 * (1 + xm/sphereR) * tScale;
      (*vtx).tf = 0.5 * (1 + ym/sphereR) * tScale;

// mirrored      
      (*vtx).sfm = 0.5 * (1 - xm/sphereR) * tScale;
      (*vtx).tfm = 0.5 * (1 + ym/sphereR) * tScale;
      
//      (*vtx).si = (*vtx).sf * (1050.0 / 4200.0);// * (4200.0 / 1050.0);
//      (*vtx).ti = (*vtx).tf;// * (4200.0 / 1050.0);//(1050.0 / 4200.0);

//      (*vtx).s = 720.0f * (*vtx).sf;
//      (*vtx).t = 576.0f * (*vtx).tf;
     
      sliceA = sliceA + sliceAngleInc;
      vtx++;
    }  
    stackAngle = stackAngle + stackAngleInc;
  }  
}

- (void) setSliceAngle : (float) angle
{
  sliceAngle = angle;
  [self createVertices];
}

- (void) createSideVertices
{
  float sliceA;
  float sliceAngleInc;
  float stackAngle;
  float stackAngleInc;
  float zm,r,xm,ym;
  
  int stack;
  int slice;
  
  if (vertex) free(vertex);
  int size = slices * stacks * sizeof(Vertex);
  vertex = malloc(size);
  Vertex *vtx = vertex;
  
  sliceAngleInc = [Routines degToRad : sliceAngle] / (slices-1);
  stackAngleInc = (M_PI/2.0 - [Routines degToRad : endAngle])/ (stacks-1);

  stackAngle = M_PI / 2.0;
  for (stack = 0; stack < stacks; stack++) {
    zm = sphereR * sin(stackAngle) - sphereR;
    r = sphereR * cos(stackAngle);
    
    sliceA = - [Routines degToRad : sliceAngle]/2.0;
    for (slice = 0; slice < slices; slice++) {
      xm = r * sin(sliceA);
      ym = r * cos(sliceA);// - sphereR;
      
      (*vtx).point.x = xm;
      (*vtx).point.y = ym;
      (*vtx).point.z = zm;
      
// set the texture S,T
      (*vtx).sf = 0.5 * (1 + xm/sphereR);
      (*vtx).tf = 0.5 * (1 + ym/sphereR);
      
      (*vtx).s = 720.0f * (*vtx).sf;
      (*vtx).t = 576.0f * (*vtx).tf;
     
      sliceA = sliceA + sliceAngleInc;
      vtx++;
    }  
    stackAngle = stackAngle - stackAngleInc;
  }  
}


- (void) createDisplayList
{
  dlIndex = glGenLists(1);
  if (dlIndex > 0) {
    glNewList(dlIndex, GL_COMPILE);
      [self renderTexturedForDisplayList];
    glEndList();
  }
}

- (void) freeDisplayList 
{
  if (dlIndex > 0) {
    glDeleteLists(dlIndex, 1);
  }  
}

- (void) setSphereR : (float) r
{
  sphereR = r;
  [self createVertices];
}

- (void) setSeason : (int) s
{
  [glView applyLock];
  
  [self setSwingStartVars];
  
  if (s != season) {
    if (season != -1) [glView saveAll];
    season = s;
  }
  [glView loadAll];
  
  [self startSwing];
  
  [glView removeLock];
}

- (float) sceneRx
{
  return sceneRx;
  
  float result;
  
  [glView applyLock];
    result = sceneRx;
  [glView removeLock];
  
  return result;
}  

- (void) setSceneRx : (float) v
{
  [glView applyLock];
    sceneRx = v;
  [glView removeLock];
}

- (float) sceneRz
{
  return sceneRz;
  
  float result;
  
  [glView applyLock];
    result = sceneRz;
  [glView removeLock];
  
  return result;
}  

- (void) setSceneRz : (float) v
{
  [glView applyLock];
    sceneRz = v;
  [glView removeLock];
}  

- (void) homeBtnClicked : (id) sender
{
  [glView applyLock];
    self.sceneRx = 0;
    self.sceneRz = 0;
  [glView removeLock];
}

- (void) setSwingStartVars
{
  swing.startSceneRx = sceneRx;
  swing.startSceneRz = sceneRz;
  swing.startCamZ = camZ;
  swing.startFov = fov;
}

- (void) swingToSceneRx : (float) srx sceneRz : (float) srz z : (float) cz andFov : (float) cFov
{
  swing.startTime = [Routines currentMicroseconds];
  swing.startSceneRx = sceneRx;
  swing.startSceneRz = sceneRz;
  swing.startCamZ = camZ;
  swing.startFov = fov;
  
  swing.endSceneRx = srx;
  swing.endSceneRz = srz;
  swing.endCamZ = cz;
  swing.endFov = cFov;
  
  swing.active = YES;
}

- (void) startSwing
{
  swing.startTime = [Routines currentMicroseconds];

  swing.endSceneRx = sceneRx;
  swing.endSceneRz = sceneRz;
  swing.endCamZ = camZ;
  swing.endFov = fov;
  
  swing.active = YES;
}

- (void) updateSwing
{
  if (!swing.active) return;
  
  uint64_t uSec = [Routines currentMicroseconds];
  
  float elapsedSecs = (float) (uSec - swing.startTime) / 1000000.0f;
  
  float fraction = elapsedSecs / swingTime;
  
  if (fraction >= 1.0) {
    [self endSwing];
  }  
  else {
    float angle = M_PI * (fraction - 0.5);
    
//NSLog(@"f = %f a = %f", fraction, angle);  
    
    fraction = (1.0 + sin(angle)) / 2.0;
//NSLog(@"f = %f", fraction);
    
    self.sceneRx = swing.startSceneRx + (swing.endSceneRx - swing.startSceneRx) * fraction;
    self.sceneRz = swing.startSceneRz + (swing.endSceneRz - swing.startSceneRz) * fraction;
    self.camZ = swing.startCamZ + (swing.endCamZ - swing.startCamZ) * fraction;
    self.fov = swing.startFov + (swing.endFov - swing.startFov) * fraction;
  }  
}

- (void) endSwing
{
  self.sceneRx = swing.endSceneRx;
  self.sceneRz = swing.endSceneRz;
  self.camZ = swing.endCamZ;
  self.fov = swing.endFov;
  swing.active = NO;
}  

@end