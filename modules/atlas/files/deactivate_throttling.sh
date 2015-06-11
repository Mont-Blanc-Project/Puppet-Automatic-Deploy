#!/bin/bash

PROC_COUNT=$1

i=0
while [ $i -lt $PROC_COUNT ]
do
	echo performance > /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_governor
	i=$(( $i + 1 ))
done
