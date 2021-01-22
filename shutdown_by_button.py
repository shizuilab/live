#!/usr/bin/python
# -*- coding: utf-8 -*-

import RPi.GPIO as GPIO
import os, time
#from pijuice import PiJuice
#import Adafruit_SSD1306

#import Image
#import ImageDraw
#import ImageFont

GPIO.setmode(GPIO.BCM)

#pj = PiJuice(1, 0x14)

# Raspberry Pi pin configuration
#RST = 24
#disp = Adafruit_SSD1306.SSD1306_128_64(rst=RST)

# Initialize library.
#disp.begin()

# Clear display.
#disp.clear()
#disp.display()

# Create blank image for drawing.
# Make sure to create image with mode '1' for 1-bit color.
#width = disp.width
#height = disp.height
#image = Image.new('1', (width, height))

# Get drawing object to draw on image.
#draw = ImageDraw.Draw(image)

# Draw a black filled box to clear the image.
#draw.rectangle((0,0,width,height), outline=0, fill=0)

#font = ImageFont.truetype('/usr/share/fonts/truetype/kochi/kochi-gothic-subst.ttf', 16, encoding='unic')

# GPIO6 : shutdown button = second raw of AIY shield
GPIO.setup(6, GPIO.IN, pull_up_down = GPIO.PUD_UP)
while True:
    GPIO.wait_for_edge(6, GPIO.FALLING)
    sw_counter = 0
 
    while True:
        sw_status = GPIO.input(6)
        if sw_status == 0:
            sw_counter = sw_counter + 1
            if sw_counter >= 5:

            # Shutdown Message
                #pj.power.SetPowerOff(30)
                #os.system("sudo systemctl stop meter.service")
                time.sleep(1)

                #draw.rectangle((0,0,width,height), outline=0, fill=0)

                #mystring= u'VT250F'
                #draw.text((0,0), mystring, font=font, fill=255)
                #mystring= u'内部バッテリ'
                #draw.text((0,20), mystring, font=font, fill=255)
                #mystring= u'に接続します'
                #draw.text((0,40), mystring, font=font, fill=255)

                #disp.image(image)
                #disp.display()
                #time.sleep(1)

                #os.system("sudo /home/pi/shutdownVT.sh")
                os.system("sudo shutdown -h now")
                break
        else:
            print("signal not significant")
            break

        time.sleep(0.01)
     
    print(sw_counter)
