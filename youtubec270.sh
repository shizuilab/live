#!/bin/bash

set -e

if [ ! -e /dev/video0 ]; then
 sudo /bin/bash /home/pi/live/usbreset.sh
 /home/pi/aquestalkpi/AquesTalkPi "ビデオカメラが見つかりません" | aplay -D plughw:1,0
 exit 0
fi

if [ -d /media/pi/USB0/webcam ]; then
 USBDRIVE=USB0
elif [ -d /media/pi/8595-5A62/webcam ]; then
 USBDRIVE=8595-5A62
else
 sudo /bin/bash /home/pi/live/usbreset.sh
 /home/pi/aquestalkpi/AquesTalkPi "USBメモリがみつかりません" | aplay -D plughw:1,0
 exit 0
fi

latest=`ls -rt /media/pi/$USBDRIVE/webcam/ | tail -n 1`
MD5=`md5sum /media/pi/$USBDRIVE/webcam/$latest`
MD5=($MD5)
echo ${MD5[0]} ${MD5[1]##*/} > /home/pi/live/hash.txt
cp /home/pi/live/hash.txt /media/pi/$USBDRIVE/webcam/$latest.hash.txt
/home/pi/aquestalkpi/AquesTalkPi "最新ファイルのハッシュ値を保存しました" | aplay -D plughw:1,0

URL=`cat /home/pi/live/config/youtube_url.txt`

if [[ $(arecord -l) == *'[USB Audio]'* ]]; then
 /home/pi/aquestalkpi/AquesTalkPi "マイク音声のストリーミングを開始します" | aplay -D plughw:1,0

 ffmpeg\
 -f alsa -thread_queue_size 8192 -i plughw:2,0\
 -f v4l2 -thread_queue_size 16384 -input_format yuyv422 -video_size 864x480 -framerate 20 -itsoffset 0.4 -i /dev/video0\
 -vf drawtext="fontfile=/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc:\
 fontcolor=#FFFFFF:fontsize=20:x=10:y=10:box=1:boxcolor=black@0.4:\
 textfile='/var/tmp/location.txt':reload=1":\
 -c:v h264_omx -b:v 1000k -bufsize 3000k -vsync 0\
 -c:a aac -ab 128k -af volume=1.0 -g 16 -t 3600\
 -f flv ${URL}

else
 /home/pi/aquestalkpi/AquesTalkPi "音声デバイスがみつかりません" | aplay -D plughw:1,0
fi
