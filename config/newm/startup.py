import os

# SCRIPTS = os.path.expanduser("~/.scripts")


def execute(cmd):
    os.system(f"{cmd} &")


def execute_iter(commands):
    from multiprocessing import Pool, cpu_count

    with Pool(processes=cpu_count()) as pool:
        for _ in pool.imap_unordered(execute, commands):
            pass


def startup():
    INIT_SERVICES = (
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "dbus-update-activation-environment 2>/dev/null \
        && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "/usr/lib/polkit-kde-authentication-agent-1",
        "fnott",
        "nm-applet --indicator",
        # "avizo-service",
        "wlsunset -l 16.0867 -L -93.7561 -t 2500 -T 6000",
        "brightnessctl set 1",
        # f"{SCRIPTS}/battery-status.sh",
        # "wl-paste --watch cliphist store",
        "copyq --start-server",
    )

    execute_iter(INIT_SERVICES)
