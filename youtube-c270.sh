#!/bin/bash

set -e

sleep 5

#sudo /bin/bash /home/pi/wanapi/usbreset.sh

cat /media/pi/USB0/BGM/mylist.txt | sort -R > /home/pi/wanapi/playlist.txt

if [ ! -e /dev/video0 ]; then
 /home/pi/aquestalkpi/AquesTalkPi "ビデオカメラが見つかりません" | aplay -D plughw:2,0
 exit 0
fi


if [[ $(arecord -l) == *'[USB Audio Device]'* ]]; then
 /home/pi/aquestalkpi/AquesTalkPi "音声付きストリーミングを開始します" | aplay -D plughw:2,0

 ffmpeg\
 -f alsa -thread_queue_size 8192 -i plughw:0,0\
 -f v4l2 -thread_queue_size 8192 -input_format yuyv422 -video_size 1280x720 -framerate 30 -i /dev/video0\
 -vf drawtext="fontfile=/usr/share/fonts/truetype/fonts-japanese-gothic.ttf:\
 fontcolor=#FFFFFF:fontsize=20:x=10:y=10:box=1:boxcolor=black@0.4:\
 textfile='/var/tmp/location.txt':reload=1":\
 -c:v h264_omx -b:v 1000k -bufsize 3000k -vsync 0\
 -c:a aac -ab 128k -af volume=1.0 -g 16 -t 3600\
 -f flv rtmp://a.rtmp.youtube.com/live2/ux0k-wtpj-1ttr-7t0h-adqq

else
 /home/pi/aquestalkpi/AquesTalkPi "BGM付きストリーミングを開始します" | aplay -D plughw:2,0

 ffmpeg -thread_queue_size 8192\
 -f concat -safe 0 -i /home/pi/wanapi/playlist.txt\
 -f v4l2 -input_format yuyv422 -video_size 1280x720 -framerate 30 -i /dev/video0\
 -vf drawtext="fontfile=/usr/share/fonts/truetype/fonts-japanese-gothic.ttf:\
 fontcolor=#FFFFFF:fontsize=20:x=10:y=10:box=1:boxcolor=black@0.4:\
 textfile='/var/tmp/location.txt':reload=1":\
 -c:v h264_omx -b:v 1000k -bufsize 1500k -vsync 0\
 -c:a aac -ab 128k -af volume=-10dB -g 16 -t 3600\
 -f flv rtmp://a.rtmp.youtube.com/live2/ux0k-wtpj-1ttr-7t0h-adqq
fi
