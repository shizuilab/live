#!/bin/bash

set -e

if [ pgrep -l file- ]; then
 /home/pi/aquestalkpi/AquesTalkPi "ドライブレコーダーを終了しています" | aplay -D plughw:1,0
 exit 0
fi

#sudo /bin/bash /home/pi/live/usbreset.sh

if [ ! -d /media/pi/USB0/webcam ]; then
 sudo /bin/bash /home/pi/live/usbreset.sh
 /home/pi/aquestalkpi/AquesTalkPi "USBメモリがみつかりません" | aplay -D plughw:1,0
 exit 0
fi

cat /media/pi/USB0/BGM/mylist.txt | sort -R > /home/pi/live/playlist.txt

if [ ! -e /dev/video0 ]; then
 sudo /bin/bash /home/pi/live/usbreset.sh
 /home/pi/aquestalkpi/AquesTalkPi "ビデオカメラが見つかりません" | aplay -D plughw:1,0
 exit 0
fi

URL=`cat /home/pi/live/config/youtube_url.txt`

if [[ $(arecord -l) == *'[USB Audio Device]'* ]]; then
 /home/pi/aquestalkpi/AquesTalkPi "音声付きストリーミングを開始します" | aplay -D plughw:1,0

 ffmpeg\
 -f alsa -thread_queue_size 8192 -i plughw:2,0\
 -f v4l2 -thread_queue_size 16384 -input_format yuyv422 -video_size 864x480 -framerate 20 -i /dev/video0\
 -vf drawtext="fontfile=/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc:\
 fontcolor=#FFFFFF:fontsize=20:x=10:y=10:box=1:boxcolor=black@0.4:\
 textfile='/var/tmp/location.txt':reload=1":\
 -c:v h264_omx -b:v 1000k -bufsize 3000k -vsync 0\
 -c:a aac -ab 128k -af volume=1.0 -g 16 -t 3600\
 -f flv ${URL}

else
 /home/pi/aquestalkpi/AquesTalkPi "BGM付きストリーミングを開始します" | aplay -D plughw:1,0

 ffmpeg\
 -f concat -safe 0 -thread_queue_size 8192 -i /home/pi/live/playlist.txt\
 -f v4l2 -thread_queue_size 16384 -input_format yuyv422 -video_size 640x320 -framerate 15 -i /dev/video0\
 -vf drawtext="fontfile=/usr/share/fonts/truetype/fonts-japanese-gothic.ttf:\
 fontcolor=#FFFFFF:fontsize=20:x=10:y=10:box=1:boxcolor=black@0.4:\
 textfile='/var/tmp/location.txt':reload=1":\
 -c:v h264_omx -b:v 1000k -bufsize 3000k -vsync 0\
 -c:a aac -ab 128k -af volume=-10dB -g 16 -t 3600\
 -f flv ${URL}

fi
