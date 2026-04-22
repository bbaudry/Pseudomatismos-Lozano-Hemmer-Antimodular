#include <Carbon/Carbon.h>

typedef unsigned char byte;

typedef enum CamModeEnum {cmNormal, cmSubtracted, cmPosturized, cmInBlobs} CamMode;

typedef enum RenderModeEnum { rmPoints = 0, rmWireFrame, rmSolid, rmTextured} 
             RenderMode;
             
typedef struct PoseStruct {
  float x,y,z;    // position
  float rx,ry,rz; // orientation
} Pose;

typedef struct WindowStruct {
  int x,y;
  int w,h;
} Window;

typedef struct Point2DStruct {
  float x;
  float y;
} Point2D;

typedef Point2D ScreenPt[4];

typedef struct Point3DStruct {
  float x;
  float y;
  float z;
} Point3D;

typedef struct GLColorStruct {
  float r;
  float g;
  float b;
  float a;
} GLColor;

typedef struct VertexStruct {
  Point3D point;
  float  sf,tf;
  float s,t;
  float si,ti;
  float sfm,tfm;
} Vertex;

typedef struct RGBPixelStruct {
	unsigned char r;
	unsigned char g;
	unsigned char b;
} RGBPixel; 

typedef struct RGBAPixelStruct {
  unsigned char r;
  unsigned char g;
  unsigned char b;
  unsigned char a;
} RGBAPixel; 


