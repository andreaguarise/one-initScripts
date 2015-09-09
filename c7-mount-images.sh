#!/bin/sh

#  c7-mount-images.sh
#  
#
#  Created by Andrea Guarise on 7/10/15.
#


for i in $(lsblk  -Pdo NAME,MOUNTPOINT,PKNAME,FSTYPE | grep -v FSTYPE=\"\" | grep -v FSTYPE=\"iso9660\" | sed -e "s/NAME=\"\(.*\)\"\sMOUNT.*/\1/g"); do
mkdir /mnt-$i
FSTYPE=$(lsblk  -Ppdo NAME,FSTYPE | grep $i | sed -e "s/.*FSTYPE=\"\(.*\)\".*/\1/g")
echo "device: $i fstype:$FSTYPE"
echo "/dev/$i /mnt-$i $FSTYPE defaults 1 1" >> /etc/fstab
done

mount -a