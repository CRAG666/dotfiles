#!/bin/sh

turn_on_off_cpu() {
	_turn_on_off_cpu_value=$1
	_turn_on_off_cpu_action="turned on"
	if [ "$_turn_on_off_cpu_value" -eq 0 ]; then
		_turn_on_off_cpu_action="turned off"
	fi
	i=4
	while [ "$i" -le 11 ]; do
		if [ "$(cat /sys/devices/system/cpu/cpu"$i"/online)" -ne "$_turn_on_off_cpu_value" ]; then
			echo "$_turn_on_off_cpu_value" >/sys/devices/system/cpu/cpu"$i"/online
			echo "CPU $i $_turn_on_off_cpu_action"
		else
			echo "CPU $i was already $_turn_on_off_cpu_action"
		fi
		i=$((i + 1))
	done
}

set_energy_preference() {
	for path in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
		if [ -f "$path" ]; then
			echo "$1" >"$path"
		fi
	done
}

on_ac_power=$(cat /sys/class/power_supply/AC/online)
if [ "$on_ac_power" -eq 1 ]; then
	echo "Power mode"
	sysctl -p /etc/acpi/actions/99-performance.conf
	echo 0 >/proc/sys/vm/laptop_mode
	echo 10 >/proc/sys/vm/dirty_ratio
	echo 5 >/proc/sys/vm/dirty_background_ratio
	echo 60000 >/proc/sys/vm/dirty_writeback_centisecs
	for i in /sys/class/scsi_host/*/link_power_management_policy; do
		echo max_performance >"$i"
	done
	modprobe uvcvideo
	turn_on_off_cpu 1
	echo 85 >/sys/devices/system/cpu/intel_pstate/max_perf_pct
	echo 20 >/sys/devices/system/cpu/intel_pstate/min_perf_pct
	set_energy_preference 115
	echo default >/sys/module/pcie_aspm/parameters/policy
	iw dev wlan0 set power_save off
	btmgmt power on
	ethtool -s enp0s31f6 wol g
else
	echo "Battery mode"
	sysctl -p /etc/acpi/actions/98-power-saving.conf
	/usr/bin/powertop --auto-tune
	echo 5 >/proc/sys/vm/laptop_mode
	echo 15 >/proc/sys/vm/dirty_ratio
	echo 5 >/proc/sys/vm/dirty_background_ratio
	echo 6000 >/proc/sys/vm/dirty_writeback_centisecs
	for i in /sys/bus/pci/devices/*/power/control; do
		echo auto >"$i"
	done
	for i in /sys/class/scsi_host/*/link_power_management_policy; do
		echo med_power_with_dipm >"$i"
	done
	modprobe -r uvcvideo
	turn_on_off_cpu 0
	echo 30 >/sys/devices/system/cpu/intel_pstate/max_perf_pct
	echo 30 >/sys/devices/system/cpu/intel_pstate/min_perf_pct
	set_energy_preference 225
	echo powersave >/sys/module/pcie_aspm/parameters/policy
	iw dev wlan0 set power_save on
	btmgmt power off
	ethtool -s enp0s31f6 wol d
	rfkill block bluetooth
fi
exit 0
