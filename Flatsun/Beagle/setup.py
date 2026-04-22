#!/usr/bin/python
KERNEL_VERSION="3.2.28"
uImage = "uImage-" + KERNEL_VERSION + "-flatsun"
fsmodule = "flatsun-" + KERNEL_VERSION + ".ko"
fsserver = 'fsserver'
fsinit = 'flatsun.sh'
pullupscript = 'pullup.sh'

import sys
import subprocess

# Check if ethernet cable is connected, if not - bail out.
get_services_out = subprocess.check_output(["/usr/lib/connman/test/get-services"])
if len(get_services_out) <= 0:
	print "Ethernet cable not connected - needs to be connected to execute this script"
	sys.exit(1)

print "Copying new kernel"
# Copy the new kernel with flatsun support to the boot directory
subprocess.call(['/bin/cp', uImage, '/boot'])
subprocess.call(['/bin/mv', '/boot/uImage', '/boot/uImage-org'])
subprocess.call(['/bin/mv', uImage, '/boot/uImage'])

print "Updating startup scripts"
subprocess.call(['/bin/cp', fsinit, '/etc/init.d'])
subprocess.call(['/usr/sbin/update-rc.d', fsinit, 'defaults'])

print "Installing fsserver app and kernel module"
subprocess.call(['/bin/cp', fsmodule, '/home/root/flatsun.ko'])
subprocess.call(['/bin/cp', fsserver, '/home/root'])
subprocess.call(['/bin/cp', pullupscript, '/home/root'])
subprocess.call(['/bin/sync'])

# Set the ip address of the ethernet interface to 
# static 192.168.0.50 - nameserver google.com
print "Reboot BeagleBone after Setting method manual.... message"
b = get_services_out.split()[1].split('/')[4]
subprocess.call(['/usr/lib/connman/test/set-nameservers', b,  '8.8.8.8'])
subprocess.call(['/usr/lib/connman/test/set-ipv4-method', b,  'manual', '192.168.0.50', '255.255.255.0', '192.168.0.1'])

