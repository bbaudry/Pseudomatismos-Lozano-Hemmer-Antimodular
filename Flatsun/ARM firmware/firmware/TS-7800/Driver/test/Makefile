# Cross compilation makefile for TS-7800
CC=$(CROSS_COMPILE)gcc

CFLAGS = -g -O2 -Wall -W
LDFLAGS = -g -static
target = fstest

$(target) : $(target).c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $^ $(LDLIBS) -lm -o $@

