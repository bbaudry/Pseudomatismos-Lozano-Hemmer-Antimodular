#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>
#import <OpenGL/OpenGL.h>
#import <GLUT/glut.h>
#import "Noise3DTexture.h"
#include "mat4.h"

typedef struct _Parameter {
	float current [4];
	float min     [4];
	float max     [4];
	float delta   [4];
	
} Parameter;

// Macros 
#define PARAMETER_CURRENT(p)    (p.current)
#define PARAMETER_ANIMATE(p)    ({ int i; for (i = 0; i < 4; i ++) { \
											p.current[i] += p.delta[i]; \
											if ((p.current[i] < p.min[i]) || (p.current[i] > p.max[i])) \
												p.delta[i] = -p.delta[i]; } } )


@interface Shader : NSObject {
  BOOL initialized;
  GLhandleARB programObject;

  BOOL gpuProcessing;
}

- (id) init;
- (void) initLazy;
- (void) dealloc;
- (NSString *) name;
- (NSString *) descriptionFilename;
- (void) loadVertexShader: (NSString *) vertexString andFragmentShader: (NSString *) fragmentString;

@end
