#!/bin/sh

if [ -d /media/pi/USB0/webcam ]; then
 USBDRIVE=USB0
elif [ -d /media/pi/8595-5A62/webcam ]; then
 USBDRIVE=8595-5A62
else
 sudo /bin/bash /home/pi/live/usbreset.sh
 /home/pi/aquestalkpi/AquesTalkPi "USBメモリがみつかりませんが続行します" | aplay -D plughw:1,0
fi

sudo pkill -SIGTERM -f youtubec270
sudo pkill -SIGTERM -f filec270

/home/pi/aquestalkpi/AquesTalkPi "配信システムを終了しています" | aplay -D plughw:1,0
sleep 4

sudo systemctl stop youtube
sudo systemctl stop filetube

/home/pi/aquestalkpi/AquesTalkPi "デーモンに停止シグナルを送信しました" | aplay -D plughw:1,0
sleep 4

latest=`ls -rt /media/pi/$USBDRIVE/webcam/ | tail -n 1`
md5sum /media/pi/$USBDRIVE/webcam/$latest > /home/pi/live/hash.txt
cp /home/pi/live/hash.txt /media/pi/$USBDRIVE/webcam/$latest.hash.txt
/home/pi/aquestalkpi/AquesTalkPi "最終ファイルのハッシュ値を保存しました" | aplay -D plughw:1,0

/home/pi/aquestalkpi/AquesTalkPi "VT250F システムを終了します　お疲れ様でした" | aplay -D plughw:1,0

exit 0

