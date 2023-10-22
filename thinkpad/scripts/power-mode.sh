#!/bin/sh

if [ "$1" == "battery" ]; then
	logger "La computadora está en modo batería."

	# Ajustes de energía en modo batería
	/usr/bin/powertop --auto-tune
	echo 5 >/proc/sys/vm/laptop_mode
	echo 10 >/proc/sys/vm/dirty_ratio
	echo 3 >/proc/sys/vm/dirty_background_ratio
	echo 15000 >/proc/sys/vm/dirty_writeback_centisecs

	echo enabled | tee /sys/bus/usb/devices/{usb1,usb2}/power/wakeup
	echo powersave >/sys/module/pcie_aspm/parameters/policy

	echo auto >/sys/block/sda/device/power/control

	echo auto | tee /sys/bus/i2c/devices/{i2c-0,i2c-1,i2c-2}/device/power/control

	echo med_power_with_dipm | tee /sys/class/scsi_host/*/link_power_management_policy

	echo auto | tee /sys/bus/pci/devices/0000:00:17.0/{ata1,ata2,ata3}/power/control

	modprobe -r uvcvideo

	echo powersave >/sys/module/pcie_aspm/parameters/policy
	iw dev wlan0 set power_save on
	ethtool -s enp0s31f6 wol d
	rfkill block bluetooth

	# Aplicar configuraciones
	sysctl -p /home/think-crag/Git/dotfiles/thinkpad/scripts/98-power-saving.conf

	echo auto | tee /sys/bus/pci/devices/{0000:00:00.0,0000:00:12.0,0000:00:14.0,0000:00:14.2,0000:00:17.0,0000:00:1f.0,0000:00:1f.5,0000:00:1f.6,0000:01:00.0,0000:02:00.0,0000:52:00.0}/power/control
elif [ "$1" == "ac" ]; then
	logger "La computadora está en modo AC (corriente alterna)."

	# Ajustes de energía en modo AC
	echo 0 >/proc/sys/vm/laptop_mode
	echo 50 >/proc/sys/vm/dirty_ratio
	echo 5 >/proc/sys/vm/dirty_background_ratio
	echo 5000 >/proc/sys/vm/dirty_writeback_centisecs

	echo disabled | tee /sys/bus/usb/devices/{usb1,usb2}/power/wakeup
	echo performance >/sys/module/pcie_aspm/parameters/policy

	echo on >/sys/block/sda/device/power/control

	echo on | tee /sys/bus/i2c/devices/{i2c-0,i2c-1,i2c-2}/device/power/control

	echo max_performance | tee /sys/class/scsi_host/*/link_power_management_policy

	echo on | tee /sys/bus/pci/devices/0000:00:17.0/{ata1,ata2,ata3}/power/control

	modprobe uvcvideo

	echo performance >/sys/module/pcie_aspm/parameters/policy
	iw dev wlan0 set power_save off
	ethtool -s enp0s31f6 wol g
	rfkill unblock bluetooth

	# Aplicar configuraciones de rendimiento
	sysctl -p /home/think-crag/Git/dotfiles/thinkpad/scripts/99-performance.conf

	echo on | tee /sys/bus/pci/devices/{0000:00:00.0,0000:00:12.0,0000:00:14.0,0000:00:14.2,0000:00:17.0,0000:00:1f.0,0000:00:1f.5,0000:00:1f.6,0000:01:00.0,0000:02:00.0,0000:52:00.0}/power/control
else
	logger "Estado de alimentación desconocido: $1"
fi
