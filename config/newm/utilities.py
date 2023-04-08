import psutil
import os


def set_value(keyval, file):
    var, val = keyval.split("=")
    return f"sed -i 's/^{var}\\=.*/{var}={val}/' {file}"


def run(cmd):
    return lambda: os.system(f"{cmd} &")


def notify(title: str, msg: str, icon="preferences-system"):
    os.system(f"notify-send -i '{icon}' -a '{title}' '{msg}' &")


def toggle_inhibit_idle():
    process_id = 0
    for process in psutil.process_iter(["cmdline"]):
        if "newm-cmd" in process.name():
            process_id = process.pid
            break

    if process_id:
        psutil.Process(process_id).kill()
        notify("Idle", "Inhibit idle disabled", "gnome-lockscreen")
    else:
        os.system("newm-cmd inhibit-idle &")
        notify("Idle", "Inhibit idle enabled", "preferences-desktop-screensaver")
