#!/bin/sh

#  jetty8_1_7.sh
#  
#
#  Created by Andrea Guarise on 7/1/15.
#


rpm -Uvh http://central.maven.org/maven2/org/mortbay/jetty/dist/jetty-rpm/8.1.7.v20120910/jetty-rpm-8.1.7.v20120910.rpm &> /tmp/jetty8_1_7.log

if [ $? = 0 ]; then
 echo "Jetty 8.1.7 succesfully installed" &> /tmp/jetty8_1_7.log
fi