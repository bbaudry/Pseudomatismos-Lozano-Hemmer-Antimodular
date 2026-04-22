//
//  FSInterface.h
//

#import <Cocoa/Cocoa.h>

@interface FSInterface : NSObject {
    void *              _displayInterface;
}

- (void) open;
- (void) setPixelVal:(unsigned char) val atX:(int) x atY:(int) y;
- (void) setHaloVal:(unsigned char) val at: (int) pos;
- (void) update;
- (void) logMessage: (NSString *) msg;

@end
