#!/usr/bin/python

import broadlink, sys, getopt

device = broadlink.mp1(host=(IP,80), mac=bytearray.fromhex(MAC), devtype = 'SP1')
device.auth()
device.set_power(1, False)
device.set_power(2, False)
device.set_power(3, False)
device.set_power(4, False)