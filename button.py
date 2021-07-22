#!/usr/bin/python3
# -*- coding: utf-8 -*-

import RPi.GPIO as GPIO
import os, time

GPIO.setmode(GPIO.BCM)

GPIO.setup(23, GPIO.IN, pull_up_down = GPIO.PUD_UP)
GPIO.setup(25, GPIO.OUT) #blue
GPIO.setup(26, GPIO.IN, pull_up_down = GPIO.PUD_UP)
GPIO.setup(24, GPIO.OUT) #red

GPIO.output(24, GPIO.HIGH)
GPIO.output(25, GPIO.HIGH)
time.sleep(5)
GPIO.output(25, GPIO.LOW)

os.system('/home/pi/aquestalkpi/AquesTalkPi "システム起動しました" | aplay -D plughw:1,0')

os.system('/home/pi/aquestalkpi/AquesTalkPi "10秒後にドライブレコーダーを開始します" | aplay -D plughw:1,0')

time.sleep(10)

os.system("sudo systemctl start filetube")

try:
    button_previous = 1
    button_current = 1
    brojac = 0
    flag_pressed = 0

    while True:
        button_current = GPIO.input(26)
        print(button_current)
        flag_pressed = button_previous + button_current

        if (not(flag_pressed)):
            brojac += 1
        else:
            brojac = 0

        if(button_current and (not button_previous)):
            GPIO.output(24,GPIO.LOW)
            os.system('/home/pi/aquestalkpi/AquesTalkPi "シャットダウンします" | aplay -D plughw:1,0')
            os.system('/home/pi/live/shutdownVT.sh')
            os.system("sudo shutdown -h now")
        if((not flag_pressed) and brojac >= 5):
            GPIO.output(24,GPIO.LOW)
            os.system('/home/pi/aquestalkpi/AquesTalkPi "強制シャットダウンします" | aplay -D plughw:1,0')
            os.system("sudo shutdown -h now")
            break

        sw_status2 = GPIO.input(23)
        if os.system('pgrep -l youtube-') == 0:
            GPIO.output(25, GPIO.HIGH)
        else:
            GPIO.output(25, GPIO.LOW)

        if sw_status2 == 0:
            GPIO.output(25, GPIO.HIGH)
            if os.system('pgrep -l youtube-') == 256:
                print("starting Youtube streameing...")
                os.system("sudo systemctl stop filetube.service")
                os.system("sudo systemctl start youtube.service")
            else:
                print("starting drive recorder...")
                os.system("sudo systemctl stop youtube.service")
                os.system("sudo systemctl start filetube.service")

        button_previous = button_current
        time.sleep(0.5)

        GPIO.output(24, GPIO.HIGH)

except KeyboardInterrupt:
    print("exiting")
    GPIO.cleanup()
