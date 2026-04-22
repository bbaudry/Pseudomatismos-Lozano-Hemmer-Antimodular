/*
 *  USBHandler.cpp
 *  FlatSun
 *
 *  Created by Gideon May on 10/06/11.
 *  Copyright 2011 Virtulight. All rights reserved.
 *
 */

#include "USBHandler.h"
#include "USBInterface.h"
#include <libusb/libusb.h>

extern double FSGetTime();

USBHandler::USBHandler()
{
    _interfaceAdded = false;
    pthread_mutex_init(&_handlerMutex, NULL);
    _thread = NULL;
    startThread();
}

USBHandler::~USBHandler()
{
    pthread_mutex_destroy(&_handlerMutex);    
}

void USBHandler::addInterface(USBInterface * interface)
{
    fprintf(stderr, "Adding interface\n");
    pthread_mutex_lock(&_handlerMutex); 
    _interfaces.push_back(interface);
    _interfaceAdded = true;
    pthread_mutex_unlock(&_handlerMutex);
    fprintf(stderr, "DONE\n");
}

void USBHandler::removeInterface()
{
}

bool USBHandler::startThread()
{
    if (_thread == NULL) {
        pthread_create(&_thread, NULL, threadFunc, this);
        return true;
    } else {
        fprintf(stderr, "Unable to start USBHandler thread\n");
    }
    return false;
}

void *   USBHandler::threadFunc(void * udata)
{
    libusb_context * context;
    libusb_init(&context);
    libusb_set_debug(context, 2);
//    int check_ports = 1000;
    
    USBHandler * self = (USBHandler *) udata;
    
//    int check_for_interfaces = 0;
//    fprintf(stderr, "ia = %d " , self->_interfaceAdded);
    
    fprintf(stderr, "USBHandler started\n");

    double tm = FSGetTime();
    while (1) {
#if 0
        if (check_ports == 0) {
            check_ports = 1000;
            self->_interfaceAdded = true;
        } else {
            check_ports --;
        }
#endif
        
        if (self->_interfaceAdded) {
            bool failed_open = false;
            fprintf(stderr, "Opening usb ports\n");
            pthread_mutex_lock(&self->_handlerMutex); 
            sleep(1);
            for(std::list<USBInterface *>::iterator list_iter = self->_interfaces.begin(); 
                list_iter != self->_interfaces.end(); list_iter++) {
                USBInterface * iface = *list_iter;
                if (iface->isOpen() == false) {
                    iface->open();
                    failed_open = true;
                    fprintf(stderr, "OPENING Interface\n");
                }
            }
            self->_interfaceAdded = failed_open;
            pthread_mutex_unlock(&self->_handlerMutex);
        }
        
        struct timeval tv;
        tv.tv_sec = 0;
        tv.tv_usec = 1000;
        libusb_handle_events_timeout(NULL, &tv);
        
        if ((FSGetTime() - tm) < (ISO_PACKETS) / 1000.0) continue;
//        fprintf(stderr, " %lf ", (FSGetTime() - tm));
        tm = FSGetTime();
//        fprintf(stderr, " %lf ", tm);
        
        pthread_mutex_lock(&self->_handlerMutex); 
        for(std::list<USBInterface *>::iterator list_iter = self->_interfaces.begin(); 
            list_iter != self->_interfaces.end(); list_iter++) {
            USBInterface * iface = *list_iter;
            if (iface->isOpen()) {
                
                int err = iface->transmitISO();
                if (err == LIBUSB_ERROR_NO_DEVICE) {
                    fprintf(stderr, "ERROR sending: %d, reopening device\n", err);
                    iface->close();
                    self->_interfaceAdded = true;
                }
//                fprintf(stderr, ".");
            }
        }
        pthread_mutex_unlock(&self->_handlerMutex);
        usleep(1000);
    }
    
    return NULL;
}