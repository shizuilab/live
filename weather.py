#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os, time, datetime
import urllib.request
import pprint
import json
import sys

d = datetime.datetime.today()

# Speak Temp and Hum
os.system("sudo date +'%I時%M分' | /home/pi/aquestalkpi/AquesTalkPi -g 100 -f - | aplay -D plughw:1,0")

with open("/var/tmp/temperature.txt", "r") as myfile:
    mytemperature = myfile.read()
    mytext = "気温は摂氏" + mytemperature + "度です"
    os.system('/home/pi/aquestalkpi/AquesTalkPi -g 100 "' + mytext + '" | aplay -D plughw:1,0')
with open("/var/tmp/humidity.txt", "r") as myfile:
    myhumidity = myfile.read()
    mytext = "湿度は" + myhumidity + "パーセントです"
    os.system('/home/pi/aquestalkpi/AquesTalkPi -g 100 "' + mytext + '" | aplay -D plughw:1,0')

# Weather
APP_ID = "dj0zaiZpPUhFckxmNlZqMDRubSZzPWNvbnN1bWVyc2VjcmV0Jng9ZDM-"

# BASE_URL = "http://weather.olp.yahooapis.jp/v1/place"
with open("/var/tmp/lnglat.txt", "r") as myfile:
    tempcoordinates = myfile.read()
if tempcoordinates.find("No") < 0:
    COORDINATES = tempcoordinates
    print(COORDINATES)
else:
    os.system("/home/pi/aquestalkpi/AquesTalkPi -g 100 '位置を測位中です' | aplay -D plughw:1,0")
    sys.exit()

OUTPUT="json"

# Reverse Geocoding from Coodinates
ZIP_BASE_URL = "https://map.yahooapis.jp/geoapi/V1/reverseGeoCoder"
zip_url = ZIP_BASE_URL + "?appid=%s&coordinates=%s&output=%s" % (APP_ID,COORDINATES,OUTPUT)
req = urllib.request.Request(zip_url)
with urllib.request.urlopen(req) as res:
    print(res)
    zip_json_tree = json.load(res)
    print(zip_json_tree)
name = zip_json_tree['Feature'][0]['Property']['Address']
print(name)

if len(name) > 0:
    os.system('/home/pi/aquestalkpi/AquesTalkPi -g 100 "' + name + '" | aplay -D plughw:1,0')
else:
    os.system("/home/pi/aquestalkpi/AquesTalkPi -g 100 '住所を特定できません' | aplay -D plughw;1,0")
    sys.exit()

# Weather forcast from Coordinates
BASE_URL = "https://map.yahooapis.jp/weather/V1/place"
url = BASE_URL + "?appid=%s&coordinates=%s&output=%s" % (APP_ID,COORDINATES,OUTPUT)
req = urllib.request.Request(url)
with urllib.request.urlopen(req) as res:
    json_tree = json.load(res)

for var in range(0,7):
    date     = json_tree['Feature'][0]['Property']['WeatherList']['Weather'][var]['Date']
    rainfall = json_tree['Feature'][0]['Property']['WeatherList']['Weather'][var]['Rainfall']
    type     = json_tree['Feature'][0]['Property']['WeatherList']['Weather'][var]['Type']
    #print("%s,%s,%s"%(date,rainfall,type))
    rain_level = ""
    talk = ""
    if (rainfall == 0.0):
        rain_level = "雨は降"
    elif (rainfall < 5.0) :
        rain_level = "雨がちょっと降"
    elif (rainfall < 10.0):
        rain_level = "雨が結構降"
    elif (rainfall < 20.0):
        rain_level = "やや強い雨が降"
    elif (rainfall < 30.0):
        rain_level = "土砂降りの雨が降"
    elif (rainfall < 50.0):
        rain_level = "激しい雨が降"
    elif (rainfall < 80.0):
        rain_level = "非常に激しい雨が降"
    elif (rainfall >= 80.0):
        rain_level = "猛烈な雨が降"

    if type == "observation" :
        time = "今、"
        if rainfall == 0.0:
            suffix = "っていません"
            talk = time + rain_level + suffix
        else:
            suffix = "っています"
            talk = time + rain_level + suffix
    else:
        time = str(var * 10) + "分後に、"
        if rainfall == 0.0:
            # suffix = "りません。"
            talk = ""
        else:
            suffix = "りそうです。"
            talk = time + rain_level + suffix

    #print talk
    if len(talk) > 0:
        os.system('/home/pi/aquestalkpi/AquesTalkPi -g 100 "' + talk + '" | aplay -D plughw:1,0')

