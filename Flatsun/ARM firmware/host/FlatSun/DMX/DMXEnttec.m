//
//  DMXEnttec.m
//  DMX
//
//  Created by Gideon May on 19-09-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DMXEnttec.h"
#import "AMSerialPort.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"


@implementation DMXEnttec

- (id) init
{
    if (self = [super init]) {
        deviceTemplate = @"usbserial-EN";
    }
    return self;
}

- (AMSerialPort *)port
{
    return port;
}

- (void)setPort:(AMSerialPort *)newPort
{
    id old = nil;
    
    if (newPort == nil) {
        NSLog(@"DMXEnttec setPort: selecting default port");
        // get an port enumerator
        NSEnumerator *enumerator = [AMSerialPortList portEnumeratorForSerialPortsOfType:(NSString*)CFSTR(kIOSerialBSDRS232Type)];
        AMSerialPort *aPort;
        while (aPort = [enumerator nextObject]) {
            // print port name
            NSLog(@"  Found port %@ with path %@", [aPort name], [aPort bsdPath]);
            NSString * name = [aPort name];
            NSRange range;
            range.length = [deviceTemplate length];
            range.location = 0;
            
            if ([name compare:deviceTemplate options: NSLiteralSearch range:range] == NSOrderedSame) {
                NSLog(@"  Selecting port %@", name);
                newPort = aPort;
                
            }
        }
    }
    
    if (newPort == nil) {
        NSLog(@"[DMXEnttec setPort] NO Enttec Device");        
    }
    
    if (newPort != port) {
        old = port;
        port = [newPort retain];
        [old release];
    }
}

- (BOOL) open
{
    if (port) {
        [port open];
    }
    if ([port isOpen]) {
        [port setSpeed:230400];
        [port setDataBits:8];
        [port setParity:kAMSerialParityNone];
        [port setStopBits:kAMSerialStopBitsOne];
    }
    return YES;
}

- (BOOL)isOpen
{
    return [port isOpen];
}


- (BOOL) isEnabled
{
    return enabled;
}

- (void) enabled:(BOOL) state
{
    enabled = state;
    if (enabled) {
        NSLog(@"DMXEnttec enabled: updating status");
        channels[0] = 0;    // Default DMX packet type
        NSData * channelData = [NSData dataWithBytes:channels length:maxChannel + 1];
        NSData * packet = [self makePacket: channelData
                                  withType:kEnttecOutputOnlySendDMXPacket];
        [self sendPacket:packet];        
    }
}

- (unsigned long) serialNumber
{
    unsigned long serial = 0;
    
    if ([self isOpen] == NO) {
        return -1;
    }
    
    NSData * packet = [self makePacket:[NSData data] withType:kEnttecGetWidgetSerialNumber];
    [self sendPacket:packet];
    NSData * data = [self receivePacket];
    NSLog(@"DMXEnttec serialNumber, received %@", data);
    if ([data length] == 4) {
        unsigned char * bytes = (unsigned char *) [data bytes];
        serial =   (unsigned long) bytes[0];
        serial += ((unsigned long) bytes[1]) << 8;
        serial += ((unsigned long) bytes[2]) << 16;
        serial += ((unsigned long) bytes[3]) << 24;
    }
    return serial;
}

- (void) setChannel:(unsigned long) chan withValue:(unsigned long) value
{
    if (chan < 1 || chan > 512 || value > 255) {
        NSLog(@"DMXEnttec setChannel out of bounds %d:%d", chan, value);
        return;
    }
    if (chan > maxChannel) maxChannel = chan;
    channels[chan] = value;
}

- (void) updateChannels
{
    if (enabled) {
        channels[0] = 0;    // Default DMX packet type
        NSData * channelData = [NSData dataWithBytes:channels length:maxChannel + 1];
        NSData * packet = [self makePacket: channelData
                                  withType:kEnttecOutputOnlySendDMXPacket];
        [self sendPacket:packet];
    }    
}


- (long) channel
{
    return 0;
}

- (void) reset
{
    
}

- (void) setBreakTime:(unsigned long) btime MarkTime:(unsigned long) mtime Rate:(unsigned long) rate
{
    
}

- (void) sendPacket:(NSData *) packet
{
    // NSLog(@"DMXEnttec sendPacket:%@", packet);
    [port writeData:packet error:nil];
}

- (NSData *) receivePacket
{
    unsigned char bytes[1024];
    int cnt = 0;
    int type, length;
    
    while (1) {
        int avail = [port bytesAvailable];
        if (avail) {
            NSData * data = [port readBytes:avail error:nil];
            [data getBytes:&bytes[cnt]];
            cnt += avail;
        }
        if (cnt) {
            if (bytes[0] != 0x7E) return nil;
            if (cnt >= 4) {
                type = bytes[1];
                length = bytes[2] + bytes[3] * 0x100;
                if (cnt >= (length + 4) && bytes[cnt - 1] == 0xE7) {
                    return [NSData dataWithBytes:&bytes[4] length:length];
                }
            }
        }
    }
}

- (NSData *) makePacket:(NSData *) data withType:(EnttecType) type
{
    unsigned char bytes[1024];
    int dataLength = [data length];
    
    bytes[0] = 0x7E;
    bytes[1] = type;
    bytes[2] = dataLength & 0xFF;
    bytes[3] = dataLength / 0x100;
    memcpy(&bytes[4], [data bytes], dataLength);
    bytes[dataLength + 4] = 0xE7;
    
    NSData * packet = [NSData dataWithBytes:bytes length:dataLength + 5];
    
    // NSLog(@"DMXEnttec makePacket, packet = %@", packet);
    return packet;
}

@end
