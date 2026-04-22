#ifndef __FS_PACKET_H__
#define __FS_PACKET_H__

#define FS_PIXELS_PER_PANEL     1024
#define FS_PIXELS_PER_TRANSFER  172

#define FS_PACKETS_PER_PANEL    6   /* Must be more than FS_PIXELS_PER_PANEL / FS_PIXELS_PER_TRANSFER */

typedef struct {
    unsigned char   panel;
    unsigned char   block;
    unsigned char   crc;
    unsigned char   fill;
    unsigned char   data[FS_PIXELS_PER_TRANSFER];
} FSPacketData;

typedef FSPacketData FSPacket;

#endif // __FS_PACKET_H__
