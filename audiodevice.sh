#!/bin/bash

if [ ! -e /dev/video0 ]; then
echo "ビデオカメラが見つかりません"
exit 0
fi

if [ ! -d /dev/snd/by-id ]; then
echo "マイクが見つかりません"
exit 0
fi

if [ ! -d /media/pi/3DF7-5138 ]; then
echo "USBメモリがみつかりません"
exit 0
fi

if [[ $(arecord -l) == *'USB Audio Device'*  ]]; then
 echo "マイクが見つかりました"
 exit 0

else
 echo "マイクが見つかりません"
 exit 0
fi
