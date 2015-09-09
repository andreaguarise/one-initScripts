#!/bin/sh

#  java8.sh
#  
#
#  Created by Andrea Guarise on 7/1/15.
#

yum install -y java-1.8.0 &> /tmp/java8.log

java8=`alternatives --display java | grep -v slave | grep 1.8 | cut -d ' ' -f1`
alternatives --set java $java8

alternatives --display java | grep "points to" | grep 1.8.0

if [ $? = 0 ]; then
    echo "Java 1.8.0 correctly installed and configured" &> /tmp/java8.log
fi




