//
//  RDInterface.m
//  RDQuartz
//
//  Created by Gideon May on 01-02-10.
//  Copyright 2010 Virtulight. All rights reserved.
//

#import "FSInterface.h"
#import "DisplayInterface.h"

@implementation FSInterface

- (id) init
{
    if (self = [super init]) {

        _displayInterface = NULL;
    }
    return self;
}

- (void) open
{
    _displayInterface = new DisplayInterface;
 
}

- (void) setPixelVal:(unsigned char) val atX:(int) x atY:(int) y
{
    DisplayInterface * di = (DisplayInterface *) _displayInterface;
    if (di) {
        di->setPixel( x, y, val);
    }
}

- (void) setHaloVal:(unsigned char) val at: (int) pos
{
    DisplayInterface * di = (DisplayInterface *) _displayInterface;
    di->setHalo(pos, val);
}

- (void) update
{
    DisplayInterface * di = (DisplayInterface *) _displayInterface;
    if (di) {
        di->update();
    }
}

- (void) logMessage: (NSString *) msg
{
    NSLog(@"%@\n", msg);    
}

@end
