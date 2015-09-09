#!/bin/sh

#  c7-kibana4_1_1.sh
#  
#
#  Created by Andrea Guarise on 8/31/15.
#
# Uses ELMASTER
LOGFILE=/tmp/kibana.log
yum -y install wget >> $LOGFILE 2>&1
wget -O /tmp/kibana.tgz https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz >> $LOGFILE 2>&1
cd /tmp
tar xzvf kibana.tgz >> $LOGFILE 2>&1
mv -f kibana-4.1.1-linux-x64 /opt/
sed -e "s@elasticsearch_url: .*\$@elasticsearch_url: \"http://localhost:9200\"@g" /opt/kibana-4.1.1-linux-x64/config/kibana.yml  > /opt/kibana-4.1.1-linux-x64/config/kibana.yml.new
mv -f /opt/kibana-4.1.1-linux-x64/config/kibana.yml.new /opt/kibana-4.1.1-linux-x64/config/kibana.yml
/opt/kibana-4.1.1-linux-x64/bin/kibana >> $LOGFILE 2>&1 &

