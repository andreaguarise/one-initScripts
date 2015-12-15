#!/bin/sh

#  c7-killbill.sh
#  
#
#  Created by Andrea Guarise on 9/21/15.
#
#USES KILLBILLPWD

LOGFILE=/tmp/killbill.log
yum -y install wget >> $LOGFILE 2>&1
wget -O /tmp/killbill.war  http://search.maven.org/remotecontent?filepath=org/kill-bill/billing/killbill-profiles-killbill/0.14.0/killbill-profiles-killbill-0.14.0-jetty-console.war >> $LOGFILE 2>&1
wget -O /tmp/ddl.sql http://docs.killbill.io/0.14/ddl.sql
#FIxes a typo in
sed /tmp/ddl.sql -e 's!; \*/$! \*/;!g' > /tmp/ddl.fix.sql

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
mysql -uroot -p$MYSQLROOT $K_DB < /tmp/ddl.fix.sql >> $LOGFILE 2>&1

mkdir /opt/killbill
mv /tmp/killbill.war /opt/killbill/ >> $LOGFILE 2>&1
cd /opt/killbill
java -Dorg.killbill.dao.url=jdbc:mysql://127.0.0.1:3306/killbill -Dorg.killbill.dao.user=killbill -Dorg.killbill.dao.password=$KILLBILLPWD -jar killbill.war >> $LOGFILE 2>&1 &

firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload

#curl -v      -X POST      -u admin:password      -H 'Content-Type: application/json'      -H 'X-Killbill-CreatedBy: admin'      -d '{"apiKey": "bob", "apiSecret": "lazar"}'      "http://127.0.0.1:8080/1.0/kb/tenants" >> $LOGFILE 2>&1



