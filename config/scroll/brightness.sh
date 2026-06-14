#!/bin/bash
# Brillo rapido: backlight del portatil + monitores externos via DDC/CI.
#
# Problemas que resuelve:
#  - `ddcutil` re-detecta monitores en CADA invocacion (~1.4 s): se detectan
#    una vez por sesion y se cachean los buses i2c (--bus + sleeps reducidos
#    deja la escritura en ~0.2 s).
#  - El bus i2c solo admite una transaccion a la vez: las pulsaciones se
#    ACUMULAN en un contador y un unico worker en segundo plano (flock) las
#    aplica en lotes (`setvcp 10 + N`), asi mantener la tecla pulsada no
#    encola procesos compitiendo por el bus.
#  - La pulsacion retorna en unos pocos ms; el hardware converge solo.
#
# Si el setvcp falla (monitor cambiado/desconectado) se borra el cache de
# buses para re-detectar en la siguiente pulsacion.

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

# backlight del portatil: instantaneo al subir, ~350 ms al bajar -> al fondo
if [[ $d -gt 0 ]]; then
	brightnessctl s +1% >/dev/null 2>&1 &
else
	brightnessctl s 1%- >/dev/null 2>&1 &
fi

# acumula la pulsacion (seccion critica minima)
{
	flock 8
	n=0
	[[ -s $pend ]] && read -r n < "$pend"
	echo $((n + d)) > "$pend"
} 8>"$pend.lk"

worker() {
	exec 9>"$lock"
	flock -n 9 || return 0   # ya hay un worker drenando; quedo contada

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
			# gracia de 50 ms: cubre la pulsacion que incremento el
			# contador justo cuando este worker decidia terminar
			empty=$((empty + 1))
			[[ $empty -ge 2 ]] && break
			sleep 0.05
			continue
		fi
		empty=0
		op=+
		if [[ $n -lt 0 ]]; then op=-; n=$((-n)); fi
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
