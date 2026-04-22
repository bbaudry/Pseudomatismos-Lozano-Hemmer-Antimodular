#include <stdio.h>
#include <unistd.h>

int main() { 
  unsigned short pdata[12];
  char dummy;
  volatile int k;
  unsigned char val = 0;
  FILE * FlatSun;

  /* Opening the device parlelport */
  FlatSun=fopen("/dev/flatsun","w");
  /* We remove the buffer from the file i/o */
  setvbuf(FlatSun,&dummy,_IONBF,1);

  for (k=0; k<12; k++) pdata[k] = k;
  pdata[1] = 0x100;
  pdata[2] = 0x1;
  pdata[3] = 0x1FF;
  pdata[7] |= 0x100;
  pdata[8] |= 0x100;

  pdata[0] = 0;
  
  while (1) { 
      fprintf(stderr, "0x%02x ", val);
      for (k=0; k<12; k++) {
          pdata[k] = val;
      }
      val ++;
      fwrite(pdata,sizeof(unsigned short),12,FlatSun);
      for (k=0; k<5000000; k++) ;
  }

  fclose(FlatSun);
}

