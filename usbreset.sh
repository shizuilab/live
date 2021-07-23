#!/usr/bin/bash
#ID='046d:0825' #old camera
BUS1=`lsusb | grep 'C270' | tail -1 | cut --delimiter=' ' --fields='2' | tr --delete ':'`
ID1=`lsusb | grep 'C270' | tail -1 | cut --delimiter=' ' --fields='4' | tr --delete ':'`
PATH1="/dev/bus/usb/${BUS1}/${ID1}"
echo $PATH1
/usr/bin/sudo /home/pi/live/usbreset $PATH1

BUS2=`lsusb | grep 'Arduino' | tail -1 | cut --delimiter=' ' --fields='2' | tr --delete ':'`
ID2=`lsusb | grep 'Arduino' | tail -1 | cut --delimiter=' ' --fields='4' | tr --delete ':'`
PATH2="/dev/bus/usb/${BUS2}/${ID2}"
echo $PATH2
/usr/bin/sudo /home/pi/live/usbreset $PATH2

