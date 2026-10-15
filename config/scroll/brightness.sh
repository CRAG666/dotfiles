#!/bin/bash
rt="${XDG_RUNTIME_DIR:-/tmp}"
busfile="$rt/ddc-brightness.bus"
pend="$rt/ddc-brightness.pending"
lock="$rt/ddc-brightness.lock"
# Last % of the external monitor. systemd remembers the laptop's; not the external's
# (and ktc-brightness.sh sets the laptop backlight to 0, so it can't act as a proxy).
levelfile="$rt/ddc-brightness.level"

clamp() { local v=$1 hi=${2:-100}; ((v<0)) && v=0; ((v>hi)) && v=$hi; echo "$v"; }

# The sixteenth step `delta` presses land on from `cur` of `max`. Between two
# steps the first press only reaches the next one, as on macOS; `tol` absorbs
# the rounding of values already on a step.
step_after() {
    local cur=$1 max=$2 delta=$3 tol=$4
    if ((delta > 0)); then
        clamp $(((cur * 16 + tol) / max + delta)) 16
    else
        clamp $(((cur * 16 - tol + max - 1) / max + delta)) 16
    fi
}

# Shows the level on the Quickshell HUD (quickshell/osd/Osd.qml): the laptop
# panel's, or the external monitor's $1 while ktc-brightness.sh keeps the panel
# off. Only builtins guard the write: the pid the HUD left must still be a
# quickshell holding the fifo open, so it cannot block.
osd() {
    local pct pid name fifo="$rt/osd.fifo"
    pct=$(brightnessctl -m 2>/dev/null | cut -d, -f4)
    pct=${pct%\%}
    [[ -n $pct && $pct -gt 0 ]] || pct=$1
    read -r pid 2>/dev/null < "$fifo.pid" && read -r name 2>/dev/null < "/proc/$pid/comm" &&
        [[ $name == quickshell && -p $fifo ]] && printf 'brightness %s\n' "$pct" > "$fifo"
}

# Detects the DDC buses of external monitors by probing a real VCP 10 read
# and caches the responsive ones in busfile. We don't use `ddcutil detect`: its
# connector↔bus mapping fails per driver (amdgpu exposes the AUX bus under card1-*/ and
# classifies valid monitors as "Invalid display"), and the names vary
# by GPU ("DM i2c hw bus" on amd, "i915 gmbus" on intel). Candidates = i2c
# buses hanging off the GPU (drm): covers amd/intel/nouveau and excludes the
# dangerous ones (SMBus, DesignWare touchpad). Dead-bus probe: ~80ms.
detect_buses() {
    local dev devdir bus found=()
    for dev in /sys/class/i2c-dev/i2c-*; do
        devdir="$(readlink -f "$dev/device")"
        # DDC buses: hang off a device with drm (parent) or off a cardN
        [[ -d "${devdir%/*}/drm" || "$devdir" == */drm/* ]] || continue
        bus="${dev##*/i2c-}"
        timeout 3 ddcutil --bus "$bus" --skip-ddc-checks --noverify \
            --sleep-multiplier .05 getvcp 10 >/dev/null 2>&1 || continue
        found+=("$bus")
    done
    # written in one go: a keypress reading it mid-probe would start its own
    printf '%s\n' "${found[@]:-none}" > "$busfile.$$" && mv "$busfile.$$" "$busfile"
}

case $1 in
up)   d=1 ;;
down) d=-1 ;;
init)
    # Restore the last saved % (explicit arg > levelfile > 50).
    level="$2"
    [[ -z $level && -s $levelfile ]] && read -r level < "$levelfile"
    : "${level:=50}"
    # a monitor can take a while to answer DDC after login or a plug-in:
    # keep probing for half a minute while an external output is active
    for _ in {1..6}; do
        detect_buses
        [[ $(<"$busfile") != none ]] && break
        scrollmsg -t get_outputs -r |
            jq -e 'any(.[]; .active and (.name | startswith("eDP") | not))' >/dev/null || exit 0
        sleep 5
    done
    [[ $(<"$busfile") == none ]] && exit 0
    while IFS= read -r bus; do
        ddcutil --bus "$bus" --skip-ddc-checks --noverify --sleep-multiplier .1 \
            setvcp 10 "$level" >/dev/null 2>&1
    done < "$busfile"
    echo "$level" > "$levelfile"
    exit 0
    ;;
test)
    [[ $(clamp -5) == 0 && $(clamp 150) == 100 && $(clamp 40) == 40 &&
        $(step_after 35383 65535 1 16) == 9 && $(step_after 35383 65535 -1 16) == 8 &&
        $(step_after 40959 65535 1 16) == 11 && $(step_after 40959 65535 -1 16) == 9 &&
        $(step_after 56 100 1 8) == 10 && $(step_after 56 100 -1 8) == 8 ]] \
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
    local empty=0 n
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

        # macOS steps: each press moves 1/16 of the range, snapped to that grid,
        # so it fills or empties one of the HUD's sixteen segments. The panel is
        # left alone at 0 while an external monitor is on: ktc-brightness.sh
        # turned it off; brightnessctl never sets it below 1 itself.
        local cur max step
        cur=$(brightnessctl g 2>/dev/null)
        max=$(brightnessctl m 2>/dev/null)
        if [[ -n $max ]] && (( cur > 0 || ${#buses[@]} == 0 )); then
            step=$(step_after "$cur" "$max" "$n" 16)
            brightnessctl -q s $(( step * max / 16 )) &
        fi

        if [[ ${#buses[@]} -gt 0 ]]; then
            local ok=0
            step=$(step_after "$level" 100 "$n" 8)
            for bus in "${buses[@]}"; do
                ddcutil --bus "$bus" --skip-ddc-checks --noverify --sleep-multiplier .1 \
                    setvcp 10 $(( (step * 100 + 8) / 16 )) >/dev/null 2>&1 && ok=1
            done
            # Re-detect only if NO bus responded (full disconnect). A
            # monitor without DDC or a one-off timeout is ignored; the rest continue
            # and the failed one is retried on the next keypress.
            [[ $ok -eq 0 ]] && { rm -f "$busfile"; break; }
            level=$(( (step * 100 + 8) / 16 ))
            echo "$level" > "$levelfile"
        fi
        wait
        osd "$level"
    done
}
worker &
disown
