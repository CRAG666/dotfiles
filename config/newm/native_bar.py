import os
import pwd
import time
import psutil
from subprocess import check_output

ssid = "nmcli -t -f active,ssid dev wifi | egrep '^sí'\
    | cut -d\\: -f2"

brightness = "brightnessctl i | grep 'Current' | cut -d\\( -f2"

volume = "awk -F\"[][]\" '/Left:/ { print $2 }' <(amixer sget Master)"


def get_nw():
    ifdevice = "wlan0"
    ip = ""
    try:
        ip = psutil.net_if_addrs()[ifdevice][0].address
    except Exception:
        ip = "-/-"
    ssid_string = check_output(ssid, shell=True).decode("utf-8")
    return f"  {ifdevice}: {ssid_string[:-1]} / {ip}"


bar = {
    "font": "Lilex Nerd Font",
    "font_size": 15,
    "height": 20,
    "top_texts": lambda: [
        pwd.getpwuid(os.getuid())[0],
        f" {psutil.cpu_percent(interval=1)}",
        f" {psutil.virtual_memory().percent}%",
        f"/ {psutil.disk_usage('/').percent}%\
            /home {psutil.disk_usage('/home').percent}%",
    ],
    "bottom_texts": lambda: [
        # f'{psutil.sensors_battery().percent} \
        # {"↑" if psutil.sensors_battery().power_plugged else "↓"}',
        f' {check_output(brightness, shell=True).decode("utf-8")[:-2]}',
        f'墳 {check_output(volume, shell=True).decode("utf-8")[:-1]}',
        get_nw(),
        f' {time.strftime("%c")}',
    ],
}
