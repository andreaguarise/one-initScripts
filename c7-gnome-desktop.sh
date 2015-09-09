#!/bin/sh

#  c7-gnome-desktop.sh
#  
#
#  Created by Andrea Guarise on 7/3/15.
#

LOGFILE=/tmp/desktop.log

yum -y groups install "GNOME Desktop"


if [ -n ${ROOTPASSWORD} ]; then
echo "Setting root password as specified by user" >> $LOGFILE 2>&1
ROOTPWD=$ROOTPASSWORD
echo -n "$ROOTPWD" | passwd --stdin root >> $LOGFILE 2>&1
else
echo "You need to manually set the root passord" >> $LOGFILE 2>&1
fi

systemctl set-default graphical.target >> $LOGFILE 2>&1


