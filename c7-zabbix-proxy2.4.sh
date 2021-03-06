#!/bin/sh

#  c7-ZabbixServer2.4.sh
#
#
#  Created by Andrea Guarise on 7/8/15.
#
# Needs: $ZABBIXDB $ZABBIXPWD(*) $MYSQLROOT(*) $ZABBIX_SERVICE_NAME
# (*): REQUIRED

LOGFILE=/tmp/zabbix-server.log

##Install Zabbix repo

rpm -i http://repo.zabbix.com/zabbix/2.4/rhel/7/x86_64/zabbix-release-2.4-1.el7.noarch.rpm >> $LOGFILE 2>&1

yum update >> $LOGFILE 2>&1

yum install -y zabbix-proxy.x86_64 zabbix-web-mysql.noarch

Z_DB=zabbix_proxy
if [ -z ${ZABBIXDB} ]; then
echo "Setting MySQL zabbix database as default: ${Z_DB}" >> $LOGFILE 2>&1
else
Z_DB=$ZABBIXDB
echo "Setting MySQL zabbix database as specified by user: $Z_DB" >> $LOGFILE 2>&1
fi

if [ -z ${ZABBIXPWD} ]; then
echo "Zabbix password must not be null" >> $LOGFILE 2>&1
fi

mysql -uroot -p$MYSQLROOT -e "create database $Z_DB character set utf8" >> $LOGFILE 2>&1

mysql -uroot -p$MYSQLROOT -e "grant all privileges on $Z_DB.* to zabbix@'localhost' identified by \"$ZABBIXPWD\"" >> $LOGFILE 2>&1
mysql -uroot -p$MYSQLROOT -e "FLUSH PRIVILEGES" >> $LOGFILE 2>&1

mysql -u zabbix -p$ZABBIXPWD ${Z_DB} < /usr/share/doc/zabbix-proxy-mysql-2.4.7/create/schema.sql

sed -e "s/DBName=zabbix/DBName=$Z_DB/g;s/# DBPassword=/DBPassword=$ZABBIXPWD/g" /etc/zabbix/zabbix_proxy.conf > /etc/zabbix/zabbix_proxy.conf.new
mv -f /etc/zabbix/zabbix_proxy.conf.new /etc/zabbix/zabbix_proxy.conf

service zabbix-proxy start >> $LOGFILE 2>&1
chkconfig zabbix-proxy on >> $LOGFILE 2>&1


#open zabbix proxy port

firewall-cmd --zone=public --add-port=10051/tcp --permanent >> $LOGFILE 2>&1

firewall-cmd --reload >> $LOGFILE 2>&1