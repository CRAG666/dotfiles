#!/bin/sh

# Función para activar/desactivar CPU
turn_on_off_cpu() {
	local _turn_on_off_cpu_value=$1
	local _turn_on_off_cpu_action="turned on"
	if [ "$_turn_on_off_cpu_value" -eq 0 ]; then
		_turn_on_off_cpu_action="turned off"
	fi

	for i in {4..11}; do
		if [ "$(cat "/sys/devices/system/cpu/cpu$i/online")" -ne "$_turn_on_off_cpu_value" ]; then
			echo "$_turn_on_off_cpu_value" >"/sys/devices/system/cpu/cpu$i/online"
			echo "CPU $i $_turn_on_off_cpu_action"
		else
			echo "CPU $i was already $_turn_on_off_cpu_action"
		fi
	done
}

# Función para establecer la preferencia de rendimiento energético
set_energy_preference() {
	for path in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
		if [ -f "$path" ]; then
			echo "$1" >"$path"
		fi
	done
}

if [ "$1" == "battery" ]; then
	logger "La computadora está en modo batería."

	# Ajustes de energía en modo batería
	/usr/bin/powertop --auto-tune
	echo 5 >/proc/sys/vm/laptop_mode
	echo 15 >/proc/sys/vm/dirty_ratio
	echo 5 >/proc/sys/vm/dirty_background_ratio
	echo 6000 >/proc/sys/vm/dirty_writeback_centisecs

	# Ajustes de energía para dispositivos PCI y SCSI
	for i in /sys/bus/pci/devices/*/power/control; do
		echo auto >"$i"
	done

	for i in /sys/class/scsi_host/*/link_power_management_policy; do
		echo med_power_with_dipm >"$i"
	done

	# Desactivar módulo de video USB
	modprobe -r uvcvideo

	# Ajustes de rendimiento de CPU
	echo 40 >/sys/devices/system/cpu/intel_pstate/max_perf_pct
	echo 40 >/sys/devices/system/cpu/intel_pstate/min_perf_pct

	# Establecer preferencia de rendimiento energético
	set_energy_preference 215

	# Ajustes de ahorro de energía PCIe, WiFi y Bluetooth
	echo powersave >/sys/module/pcie_aspm/parameters/policy
	iw dev wlan0 set power_save on
	btmgmt power off

	# Desactivar Wake-on-LAN Ethernet
	ethtool -s enp0s31f6 wol d

	# Bloquear Bluetooth
	rfkill block bluetooth

	# Aplicar configuraciones
	sysctl -p /etc/acpi/actions/98-power-saving.conf

	# Desactivar CPU
	turn_on_off_cpu 0

elif [ "$1" == "ac" ]; then
	logger "La computadora está en modo AC (corriente alterna)."

	# Activar CPU
	turn_on_off_cpu 1

	# Ajustes de energía en modo AC
	echo 0 >/proc/sys/vm/laptop_mode
	echo 10 >/proc/sys/vm/dirty_ratio
	echo 5 >/proc/sys/vm/dirty_background_ratio
	echo 60000 >/proc/sys/vm/dirty_writeback_centisecs

	# Ajustes de rendimiento de CPU
	echo 85 >/sys/devices/system/cpu/intel_pstate/max_perf_pct
	echo 20 >/sys/devices/system/cpu/intel_pstate/min_perf_pct

	# Establecer preferencia de rendimiento energético
	set_energy_preference 115

	# Restaurar política PCIe predeterminada
	echo default >/sys/module/pcie_aspm/parameters/policy

	# Desactivar el ahorro de energía WiFi
	iw dev wlan0 set power_save off

	# Encender Bluetooth
	btmgmt power on

	# Habilitar Wake-on-LAN Ethernet
	ethtool -s enp0s31f6 wol g

	# Aplicar configuraciones de rendimiento
	sysctl -p /etc/acpi/actions/99-performance.conf

else
	logger "Estado de alimentación desconocido: $1"
fi
