#ifndef GLVIEW_H
#define GLVIEW_H

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "ReactDiffuse.h"
#import "RDColor.h"
#import "ImageUtils.h"
#import "Perlin.h"
#import "LedPanel.h"
#import "LedPanelView.h"
#import "StopWatch.h"
#import "Sphere.h"
#import "HaloView.h"
#import "Camera.h"
#import "Texture.h"

@class RDColor;
@class Perlin;
@class Sphere;
@class Camera;
@class Texture;
@class ReactDiffuse;

@interface GLView : NSOpenGLView 
{
  float sOffset;
  
  IBOutlet ReactDiffuse *reactDiffuse1;
  IBOutlet ReactDiffuse *reactDiffuse2;
  
  IBOutlet RDColor *rdColor1;
  IBOutlet RDColor *rdColor2;
  
  IBOutlet Perlin *perlin;
  
  IBOutlet LedPanel *ledPanel;
  IBOutlet LedPanelView *ledPanelView;
  
  IBOutlet StopWatch *stopWatch;
  
  IBOutlet Sphere *sphere;
  
  IBOutlet HaloView *haloView;
  
  IBOutlet Camera *camera;
  
  IBOutlet Texture *texture;
  
  float sceneRx;
  float sceneRz;
  
  float fov;
  float camZ;
  
  NSPoint startPt;
  
  NSBitmapImageRep *bmp;
  
  NSThread *thread;
  
  NSRecursiveLock *lock;
  
  int x;
  
  BOOL twoD;
  
}

- (void) drawRect : (NSRect) bounds;
- (void) prepareToRender2D;
- (void) prepareToRender3D;

- (void) setupPixelFormat;

- (void) render;

- (void) drawOnBmp;
- (void) drawBmp : (NSRect) rect;

- (NSBitmapImageRep *) bmp;

- (void) startThread;
- (void) stopThread;

- (void) shutDown;

- (void) loadSettings;
- (void) saveSettings;

- (void) initShaders;

- (void) loadAll;
- (void) saveAll;

- (void) applyLock;
- (void) removeLock;

- (IBAction) twoDBtnClicked : (id) sender;

- (IBAction) defaultsBtnClicked : (id) sender;

- (IBAction) homeBtnClicked : (id) sender;

- (void) renderReactDiffuse1Texture;
- (void) renderReactDiffuse2Texture;
- (void) renderReactDiffuse1;
- (void) renderReactDiffuse2;
- (void) renderImage;
- (void) renderPerlin;

@property float sOffset;

@property float fov;
@property float sceneRx;
@property float sceneRz;
@property float camZ;

@property BOOL twoD;

//@property int season;

@end

#endif