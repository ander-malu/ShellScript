#!/bin/bash


echo "=== Change SSH port to 2259 ==="
echo " "
sleep 3

sed -i 's/#Port [0-9]\+$/Port 2259/' /etc/ssh/sshd_config

#Check the change
/etc/init.d/ssh restart && sleep 1 && /etc/init.d/ssh status

exit
