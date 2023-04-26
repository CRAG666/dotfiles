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
		echo $1 > "$path"
	done
}

# function set_scaling_governor() {
# 	for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
# 		echo "$1" > "$i"
# 	done
# }

on_ac_power=$(cat /sys/class/power_supply/AC/online)
if [ "$on_ac_power" -eq 1 ]; then
	echo "Power mode"

	# The following line of code changes the value of the "laptop_mode" parameter to 0 in the /proc/sys/vm file,
	# which means that the laptop mode that adjusts the system to save power and extend battery life is turned off.
	echo 0 > /proc/sys/vm/laptop_mode

	# The following line of code changes the value of the "dirty_ratio" parameter to 10 in the /proc/sys/vm file,
	# which means that the threshold for the percentage of dirty memory that can be used by applications before the kernel
	# starts to free it asynchronously is set.
	echo 10 > /proc/sys/vm/dirty_ratio

	# The following line of code changes the value of the "dirty_background_ratio" parameter to 5 in the /proc/sys/vm file,
	# which means that the threshold for the percentage of dirty memory that can be used in the background
	# before the kernel starts to free it asynchronously is set.
	echo 5 > /proc/sys/vm/dirty_background_ratio

	# The following line of code changes the value of the "dirty_writeback_centisecs" parameter to 6000 in the /proc/sys/vm file,
	# which means that the time that must elapse before the kernel starts writing dirty memory data to the hard drive is set.
	echo 600 > /proc/sys/vm/dirty_writeback_centisecs

  echo N > /sys/module/snd_hda_intel/parameters/power_save_controller
  echo 0 > /sys/module/snd_hda_intel/parameters/power_save

	# The following line of code uses a for loop to iterate over all SCSI device power management policy files.
	# For each file, the value is changed to "max_performance", which means that the power policy is set to maximum performance.
	for i in /sys/class/scsi_host/*/link_power_management_policy; do
		echo max_performance >"$i"
	done

	# The following line of code loads the "uvcvideo" module, which is a video driver for devices that comply with the USB Video Class.
	modprobe uvcvideo

	# cat /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_available_preferences

  # Enable disbled cpu
  turn_on_off_cpu 1

  # See scaling governor available cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
  # set_scaling_governor performance

	# The Energy Performance Preference (EPP)
	# These 4 numbers when written translate like so:
	# Number 	EPP
	# 0 	  performance
	# 128 	balance_performance
	# 192 	balance_power
	# 255 	power               *
	# The numbers above are only suggestions, you can use the value that best suits your needs
  set_energy_preference 128

  echo 1 > /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost
  echo 80 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
  echo 20 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
  echo  0 > /sys/devices/system/cpu/intel_pstate/no_turbo

	# The following line of code changes the value of the "policy" parameter to "default" in the /sys/module/pcie_aspm/parameters file,
	# which means that the PCIe power management policy is set to the default value.
	echo default > /sys/module/pcie_aspm/parameters/policy

  # Set WiFi power saving mode to off
  iw dev wlan0 set power_save off
  # Set Bluetooth power saving mode to off
  btmgmt power on
  # Enable Wake-on-LAN
  ethtool -s enp0s31f6 wol g

else
	echo "Battery mode"

	# See https://github.com/fenrus75/powertop
	/usr/bin/powertop --auto-tune

	# The following line of code changes the value of the "laptop_mode" parameter to 5 in the /proc/sys/vm file,
	# which means that the system is set to balance power consumption and performance by reducing the number of disk
	# writes and increasing the interval between flushing dirty buffers to disk.
	echo 5 > /proc/sys/vm/laptop_mode

	# The following line of code changes the value of the "dirty_ratio" parameter to 90 in the /proc/sys/vm file,
	# which means that the threshold for the percentage of dirty memory that can be used by applications before the kernel
	# starts to free it asynchronously is set to a higher value, allowing applications to use more memory before it's freed.
	echo 90 > /proc/sys/vm/dirty_ratio

	# The following line of code changes the value of the "dirty_background_ratio" parameter to 1 in the /proc/sys/vm file,
	# which means that the threshold for the percentage of dirty memory that can be used in the background
	# before the kernel starts to free it asynchronously is set to a lower value, allowing the kernel to free memory
	# more aggressively in the background.
	echo 1 > /proc/sys/vm/dirty_background_ratio

	# The following line of code changes the value of the "dirty_writeback_centisecs" parameter to 60000 in the /proc/sys/vm file,
	# which means that the time that must elapse before the kernel starts writing dirty memory data to the hard drive is set to a higher value.
	echo 60000 > /proc/sys/vm/dirty_writeback_centisecs

	# Runtime power management for I2C devices
	# for i in /sys/bus/i2c/devices/*/device/power/control ; do
	#   echo auto > ${i}
	# done

	# The following line of code uses a for loop to iterate over all PCI devices power management control files.
	# For each file, the value is changed to "auto", which means that the power management policy is set to automatic.
	for i in /sys/bus/pci/devices/*/power/control; do
		echo auto > "$i"
	done

	# Runtime power-management for USB devices
	# for i in /sys/bus/usb/devices/*/power/control ; do
	#   echo auto > ${i}
	# done

  # Intel power saving
  echo Y > /sys/module/snd_hda_intel/parameters/power_save_controller
  echo 10 > /sys/module/snd_hda_intel/parameters/power_save

	# The following line of code uses a for loop to iterate over all SCSI device power management policy files.
	# For each file, the value is changed to "min_power", which means that the power policy is set to minimum power usage.
	for i in /sys/class/scsi_host/*/link_power_management_policy; do
		echo min_power > "$i"
	done

	# The following line of code removes the "uvcvideo" module, which is a video driver for devices that comply with the USB Video Class.
	modprobe -r uvcvideo

  # set_scaling_governor powersave

	# The Energy Performance Preference (EPP)
	# These 4 numbers when written translate like so:
	# Number 	EPP
	# 0 	  performance          *
	# 128 	balance_performance
	# 192 	balance_power
	# 255 	power
	# The numbers above are only suggestions, you can use the value that best suits your needs
  set_energy_preference 255

  # Disable some cpu, this is workable on high end computers, check your workflow for this
  turn_on_off_cpu 0

  echo 0 > /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost
  echo 25 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
  echo 17 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
  echo  1 > /sys/devices/system/cpu/intel_pstate/no_turbo

	# The following line of code changes the value of the "policy" parameter to "powersave" in the /sys/module/pcie_aspm/parameters file,
	# which means that the PCIe power management policy is set to power-saving.
	echo powersave > /sys/module/pcie_aspm/parameters/policy

  # Set WiFi power saving mode to on
  iw dev wlan0 set power_save on
  # Set Bluetooth power saving mode to on
  btmgmt power off
  # Disable Wake-on-LAN
  ethtool -s enp0s31f6 wol d
  # Disable Bluetooth
  rfkill block bluetooth
fi
exit 0
