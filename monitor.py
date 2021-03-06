#!/usr/bin/python3
# -*- coding: utf-8 -*-

import RPi.GPIO as GPIO
import sys, os, time, ipget
import Adafruit_SSD1306

from PIL import Image, ImageDraw, ImageFont

import datetime

GPIO.setmode(GPIO.BCM)

# Raspberry Pi pin configuration
RST = 21

disp = Adafruit_SSD1306.SSD1306_128_64(rst=RST)

# Initialize library.
disp.begin()

# Clear display.
disp.clear()
disp.display()

# Create blank image for drawing.
# Make sure to create image with mode '1' for 1-bit color.
width = disp.width
height = disp.height
image = Image.new('1', (width, height))

# Get drawing object to draw on image.
draw = ImageDraw.Draw(image)

# Draw a black filled box to clear the image.
draw.rectangle((0,0,width,height), outline=0, fill=0)

font = ImageFont.truetype('/usr/share/fonts/truetype/noto/NotoMono-Regular.ttf', 12, encoding='unic')

try:
    while True:
        # Get time and date
        d = datetime.datetime.today()
        mydate = d.strftime("%m/%d-")
        mytime = d.strftime("%H:%M:%S")

        # Get IP address
        ip=ipget.ipget()

        #draw.rectangle((0,0,width,height), outline=0, fill=0)

        mystring= mydate + mytime
        draw.text((0,0), mystring, font=font, fill=255)
        draw.text((0,20), ip.ipaddr('wlan0') , font=font, fill=255)
        draw.text((0,40), ip.ipaddr('eth0') , font=font, fill=255)

        disp.image(image)
        disp.display()

        time.sleep(1)

except KeyboardInterrupt:
    print('exiting...')
    sys.exit()
