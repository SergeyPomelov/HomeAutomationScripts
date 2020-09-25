#!/usr/bin/python

import broadlink, sys, getopt
device = broadlink.mp1(host=(IP,80), mac=bytearray.fromhex(MAC), devtype = 'SP1')
device.auth()
if sys.argv[2] == 'On':
    device.set_power(int(sys.argv[1]), True)
elif sys.argv[2] == 'Off':
    device.set_power(int(sys.argv[1]), False)
elif sys.argv[2] == 'status':
    print(device.check_power())