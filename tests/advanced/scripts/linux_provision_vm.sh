#!/bin/bash

## Format and Mount Data Disks
for LUN in $(ls /dev/disk/azure/scsi1)
do 
    NUM=$(echo $LUN | grep -o -E "[0-9]+")
    if [ -d "/mnt/data$NUM" ]
    then
        echo "Disk Exists"
    else
        echo "y" | mkfs.ext4 /dev/disk/azure/scsi1/$LUN
        mkdir /mnt/data$NUM
        echo "/dev/disk/azure/scsi1/$LUN /mnt/data$NUM ext4 defaults,nofail 0 0" >>/etc/fstab
    fi
done

mount -a

## Add Softcatadmin user

if id -u "softcatadmin" >/dev/null 2>&1
then
    echo "softcatadmin exists"
else
    useradd -md /home/softcatadmin softcatadmin
    usermod -aG sudo softcatadmin
    echo softcatadmin:${password} | chpasswd
fi
