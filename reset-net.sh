#!/bin/sh
# centos6 虚拟机重置网卡信息
set -x

ETH=0
MAC=0
declare -u MAC

IFCFG=/etc/sysconfig/network-scripts/ifcfg-eth0

for eth in `ls /sys/class/net`;do
        if [[ $eth == eth* ]]; then
                ETH=$eth
                MAC=`cat /sys/class/net/$eth/address`
                break;
        fi
done

echo "eth: $ETH, mac: $MAC"

grep $ETH $IFCFG && grep $MAC $IFCFG && exit 0

echo "eth change"

echo "DEVICE=$ETH
HWADDR=$MAC
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=dhcp" > $IFCFG
/etc/init.d/network restart
		