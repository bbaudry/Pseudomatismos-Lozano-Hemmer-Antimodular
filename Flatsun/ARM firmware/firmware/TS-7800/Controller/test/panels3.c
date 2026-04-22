#include<unistd.h>
#include<sys/mman.h>
#include<fcntl.h>
#include<stdio.h>
#include<stdlib.h>
#include <stdint.h>
#include "FSPacket.h"
#include "LCD.h"

#define DIOBASE 0xE8000000
#define SPI_CLK     (1 << 15)
#define DATA_DIR    (1 << 30)
#define PANEL_COUNT 9

// PORT A
#define PORT_DATA *(dioptr + 0x10 / sizeof(unsigned int))
#define PORT_DIR  *(dioptr + 0x20 / sizeof(unsigned int))
#define	PORT_FUNC *(dioptr + 0x30 / sizeof(unsigned int))

#define BASELINE_MASK 0x00080000
#define RS_MASK       0x00040000
#define BUSY_MASK     0x20000000

volatile unsigned int *dioptr;
#define RW_REG(ptr) *(ptr + 0x08/sizeof(unsigned int))

void init_spi() {
    int fd;
    fd = open("/dev/mem", O_RDWR|O_SYNC);
    dioptr = (unsigned int *)mmap(0, getpagesize(),
        PROT_READ|PROT_WRITE, MAP_SHARED, fd, DIOBASE);
    PORT_FUNC = 0;
    PORT_DIR = 0xFFFFFFFF;
    
    RW_REG(dioptr) &= ~BASELINE_MASK; /* baseline should always be zero */
}


void spi_writepanels(short * panels, int frame_size )
{
    unsigned int mc1, mc0;
    unsigned short bit;
    unsigned int mask;
    int i, p;
    volatile int k;

    unsigned int words[32];
    unsigned int * ptr;

    ptr = words;

#if 0
    for (p=PANEL_COUNT - 1; p >= 0; p--) {
	fprintf(stderr, "%03x ", panels[p]);
    }
    fprintf(stderr, "\n");
#endif

    * ptr ++ = DATA_DIR;		/* Start bit  */
    for (i=frame_size - 1, bit=0x1; i >= 0; i--, bit <<=1) {
        mc0 = 0;
        for (p=PANEL_COUNT - 1; p >= 0; p--) {
            mask = 1 << p;
            if ((panels[p] & bit) == 0) mc0 |= mask;
        }
        * ptr ++ = DATA_DIR | mc0;
    }     
    * ptr ++ = DATA_DIR | 0x7F;	/* Stop bit */

    #define DELAY 7
    ptr = words;
    for (i=frame_size + 1; i >= 0; i--) {
	for (k=0; k<DELAY; k++);
	PORT_DATA = * ptr ++;
    }
}

unsigned short  panels[PANEL_COUNT + 1];

main()
{
    volatile int k;
    int i, frame, update;
    char * s, string[80];
    for (i=0; i<PANEL_COUNT; i+= 2) {
	panels[i] = 0x80;
	panels[i+1] = 0x80;
    }
    
    init_spi();
    lcd_init(dioptr);
    
    update = 0;

    while (1) {
        for (frame=0; frame<24; frame++) {
            for (i=0; i<(1024 + 32) * 8; i++) {
                spi_writepanels(panels, 9);
		//for (k=0; k<100; k++) ;
            }
        }
        update ++;
        sprintf(string, "%8d", update);
        lcd_wait_not_busy();
        lcd_cmd(0xa8); // // set DDRAM addr to second row
        s = string;
        while (*s) {
          lcd_data(*(s++));
        }
    }
}
