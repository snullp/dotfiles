#!/bin/sh

free -m

sensors

for f in `ls /dev/sd?`
do
echo $f:
sudo smartctl -l scttempsts $f | grep Temperature | head -n 3
done
