#!/bin/bash

#  c7-mysql-server.sh
#  
#
#  Created by Andrea Guarise on 7/1/15.
#
#USes: MYSQLDATADIR MYSQLROOT

LOGFILE=/tmp/mysql.log
DBPWD="myPWD"
DATADIR=/var/lib/mysql

source /mnt/context.sh


if [ -n "${MYSQLROOT}" ]; then
echo "Setting MySQL root password as specified by user" >> $LOGFILE 2>&1
DBPWD=$MYSQLROOT
fi


rpm -Uvh https://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm >> $LOGFILE 2>&1

echo "Installing MYSQL Server" >> $LOGFILE
yum -y install mysql-server >> $LOGFILE 2>&1

if [ -n "${MYSQLDATADIR}" ]; then
echo "Using datadir specified by user: ${MYSQLDATADIR}"
DATADIR=${MYSQLDATADIR}
sed -e "s@datadir=\/var\/lib\/mysql@datadir=${DATADIR}@g" /etc/my.cnf > /etc/my.cnf.new
mv -f /etc/my.cnf.new /etc/my.cnf
chown mysql:mysql ${DATADIR}
fi

service mysqld start >> $LOGFILE 2>&1
chkconfig --level 345 mysqld on >> $LOGFILE 2>&1
mysqladmin -u root password "$DBPWD" >> $LOGFILE 2>&1


