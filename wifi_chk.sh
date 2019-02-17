#!/bin/sh

## Dependencies
## opkg install msmtp,configured for account gsuite
## opkg install iwinfo
## Set cron to execute every 5 minutes wifi_chk.sh
## Currently checks existence of Signal and Bit Rate

DWAP=ap1.domain.tld
HOST=ap1
MAIL=ALERT@domain.tld
SMS=number@vtext.com

INTFC=wlan0
WAP=`iwinfo | grep ESSID | cut -d\" -f2`
SIGNAL=`iwinfo | grep Signal | cut -d: -f2 | cut -d" " -f2`
BITRATE=`iwinfo | grep "Bit Rate" | cut -d: -f2 | cut -d" " -f2`
TXTBODY=`iwinfo`

## Nested loops, send 3 alerts over 5 minute periods (cron) via email and SMS, then stop.  Reset alerts count to null upon recovery.

if [ "$SIGNAL" = "unknown" ] || [ -z "$SIGNAL" ] && SIGNAL=0 && WAP="$DWAP" && TXTBODY="$DWAP" || [ "$BITRATE" = "unknown" ] || [ -z "$BITRATE" ] && BITRATE=0 && WAP="$DWAP" && TXTBODY="$DWAP"; then
   touch /tmp/wifi-alarms.txt
   MAILCT=`cat /tmp/wifi-alarms.txt`

   if [ -z "$MAILCT" ] && echo 1 > /tmp/wifi-alarms.txt; then
      logread > /tmp/syslogs.txt;                                                                                                                                
      SYSLOG100=`cat /tmp/syslogs.txt | grep -v dnsmasq-dhcp | grep -v crond | grep -v msmtp`;                                                                   
      /bin/rm /tmp/syslogs.txt                                                                                                                                   
      echo -e "From: ALERT@$DWAP\r\nTo: $SMS\r\nSubject: $WAP DOWN\r\n\r\n$WAP\r\nSignal: $SIGNAL dBm\r\nBit Rate: $BITRATE MBit/s." | msmtp -d -a gsuite
      echo -e "From: ALERT@$DWAP\r\nTo: $MAIL\r\nSubject: $WAP DOWN\r\n\r\n$TXTBODY\r\n\r\n$SYSLOG100\r\nDone." | msmtp -d -a gsuite -t
      exit 1

   elif [ "$MAILCT" = 1 ] && echo 2 > /tmp/wifi-alarms.txt; then
      logread > /tmp/syslogs.txt;                                                                                                                                
      SYSLOG100=`cat /tmp/syslogs.txt | grep -v dnsmasq-dhcp | grep -v crond | grep -v msmtp`;                                                                   
      /bin/rm /tmp/syslogs.txt                                                                                                                                   
      echo -e "From: ALERT@$DWAP\r\nTo: $SMS\r\nSubject: $WAP DOWN\r\n\r\n$WAP\r\nSignal: $SIGNAL dBm\r\nBit Rate: $BITRATE MBit/s." | msmtp -d -a gsuite
      echo -e "From: ALERT@$DWAP\r\nTo: $MAIL\r\nSubject: $WAP DOWN\r\n\r\n$TXTBODY\r\n\r\n$SYSLOG100\r\nDone." | msmtp -d -a gsuite -t
      exit 2

   elif [ "$MAILCT" = 2 ] && echo 3 > /tmp/wifi-alarms.txt; then
      logread > /tmp/syslogs.txt;                                                                                                                                
      SYSLOG100=`cat /tmp/syslogs.txt | grep -v dnsmasq-dhcp | grep -v crond | grep -v msmtp`;                                                                   
      /bin/rm /tmp/syslogs.txt                                                                                                                                   
      echo -e "From: ALERT@$DWAP\r\nTo: $SMS\r\nSubject: $WAP DOWN\r\n\r\n$WAP\r\nSignal: $SIGNAL dBm\r\nBit Rate: $BITRATE MBit/s." | msmtp -d -a gsuite
      echo -e "From: ALERT@$DWAP\r\nTo: $MAIL\r\nSubject: $WAP DOWN\r\n\r\n$TXTBODY\r\n\r\n$SYSLOG100\r\nDone." | msmtp -d -a gsuite -t
      exit 3

   elif [ "$MAILCT" = 3 ]; then 
      exit 4 
   fi

else /bin/rm -f /tmp/wifi-alarms.txt

fi
