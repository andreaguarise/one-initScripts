#!/bin/sh

#  c7-kaui.sh
#  
#
#  Created by Andrea Guarise on 9/28/15.
#
LOGFILE=/tmp/killbill.log
yum -y install git
yum -y install ruby ruby-devel
yum -y install gcc
yum -y install zlib zlib-devel
yum -y install patch
yum -y install mysql-devel
cd /opt
git clone https://github.com/killbill/killbill-admin-ui.git
cd killbill-admin-ui
gem install bundler
bundle install
cd test/dummy
export RAILS_ENV=development
bundle install
sed -e "s@password: root@password: ${KILLBILLPWD}@g;" ./config/database.yml > ./config/database.yml.new
mv -f ./config/database.yml.new ./config/database.yml

mysql -uroot -p$MYSQLROOT -e "create database kaui character set utf8" >> $LOGFILE 2>&1

mysql -uroot -p$MYSQLROOT -e "grant all privileges on kaui.* to killbill@'localhost' identified by \"$KILLBILLPWD\"" >> $LOGFILE 2>&1
mysql -uroot -p$MYSQLROOT -e "FLUSH PRIVILEGES" >> $LOGFILE 2>&1
rake kaui:install:migrations
rake db:migrate

firewall-cmd --zone=public --add-port=3000/tcp --permanent
firewall-cmd --reload
cat >> config/initializers/killbill_client.rb << EOL
KillBillClient.api_key = 'bob'
KillBillClient.api_secret = 'lazar'
EOL

rails server -b $ETH0_IP >> $LOGFILE 2>&1