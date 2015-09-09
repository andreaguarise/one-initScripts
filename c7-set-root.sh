#!/bin/sh

#  c7-set-root.sh
#  
#
#  Created by Andrea Guarise on 7/8/15.
#

LOGFILE=/tmp/set-root.log

if [ -n ${ROOTPASSWORD} ]; then
echo "Setting root password as specified by user" >> $LOGFILE 2>&1
ROOTPWD=$ROOTPASSWORD
echo -n "$ROOTPWD" | passwd --stdin root >> $LOGFILE 2>&1
else
echo "You need to manually set the root passord" >> $LOGFILE 2>&1
fi


