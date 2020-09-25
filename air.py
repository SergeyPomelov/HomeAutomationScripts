#!/usr/bin/python3

import miio, sys

monitor_conn = miio.airqualitymonitor.AirQualityMonitor(ip=MONITOR_IP, token=MONITOR_TOKEN, model='cgllc.airmonitor.s1')
st = monitor_conn.status()

json = ("{ " 
+ '"battery": ' +  str(st.battery) + ', ' 
+ '"temperature": ' + str(st.temperature) + ', ' 
+ '"humidity": ' + str(st.humidity) + ', ' 
+ '"co2": ' + str(st.co2) + ', ' 
+ '"pm25": ' + str(st.pm25) + ', '
+ '"tvoc": ' + str(st.tvoc) + ' }')

print(json)