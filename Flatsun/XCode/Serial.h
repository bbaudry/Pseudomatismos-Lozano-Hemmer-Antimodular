#import <Cocoa/Cocoa.h>
#include "Routines.h"

@interface Serial : NSObject {
  int fd;
  BOOL switchOn;
  UInt8 rxValue;
}

- (BOOL) ableToOpenPort;
- (void) closePort;

- (BOOL) found;

- (BOOL) pollRx;

- (BOOL) switchOn;

- (void) sendSingleByteCmd : (unsigned char) cmd;

- (BOOL) opened;

- (void) flushBuffer;

- (void) requestData;

@property (nonatomic) UInt8 rxValue;

@end
