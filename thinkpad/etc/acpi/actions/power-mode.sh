#!/bin/sh

function turn_on_off_cpu() {
  local value=$1
  local action="turned on"
  if [ "$value" -eq 0 ]; then
    action="turned off"
  fi
  for i in {4..11}; do
    if [ "$(cat /sys/devices/system/cpu/cpu$i/online)" -ne "$value" ]; then
      echo "$value" > /sys/devices/system/cpu/cpu$i/online
      echo "CPU $i $action"
    else
      echo "CPU $i was already $action"
    fi
  done
}

function set_energy_preference() {
  for path in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    if [ -f "$path" ]; then
      echo $1 > "$path"
    fi
  done
}

on_ac_power=$(cat /sys/class/power_supply/AC/online)
if [ "$on_ac_power" -eq 1 ]; then
	echo "Power mode"
	echo 0 > /proc/sys/vm/laptop_mode
	echo 10 > /proc/sys/vm/dirty_ratio
	echo 5 > /proc/sys/vm/dirty_background_ratio
	echo 60000 > /proc/sys/vm/dirty_writeback_centisecs
	for i in /sys/class/scsi_host/*/link_power_management_policy; do
		echo max_performance >"$i"
	done
	modprobe uvcvideo
  turn_on_off_cpu 1
  echo 80 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
  echo 20 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
  set_energy_preference 128
	echo default > /sys/module/pcie_aspm/parameters/policy
  iw dev wlan0 set power_save off
  btmgmt power on
  ethtool -s enp0s31f6 wol g
else
	echo "Battery mode"
	/usr/bin/powertop --auto-tune
	echo 5 > /proc/sys/vm/laptop_mode
	echo 15 > /proc/sys/vm/dirty_ratio
	echo 5 > /proc/sys/vm/dirty_background_ratio
	echo 6000 > /proc/sys/vm/dirty_writeback_centisecs
	for i in /sys/bus/pci/devices/*/power/control; do
		echo auto > "$i"
	done
	for i in /sys/class/scsi_host/*/link_power_management_policy; do
		echo med_power_with_dipm > "$i"
	done
	modprobe -r uvcvideo
  turn_on_off_cpu 0
  echo 20 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
  echo 20 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
  set_energy_preference 225
	echo powersave > /sys/module/pcie_aspm/parameters/policy
  iw dev wlan0 set power_save on
  btmgmt power off
  ethtool -s enp0s31f6 wol d
  rfkill block bluetooth
fi
exit 0
