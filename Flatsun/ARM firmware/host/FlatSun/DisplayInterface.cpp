/*
 *  DisplayInterface.cpp
 *  ReactionDiffusion
 *
 *  Created by Gideon May on 08/09/2009.
 *  Copyright 2009 Virtulight. All rights reserved.
 *
 */

#include <stdio.h>      /* standard C i/o facilities */
#include <stdlib.h>     /* needed for atoi() */
#include <unistd.h>  	/* defines STDIN_FILENO, system calls,etc */
#include <sys/types.h>  /* system data type definitions */
#include <sys/socket.h> /* socket specific definitions */
#include <netinet/in.h> /* INET constants and stuff */
#include <arpa/inet.h>  /* IP address conversion stuff */
#include <netdb.h>	/* gethostbyname */

#include "DisplayInterface.h"
#include "USBInterface.h" 
#include "USBHandler.h"
#include "FSPacket.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

extern double FSGetTime();

DisplayInterface::DisplayInterface()
{
    int i, j;

    fprintf(stderr, "FS Interface 4.0\n");

    for (i=0; i<PANEL_COUNT; i++) {
        _panels[i] = (unsigned char *) malloc(PANEL_SIZE);
        for (j=0; j<PANEL_SIZE; j++) {
            _panels[i][j] = 0;
        }
    }
    for (i=0; i<HALO_SIZE; i++) {
        _halo[i] = 0;
    }
    
    // Initialize the 2 lookup tables to translate from OpenGL coordinates to 
    // Panel indices.
    for (int y=0; y<MAX_Y; y++) {
        for (int x=0; x<MAX_X; x++) {
            int pix = y * MAX_X + x;
            int panel_col, panel_row, panel_quad, panel_idx, pixel_idx;
            
            if (coord_trans(x, y, panel_col, panel_row, panel_quad, pixel_idx)) {
                panel_idx = panel_row * COLUMN_COUNT + panel_col;
            } else {
                panel_idx = -1;
                pixel_idx = -1;
            }
            
            _xlatePanelIdx[pix] = panel_idx;
            _xlatePixelIdx[pix] = pixel_idx;
            
//            fprintf(stderr, "[%3d,%3d] : %3d-%4d\n", x, y, panel_idx, pixel_idx);
        }
    }
    _frame = 0;
    _socket = -1;
    open_comm("flatsun", 12399);
//    open_comm("localhost", 12399);
}

DisplayInterface::~DisplayInterface()
{
    int i;

    for (i=0; i<PANEL_COUNT; i++) {
        free(_panels[i]);
    }
}

bool DisplayInterface::coord_trans(int x, int y, int & panel_col, int & panel_row, int & panel_quad, int & panel_idx)
{
    panel_col = panel_row = panel_quad = panel_idx = 0;

    if (x < 0 || x >= MAX_X) return false;
    if (y < 0 || y >= MAX_Y) return false;
    bool swap_xy = false;
    bool blackout = false;
    
    // Invert the Y coordinate
    y = MAX_Y - y - 1;

    // Get the default row,column,bank for the large panels
    int bank = 0;
    int row = y / 32;
    int col = x / 32;
    int x_col = x % 32;
    int y_row = y % 32;

    if (y_row < 16) {
        if (x_col < 16) {
            bank = 3;
        } else {
            bank = 2;
        }
    } else {
        if (x_col < 16) {
            bank = 1;
        } else {
            bank = 0;
        }
    }
    
    // Black out of the edges outside the circle
    if (x >=   0 && x <  16 &&  y >=   0 && y <  80) blackout = true;
    if (x >=   0 && x <  16 &&  y >= 176 && y < 256) blackout = true;
    if (x >=  16 && x <  32 &&  y >=   0 && y <  48) blackout = true;
    if (x >=  16 && x <  32 &&  y >= 208 && y < 256) blackout = true;
    if (x >=  32 && x <  48 &&  y >=   0 && y <  32) blackout = true;
    if (x >=  32 && x <  48 &&  y >= 224 && y < 256) blackout = true;
    if (x >=  48 && x <  80 &&  y >=   0 && y <  16) blackout = true;
    if (x >=  48 && x <  80 &&  y >= 240 && y < 256) blackout = true;
    
    if (x >= 176 && x < 208 &&  y >=   0 && y <  16) blackout = true;
    if (x >= 176 && x < 208 &&  y >= 240 && y < 256) blackout = true;
    if (x >= 208 && x < 224 &&  y >=   0 && y <  32) blackout = true;
    if (x >= 208 && x < 224 &&  y >= 224 && y < 256) blackout = true;
    if (x >= 224 && x < 240 &&  y >=   0 && y <  48) blackout = true;
    if (x >= 224 && x < 240 &&  y >= 208 && y < 256) blackout = true;
    if (x >= 240 && x < 256 &&  y >=   0 && y <  80) blackout = true;
    if (x >= 240 && x < 256 &&  y >= 176 && y < 256) blackout = true;
    
    
//    blackout = true;
        
    // Special corner cases for the 16x16 panels
    if (x >=   0 && x <  32 && y >=  64 && y <  96) {           col = 0; row = 2;}
    if (x >=  16 && x <  32 && y >=  48 && y <  64) { bank = 3; col = 0; row = 2;}

    if (x >=  64 && x <  96 && y >=   0 && y <  32) {           col = 0; row = 1;}
    if (x >=  48 && x <  64 && y >=  16 && y <  32) { bank = 3; col = 0; row = 1;}

    if (x >= 160 && x < 192 && y >=   0 && y <  32) {           col = 7; row = 1;}
    if (x >= 192 && x < 208 && y >=  16 && y <  32) { bank = 2; col = 7; row = 1;}

    if (x >= 224 && x < 256 && y >=  64 && y <  96) {           col = 7; row = 2;}
    if (x >= 224 && x < 240 && y >=  48 && y <  64) { bank = 2; col = 7; row = 2;}
    
    if (x >=   0 && x <  32 && y >= 160 && y < 192) {           col = 0; row = 5;}
    if (x >=  16 && x <  32 && y >= 192 && y < 208) { bank = 1; col = 0; row = 5;}

    if (x >=  64 && x <  96 && y >= 224 && y < 256) {           col = 0; row = 6;}
    if (x >=  48 && x <  64 && y >= 224 && y < 240) { bank = 1; col = 0; row = 6;}

    if (x >= 160 && x < 192 && y >= 224 && y < 256) {           col = 7; row = 6;}
    if (x >= 192 && x < 208 && y >= 224 && y < 240) { bank = 0; col = 7; row = 6;}
    
    if (x >= 224 && x < 256 && y >= 160 && y < 192) {           col = 7; row = 5;}
    if (x >= 224 && x < 240 && y >= 192 && y < 208) { bank = 0; col = 7; row = 5;}
    
#if 1
    // Special corner cases for the 8x8 panels
    if (x >=   8 && x <  16 &&  y >=  72 && y <  80) { bank = 0; col = 0; row = 7; x_col = x -   8;     y_row = y - 72;  blackout = false; }  // bank 0   row 0-7 col 0-7
    if (x >=  72 && x <  80 &&  y >=   8 && y <  16) { bank = 0; col = 0; row = 7; x_col = x -  72 + 8; y_row = y - 8;   blackout = false; }  // bank 0   row 0-7 col 8-15
    if (x >= 176 && x < 184 &&  y >=   8 && y <  16) { bank = 1; col = 0; row = 7; x_col = x - 176;     y_row = y - 8;   blackout = false; }  // bank 1   row 0-7 col 0-7
    if (x >= 240 && x < 248 &&  y >=  72 && y <  80) { bank = 1; col = 0; row = 7; x_col = x - 240 + 8; y_row = y - 72;  blackout = false; }  // bank 1   row 0-7 col 8-15
#endif

#if 1
    if (x >=   8 && x <  16 &&  y >= 176 && y < 184) { bank = 2; col = 0; row = 7; x_col = x -   8;     y_row = y - 176 + 8; blackout = false; }  // bank 2   row 0-7 col 0-7
    if (x >=  72 && x <  80 &&  y >= 240 && y < 248) { bank = 2; col = 0; row = 7; x_col = x -  72 + 8; y_row = y - 240 + 8; blackout = false; }  // bank 2   row 0-7 col 8-15
    if (x >= 176 && x < 184 &&  y >= 240 && y < 248) { bank = 3; col = 0; row = 7; x_col = x - 176;     y_row = y - 240 + 8; blackout = false; }  // bank 3   row 0-7 col 0-7
    if (x >= 240 && x < 248 &&  y >= 176 && y < 184) { bank = 3; col = 0; row = 7; x_col = x - 240 + 8; y_row = y - 176 + 8; blackout = false; }  // bank 3   row 0-7 col 8-15    
#endif
    
    if (blackout) {
        return false;
    }
    
    panel_row = row;
    panel_col = col;
    panel_quad = bank;
    panel_idx = (bank * 256) + (y_row % 16) * 16 + (15 - (x_col % 16));

    return true;
}


void DisplayInterface::setPixel(int x, int y, unsigned char pixel)
{
    int pix = y * MAX_X + x;
    
    int panel_idx = _xlatePanelIdx[pix];
    int pixel_idx = _xlatePixelIdx[pix];
    
    if (panel_idx < 0) return;
    
    unsigned char * panel = _panels[ panel_idx];
    panel[pixel_idx] = pixel;    
    
    return;
}

void DisplayInterface::setHalo(int pos, unsigned char val)
{
    int panel_offset = 0;
    if (pos < 0 || pos >= HALO_SIZE) {
        fprintf(stderr, "DisplayInterface::setHalo, position (%d) out of bounds\n", pos);
        return;
    }
    _useHalo = true;
    
    
    pos = (pos + 32) % 128;
    
    if (pos >= 128) return;
    if (pos >= 64) {
        pos -= 64;
//        pos = 63 - pos;
        panel_offset += 1024;
    } else {
//        pos = 63 - pos;
    }
    
    if (pos < 16) { /* Lower Left corner */
        for (int y=0; y<16; y++) {
            int pix = y * 16 + 15 - pos;
            _halo[panel_offset + 768 + pix] = val;
        }
    } else if (pos < 32) {  /* Lower Right corner */
        for (int y=0; y<16; y++) {
            int pix = y * 16 + 31 - pos;
            _halo[panel_offset + 512 + pix] = val;
        }        
    } else if (pos < 48) {  /* Upper Left corner */
        for (int y=0; y<16; y++) {
            int pix = y * 16 + 47 - pos;
            _halo[panel_offset + 256 + pix] = val;
        }        
    } else if (pos < 64) {  /* Upper Left corner */
        for (int y=0; y<16; y++) {
            int pix = y * 16 + 63 - pos;
            _halo[panel_offset + 000 + pix] = val;
        }        
    }
    return;
}



void DisplayInterface::update()
{
    int x, y;
    int panelIdx;

    for (y=0; y<ROW_COUNT; y++) {
        for (x=0; x<COLUMN_COUNT; x++) {
            panelIdx = y * COLUMN_COUNT + x;
            unsigned char * panel = _panels[panelIdx];
            
            FSPacket packet;
            packet.panel_col = x;
            packet.panel_row = y;
            packet.type = FS_TYPE_DATA;
            
            memcpy(packet.display_packet.pixels, panel, FS_PIXELS_PER_PANEL);
            packet.display_packet.panel_id = x;
            packet.display_packet.dot_cor = 20;
            packet.display_packet.crc = 0;
            send_packet(&packet);
        }
    }
    
    for (x=0; x<HALO_PANELS; x++) {
        FSPacket packet;
        packet.panel_col = x;
        packet.panel_row = ROW_COUNT;   /* Halo row (8) */
        packet.type = FS_TYPE_DATA;
        
        memcpy(packet.display_packet.pixels, &_halo[x * FS_PIXELS_PER_PANEL], FS_PIXELS_PER_PANEL);
        packet.display_packet.panel_id = x;
        packet.display_packet.dot_cor = 20;
        packet.display_packet.crc = 0;
        send_packet(&packet);
        
    }
    
    FSPacket packet;
    packet.type = FS_TYPE_SYNC;
    send_packet(&packet);

    _frame ++;
}

int DisplayInterface::open_comm(const char * hostname, int udp_port)
{
    struct hostent *hp;
    
    
    if ((_socket = socket( PF_INET, SOCK_DGRAM, 0 )) < 0) {
        printf("Problem creating socket\n");
        return -1;
    }
    
    _server.sin_family = AF_INET;
    if ((hp = gethostbyname(hostname))==0) {
        printf("Invalid or unknown host\n");
        return -2;
    }
    
    memcpy( &_server.sin_addr.s_addr, hp->h_addr, hp->h_length);
    
    _server.sin_port = htons(udp_port);
    return 0;
}

int DisplayInterface::send_packet(FSPacket * packet)
{
    int n_sent;
    n_sent = sendto(_socket, (char *) packet, sizeof(FSPacket), 0, (struct sockaddr*) &_server,sizeof(_server));
    
    if (n_sent != sizeof(FSPacket)) {
        fprintf(stderr,  "DisplayInterface::send_packet, error sending packet\n");
        return -1;
    }

    return 0;
}
