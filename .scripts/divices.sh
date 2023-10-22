#!/bin/bash

# Iterar a través de los archivos en /sys/bus/pci/devices/*/power/control
for file in /sys/bus/pci/devices/*/power/control; do
	# Leer y mostrar el valor actual del archivo
	power_control_value=$(cat "$file")

	# Imprimir el nombre del dispositivo y su valor de control de energía
	echo "$file $power_control_value"
done
