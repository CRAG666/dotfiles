#!/bin/bash
rt="${XDG_RUNTIME_DIR:-/tmp}"
busfile="$rt/ddc-brightness.bus"
pend="$rt/ddc-brightness.pending"
lock="$rt/ddc-brightness.lock"
# Last % of the external monitor. systemd remembers the laptop's; not the external's
# (and ktc-brightness.sh sets the laptop backlight to 0, so it can't act as a proxy).
levelfile="$rt/ddc-brightness.level"

clamp() { local v=$1; ((v<0)) && v=0; ((v>100)) && v=100; echo "$v"; }

# Detects the DDC buses of external monitors by probing a real VCP 10 read
# and caches the responsive ones in busfile. We don't use `ddcutil detect`: its
# connector↔bus mapping fails per driver (amdgpu exposes the AUX bus under card1-*/ and
# classifies valid monitors as "Invalid display"), and the names vary
# by GPU ("DM i2c hw bus" on amd, "i915 gmbus" on intel). Candidates = i2c
# buses hanging off the GPU (drm): covers amd/intel/nouveau and excludes the
# dangerous ones (SMBus, DesignWare touchpad). Dead-bus probe: ~80ms.
detect_buses() {
    local dev devdir bus
    : > "$busfile"
    for dev in /sys/class/i2c-dev/i2c-*; do
        devdir="$(readlink -f "$dev/device")"
        # DDC buses: hang off a device with drm (parent) or off a cardN
        [[ -d "${devdir%/*}/drm" || "$devdir" == */drm/* ]] || continue
        bus="${dev##*/i2c-}"
        timeout 3 ddcutil --bus "$bus" --skip-ddc-checks --noverify \
            --sleep-multiplier .05 getvcp 10 >/dev/null 2>&1 || continue
        echo "$bus" >> "$busfile"
    done
    [[ -s $busfile ]] || echo none > "$busfile"
}

case $1 in
up)   d=1 ;;
down) d=-1 ;;
init)
    # Restore the last saved % (explicit arg > levelfile > 50).
    level="$2"
    [[ -z $level && -s $levelfile ]] && read -r level < "$levelfile"
    : "${level:=50}"
    detect_buses
    [[ $(<"$busfile") == none ]] && exit 0
    while IFS= read -r bus; do
        ddcutil --bus "$bus" --skip-ddc-checks --noverify --sleep-multiplier .1 \
            setvcp 10 "$level" >/dev/null 2>&1
    done < "$busfile"
    echo "$level" > "$levelfile"
    exit 0
    ;;
test)
    [[ $(clamp -5) == 0 && $(clamp 150) == 100 && $(clamp 40) == 40 ]] \
        && echo OK || { echo FAIL; exit 1; }
    exit 0
    ;;
*)    exit 0 ;;
esac

{
    flock 8
    n=0
    [[ -s $pend ]] && read -r n < "$pend"
    echo $((n + d)) > "$pend"
} 8>"$pend.lk"

worker() {
    exec 9>"$lock"
    flock -n 9 || return 0
    [[ -s $busfile ]] || detect_buses
    local -a buses
    mapfile -t buses < "$busfile"
    # "none" = laptop screen only: no external buses, but we still
    # adjust the internal backlight with brightnessctl further down.
    [[ "${buses[0]}" == none ]] && buses=()
    local level=50
    [[ -s $levelfile ]] && read -r level < "$levelfile"
    local empty=0 n op
    while :; do
        {
            flock 8
            n=0
            [[ -s $pend ]] && read -r n < "$pend"
            echo 0 > "$pend"
        } 8>"$pend.lk"
        if [[ $n -eq 0 ]]; then
            empty=$((empty + 1))
            [[ $empty -ge 2 ]] && break
            sleep 0.05
            continue
        fi
        empty=0
        op=+
        if [[ $n -lt 0 ]]; then op=-; n=$((-n)); fi

        # brightnessctl scales with the real accumulated delta
        if [[ $op == + ]]; then
            brightnessctl s +"${n}%" >/dev/null 2>&1 &
        else
            brightnessctl s "${n}%-" >/dev/null 2>&1 &
        fi

        if [[ ${#buses[@]} -gt 0 ]]; then
            local ok=0
            for bus in "${buses[@]}"; do
                ddcutil --bus "$bus" --skip-ddc-checks --noverify --sleep-multiplier .1 \
                    setvcp 10 $op $n >/dev/null 2>&1 && ok=1
            done
            # Re-detect only if NO bus responded (full disconnect). A
            # monitor without DDC or a one-off timeout is ignored; the rest continue
            # and the failed one is retried on the next keypress.
            [[ $ok -eq 0 ]] && { rm -f "$busfile"; break; }
            level=$(clamp $((level $op n)))
            echo "$level" > "$levelfile"
        fi
    done
}
worker &
disown
