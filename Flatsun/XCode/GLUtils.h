#import <Cocoa/Cocoa.h>


@interface GLUtils : NSObject {

}

+ (void) Render2DQuadWithWidth : (int) w andHeight : (int) h;
+ (void) Render3DQuadWithSize : (float) size;

+ (void) Texture2DQuadWithWidth : (int) w andHeight : (int) h;
+ (void) Texture3DQuadWithSize : (float) size;

+ (void) Texture3DQuadWithSize : (float) size andSOffset : (float) sOffset;
+ (void) Texture3DQuadWithSize : (float) size sOffset : (float) sOffset andTOffset : (float) tOffset;

@end
