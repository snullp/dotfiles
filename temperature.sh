#!/bin/sh

sensors

echo /dev/sda:
sudo smartctl -a /dev/sda | grep Temperature | awk '{print $10 $11 $12}'
