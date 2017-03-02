#!/bin/sh
# echo "please wait..."
# PASSWORD=`cat /dev/urandom | sed 's/[^a-zA-Z0-9]//g'  |strings -n 8| head -n 1`
# echo "root:$PASSWORD" | chpasswd
# echo "password: $PASSWORD"


PASSWORD=`cat /proc/sys/kernel/random/uuid | awk -F '-' '{print $5}'`
echo "root:$PASSWORD" | chpasswd
echo "new password: $PASSWORD"
