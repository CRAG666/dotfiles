from __future__ import annotations

import logging
import os
from pathlib import Path

from newm.helper import BacklightManager
from newm.layout import Layout
from newm.view import View
from startup import execute_iter, startup
from utilities import notify, run, set_value, toggle_inhibit_idle

logger = logging.getLogger(__name__)

on_startup = startup


def on_reconfigure():
    gnome_schema = "org.gnome.desktop.interface"
    gnome_peripheral = "org.gnome.desktop.peripherals"
    gnome_preferences = "org.gnome.desktop.wm.preferences"
    # easyeffects = "com.github.wwmm.easyeffects"
    theme = "Catppuccin-Mocha-Standard-Lavender-Dark"
    icons = "candy-icons"
    cursor = "Catppuccin-Mocha-Lavender-Cursors"
    font = "SF Pro 14"
    gtk2 = "~/.gtkrc-2.0"

    GSETTINGS = (
        f"gsettings set {gnome_preferences} button-layout :",
        f"gsettings set {gnome_preferences} theme {theme}",
        f"gsettings set {gnome_schema} gtk-theme {theme}",
        f"gsettings set {gnome_schema} color-scheme prefer-dark",
        f"gsettings set {gnome_schema} icon-theme {icons}",
        f"gsettings set {gnome_schema} cursor-theme {cursor}",
        f"gsettings set {gnome_schema} cursor-size 30",
        f"gsettings set {gnome_schema} font-name '{font}'",
        f"gsettings set {gnome_peripheral}.keyboard repeat-interval 30",
        f"gsettings set {gnome_peripheral}.keyboard delay 250",
        f"gsettings set {gnome_peripheral}.mouse natural-scroll true",
        f"gsettings set {gnome_peripheral}.mouse speed 0.0",
        f"gsettings set {gnome_peripheral}.mouse accel-profile 'default'",
        # "gsettings set org.gnome.desktop.a11y.keyboard mousekeys-enable true",
        # "gsettings set org.gnome.desktop.a11y.keyboard mousekeys-max-speed 2000",
        # "gsettings set org.gnome.desktop.a11y.keyboard mousekeys-init-delay 20",
        # "gsettings set org.gnome.desktop.a11y.keyboard mousekeys-accel-time 2000",
        # f"gsettings {easyeffects} process-all-inputs true",
        # f"gsettings {easyeffects} process-all-outputs true",
    )

    def options_gtk(file, c=""):
        CONFIG_GTK = (
            set_value(f"gtk-theme-name={c}{theme}{c}", file),
            set_value(f"gtk-icon-theme-name={c}{icons}{c}", file),
            set_value(f"gtk-font-name={c}{font}{c}", file),
            set_value(f"gtk-cursor-theme-name={c}{cursor}{c}", file),
        )
        execute_iter(CONFIG_GTK)

    # options_gtk(gtk3)
    options_gtk(gtk2, '"')
    execute_iter(GSETTINGS)
    notify("Reload", "update config success")


outputs = [
    {
        "name": "eDP-1",
        "scale": 1.0,
        # "width": 1920,
        # "height": 1080,
        # "mHz": 0,
        "pos_x": 0,
        "pos_y": 0,
    },
    # {"name": "DP-2", "scale": 0.7},
]

pywm = {
    "enable_xwayland": False,
    # "xkb_model": "PLACEHOLDER_xkb_model",
    # "xkb_layout": "es",
    # "xkb_layout": "latam",
    "xkb_layout": "us",
    # "xkb_variant": "intl",
    # "xkb_options": "keypad:pointerkeys",
    # "xkb_options": "mousekeys:enable",
    # "xkb_options": "compose:menu",
    "xcursor_theme": "Catppuccin-Mocha-Lavender-Cursors",
    "xcursor_size": 30,
    "focus_follows_mouse": True,
    # "contstrain_popups_to_toplevel": True,
    "encourage_csd": False,
    "texture_shaders": "basic",
    "renderer_mode": "pywm",
}

HOME = Path.home()

background = {
    # "path": f"{HOME}/Imágenes/wallpaperCicle/8.jpg",
    # "path": f"{HOME}/Imágenes/wallpaperCicle/18.png",
    "path": f"{HOME}/Imágenes/wallpaperCicle/19.jpeg",
    # "path": f"{HOME}/Imágenes/wallpaperCicle/tec/1.png",
    # "path": f"{HOME}/Imágenes/wallpaperCicle/21.webp",
    # "path": f"{HOME}/Imágenes/wallpaperCicle/11.jpg",
    # "path": f"{HOME}/Imágenes/wallpaperCicle/25.jpg",
    # "path": f"{HOME}/Imágenes/wallpaperCicle/17.jpg",
    # "path": f"{HOME}/Imágenes/wallpaperCicle/20.jpg",
    # "path": f"{HOME}/Imágenes/cyberpunk/thefuture7.jpeg",
    # "path": f"{HOME}/Imágenes/paisajes/4k-wallpaper-3.jpg",
    # "path": f"{HOME}/Imágenes/art/rombo.jpg",
    "time_scale": 0.11,
    "anim": True,
}

anim_time = 0.2
blend_time = 0.5
corner_radius = 0

common_rules = {
    # "opacity": 0.8,
    "float": True,
    "float_size": (750, 750),
    "float_pos": (0.5, 0.35),
}

float_app_ids = (
    "albert",
    "pavucontrol",
    "blueman-manager",
    "app.landrop.landrop",
    "landrop",
    "lf-select",
)

float_titles = ("Dialect",)

term = "kitty"

blur_apps = (term, "rofi", "Alacritty", "tenacity")


def rules(view: View):
    app_rule = None
    # NOTE: Show view info
    # os.system(
    #     f"echo '{view.app_id}, {view.title}, {view.role}, {view.pid}, {view.panel}' >> ~/.config/newm/apps"
    # )
    # Set float common rules
    # if view.up_state.is_floating and view.app_id != "albert":
    #     app_rule = common_rules
    if view.app_id == "catapult":
        app_rule = {"float": True, "float_pos": (0.5, 0.1)}
    # elif view.app_id == "albert" and view.title == "Albert":
    #     app_rule = {
    #         "float": True,
    #         "float_size": (640, 440),
    #         # "float_size": (900, 900),
    #         "float_pos": (0.5, 0.22),
    #         # "opacity": 0.8,
    #         # "blur": {"radius": 5, "passes": 6},
    #     }
    elif (
        view.title is not None
        and "Firefox - Indicador de compartición" in view.title.lower()
    ):
        return {"float": True, "float_size": (30, 20)}
    elif view.app_id == "io.bassi.Amberol":
        app_rule = {"opacity": 0.7, "blur": {"radius": 5, "passes": 6}}
    elif view.app_id == "app.landrop.landrop" and view.title == "Transferring":
        app_rule = {
            "float": True,
            "float_size": (600, 100),
            "float_pos": (0.5, 0.15),
        }
    elif view.app_id in float_app_ids or view.title in float_titles:
        app_rule = common_rules
    elif view.app_id in blur_apps:
        app_rule = {"blur": {"radius": 5, "passes": 6}}
    return app_rule


view = {
    "padding": 6,
    "fullscreen_padding": 0,
    "send_fullscreen": False,
    "accept_fullscreen": True,
    "sticky_fullscreen": True,
    "floating_min_size": False,
    # "border_ws_switch": 3,
    "rules": rules,
    "debug_scaling": False,
    "ssd": {"enabled": False},
    "border_ws_switch": 100,
}

focus = {
    "color": "#cba6f7",  # change color
    "distance": 3,
    "width": 2.5,
    "animate_on_change": True,
    "anim_time": 0.35,
    "enabled": True,
}

swipe_zoom = {
    "grid_m": 1,
    "grid_ovr": 0.02,
}

backlight_manager = BacklightManager(dim_factors=(0.2, 0.1), anim_time=1.0)
# # Config for keyboard light
# kbdlight_manager = BacklightManager(
#     args="--device='*::kbd_backlight'", anim_time=1.0, bar_display=wob_runner
# )


def synchronous_update() -> None:
    # kbdlight_manager.update()
    backlight_manager.update()


mod = "L"  # or "A", "C", "1", "2", "3"

altgr = "3-"
ctrl = "C-"
alt = "A-"
COPY_PASTE = f"{HOME}/.scripts/super_copy_paste.sh"
ROFI = f"{HOME}/.config/rofi/scripts"


def key_bindings(layout: Layout):
    super = mod + "-"

    def super_clipboard(key: str = "v"):
        view = layout.find_focused_view()
        mode = " term" if view is not None and view.app_id == term else ""
        os.system(f"{COPY_PASTE} {key}{mode} &")

    # Change the order to enable vertical(first i) or horizontal(first j) sorting
    def compare_views(view: View):
        view_state = layout.state.get_view_state(view)
        return view_state.i, view_state.j

    def get_sorted_views():
        workspace = layout.get_active_workspace()
        views = sorted(layout.tiles(workspace), key=compare_views)
        return views

    def goto_view(index: int):
        if index == 0:
            return
        views = get_sorted_views()
        num_w = len(views)
        if index > num_w:
            return
        layout.focus_view(views[index - 1])

    def cycle_views(steps: int = 1):
        views = tuple(get_sorted_views())
        current_view = layout.find_focused_view()
        if not current_view or current_view not in views:
            return
        index = views.index(current_view) + steps
        select_view(index, views)

    def select_view(index: int, views: tuple[View]):
        num_w = len(views)
        index = (index + num_w) % num_w
        layout.focus_view(views[index])

    return (
        (alt + "Tab", cycle_views),
        (alt + "S-Tab", lambda: cycle_views(-1)),
        # Goto title
        *((super + str(i), lambda i=i: goto_view(i)) for i in range(1, 11)),
        # Move like the star of the winds
        (super + "h", lambda: layout.move(-1, 0)),
        (super + "j", lambda: layout.move(0, 1)),
        (super + "k", lambda: layout.move(0, -1)),
        (super + "l", lambda: layout.move(1, 0)),
        (super + "u", lambda: layout.move(-1, -1)),
        (super + "m", lambda: layout.move(1, 1)),
        (super + "i", lambda: layout.move(1, -1)),
        (super + "n", lambda: layout.move(-1, 1)),
        (super + "t", lambda: layout.move_in_stack(1)),
        # Move focused view
        (
            super + "Left",
            lambda: layout.move_focused_view(-1, 0),
        ),
        (super + "Down", lambda: layout.move_focused_view(0, 1)),
        (
            super + "Up",
            lambda: layout.move_focused_view(0, -1),
        ),
        (super + "Right", lambda: layout.move_focused_view(1, 0)),
        # Resize windows
        (
            super + ctrl + "h",
            lambda: layout.resize_focused_view(-1, 0),
        ),
        (
            super + ctrl + "j",
            lambda: layout.resize_focused_view(0, 1),
        ),
        (
            super + ctrl + "k",
            lambda: layout.resize_focused_view(0, -1),
        ),
        (
            super + ctrl + "l",
            lambda: layout.resize_focused_view(1, 0),
        ),
        (super + "v", layout.toggle_focused_view_floating),
        # (altgr + "w", layout.change_focused_view_workspace),
        # ("Henkan_supere", layout.move_workspace),
        (super + "comma", lambda: layout.basic_scale(1)),
        (super + "period", lambda: layout.basic_scale(-1)),
        (super + "f", layout.toggle_fullscreen),
        (super + "L", lambda: layout.ensure_locked(dim=True)),
        (super + "P", layout.terminate),
        ("XF86Close", layout.close_focused_view),
        ("XF86Reload", layout.update_config),
        (
            super,
            lambda: layout.toggle_overview(only_active_workspace=True),
        ),
        (super + "z", layout.swallow_focused_view),
        ("XF86AudioPrev", run("playerctl previous")),
        ("XF86AudioNext", run("playerctl next")),
        ("XF86AudioPlay", run("playerctl play-pause")),
        (super + "Return", run(term)),
        (altgr + "e", run(f"{ROFI}/powermenu")),
        ("XF86Paste", super_clipboard),
        ("XF86Copy", lambda: super_clipboard("c")),
        ("XF86Open", run(f"{ROFI}/clipboard")),
        ("XF86Favorites", run(f"{ROFI}/bookmarks")),
        (super + "p", run(f"{ROFI}/passman --type")),
        ("XF86AudioMicMute", run("volumectl -m toggle-mute")),
        (
            "XF86MonBrightnessUp",
            run("lightctl +2%"),
        ),
        (
            "XF86MonBrightnessDown",
            run("lightctl -1%"),
        ),
        # (
        # "XF86KbdBrightnessUp",
        # lambda: kbdlight_manager.set(kbdlight_manager.get() + 0.1)),
        # (
        # "XF86KbdBrightnessDown",
        # lambda: kbdlight_manager.set(kbdlight_manager.get() - 0.1)),
        ("XF86AudioRaiseVolume", run("volumectl -u up")),
        ("XF86AudioLowerVolume", run("volumectl -u down")),
        ("XF86AudioMute", run("volumectl toggle-mute")),
        (
            "XF86Tools",
            run("kitty nvim ~/.config/newm/config.py"),
        ),
        ("XF86Search", run("catapult")),
        ("XF86Explorer", run(f"{ROFI}/launcher")),
        # ("XF86LaunchA", execute(f"{self.ROFI}/apps")),
        ("Print", run("shotman --capture output")),
        (
            super + "Print",
            run("shotman --capture region"),
        ),
        ("XF86Go", run(f"{ROFI}/wifi")),
        (
            "XF86Mail",
            run("betterbird"),
        ),
        ("XF86Bluetooth", run("blueman-manager")),
        ("XF86AudioPreset", run("pavucontrol")),
        ("XF86WWW", run("firefox -P Privacy")),
        ("XF86Documents", run("kitty lf")),
        (super + "c", run("hyprpicker -a")),
        (super + "s", toggle_inhibit_idle),
        (super + "d", run("kitty --class lf-select -e lf")),
    )


gestures = {
    "lp_freq": 120.0,
    "lp_inertia": 0.4,
    # "c": {"enabled": False},
    # "pyevdev": {"enabled": True},
}

swipe = {"gesture_factor": 3}

panels = {
    "lock": {
        "cmd": f"{term} newm-panel-basic lock",
        "w": 0.7,
        "h": 0.7,
        "corner_radius": 50,
    },
    "bar": {
        "cmd": "waybar",
        "visible_normal": False,
        "visible_fullscreen": False,
    },
}
grid = {"throw_ps": [2, 10]}
energy = {"idle_times": [300, 600, 1800], "idle_callback": backlight_manager.callback}
