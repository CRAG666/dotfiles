#!/bin/sh

on_ac_power=$(cat /sys/class/power_supply/AC/online)
if [ "$on_ac_power" -eq 1 ]; then
	echo "Power mode"

	# cat /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_available_preferences

  # Enable disbled cpu
  for i in {4..11}; do
    echo 1 > /sys/devices/system/cpu/cpu$i/online
  done

  echo 80 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
  echo 20 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
  echo  0 > /sys/devices/system/cpu/intel_pstate/no_turbo

	# The Energy Performance Preference (EPP)
	# These 4 numbers when written translate like so:
	# Number 	EPP
	# 0 	  performance
	# 128 	balance_performance
	# 192 	balance_power
	# 255 	power               *
	# The numbers above are only suggestions, you can use the value that best suits your needs
	echo "128" > /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
  # See scaling governor available cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
  echo "performance" > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
  echo 1 > /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost

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
	echo 6000 > /proc/sys/vm/dirty_writeback_centisecs

	# The following line of code uses a for loop to iterate over all SCSI device power management policy files.
	# For each file, the value is changed to "max_performance", which means that the power policy is set to maximum performance.
	for i in /sys/class/scsi_host/*/link_power_management_policy; do
		echo max_performance >"$i"
	done

	# The following line of code changes the value of the "power_save" parameter to 0 in the /sys/module/snd_hda_intel/parameters file,
	# which means that power-saving is turned off for the Intel sound driver.
	echo 0 > /sys/module/snd_hda_intel/parameters/power_save

	# The following line of code loads the "uvcvideo" module, which is a video driver for devices that comply with the USB Video Class.
	modprobe uvcvideo

	# The following line of code changes the value of the "policy" parameter to "default" in the /sys/module/pcie_aspm/parameters file,
	# which means that the PCIe power management policy is set to the default value.
	echo default > /sys/module/pcie_aspm/parameters/policy
else
	echo "Battery mode"

	# See https://github.com/fenrus75/powertop
	/usr/bin/powertop --auto-tune

  # Disable some cpu, this is workable on high end computers, check your workflow for this
  for i in {4..11}; do
    echo 0 > /sys/devices/system/cpu/cpu$i/online
  done

  echo 25 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
  echo 25 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
  echo  1 > /sys/devices/system/cpu/intel_pstate/no_turbo

	# The Energy Performance Preference (EPP)
	# These 4 numbers when written translate like so:
	# Number 	EPP
	# 0 	  performance          *
	# 128 	balance_performance
	# 192 	balance_power
	# 255 	power
	# The numbers above are only suggestions, you can use the value that best suits your needs
	echo "225" > /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
  echo "powersave" > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
  echo 0 > /sys/devices/system/cpu/intel_pstate/hwp_dynamic_boost

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

	# The following line of code uses a for loop to iterate over all SCSI device power management policy files.
	# For each file, the value is changed to "min_power", which means that the power policy is set to minimum power usage.
	for i in /sys/class/scsi_host/*/link_power_management_policy; do
		echo min_power > "$i"
	done

	# The following line of code changes the value of the "power_save" parameter to 1 in the /sys/module/snd_hda_intel/parameters file,
	# which means that power-saving is turned on for the Intel sound driver.
	echo 1 > /sys/module/snd_hda_intel/parameters/power_save

	# The following line of code removes the "uvcvideo" module, which is a video driver for devices that comply with the USB Video Class.
	modprobe -r uvcvideo

	# The following line of code changes the value of the "policy" parameter to "powersave" in the /sys/module/pcie_aspm/parameters file,
	# which means that the PCIe power management policy is set to power-saving.
	echo powersave > /sys/module/pcie_aspm/parameters/policy

  # Disable Bluetooth
  rfkill block bluetooth

fi
exit 0
