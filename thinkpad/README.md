# For Thinkpad's lovers

I am a Thinkpad user since 2017, One of the most recurring problems is the battery life, I tried everything, until I finally achieved the results I wanted.
This configuration is applicable for any thinkpad except for some exceptions(I will specify if it applies or not to older thinkpads)

## Power Management

### Basics

Install [auto-cpufreq](https://github.com/AdnanHodzic/auto-cpufreq), [ananicy-cpp](https://gitlab.com/ananicy-cpp/ananicy-cpp)(optional) and thermald. Excecute this:

```bash
sudo systemctl --now enable auto-cpufreq ananicy-cpp thermald
```

With these packages you will already have a significant improvement in the duration of your battery.

Note: If you see that the battery life is still the same, it may be due to the frequency driver you use, I understand that the default is `intel_pstate`, so just disable it from the kernel parameters `intel_pstate=disable`

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
  echo 0 > /proc/sys/vm/laptop_mode
  echo 10 > /proc/sys/vm/dirty_ratio
  echo 5 > /proc/sys/vm/dirty_background_ratio
  echo 6000 > /proc/sys/vm/dirty_writeback_centisecs
  for i in /sys/class/scsi_host/*/link_power_management_policy ; do
    echo max_performance > ${i}
  done
  echo 0 > /sys/module/snd_hda_intel/parameters/power_save
  modprobe uvcvideo
  echo default > /sys/module/pcie_aspm/parameters/policy # this option requires you to enable an option in the kernel parameters pcie_aspm=force
else
  echo "Battery mode"
  # /usr/bin/powertop --auto-tune # This is optional, maybe it will give you good results as it has given me
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
  echo powersave > /sys/module/pcie_aspm/parameters/policy # this option requires you to enable an option in the kernel parameters pcie_aspm=force
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
