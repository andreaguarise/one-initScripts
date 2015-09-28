#!/bin/sh

#  c7-killbill.sh
#  
#
#  Created by Andrea Guarise on 9/21/15.
#
#USES KILLBILLPWD

LOGFILE=/tmp/killbill.log
yum -y install wget >> $LOGFILE 2>&1
wget -O /tmp/killbill.war  http://search.maven.org/remotecontent?filepath=org/kill-bill/billing/killbill-profiles-killbill/0.14.0/killbill-profiles-killbill-0.14.0.war >> $LOGFILE 2>&1
wget -O /tmp/ddl.sql http://docs.killbill.io/0.14/ddl.sql
#FIxes a typo in
sed /tmp/ddl.sql -e 's!; \*/$! \*/;!g' > /tmp/ddl.fix.sql

cat >> /opt/jetty/start.ini << EOL
# Kill Bill properties
-Dorg.killbill.dao.url=jdbc:mysql://127.0.0.1:3306/killbill
-Dorg.killbill.dao.user=killbill
-Dorg.killbill.dao.password=$KILLBILLPWD
EOL

K_DB=killbill
if [ -z ${KILLBILLDB} ]; then
echo "Setting MySQL killbill database as default: ${K_DB}" >> $LOGFILE 2>&1
else
K_DB=$KILLBILLDB
echo "Setting MySQL killbill database as specified by user: $K_DB" >> $LOGFILE 2>&1
fi

if [ -z ${KILLBILLPWD} ]; then
echo "killbill password must not be null" >> $LOGFILE 2>&1

fi

mysql -uroot -p$MYSQLROOT -e "create database $K_DB character set utf8" >> $LOGFILE 2>&1

mysql -uroot -p$MYSQLROOT -e "grant all privileges on $K_DB.* to killbill@'localhost' identified by \"$KILLBILLPWD\"" >> $LOGFILE 2>&1
mysql -uroot -p$MYSQLROOT -e "FLUSH PRIVILEGES" >> $LOGFILE 2>&1
mysql -uroot -p$MYSQLROOT < /tmp/ddl.fix.sql >> $LOGFILE 2>&1

mv /tmp/killbill.war /opt/jetty/webapps >> $LOGFILE 2>&1

service jetty restart >> $LOGFILE 2>&1

firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload

