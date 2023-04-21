#!/bin/sh

on_ac_power=$(cat /sys/class/power_supply/AC/online)
if [ "$on_ac_power" -eq 1 ]; then
  echo "Power mode"
  echo 0 > /proc/sys/vm/laptop_mode
  echo 10 > /proc/sys/vm/dirty_ratio
  echo 5 > /proc/sys/vm/dirty_background_ratio
  echo 6000 > /proc/sys/vm/dirty_writeback_centisecs
  for i in /sys/class/scsi_host/*/link_power_management_policy ; do
    echo max_performance > ${i}
  done
  echo 0 > /sys/module/snd_hda_intel/parameters/power_save
  modprobe uvcvideo
  echo default > /sys/module/pcie_aspm/parameters/policy
else
  echo "Battery mode"
  /usr/bin/powertop --auto-tune
  echo 5 > /proc/sys/vm/laptop_mode
  echo 90 > /proc/sys/vm/dirty_ratio
  echo 1 > /proc/sys/vm/dirty_background_ratio
  echo 60000 > /proc/sys/vm/dirty_writeback_centisecs
  # Runtime power management for I2C devices
  # for i in /sys/bus/i2c/devices/*/device/power/control ; do
  #   echo auto > ${i}
  # done

  # Runtime power-management for PCI devices
  for i in /sys/bus/pci/devices/*/power/control ; do
    echo auto > ${i}
  done

  # Runtime power-management for USB devices
  # for i in /sys/bus/usb/devices/*/power/control ; do
  #   echo auto > ${i}
  # done

  # Low power SATA
  for i in /sys/class/scsi_host/*/link_power_management_policy ; do
    echo min_power > ${i}
  done
  echo 1 > /sys/module/snd_hda_intel/parameters/power_save
  modprobe -r uvcvideo
  echo powersave > /sys/module/pcie_aspm/parameters/policy
fi
exit 0
