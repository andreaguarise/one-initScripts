#!/bin/sh

#  c7-ZabbixServer2.4.sh
#  
#
#  Created by Andrea Guarise on 7/8/15.
#
# Needs: $ZABBIXDB $ZABBIXPWD $MYSQLROOT $ZABBIX_SERVICE_NAME

LOGFILE=/tmp/zabbix-server.log

##Install Zabbix repo

rpm -i http://repo.zabbix.com/zabbix/2.4/rhel/7/x86_64/zabbix-release-2.4-1.el7.noarch.rpm >> $LOGFILE 2>&1

yum update >> $LOGFILE 2>&1

yum install -y zabbix-server.x86_64 zabbix-web-mysql.noarch

sed -e "s/# php_value date.timezone Europe\/Riga/php_value date.timezone Europe\/Rome/g" /etc/httpd/conf.d/zabbix.conf > /etc/httpd/conf.d/zabbix.conf.new

mv -f /etc/httpd/conf.d/zabbix.conf.new /etc/httpd/conf.d/zabbix.conf

cat /etc/httpd/conf.d/zabbix.conf >> $LOGFILE 2>&1


Z_DB=zabbix
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

mysql -u zabbix -p$ZABBIXPWD ${Z_DB} < /usr/share/doc/zabbix-server-mysql-2.4.5/create/schema.sql
mysql -u zabbix -p$ZABBIXPWD ${Z_DB} < /usr/share/doc/zabbix-server-mysql-2.4.5/create/images.sql
mysql -u zabbix -p$ZABBIXPWD ${Z_DB} < /usr/share/doc/zabbix-server-mysql-2.4.5/create/data.sql

sed -e "s/DBName=zabbix/DBName=$Z_DB/g;s/# DBPassword=/DBPassword=$ZABBIXPWD/g" /etc/zabbix/zabbix_server.conf > /etc/zabbix/zabbix_server.conf.new
mv -f /etc/zabbix/zabbix_server.conf.new /etc/zabbix/zabbix_server.conf

service zabbix-server start >> $LOGFILE 2>&1
chkconfig zabbix-server on >> $LOGFILE 2>&1


cat > /etc/zabbix/web/zabbix.conf.php << EOL
<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB["TYPE"]                            = 'MYSQL';
\$DB["SERVER"]                  = 'localhost';
\$DB["PORT"]                            = '0';
\$DB["DATABASE"]                        = '$ZABBIXDB';
\$DB["USER"]                            = 'zabbix';
\$DB["PASSWORD"]                        = '$ZABBIXPWD';
// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB["SCHEMA"]                  = '';

\$ZBX_SERVER                            = 'localhost';
\$ZBX_SERVER_PORT               = '10051';
\$ZBX_SERVER_NAME               = '';

\$IMAGE_FORMAT_DEFAULT  = IMAGE_FORMAT_PNG;
?>
EOL

service httpd start >> $LOGFILE 2>&1
chkconfig httpd on >> $LOGFILE 2>&1

firewall-cmd --zone=public --add-port=80/tcp --permanent >> $LOGFILE 2>&1
firewall-cmd --reload >> $LOGFILE 2>&1

## PUBLISH zabbix service on avahi

Z_SERVICE_NAME=zabbix-server
if [ -z ${ZABBIX_SERVICE_NAME} ]; then
echo "Setting service name on AVAHI as default: ${Z_SERVICE_NAME}" >> $LOGFILE 2>&1
else
Z_SERVICE_NAME=$ZABBIX_SERVICE_NAME
echo "Setting MySQL zabbix database as specified by user: $Z_SERVICE_NAME" >> $LOGFILE 2>&1
fi

cat > /etc/avahi/services/$Z_SERVICE_NAME.service << EOL

<!-- See avahi.service(5) for more information about this configuration file -->

<service-group>

<name replace-wildcards="yes">%h</name>

<service>
<type>_$Z_SERVICE_NAME._tcp</type>
<port>10051</port>
</service>

</service-group>
EOL

service avahi-daemon start
chkconfig avahi-daemon on

#open zabbix server port

firewall-cmd --zone=public --add-port=10051/tcp --permanent >> $LOGFILE 2>&1

#open avahi port

firewall-cmd --zone=public --add-port=5353/udp --permanent >> $LOGFILE 2>&1
firewall-cmd --reload >> $LOGFILE 2>&1
