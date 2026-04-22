#include "Packet.h"
#include "stm32f10x.h"


void    Packet_Init()
{
    /* Enable CRC clock */
    RCC_AHBPeriphClockCmd(RCC_AHBPeriph_CRC, ENABLE);
}

void    Packet_SetCRC(DisplayPacket * packet)
{
    int     words = (sizeof(DisplayPacket) - sizeof(uint32_t)) / sizeof(uint32_t);
    __IO uint32_t CRCValue;
    
    CRC_ResetDR();
    CRCValue = CRC_CalcBlockCRC((uint32_t *) packet, words);

    packet->crc = CRCValue;
}

unsigned char    Packet_CheckCRC(DisplayPacket * packet)
{
    int     words = (sizeof(DisplayPacket) - sizeof(uint32_t)) / sizeof(uint32_t);
    __IO uint32_t CRCValue;
    
    CRC_ResetDR();
    CRCValue = CRC_CalcBlockCRC((uint32_t *) packet, words);

    if (packet->crc == CRCValue) {
        return TRUE;
    } else {
        return FALSE;
    }
}
