#ifndef __PACKET_H__
#define __PACKET_H__

#include "stm32f10x.h"
#include "stm32f10x_crc.h"


// Needs to be multiple of 4
#define PIXEL_COUNT 1024        

#ifndef TRUE
#define TRUE    1
#endif

#ifndef FALSE
#define FALSE   0
#endif

typedef struct DisplayPacket {
    uint8_t     pixels[PIXEL_COUNT];
    uint32_t    dot_cor;
    uint32_t    id;
    uint32_t    crc;            
} DisplayPacket;

void    Packet_Init();

// Updates the crc in the packet
void    Packet_SetCRC(DisplayPacket * packet);
// Returns TRUE if packet has correct CRC - FALSE otherwise
unsigned char    Packet_CheckCRC(DisplayPacket * packet);


#endif // __PACKET_H__
