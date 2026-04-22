/*
 *  DisplayInterface.h
 *  ReactionDiffusion
 *
 *  Created by Gideon May on 08/09/2009.
 *  Copyright 2009 Virtulight. All rights reserved.
 *
 */

#ifndef __DisplayInterface_h__
#define __DisplayInterface_h__

#include "FSPacket.h"
#include <netinet/in.h> /* INET constants and stuff */

class DisplayInterface {
public:
    DisplayInterface();
    ~DisplayInterface();
    void setPixel(int x, int y, unsigned char pixel);
    void setHalo(int pos, unsigned char val);
    void update();
    int open_comm(const char * hostname, int udp_port);
    int send_packet(FSPacket * packet);

protected:
    bool coord_trans(int x, int y, int & panel_col, int & panel_row, int & panel_quad, int & panel_idx);
    
    static const int COLUMN_COUNT   = 8;
    static const int ROW_COUNT      = 8;
    static const int PANEL_COUNT    = ROW_COUNT * COLUMN_COUNT;
    static const int PANEL_SIZE     = 1024;
//    static const int PACKET_COUNT   = PANEL_COUNT + 2;  /* 8x8 panels + 2 halo */
    static const int MAX_X          = 32 * COLUMN_COUNT;
    static const int MAX_Y          = 32 * ROW_COUNT;
    static const int HALO_PANELS    = 2;
    static const int HALO_SIZE      = PANEL_SIZE * HALO_PANELS;
    static const int PIXEL_COUNT    = MAX_X * MAX_Y;
    
    unsigned char *   _panels[PANEL_COUNT];
    bool              _panelsChanged[PANEL_COUNT];
    bool              _useHalo;
    unsigned char     _halo[HALO_SIZE];
    unsigned int      _frame;
    short             _xlatePanelIdx[PIXEL_COUNT];
    short             _xlatePixelIdx[PIXEL_COUNT];
    
    int                _socket;  /* UDP Comm to controller */
    struct sockaddr_in _server;
};


#endif // __DisplayInterface_h__