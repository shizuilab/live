#!/bin/bash

set -e

sleep 5

sudo /bin/bash /home/pi/usbreset.sh

cat /media/pi/3DF7-5138/BGM/mylist.txt | sort -R > /home/pi/playlist.txt

if [ ! -e /dev/video0 ]; then
 /home/pi/aquestalkpi/AquesTalkPi "ビデオカメラが見つかりません" | aplay
 exit 0
fi


if [[ $(arecord -l) == *'USB Audio Device'* ]]; then
 /home/pi/aquestalkpi/AquesTalkPi "ユーチューブライブストリーミングを開始します" | aplay

 ffmpeg\
 -f alsa -thread_queue_size 8192 -i plughw:2,0\
 -f v4l2 -thread_queue_size 8192 -input_format yuyv422 -video_size 640x360 -framerate 30 -i /dev/video0\
 -vf drawtext="fontfile=/usr/share/fonts/truetype/fonts-japanese-gothic.ttf:\
 fontcolor=#FFFFFF:fontsize=20:x=10:y=10:box=1:boxcolor=black@0.4:\
 textfile='/var/tmp/location.txt':reload=1":\
 -c:v h264_omx -b:v 1000k -bufsize 1500k -vsync 0\
<<<<<<< HEAD
 -c:a aac -ab 128k -af volume=0.9 -g 16 -t 3600\
 -f flv rtmp://a.rtmp.youtube.com/live2/ju63-rzf3-te44-c373
=======
 -c:a aac -ab 128k -af volume=0.9 -g 16 -t 600\
 -f flv rtmp://a.rtmp.youtube.com/live2/<your youtube key>
>>>>>>> 26cc12ac829ab827003b130309d0da5e0d019cc7

else
 /home/pi/aquestalkpi/AquesTalkPi "BGM付きストリーミングを開始します" | aplay

 ffmpeg -thread_queue_size 8192\
 -f concat -safe 0 -i /home/pi/playlist.txt\
 -f v4l2 -input_format yuyv422 -video_size 640x360 -framerate 30 -i /dev/video0\
 -vf drawtext="fontfile=/usr/share/fonts/truetype/fonts-japanese-gothic.ttf:\
 fontcolor=#FFFFFF:fontsize=20:x=10:y=10:box=1:boxcolor=black@0.4:\
 textfile='/var/tmp/location.txt':reload=1":\
 -c:v h264_omx -b:v 1000k -bufsize 1500k -vsync 0\
 -c:a aac -ab 128k -af volume=-10dB -g 16 -t 3600\
 -f flv rtmp://a.rtmp.youtube.com/live2/ju63-rzf3-te44-c373
fi
