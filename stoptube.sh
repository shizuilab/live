#!/bin/bash

set -e

sleep 4

sudo /home/pi/live/usbreset.sh

sleep 1

/home/pi/aquestalkpi/AquesTalkPi "ストリーミングを終了します" | aplay

