/*
 *  USBHandler.h
 *  FlatSun
 *
 *  Created by Gideon May on 10/06/11.
 *  Copyright 2011 Virtulight. All rights reserved.
 *
 */


#ifndef __USBHandler_h__
#define __USBHandler_h__


#include <pthread.h>
#include <list>

class USBInterface;

const int ISO_PACKETS = 16;     // Number of ISO packets per transfer

class USBHandler {
public:
    USBHandler();
    ~USBHandler();
    
    void    addInterface(USBInterface * interface);
    void    removeInterface();

protected:
    bool                        startThread();
    static void *               threadFunc(void *);
    
    std::list<USBInterface *> _interfaces;
    pthread_mutex_t           _handlerMutex;
    pthread_t                 _thread;
    bool                      _interfaceAdded;
};


#endif // __USBInterface_h__
