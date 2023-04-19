#!/bin/sh

on_ac_power=$(cat /sys/class/power_supply/AC/online)
if [ "$on_ac_power" -eq 1 ]; then
  echo "Power mode"
  echo 0 > /proc/sys/vm/laptop_mode
  echo 10 > /proc/sys/vm/dirty_ratio
  echo 5 > /proc/sys/vm/dirty_background_ratio
  echo 6000 > /proc/sys/vm/dirty_writeback_centisecs
  echo 0 > /sys/module/snd_hda_intel/parameters/power_save
  echo max_performance > /sys/class/scsi_host/host0/link_power_management_policy
  echo max_performance > /sys/class/scsi_host/host1/link_power_management_policy
  echo max_performance > /sys/class/scsi_host/host2/link_power_management_policy
  modprobe uvcvideo
  echo default > /sys/module/pcie_aspm/parameters/policy
else
  echo "Battery mode"
  echo 5 > /proc/sys/vm/laptop_mode
  echo 90 > /proc/sys/vm/dirty_ratio
  echo 1 > /proc/sys/vm/dirty_background_ratio
  echo 60000 > /proc/sys/vm/dirty_writeback_centisecs
  echo 10 > /sys/module/snd_hda_intel/parameters/power_save
  echo min_power > /sys/class/scsi_host/host0/link_power_management_policy
  echo min_power > /sys/class/scsi_host/host1/link_power_management_policy
  echo min_power > /sys/class/scsi_host/host2/link_power_management_policy
  modprobe -r uvcvideo
  echo powersave > /sys/module/pcie_aspm/parameters/policy
fi

