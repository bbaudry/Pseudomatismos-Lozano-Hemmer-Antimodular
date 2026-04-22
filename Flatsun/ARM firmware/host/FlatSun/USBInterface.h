/*
 *  USBInterface.h
 *  ReactionDiffusion
 *
 *  Created by Gideon May on 08/09/2009.
 *  Copyright 2009 Virtulight. All rights reserved.
 *
 */

#ifndef __USBInterface_h__
#define __USBInterface_h__

#include <pthread.h>

#include "FSPacket.h"

class USBInterface {
public:
    USBInterface(unsigned int id, unsigned int isoCount, unsigned int isoSize);
    ~USBInterface();

    int     isoPackets(FSPacket * plist, int pcount);
    bool    isOpen()   {  return _open; }
    bool    open();
    bool    close();
    int     transmitISO();
    int     transmitBulk(unsigned char * buffer, int bufferSize);
    bool    packetReset();
    
protected:
    int                         _id;
    struct libusb_device_handle *_handle;
    bool                         _open;
    
    unsigned int                _isoCount;
    unsigned int                _isoSize;
    uint8_t *                   _isoBuffer;
    
    pthread_t                   _thread;
    unsigned char *             _buffer;
    unsigned int                _bufferSize;
    unsigned int                _bufferTransmit;
    unsigned int                _isoPackets;
    
    FSPacket *                  _packetList;    /* isochronous transfer */
    int                         _packetCount;
    int                         _packetIndex;
    
    bool                        _update;
    bool                        _usb_error;
////    struct libusb_transfer *    _usb_transfer;
    
    bool                        _useIso;
};


#endif // __USBInterface_h__
