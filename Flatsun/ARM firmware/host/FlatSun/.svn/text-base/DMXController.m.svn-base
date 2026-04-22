//
//  dmxController.m
//  Syncrolite
//
//  Created by Gideon May on 21-09-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DMXController.h"
#import "DMXEnttec.h"


static DMXController * globalDMXController = nil;

@implementation DMXController

+ (DMXController*) globalDMXController
{ 
    @synchronized(self) { 
        if (globalDMXController == nil) { 
            [[self alloc] init]; // assignment not done here 
        } 
    } 
    return globalDMXController;
}

+ (id)allocWithZone:(NSZone *)zone 
{
    @synchronized(self) { 
        if (globalDMXController == nil) { 
            globalDMXController = [super allocWithZone:zone]; 
            return globalDMXController; // assignment and return on first allocation 
        } 
    } 
    return nil; //on subsequent allocation attempts return nil 
} 

- (id)copyWithZone:(NSZone *)zone 
{ 
    return self; 
}

- (id)retain 
{ 
    return self; 
}

- (NSUInteger)retainCount 
{ 
    return UINT_MAX; //denotes an object that cannot be released 
}

- (void)release 
{ 
    //do nothing 
}

- (id)autorelease 
{ 
    return self; 
} 

- (id) init
{
    if (self = [super init]) {
        
    }
    
    enabled = NO;
    for (int i=0; i<513; i++) {
        changed[i] = FALSE;
    }
    
    dmxEnttec = [[DMXEnttec alloc] init];
    [dmxEnttec setPort: nil];
    [dmxEnttec open];
    
    BOOL isOpen = [dmxEnttec isOpen];
    if (! isOpen) {
        NSLog(@"DMXController: unable to open enttec device, missing ???");
    }
    NSLog(@"DMXController: Enttec serial number = %x", [dmxEnttec serialNumber]);
    return self;
}

- (NSString *) deviceName
{
    return [[dmxEnttec port] bsdPath];
}

- (BOOL) isOpen
{
    return [dmxEnttec isOpen];
}

- (void) channel:(int) chan withValue:(int) val
{
    if ([dmxEnttec isOpen]) {
        if (value[chan] != val) {
            changed[chan] = TRUE;
            value[chan] = val;
        }
    } else {
        // NSLog(@"[DMXController channel:value:] DEVICE NOT OPEN");
    }
}

- (void) update
{
    for (int i=0; i<513; i++) {
        if (changed[i]) {
            [dmxEnttec setChannel:i withValue:value[i]];
            changed[i] = FALSE;
        }
    }
    [dmxEnttec updateChannels];
}

- (BOOL) isEnabled
{
    return enabled;
}

- (void) enabled:(BOOL) state
{
    [dmxEnttec enabled:state];
    enabled = state;
}

@end
