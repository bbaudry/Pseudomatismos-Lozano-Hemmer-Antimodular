//
//  DMXEnttec.h
//  DMX
//
//  Created by Gideon May on 19-09-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// #define AMSerialDebug
#import "AMSerialPort.h"

typedef enum {
    kEnttecReprogramFirmware = 1,
    kEnttecProgramFlashPage = 2,
    kEnttecGetWidgetParameters = 3,
    kEnttecSetWidgetParameters = 4,
    kEnttecReceivedDMXPacket = 5,
    kEnttecOutputOnlySendDMXPacket = 6,
    kEnttecRDMSendDMXPacket = 7,
    kEnttecReceiveDMXonChange = 8,
    kEnttecReceivedDMX_ChangeOfStatePacket = 9,
    kEnttecGetWidgetSerialNumber = 10,
} EnttecType;

@interface DMXEnttec : NSObject {
@private
    AMSerialPort *  port;
    int             maxChannel;
    unsigned char   channels[513];
    NSString *      deviceTemplate;

    BOOL            enabled;    
}

- (AMSerialPort *)port;
- (void)setPort:(AMSerialPort *)newPort;


- (BOOL) open;
- (BOOL) isOpen;

- (unsigned long) serialNumber;
- (void) setChannel:(unsigned long) chan withValue:(unsigned long) value;
- (void) updateChannels;
- (long) channel;

- (void) setBreakTime:(unsigned long) btime MarkTime:(unsigned long) mtime Rate:(unsigned long) rate;
// - parameters;
// - name;
- (void) reset;

- (NSData *) makePacket:(NSData *) data withType:(EnttecType) type;

- (NSData *) receivePacket;
- (void) sendPacket:(NSData *) data;

- (BOOL) isEnabled;
- (void) enabled:(BOOL) state;

@end
