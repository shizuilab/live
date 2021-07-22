#!/bin/sh


sudo pkill -SIGTERM -f youtube-
sudo pkill -SIGTERM -f file-

/home/pi/aquestalkpi/AquesTalkPi "配信システムを終了しています" | aplay -D plughw:1,0
sleep 4

sudo systemctl stop youtube
sudo systemctl stop filetube

/home/pi/aquestalkpi/AquesTalkPi "デーモンに停止シグナルを送信しました" | aplay -D plughw:1,0
sleep 4

/home/pi/aquestalkpi/AquesTalkPi "VT250F システムを終了します　お疲れ様でした" | aplay -D plughw:1,0

exit 0

