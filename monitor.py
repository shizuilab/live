#!/usr/bin/python3
# -*- coding: utf-8 -*-

#import RPi.GPIO as GPIO
import sys, os, time, serial

from board import SCL, SDA
import busio
import adafruit_ssd1306

from PIL import Image, ImageDraw, ImageFont

import datetime

#GPIO.setmode(GPIO.BCM)
i2c = busio.I2C(SCL, SDA)

disp = adafruit_ssd1306.SSD1306_I2C(128,64,i2c)

# Clear display.
disp.fill(0)
disp.show()

# Create blank image for drawing.
# Make sure to create image with mode '1' for 1-bit color.
width = disp.width
height = disp.height
image = Image.new('1', (width, height))

# Get drawing object to draw on image.
draw = ImageDraw.Draw(image)

# Draw a black filled box to clear the image.
draw.rectangle((0,0,width,height), outline=0, fill=0)

font = ImageFont.truetype('/usr/share/fonts/truetype/noto/NotoMono-Regular.ttf', 14, encoding='unic')

# Open Serial Port
try:
    ser = serial.Serial('/dev/ttyACM0', 9600, timeout=0.1)
except Exception as e:
    print(str(type(e)))
    draw.text((0,0), ip.ipaddr('eth0') , font=font, fill=255)
    draw.text((0,20), ip.ipaddr('wlan0') , font=font, fill=255)
    draw.text((0,40), "Serial ERROR", font=font, fill=255)
    disp.image(image)
    disp.show()
    sys.exit()

# Send Message to Arduino
ser.write(b'Hello VT250F')
print("Hello VT250F  ")
time.sleep(1)

#main loop
try:
    while True:

        # Get time and date
        d = datetime.datetime.today()
        mydate = d.strftime("%m/%d-")
        mytime = d.strftime("%H:%M:%S")

        # Read IP Address
        with open("/var/tmp/ipaddress.txt", "r") as myfile:
            ipaddress = myfile.read()

        # Get USB Serial Data
        try:
            String_data = ser.readline().decode('utf-8')
            #Junk_data = ser.read_all()
        except Exception as e:
            String_data = "SerialError";
            print(str(type(e)))
            sys.exit()

        print(String_data)
        if(len(String_data) > 18):
          with open("/var/tmp/speed.txt", "w") as myfile:
            myfile.write(String_data)



        draw.rectangle((0, 0, width, height), outline=0, fill=0)

        mystring= mydate + mytime
        draw.text((0,0), mystring, font=font, fill=255)
        draw.text((0,20), ipaddress, font=font, fill=255)
        draw.text((0,40), String_data, font=font, fill=255)

        disp.image(image)
        disp.show()

        time.sleep(0.1)

except KeyboardInterrupt:
    print('exiting...')
    ser.close()
    sys.exit()

