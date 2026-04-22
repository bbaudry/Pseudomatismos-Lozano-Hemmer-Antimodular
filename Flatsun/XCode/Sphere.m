#import "Sphere.h"

#define kSphereX @"sphereX"
#define kSphereY @"sphereY"
#define kSphereZ @"sphereZ"

#define kSphereRx @"sphereRx"
#define kSphereRy @"sphereRy"
#define kSphereRz @"sphereRz"

#define kSphereCamRz @"sphereCamRz"
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

@synthesize camRz;
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

@synthesize seasonI;

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

- (void) applyDefaultsToSeason : (int) s
{
  season[s].x = 0.0;
  season[s].y = 0.0;
 
  season[s].z = 0.8;
    
  season[s].rx = 0.0;
  season[s].ry = 0.0;
  season[s].rz = 0.0;
  
  season[s].camRz = 0.0;
  season[s].camZ = 0.4;
  season[s].fov = 88.0;
  season[s].slices = 25;
  season[s].stacks = 25;
  
  season[s].endAngle = 35;
  season[s].sliceAngle = 0;
  season[s].sphereR = 1.0;
 /* 
  season[s].type = 0;
  
  season[s].camVisible = NO;
  season[s].camAlpha = 0.5;
  season[s].camTScale = 0.6;  
  season[s].camSOffset = -0.50;
  season[s].camTOffset = -0.55;
  season[s].camMode = cmNormal;
  */
  season[s].sceneRx = 0;
  season[s].sceneRz = 0;
}

- (void) applyDefaults
{
  for (int s=1; s<= SEASONS; s++) {
    [self applyDefaultsToSeason : s];
  }  
}
  
- init
{
  if ((self = [super init])) {
    vertex = nil;
    seasonI = 1;
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
  if (season) free(season);
  [super dealloc];
}

- (void) loadSettings
{
  for (int s=0; s <= SEASONS; s++) {
    season[s].x = [settings floatFromKey : kSphereX andSeason : s];
    season[s].y = [settings floatFromKey : kSphereY andSeason : s];
    season[s].z = [settings floatFromKey : kSphereZ andSeason : s];
    
    season[s].rx = [settings floatFromKey : kSphereRx andSeason : s];
    season[s].ry = [settings floatFromKey : kSphereRy andSeason : s];
    season[s].rz = [settings floatFromKey : kSphereRz andSeason : s];
    
// camera Rz (the actual physical camera)
    season[s].camRz = [settings floatFromKey : kSphereCamRz andSeason : s];
 
// camZ
    season[s].camZ = [settings floatFromKey : kSphereCamZ andSeason : s];
    
// S and T offset  
    season[s].camSOffset = [settings floatFromKey : kSphereCamSOffset andSeason : s];
    season[s].camTOffset = [settings floatFromKey : kSphereCamTOffset andSeason : s];
    
// TScale  
    season[s].camTScale = [settings floatFromKey : kSphereCamTScale andSeason : s];
    
    
// fov    
    season[s].fov = [settings floatFromKey : kSphereFov andSeason : s];

// slices  
    season[s].slices = [settings intFromKey : kSphereSlices andSeason : s];
  
// stacks  
    season[s].stacks = [settings intFromKey : kSphereStacks andSeason : s];

// end angle and slice angle
    season[s].endAngle = [settings floatFromKey : kSphereEndAngle andSeason : s];
    season[s].sliceAngle = [settings floatFromKey : kSphereSliceAngle andSeason : s];
    
// radius    
    season[s].sphereR = [settings floatFromKey : kSphereSphereR andSeason : s];
  
// type    
    season[s].type = [settings intFromKey : kSphereType andSeason : s];

    season[s].camAlpha = [settings floatFromKey : kSphereCamAlpha andSeason : s];
    season[s].camVisible = [settings boolFromKey : kSphereCamVisible andSeason : s];

    season[s].sceneRx = [settings floatFromKey : kSphereSceneRx andSeason :s];  
    season[s].sceneRz = [settings floatFromKey : kSphereSceneRz andSeason :s];  
    
    season[s].camMode = [settings intFromKey : kSphereCamMode andSeason : s];
  }
}  

- (void) copyVarsFromSeason : (int) s
{  
  x = season[s].x;
  y = season[s].y;
  z = season[s].z;
  
  rx = season[s].rx;
  ry = season[s].ry;
  rz = season[s].rz;
  
  self.camRz = season[s].camRz;  
  self.camZ = season[s].camZ;
  
  self.fov = season[s].fov;
  
  self.slices = season[s].slices;
  self.stacks = season[s].stacks;
  
  self.endAngle = season[s].endAngle;
  
  self.sliceAngle = season[s].sliceAngle;
  self.sphereR = season[s].sphereR;
  
  type = season[s].type;
  
  self.camAlpha = season[s].camAlpha;
  self.camVisible = season[s].camVisible;
  
  self.camSOffset = season[s].camSOffset;
  self.camTOffset = season[s].camTOffset;
  
  self.camTScale = season[s].camTScale;
  
  self.sceneRx = season[s].sceneRx;
  self.sceneRz = season[s].sceneRz;
  
  self.camMode = season[s].camMode;
}

- (void) copyVarsToSeason : (int) s
{
  season[s].x = x;
  season[s].y = y;
  season[s].z = z;
  
  season[s].rx = rx;
  season[s].ry = ry;
  season[s].rz = rz;
  
  season[s].camRz = camRz;
  season[s].camZ = swing.endCamZ;
  season[s].fov = swing.endFov;
  
  season[s].slices = slices;
  season[s].stacks = stacks;
  
  season[s].endAngle = endAngle;
  season[s].sliceAngle = sliceAngle;
  season[s].sphereR = sphereR;
  
  season[s].type = type;
  
  season[s].camAlpha = camAlpha;
  season[s].camVisible = camVisible;
  
  season[s].camSOffset = camSOffset;
  season[s].camTOffset = camTOffset;
  
  season[s].camTScale = camTScale;
  
  season[s].sceneRx = swing.endSceneRx;
  season[s].sceneRz = swing.endSceneRz;
  
  season[s].camMode = camMode;
}

- (void) saveSettings 
{
  if (swing.active) [self endSwing];
  
  for (int s=0; s <= SEASONS; s++) {
    [settings setFloat : season[s].x forKey : kSphereX andSeason : s];
    [settings setFloat : season[s].y forKey : kSphereY andSeason : s];
    [settings setFloat : season[s].z forKey : kSphereZ andSeason : s];
  
    [settings setFloat : season[s].rx forKey : kSphereRx andSeason : s];
    [settings setFloat : season[s].ry forKey : kSphereRy andSeason : s];
    [settings setFloat : season[s].rz forKey : kSphereRz andSeason : s];

    [settings setFloat : season[s].camRz forKey : kSphereCamRz andSeason : s];
    [settings setFloat : season[s].camZ forKey : kSphereCamZ andSeason : s];
    [settings setFloat : season[s].fov forKey : kSphereFov andSeason : s];
    [settings setInt : season[s].slices forKey :  kSphereSlices andSeason : s];
    [settings setInt : season[s].stacks forKey :  kSphereStacks andSeason : s];
    [settings setFloat : season[s].endAngle forKey :  kSphereEndAngle andSeason : s];
    [settings setFloat : season[s].sliceAngle forKey :  kSphereSliceAngle andSeason : s];
    [settings setFloat : season[s].sphereR forKey : kSphereSphereR andSeason : s];
    [settings setInt : (int) season[s].type forKey : kSphereType andSeason : s];
    [settings setFloat : season[s].camAlpha forKey : kSphereCamAlpha andSeason : s];  
    [settings setInt : (int) season[s].camVisible forKey : kSphereCamVisible andSeason : s];
    [settings setFloat : season[s].camSOffset forKey : kSphereCamSOffset andSeason : s];  
    [settings setFloat : season[s].camTOffset forKey : kSphereCamTOffset andSeason : s];  
    [settings setFloat : season[s].camTScale forKey : kSphereCamTScale andSeason : s];  
  
    [settings setFloat : season[s].sceneRx forKey : kSphereSceneRx andSeason : s];  
    [settings setFloat : season[s].sceneRz forKey : kSphereSceneRz andSeason : s];  
  
    [settings setInt : (int) season[s].camMode forKey : kSphereCamMode andSeason : s];
  }  
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

- (void) setSeasonI : (int) s
{
  [glView applyLock];
  
// remeber where we are swinging from  
  [self setSwingStartVars];
  
// copy the current vars to the season[] arrays    
  [glView storeSeason];
  
  seasonI = s;
  
// copy the current vars to the season[] arrays  
  [glView assertSeason];
  
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
    
    if (!swing.active) {
      swing.endSceneRx = v;
    }  
    
  [glView removeLock];
}

- (float) sceneRz
{
//  return sceneRz;
  
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
    
  if (!swing.active) {
    swing.endSceneRz = v;
  }  

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
// OpenGL camera
  swing.startSceneRx = sceneRx;
  swing.startSceneRz = sceneRz;
  swing.startCamZ = camZ;
  swing.startFov = fov;
  
// physical camera
  swing.startCameraRz = camera.rz; 
  
// halo 
  swing.startHaloR = ledPanel.haloR;
  swing.startHaloY = ledPanel.haloY;   
  swing.startHaloMin = ledPanel.minHaloI;
  swing.startHaloMax = ledPanel.maxHaloI;
  swing.startHaloGain = ledPanel.haloGain;;
  
// reaction diffusion
  swing.startF1 = reactDiffuse1.f;
  swing.startK1 = reactDiffuse1.k;
  swing.startH1 = reactDiffuse1.h;
  swing.startColorDivisor1 = rdColor1.colorDivider;
  swing.startRDAlpha1 = reactDiffuse1.alpha;
  
  swing.startF2 = reactDiffuse2.f;
  swing.startK2 = reactDiffuse2.k;
  swing.startH2 = reactDiffuse2.h;
  swing.startColorDivisor2 = rdColor2.colorDivider;
  swing.startRDAlpha2 = reactDiffuse2.alpha;
  
// perlin
  swing.startPerlinAlpha = perlin.alpha;
  swing.startPerlinHue = perlin.hue;
  swing.startPerlinIntensity = perlin.intensity;
  swing.startPerlinSize = perlin.scale2;  
}

- (void) setSwingEndVars
{  
// halo
  swing.endHaloR = ledPanel.haloR;
  swing.endHaloY = ledPanel.haloY;
  swing.endHaloMin = ledPanel.minHaloI;
  swing.endHaloMax = ledPanel.maxHaloI;
  swing.endHaloGain = ledPanel.haloGain;
  
// reaction diffusion
  swing.endF1 = reactDiffuse1.f;
  swing.endK1 = reactDiffuse1.k;
  swing.endH1 = reactDiffuse1.h;
  swing.endColorDivisor1 = rdColor1.colorDivider;
  swing.endRDAlpha1 = reactDiffuse1.alpha;
  
  swing.endF2 = reactDiffuse2.f;
  swing.endK2 = reactDiffuse2.k;
  swing.endH2 = reactDiffuse2.h;
  swing.endColorDivisor1 = rdColor2.colorDivider;
  swing.endRDAlpha2 = reactDiffuse2.alpha;
  
// perlin
  swing.endPerlinAlpha = perlin.alpha;
  swing.endPerlinHue = perlin.hue;
  swing.endPerlinIntensity = perlin.intensity;
  swing.endPerlinSize = perlin.scale2;  
}  

- (void) swingToSceneRx : (float) srx sceneRz : (float) srz z : (float) cz andFov : (float) cFov
{
  swing.startTime = [Routines currentMicroseconds];
  
  [self setSwingStartVars];
  
  swing.endSceneRx = srx;
  swing.endSceneRz = srz;
  swing.endCamZ = cz;
  swing.endFov = cFov;
  
  [self setSwingEndVars];
  
  swing.active = YES;
}

- (void) startSwing
{
//  glView.takeSnapShot = YES;
  
  swing.startTime = [Routines currentMicroseconds];
  
  [self setSwingEndVars];

  swing.endSceneRx = sceneRx;
  swing.endSceneRz = sceneRz;
  swing.endCamZ = camZ;
  swing.endFov = fov;
  
  swing.active = YES;
}

- (BOOL) swingActive
{ 
  return swing.active;
}

- (float) swingFraction
{
  return swing.fraction;
}

- (void) updateSwing
{
  if (!swing.active) return;
  
  uint64_t uSec = [Routines currentMicroseconds];
  
  float elapsedSecs = (float) (uSec - swing.startTime) / 1000000.0f;
  
  swing.fraction = elapsedSecs / swingTime;
  
//  glView.alphaFraction = swing.fraction;
  
  if (swing.fraction >= 1.0) {
    [self endSwing];
  }  
  else {
    float angle = M_PI * (swing.fraction - 0.5);
    
//NSLog(@"f = %f a = %f", fraction, angle);  
    
    swing.fraction = (1.0 + sin(angle)) / 2.0;
//NSLog(@"f = %f", fraction);

// OpenGL camera
    self.sceneRx = swing.startSceneRx + (swing.endSceneRx - swing.startSceneRx) * swing.fraction;
    self.sceneRz = swing.startSceneRz + (swing.endSceneRz - swing.startSceneRz) * swing.fraction;
    self.camZ = swing.startCamZ + (swing.endCamZ - swing.startCamZ) * swing.fraction;
    self.fov = swing.startFov + (swing.endFov - swing.startFov) * swing.fraction;
    
// halo
    ledPanel.haloR = swing.startHaloR + (swing.endHaloR - swing.startHaloR) * swing.fraction;
    ledPanel.haloY = swing.startHaloY + (swing.endHaloY - swing.startHaloY) * swing.fraction;
    ledPanel.minHaloI = swing.startHaloMin + (swing.endHaloMin - swing.startHaloMin) * swing.fraction;
    ledPanel.maxHaloI = swing.startHaloMax + (swing.endHaloMax - swing.startHaloMax) * swing.fraction;
    ledPanel.haloGain = swing.endHaloGain;
  
// reaction diffusion
    reactDiffuse1.f = swing.startF1 + (swing.endF1 - swing.startF1);
    reactDiffuse1.k = swing.startK1 + (swing.endK1 - swing.startK1) * swing.fraction;
    reactDiffuse1.h = swing.startH1 + (swing.endH1 - swing.startH1) * swing.fraction;
    rdColor1.colorDivider = swing.startColorDivisor1 + (swing.endColorDivisor1 - swing.startColorDivisor1) * swing.fraction;
    reactDiffuse1.alpha = swing.startRDAlpha1 + (swing.endRDAlpha1 - swing.startRDAlpha1) * swing.fraction;
  
    reactDiffuse2.f = swing.startF2 + (swing.endF2 - swing.startF2) * swing.fraction;
    reactDiffuse2.k = swing.startK2 + (swing.endK2 - swing.startK2) * swing.fraction;
    reactDiffuse2.h = swing.startH2 + (swing.endH2 - swing.startH2) * swing.fraction;
    rdColor2.colorDivider = swing.startColorDivisor2 + (swing.endColorDivisor1 - swing.startColorDivisor1) * swing.fraction;
    reactDiffuse2.alpha = swing.startRDAlpha2 + (swing.endRDAlpha2 - swing.startRDAlpha2) * swing.fraction;
  
// perlin
    perlin.alpha = swing.startPerlinAlpha + (swing.endPerlinAlpha - swing.startPerlinAlpha) * swing.fraction;
    perlin.hue = swing.startPerlinHue + (swing.endPerlinHue - swing.startPerlinHue) * swing.fraction;
    perlin.intensity = swing.startPerlinIntensity + (swing.endPerlinIntensity - swing.startPerlinIntensity) * swing.fraction;
    perlin.scale2 = swing.startPerlinSize + (swing.endPerlinSize - swing.startPerlinSize) * swing.fraction;  
  }
//  NSLog(@"RD1 Alpha: %f",reactDiffuse1.alpha);
}

- (void) endSwing
{
// OpenGL camera 
  self.sceneRx = swing.endSceneRx;
  self.sceneRz = swing.endSceneRz;
  self.camZ = swing.endCamZ;
  self.fov = swing.endFov;
  
// halo
  ledPanel.haloR = swing.endHaloR;
  ledPanel.haloY = swing.endHaloY;
  ledPanel.minHaloI = swing.endHaloMin;
  ledPanel.maxHaloI = swing.endHaloMax;
  ledPanel.haloGain = swing.endHaloGain;
  
// reaction diffusion
  reactDiffuse1.f = swing.endF1;
  reactDiffuse1.k = swing.endK1;
  reactDiffuse1.h = swing.endH1;
  rdColor1.colorDivider = swing.endColorDivisor1;
  reactDiffuse1.alpha = swing.endRDAlpha1;
  
  reactDiffuse2.f = swing.endF2;
  reactDiffuse2.k = swing.endK2;
  reactDiffuse2.h = swing.endH2;
  rdColor2.colorDivider = swing.endColorDivisor1;
  reactDiffuse2.alpha = swing.endRDAlpha2;
  
// perlin
  perlin.alpha = swing.endPerlinAlpha;
  perlin.hue = swing.endPerlinHue;
  perlin.intensity = swing.endPerlinIntensity;
  perlin.scale2 = swing.endPerlinSize;  
  
// finish up  
  swing.active = NO;
}  

- (void) setFov : (float) v
{
 [glView applyLock];
  
  fov = v;
  if (!swing.active) {
    swing.endFov = v;
  }
  
  [glView removeLock];  
}

- (void) setCamZ : (float) v
{
  [glView applyLock];
 
  camZ = v;
  if (!swing.active) {
    swing.endCamZ = v;
  }  
  
  [glView removeLock];    
}

@end