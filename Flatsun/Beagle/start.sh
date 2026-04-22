#!/bin/sh
echo 7 > /sys/kernel/debug/omap_mux/gpmc_ad0
# cat /sys/kernel/debug/omap_mux/gpmc_ad0
echo 32 > /sys/class/gpio/export
echo "high" > /sys/class/gpio/gpio32/direction
mknod /dev/flatsun c 60 0
insmod flatsun.ko
