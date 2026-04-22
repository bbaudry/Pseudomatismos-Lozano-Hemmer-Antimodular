MODULE_NAME = flatsun
 
# If KERNELRELEASE is defined, we've been invoked from the
# kernel build system and can use its language.
ifneq ($(KERNELRELEASE),)
  obj-m := $(MODULE_NAME).o
 
# Otherwise we were called directly from the command
# line; invoke the kernel build system.
 
else
  KERNELDIR ?= /lib/modules/$(shell uname -r)/build
  PWD := $(shell pwd)
 
# kunil: The whitespace in front of '$(MAKE)' line should be tab
# (not spaces). Otherwise, the GNU make will not be able to run
# this Makefile
#
default:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
endif
 
clean:
	rm -rf *.o *.ko *.mod.c .*.cmd .tmp_versions Module.markers modules.order Module.symvers
