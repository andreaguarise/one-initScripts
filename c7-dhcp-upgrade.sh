#!/bin/bash

for i in $(ls /etc/sysconfig/network-scripts/ifcfg-*); do  cat $i  | sed -e s/BOOTPROTO=none/BOOTPROTO=dhcp/g > $i; done

service network restart

yum upgrade -y > /tmp/yum-upgrade.log