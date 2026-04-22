#import "GLUtils.h"

@implementation GLUtils

+ (void) Render2DQuadWithWidth : (int) w andHeight : (int) h
{
  glBegin(GL_QUADS);
  
// bottom left  
    glVertex2f(0, 0);
    
// top left    
    glVertex2f(w, 0);
    
// top right    
    glVertex2f(w, h);
    
// bottom right    
    glVertex2f(0, h);
  glEnd();
}

+ (void) Render3DQuadWithSize : (float) size
{
 	glBegin(GL_QUADS);
  
// bottom left  
    glVertex2f(-size, -size);
    
// top left    
    glVertex2f(size, -size);
    
// top right    
    glVertex2f(size, size);
    
// bottom right    
    glVertex2f(-size, size);
  glEnd();
}

+ (void) Texture2DQuadWithWidth : (int) w andHeight : (int) h
{
  glBegin(GL_QUADS);
  
// bottom left  
    glTexCoord2f(0, 0);
    glVertex2f(0, 0);
    
// top left    
    glTexCoord2f(1, 0); 
    glVertex2f(w, 0);
    
// top right    
    glTexCoord2f(1, 1);
    glVertex2f(w, h);
    
// bottom right    
    glTexCoord2f(0, 1);
    glVertex2f(0, h);
  glEnd();
}

+ (void) Texture3DQuadWithSize : (float) size
{
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

+ (void) Texture3DQuadWithSize : (float) size andSOffset : (float) sOffset
{
 	glBegin(GL_QUADS);
  
// bottom left  
    glTexCoord2f(sOffset, 0);
    glVertex2f(-size, -size);
    
// top left    
    glTexCoord2f(sOffset+1, 0); 
    glVertex2f(size, -size);
    
// top right    
    glTexCoord2f(sOffset+1, 1);
    glVertex2f(size, size);
    
// bottom right    
    glTexCoord2f(sOffset, 1);
    glVertex2f(-size, size);
  glEnd();
}

+ (void) Texture3DQuadWithSize : (float) size sOffset : (float) sOffset andTOffset : (float) tOffset
{
 	glBegin(GL_QUADS);
  
// bottom left  
    glTexCoord2f(sOffset, tOffset);
    glVertex2f(-size, -size);
    
// top left    
    glTexCoord2f(sOffset+1, tOffset); 
    glVertex2f(size, -size);
    
// top right    
    glTexCoord2f(sOffset+1, tOffset+1);
    glVertex2f(size, size);
    
// bottom right    
    glTexCoord2f(sOffset, tOffset+1);
    glVertex2f(-size, size);
  glEnd();
}

@end
