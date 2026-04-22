/*
 *  USBInterface.cpp
 *  ReactionDiffusion
 *
 *  Created by Gideon May on 08/09/2009.
 *  Copyright 2009 Virtulight. All rights reserved.
 *
 */

#include <errno.h>
#include <signal.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <unistd.h>

#include "FSPacket.h"
#include "USBInterface.h"

static const int    VENDOR_ID = 0x0483;
static const int    PRODUCT_ID = 0x7000;
static const int    HALO_PRODUCT_ID = 0x7100;

//static bool  usb_opened = false;

double FSGetTime()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return ((double)tv.tv_sec)+((double)tv.tv_usec) / 1000000.0;    
}

void iso_callback(struct libusb_transfer *xfer)
{
    libusb_free_transfer(xfer);
}

USBInterface::USBInterface(unsigned int id, unsigned int isoCount, unsigned int isoSize)
{
    
    _isoCount = isoCount;
    _isoSize = isoSize;
    if (_isoCount) {
        _isoBuffer = (uint8_t *) malloc(isoCount * isoSize);
        _useIso = true;
    }
    
    // _usb_transfer = NULL;
    
    _handle = NULL;
    _open = false;
    _usb_error = false;
    _bufferTransmit = 0;
    _update = false;
    _id = id;
    _thread = NULL;
    _packetList = NULL;
    _packetIndex = 0;
    _packetCount = 0;
    _isoPackets = 0;
}

bool USBInterface::open()
{
    int reply;
    int product_id;
    
    if (_open == true) return false;
    
    if (_useIso) {
        product_id = PRODUCT_ID + _id;
    } else {
        product_id = HALO_PRODUCT_ID + _id;
    }
    
    _handle = libusb_open_device_with_vid_pid(NULL, VENDOR_ID, product_id);    
    if (_handle == 0) {
        fprintf(stderr, "No USB Device with VID 0x%04x PID 0x%04x\n", VENDOR_ID, product_id);
        return false;
    }
    
    reply = libusb_claim_interface(_handle, 0);
    if (reply < 0) {
        fprintf(stderr, "libusb_claim_interface error %d\n", reply);
        libusb_close(_handle);                
        return false;
    }
    
    reply =  libusb_set_configuration(_handle, 1);
    if (reply < 0) {
        fprintf(stderr, "libusb_set_configuration error %d\n", reply);
        libusb_close(_handle);
        return false;
    }

#if 0
    if (_useIso) {
        _usb_transfer = libusb_alloc_transfer(_isoCount);
        _usb_transfer->type = LIBUSB_TRANSFER_TYPE_ISOCHRONOUS;
        _usb_transfer->num_iso_packets = _isoCount;
        libusb_set_iso_packet_lengths(_usb_transfer, _isoSize);
    }
#endif
    
    fprintf(stderr, "USB Device (0x%04x:0x%04x) successfully opened\n", VENDOR_ID, product_id);
    _open = true;
    return true;
}

bool USBInterface::close()
{
    if (_open) {
        libusb_close(_handle);
    }

    _open = false;
    return true;
}

USBInterface::~USBInterface()
{
    if (_open) {
        close();
    }
}

int USBInterface::isoPackets(FSPacket * plist, int pcount)
{
    _packetList = plist;
    _packetCount = pcount;
    return 0;
}

bool USBInterface::packetReset()
{
    _packetIndex = 0;
    return true;
}


int USBInterface::transmitISO()
{
    int i;
    
    struct libusb_transfer *    _usb_transfer;

        _usb_transfer = libusb_alloc_transfer(_isoCount);
        _usb_transfer->type = LIBUSB_TRANSFER_TYPE_ISOCHRONOUS;
        _usb_transfer->num_iso_packets = _isoCount;
        libusb_set_iso_packet_lengths(_usb_transfer, _isoSize);
    
    libusb_fill_iso_transfer(_usb_transfer, _handle, 1, _isoBuffer, _isoCount * _isoSize, _isoCount, iso_callback, this, 0);
    for (i=0; i<_isoCount; i++) {
        memcpy(&_isoBuffer[i * _isoSize], &_packetList[_packetIndex], _isoSize);
        _packetIndex = (_packetIndex + 1) % _packetCount;
        
        /* Dirty code - assumes that we know what we transfer!!! */
        FSPacket * packet = (FSPacket *) & _isoBuffer[i * _isoSize];
        uint8_t crc = 0;
        uint8_t * src = packet->data;
        for (int p=0; p < FS_PIXELS_PER_TRANSFER; p++, src ++) {
            crc = crc ^ (* src);
        }
        packet->crc = crc;
    }

    return libusb_submit_transfer(_usb_transfer);
}

int USBInterface::transmitBulk(unsigned char * buffer, int bufferSize)
{
    int len;
    int error;
    
    error = libusb_bulk_transfer(_handle, 1, buffer, bufferSize, &len, 0);
    //fprintf(stderr, "transmitBulk : %d\n", len);
    return error;
}


