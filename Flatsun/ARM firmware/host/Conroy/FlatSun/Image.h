#import <Cocoa/Cocoa.h>
#import "Types.h"
#import "Texture.h"

@interface Image : NSObject {
  NSString *fileName;
  
  Texture *texture;
}

- (void) loadTexture;

- (void) render;

- (void) apply;

- (void) textureQuad;

@property (retain) Texture *texture;

@end
