#!/bin/sh

#  c7-kibana_1_4_1.sh
#  
#
#  Created by Andrea Guarise on 8/27/15.
#
LOGFILE=/tmp/kibana.log
wget -O /tmp/kibana.tgz https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz >> $LOGFILE 2>&1
cd /tmp
tar xzvf kibana.tgz >> $LOGFILE 2>&1
mv -f kibana-4.1.1-linux-x64 /opt/ >> $LOGFILE 2>&1
/opt/kibana-4.1.1-linux-x64/bin/kibana & >> $LOGFILE 2>&1