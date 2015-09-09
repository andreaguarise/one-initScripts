#!/bin/sh

#  java7.sh
#
#
#  Created by Andrea Guarise on 7/1/15.
#

yum install -y java-1.7.0 &> /tmp/java7.log

alternatives --display java | grep "points to" | grep 1.7.0

if [ $? = 0 ]; then
echo "Java 1.7.0 correctly installed and configured" &> /tmp/java7.log
fi




