#include<unistd.h>
#include<sys/mman.h>
#include<fcntl.h>
#include<stdio.h>
#include<stdlib.h>

/*
TS-7800 SPI bus routines.  Usage:
First, with no SPI devices selected, call init_spi()
Then assert the chip select for your SPI device.
Then, you can use spi8 or spi32 to write and read. (normal full-duplex SPI operation -- spi8(x) sends x and then
returns any data the the slave device was sending.)
spi8 works with char values, spi32 with int values.
spi_write8 and spi_write32 are faster by a factor of 5 because they send data but ignore responses from the slave device.
*/


#define DIOBASE 0xE8000000
#define SPI_CLK     (1 << 14)
#define PANEL_COUNT 9

#define PORT_DATA *(spi_dioptr + 0x10 / sizeof(unsigned int))
#define PORT_DIR  *(spi_dioptr + 0x20 / sizeof(unsigned int))
#define	PORT_FUNC *(spi_dioptr + 0x30 / sizeof(unsigned int))

volatile unsigned int *spi_dioptr;

void init_spi() {
    int fd;
    fd = open("/dev/mem", O_RDWR|O_SYNC);
    spi_dioptr = (unsigned int *)mmap(0, getpagesize(),
        PROT_READ|PROT_WRITE, MAP_SHARED, fd, DIOBASE);
    PORT_FUNC = 0;
    PORT_DIR = 0xFFFFFFFF;
}


void spi_writepanels(char * panels)
{
    unsigned short mc1, mc0;
    unsigned char bit = 0x80;
    unsigned int mask;
    int i, p;
    volatile int k = 0;

    for (i=7; i >= 0; i--) {
        mc0 = 0;
        for (p=0; p < PANEL_COUNT; p++) {
            mask = 1 << p;
            if (panels[p] & bit) mc0 |= mask;
        }
        
        mc1 = mc0 | SPI_CLK;
	PORT_DATA = mc1;
	PORT_DATA = mc0;
        bit >>= 1;
    }     
}

unsigned char  panels[PANEL_COUNT + 1];

main()
{
    int i, frame;
    for (i=0; i<PANEL_COUNT; i+= 2) {
	panels[i] = 0xAA;
	panels[i+1] = 0x55;
    }
    
    init_spi();
    for (frame=0; frame<1000; frame++) {
        for (i=0; i<(1024 + 32) * 8; i++) {
            spi_writepanels(panels);
        }
    }
}
