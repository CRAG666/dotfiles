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

### Using Energy Performance(EPP)*

If your computer supports the intel_pstate module, you can use the following instead of auto-cpufreq:

In the script I provide in the section [further-optimize-energy-management](#further-optimize-energy-management), add add this line at the beginning:

```bash
function set_energy_preference() {
  for path in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    if [ -f "$path" ]; then
      echo $1 > "$path"
    fi
  done
}

```

Add this lines below `modprobe uvcvideo` and `modprobe uvcvideo`, remember to adjust according to your needs.

Reference values:

| Number | EPP                 |
| ------ | ------------------- |
| 0      | performance         |
| 128    | balance_performance |
| 192    | balance_power       |
| 255    | power               |

AC:

```bash
    echo 80 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
    echo 20 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
    set_energy_preference 128

```

Battery:

```bash
    echo 25 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
    echo 25 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
    set_energy_preference 225

```


#### For thinkpads with more than 6 physical cores

When you are using the battery it is not necessary to have all the active cores at all times.

Add add this line at the beginning:

```bash
function turn_on_off_cpu() {
  local value=$1
  local action="turned on"
  if [ "$value" -eq 0 ]; then
    action="turned off"
  fi
  for i in {4..11}; do # Select the range of cores you want to enable or disable
    if [ "$(cat /sys/devices/system/cpu/cpu$i/online)" -ne "$value" ]; then
      echo "$value" > /sys/devices/system/cpu/cpu$i/online
      echo "CPU $i $action"
    else
      echo "CPU $i was already $action"
    fi
  done
}
```

Add below cpu scaling settings

AC:

```bash
    turn_on_off_cpu 1
```

Battery:

```bash
    turn_on_off_cpu 0

```

If you want a reference of the script that i currently use you can see the file [power-mode](etc/acpi/actions/power-mode.sh)


Note:

- See https://community.frame.work/t/guide-linux-battery-life-tuning/6665/203

- See https://www.kernel.org/doc/html/latest/admin-guide/pm/intel_pstate.html#energy-vs-performance-hints

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
START_THRESHOLD="75"

# Stop charging threshold (0 for default, 1-99 for percent)
STOP_THRESHOLD="80"
```

Run this to apply the changes

```bash
sudo systemctl restart tpacpi-bat
```

#### Further optimize energy management

Edit or Create this `/etc/acpi/events/power_management`:

```
event=battery.*
action=/etc/acpi/actions/power-mode.sh
```

Create script:

```bash
#!/bin/sh

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
	# echo default > /sys/module/pcie_aspm/parameters/policy # Requires pcie_aspm=force as kernel parameter
    iw dev wlan0 set power_save off
    btmgmt power on
    ethtool -s enp0s31f6 wol g
else
	echo "Battery mode"
	# /usr/bin/powertop --auto-tune optional
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
	# echo powersave > /sys/module/pcie_aspm/parameters/policy
    iw dev wlan0 set power_save on
    btmgmt power off
    ethtool -s enp0s31f6 wol d
    rfkill block bluetooth
fi
exit 0
```

Run this to apply the changes:

```bash
sudo systemctl restart acpid
```

Something that you didn't, was that the script doesn't start when turning on, maybe something didn't configure well, or it had something to do with the event that I used. Anyway I managed to solve it by defining a oneshot in systemd (If you know any other solution you can do a pr):

Create this `/etc/systemd/system/power-mode.service`

```

[Unit]
Description=Set Battery or AC mode at startup

[Service]
Type=oneshot
ExecStart=/etc/acpi/actions/power-mode.sh
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
sudo systemctl enable power-mode.service
```

## Fan Control

For a long time I used thinkfan, but for me it is very cumbersome to configure. So I prefer to use [zcfan](https://github.com/cdown/zcfan), a minimalist and easy to configure alternative.

Instal [zcfan](https://github.com/cdown/zcfan) and enable:

```bash
sudo systemctl --now enable zcfan
```

# Note

If you have any suggestion, do not hesitate to do it, maybe you know some other trick that you want to share.
