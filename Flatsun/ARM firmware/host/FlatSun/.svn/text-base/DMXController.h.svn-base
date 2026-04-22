//
//  dmxController.h
//  Syncrolite
//
//  Created by Gideon May on 21-09-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DMXEnttec;


@interface DMXController : NSObject {

    DMXEnttec * dmxEnttec;
    BOOL    enabled;
    BOOL    changed[513];
    int     value[513];
}

+ (DMXController*) globalDMXController;

- (void) channel:(int) chan withValue:(int) val;
- (void) update;

- (BOOL) isEnabled;
- (void) enabled:(BOOL) state;

- (NSString *) deviceName;
- (BOOL) isOpen;
@end
