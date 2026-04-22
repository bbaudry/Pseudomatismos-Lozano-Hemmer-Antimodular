#ifndef __FS_PACKET_H__
#define __FS_PACKET_H__

#define FS_PIXELS_PER_PANEL     1024

#define FS_TYPE_DATA            0
#define FS_TYPE_SYNC            1

#define FS_ROWS                 9   /* 8 for the panels + 1 for the halo */
#define FS_COLUMNS              8

typedef struct DisplayPacket {
    uint8_t     pixels[FS_PIXELS_PER_PANEL];
    uint32_t    dot_cor;
    uint32_t    panel_id;
    uint32_t    crc;            
} DisplayPacket;

typedef struct {
    unsigned int            type;
    unsigned char           panel_row;
    unsigned char           panel_col;
    struct DisplayPacket    display_packet;
} FSPacketData;

typedef FSPacketData FSPacket;

#endif // __FS_PACKET_H__
