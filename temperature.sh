#!/bin/sh

sensors

for f in `ls /dev/sd?`
do
echo $f:
sudo smartctl -a $f | grep Temperature | awk '{print $10,$11,$12}'
done
