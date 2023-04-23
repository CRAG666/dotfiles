# For Thinkpad's lovers

I am a Thinkpad user since 2017, One of the most recurring problems is the battery life, I tried everything, until I finally achieved the results I wanted.
This configuration is applicable for any thinkpad except for some exceptions(I will specify if it applies or not to older thinkpads)

Note: This has been tested on the thinkpad l450, t440p and thinkpad p53. If you have any other thinkpads that these settings helped please add pr.

## Power Management

### Auto-cpufreq

Install [auto-cpufreq](https://github.com/AdnanHodzic/auto-cpufreq), Excecute this:

```bash
sudo systemctl --now enable auto-cpufreq
```

With these packages you will already have a significant improvement in the duration of your battery.

Note: If you see that the battery life is still the same, it may be due to the frequency driver you use, I understand that the default is `intel_pstate`, so just disable it from the kernel parameters `intel_pstate=disable`

### Using Energy Performance(EPP)

If your computer supports the intel_pstate module, you can use the following instead of auto-cpufreq:

In the script I provide in the section [further-optimize-energy-management](#further-optimize-energy-management), uncomment the following for loops `for i in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference ; do`, remember to adjust according to your needs

Note:

    * See https://community.frame.work/t/guide-linux-battery-life-tuning/6665/203

    * See https://www.kernel.org/doc/html/latest/admin-guide/pm/intel_pstate.html#energy-vs-performance-hints

### Other things that may be useful

Install [ananicy-cpp](https://gitlab.com/ananicy-cpp/ananicy-cpp)(optional) and thermald. Excecute this:

```bash
sudo systemctl --now enable ananicy-cpp thermald
```

### For the intrepid

If you are still not satisfied with the battery life, you can do some additional configurations:

Install [tpacpi-bat](https://github.com/teleshoes/tpacpi-bat), acpi_call and [acpid](https://wiki.archlinux.org/title/acpid). Excecute this:

```bash
sudo systemctl --now enable tpacpi-bat acpid
```

Note: tpacpi-bat is for more modern thinkpads, if you have a thinkpad before Ivy Bridge processors use tp_smapi

#### Config battery charging thresholds

Edit or Create this `/etc/conf.d/tpacpi`. Use the thresholds according to your needs. These are my settings:

```
# battery is 1 for main, 2 for secondary, or 0 for either/both
BATTERY="0"

# Start charging threshold (0 for default, 1-99 for percent)
START_THRESHOLD="40"

# Stop charging threshold (0 for default, 1-99 for percent)
STOP_THRESHOLD="80"
```

Run this to apply the changes

```bash
sudo systemctl restart tpacpi-bat
```

#### Further optimize energy management

Edit or Create this `/etc/acpi/events/battery_event`:

```
event=battery.*
action=/etc/acpi/actions/battery.sh
```

Create script:

```bash
#!/bin/sh

on_ac_power=$(cat /sys/class/power_supply/AC/online)
if [ "$on_ac_power" -eq 1 ]; then
	echo "Power mode"

	# The Energy Performance Preference (EPP)
	# These 4 numbers when written translate like so:
	# Number 	EPP
	# 0 	  performance
	# 128 	balance_performance
	# 192 	balance_power
	# 255 	power               *
	# The numbers above are only suggestions, you can use the value that best suits your needs
	# for i in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference ; do
	#     echo "0" > ${i}
	# done

	# The following line of code changes the value of the "laptop_mode" parameter to 0 in the /proc/sys/vm file,
	# which means that the laptop mode that adjusts the system to save power and extend battery life is turned off.
	echo 0 >/proc/sys/vm/laptop_mode

	# The following line of code changes the value of the "dirty_ratio" parameter to 10 in the /proc/sys/vm file,
	# which means that the threshold for the percentage of dirty memory that can be used by applications before the kernel
	# starts to free it asynchronously is set.
	echo 10 >/proc/sys/vm/dirty_ratio

	# The following line of code changes the value of the "dirty_background_ratio" parameter to 5 in the /proc/sys/vm file,
	# which means that the threshold for the percentage of dirty memory that can be used in the background
	# before the kernel starts to free it asynchronously is set.
	echo 5 >/proc/sys/vm/dirty_background_ratio

	# The following line of code changes the value of the "dirty_writeback_centisecs" parameter to 6000 in the /proc/sys/vm file,
	# which means that the time that must elapse before the kernel starts writing dirty memory data to the hard drive is set.
	echo 6000 >/proc/sys/vm/dirty_writeback_centisecs

	# The following line of code uses a for loop to iterate over all SCSI device power management policy files.
	# For each file, the value is changed to "max_performance", which means that the power policy is set to maximum performance.
	for i in /sys/class/scsi_host/*/link_power_management_policy; do
		echo max_performance >"$i"
	done

	# The following line of code changes the value of the "power_save" parameter to 0 in the /sys/module/snd_hda_intel/parameters file,
	# which means that power-saving is turned off for the Intel sound driver.
	echo 0 >/sys/module/snd_hda_intel/parameters/power_save

	# The following line of code loads the "uvcvideo" module, which is a video driver for devices that comply with the USB Video Class.
	modprobe uvcvideo

	# The following line of code changes the value of the "policy" parameter to "default" in the /sys/module/pcie_aspm/parameters file,
	# which means that the PCIe power management policy is set to the default value.
	echo default >/sys/module/pcie_aspm/parameters/policy
else
	echo "Battery mode"

	# The Energy Performance Preference (EPP)
	# These 4 numbers when written translate like so:
	# Number 	EPP
	# 0 	  performance          *
	# 128 	balance_performance
	# 192 	balance_power
	# 255 	power
	# The numbers above are only suggestions, you can use the value that best suits your needs
	# for i in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference ; do
	#     echo "255" > ${i}
	# done

	# See https://github.com/fenrus75/powertop
	/usr/bin/powertop --auto-tune

	# The following line of code changes the value of the "laptop_mode" parameter to 5 in the /proc/sys/vm file,
	# which means that the system is set to balance power consumption and performance by reducing the number of disk
	# writes and increasing the interval between flushing dirty buffers to disk.
	echo 5 >/proc/sys/vm/laptop_mode

	# The following line of code changes the value of the "dirty_ratio" parameter to 90 in the /proc/sys/vm file,
	# which means that the threshold for the percentage of dirty memory that can be used by applications before the kernel
	# starts to free it asynchronously is set to a higher value, allowing applications to use more memory before it's freed.
	echo 90 >/proc/sys/vm/dirty_ratio

	# The following line of code changes the value of the "dirty_background_ratio" parameter to 1 in the /proc/sys/vm file,
	# which means that the threshold for the percentage of dirty memory that can be used in the background
	# before the kernel starts to free it asynchronously is set to a lower value, allowing the kernel to free memory
	# more aggressively in the background.
	echo 1 >/proc/sys/vm/dirty_background_ratio

	# The following line of code changes the value of the "dirty_writeback_centisecs" parameter to 60000 in the /proc/sys/vm file,
	# which means that the time that must elapse before the kernel starts writing dirty memory data to the hard drive is set to a higher value.
	echo 60000 >/proc/sys/vm/dirty_writeback_centisecs

	# Runtime power management for I2C devices
	# for i in /sys/bus/i2c/devices/*/device/power/control ; do
	#   echo auto > ${i}
	# done

	# The following line of code uses a for loop to iterate over all PCI devices power management control files.
	# For each file, the value is changed to "auto", which means that the power management policy is set to automatic.
	for i in /sys/bus/pci/devices/*/power/control; do
		echo auto >"$i"
	done

	# Runtime power-management for USB devices
	# for i in /sys/bus/usb/devices/*/power/control ; do
	#   echo auto > ${i}
	# done

	# The following line of code uses a for loop to iterate over all SCSI device power management policy files.
	# For each file, the value is changed to "min_power", which means that the power policy is set to minimum power usage.
	for i in /sys/class/scsi_host/*/link_power_management_policy; do
		echo min_power >"$i"
	done

	# The following line of code changes the value of the "power_save" parameter to 1 in the /sys/module/snd_hda_intel/parameters file,
	# which means that power-saving is turned on for the Intel sound driver.
	echo 1 >/sys/module/snd_hda_intel/parameters/power_save

	# The following line of code removes the "uvcvideo" module, which is a video driver for devices that comply with the USB Video Class.
	modprobe -r uvcvideo

	# The following line of code changes the value of the "policy" parameter to "powersave" in the /sys/module/pcie_aspm/parameters file,
	# which means that the PCIe power management policy is set to power-saving.
	echo powersave >/sys/module/pcie_aspm/parameters/policy
fi
exit 0
```

Run this to apply the changes:

```bash
sudo systemctl restart acpid
```

Something that you didn't, was that the script doesn't start when turning on, maybe something didn't configure well, or it had something to do with the event that I used. Anyway I managed to solve it by defining a oneshot in systemd (If you know any other solution you can do a pr):

Create this `/etc/systemd/system/battery-mode.service`

```

[Unit]
Description=Set Battery or AC mode at startup

[Service]
Type=oneshot
ExecStart=/etc/acpi/actions/battery.sh
# disable timeout logic
TimeoutSec=0
#StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
```

Run this to apply the changes:

```bash
sudo systemctl enable battery-mode.service
```

## Fan Control

For a long time I used thinkfan, but for me it is very cumbersome to configure. So I prefer to use [zcfan](https://github.com/cdown/zcfan), a minimalist and easy to configure alternative.

Instal [zcfan](https://github.com/cdown/zcfan) and enable:

```bash
sudo systemctl --now enable zcfan
```

# Note

If you have any suggestion, do not hesitate to do it, maybe you know some other trick that you want to share.
