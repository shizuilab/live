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

if [ -f /var/tmp/location.txt ]; then

 /home/pi/aquestalkpi/AquesTalkPi "ドライブレコーダーを開始します" | aplay -D plughw:1,0

 ffmpeg -f v4l2 -thread_queue_size 8192\
 -input_format yuyv422 -video_size 752x416 -framerate 20 -i /dev/video0\
 -vf drawtext="fontfile=/usr/share/fonts/truetype/fonts-japanese-gothic.ttf:\
 fontcolor=#FFFFFF:fontsize=20:x=10:y=10:box=1:boxcolor=black@0.4:\
 textfile='/var/tmp/location.txt':reload=1"\
 -c:v h264_omx  -b:v 3000k -bufsize 10000k -vsync 0 -t 600\
 /media/pi/$USBDRIVE/webcam/`date +%Y%m%d_%H%M%S`.mp4

else

 /home/pi/aquestalkpi/AquesTalkPi "ロケーションファイルを作製します" | aplay -D plughw:1,0
 date > /var/tmp/location.txt

fi

latest=`ls -rt /media/pi/$USBDRIVE/webcam/ | tail -n 1`
MD5=`md5sum /media/pi/$USBDRIVE/webcam/$latest`
MD5=($MD5)
echo ${MD5[0]} ${MD5[1]##*/} > /home/pi/live/hash.txt
cp /home/pi/live/hash.txt /media/pi/$USBDRIVE/webcam/$latest.hash.txt
