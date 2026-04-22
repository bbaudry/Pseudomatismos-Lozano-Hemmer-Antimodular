# Cross compilation makefile for TS-7800
CC=$(CROSS_COMPILE)gcc

CFLAGS = -g -O2 -Wall -W -I../../../common
LDFLAGS = -g -static
target = fsserver

.PHONY: clean
    
$(target) : $(target).c crc.o
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $^ $(LDLIBS) -lm -o $@

clean:
	rm -f $(target) *.o
	rm -rf $(target).dSYM
