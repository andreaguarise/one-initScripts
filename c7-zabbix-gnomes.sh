#!/bin/sh

#  c7-zabbix-gnomes.sh
#  
#
#  Created by Andrea Guarise on 7/30/15.
#
# Install set of library and command line tools to interact with zabbix on the CLI

LOGFILE=/tmp/zabbix-gnomes.log

yum install -y git >> $LOGFILE 2>&1

yum install -y  python-pip >> $LOGFILE 2>&1

cd /tmp/

git clone https://github.com/q1x/zabbix-gnomes.git

cp -ax zabbix-gnomes/* /usr/local/bin/

pip install pyzabbix >> $LOGFILE 2>&1

yum install -y gcc >> $LOGFILE 2>&1

cd /tmp/

wget http://effbot.org/downloads/Imaging-1.1.7.tar.gz >> $LOGFILE 2>&1

tar xzvf Imaging-1.1.7.tar.gz >> $LOGFILE 2>&1

yum install -y  python-devel >> $LOGFILE 2>&1

yum install -y libpeg-turbo libjpeg-turbo-devel >> $LOGFILE 2>&1

yum install -y zlib zlib-devel >> $LOGFILE 2>&1

cd Imaging-1.1.7

python setup.py install >> $LOGFILE 2>&1


