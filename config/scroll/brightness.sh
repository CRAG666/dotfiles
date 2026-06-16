#!/bin/bash
rt="${XDG_RUNTIME_DIR:-/tmp}"
busfile="$rt/ddc-brightness.bus"
pend="$rt/ddc-brightness.pending"
lock="$rt/ddc-brightness.lock"

case $1 in
up)   d=1 ;;
down) d=-1 ;;
init)
    level="${2:-5}"
    ddcutil detect --brief 2>/dev/null |
        awk '/^Display/{ok=1} ok && /I2C bus:/{sub(".*i2c-",""); print}' \
        > "$busfile"
    [[ -s $busfile ]] || echo none > "$busfile"
    [[ $(<"$busfile") == none ]] && exit 0
    while IFS= read -r bus; do
        ddcutil --bus "$bus" --skip-ddc-checks --noverify --sleep-multiplier .1 \
            setvcp 10 "$level" >/dev/null 2>&1
    done < "$busfile"
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
    if [[ ! -s $busfile ]]; then
        ddcutil detect --brief 2>/dev/null |
            awk '/^Display/{ok=1} ok && /I2C bus:/{sub(".*i2c-",""); print}' \
            > "$busfile"
        [[ -s $busfile ]] || echo none > "$busfile"
    fi
    local -a buses
    mapfile -t buses < "$busfile"
    [[ "${buses[0]}" == none ]] && return 0
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

        # brightnessctl escala con el delta real acumulado
        if [[ $op == + ]]; then
            brightnessctl s +"${n}%" >/dev/null 2>&1 &
        else
            brightnessctl s "${n}%-" >/dev/null 2>&1 &
        fi

        local failed=0
        for bus in "${buses[@]}"; do
            ddcutil --bus "$bus" --skip-ddc-checks --noverify --sleep-multiplier .1 \
                setvcp 10 $op $n >/dev/null 2>&1 || failed=1
        done
        [[ $failed -eq 1 ]] && { rm -f "$busfile"; break; }
    done
}
worker &
disown
