#!/bin/bash
rt="${XDG_RUNTIME_DIR:-/tmp}"
busfile="$rt/ddc-brightness.bus"
pend="$rt/ddc-brightness.pending"
lock="$rt/ddc-brightness.lock"
# Ultimo % del monitor externo. La laptop la recuerda systemd; el externo no
# (y ktc-brightness.sh pone el backlight de laptop en 0, asi que no sirve de proxy).
levelfile="$rt/ddc-brightness.level"

clamp() { local v=$1; ((v<0)) && v=0; ((v>100)) && v=100; echo "$v"; }

# Detecta los buses DDC de monitores externos sondendo lectura real de VCP 10
# y cachea los que responden en busfile. No usamos `ddcutil detect`: su mapeo
# conector↔bus falla segun driver (amdgpu expone el bus AUX en card1-*/ y
# clasifica monitores validos como "Invalid display"), y los nombres varian
# por GPU ("DM i2c hw bus" en amd, "i915 gmbus" en intel). Candidatos = buses
# i2c que cuelgan de la GPU (drm): cubre amd/intel/nouveau y excluye los
# peligrosos (SMBus, touchpad DesignWare). Sonda de bus muerto: ~80ms.
detect_buses() {
    local dev devdir bus
    : > "$busfile"
    for dev in /sys/class/i2c-dev/i2c-*; do
        devdir="$(readlink -f "$dev/device")"
        # buses DDC: cuelgan de un dispositivo con drm (padre) o de un cardN
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
    # Restaura el ultimo % guardado (arg explicito > levelfile > 50).
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
    # "none" = solo pantalla de laptop: sin buses externos, pero igual
    # ajustamos el backlight interno con brightnessctl más abajo.
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

        # brightnessctl escala con el delta real acumulado
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
            # Redetecta solo si NINGUN bus respondio (desconexion total). Un
            # monitor sin DDC o un timeout puntual se ignora; los demas siguen
            # y el fallido se reintenta en la proxima pulsacion.
            [[ $ok -eq 0 ]] && { rm -f "$busfile"; break; }
            level=$(clamp $((level $op n)))
            echo "$level" > "$levelfile"
        fi
    done
}
worker &
disown
