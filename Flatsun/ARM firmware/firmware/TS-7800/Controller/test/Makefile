# Cross compilation makefile for TS-7800
# CC=$(CROSS_COMPILE)gcc

CFLAGS = -g -O -Wall -W
# LDFLAGS = -g -static
LDFLAGS = -g
target = panels3

$(target) : $(target).c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $^ $(LDLIBS) -lm -o $@

