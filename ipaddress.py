#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys, os, time, ipget, serial

# Get IP address
try:
    ip=ipget.ipget()
    ipaddress = ip.ipaddr('wlan0')
except Exception as e:
    print(str(type(e)))
    ipaddress = "no connection"

print(ipaddress)

with open("/var/tmp/ipaddress.txt", "w") as myfile:
    myfile.write(ipaddress)

