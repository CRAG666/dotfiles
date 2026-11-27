#!/usr/bin/env bash
set -euo pipefail

# single instance: exec_always starts this again on every reload
[[ ${FLOCKER:-} == "$0" ]] || FLOCKER=$0 exec flock -no "$0" "$0"

ktc='Shenzhen KTC Technology Group H32S17 0x00000001'
lid_inhibitor=

sync_dock() {
    local ktc_connected panel panel_active
    read -r ktc_connected panel panel_active < <(scrollmsg -t get_outputs -r | jq -r --arg ktc "$ktc" '
        (.[] | select(.name | startswith("eDP"))) as $panel
        | "\(any(.[]; "\(.make) \(.model) \(.serial)" == $ktc)) \($panel.name) \($panel.active)"')

    if [[ $ktc_connected == true ]]; then
        if [[ -z $lid_inhibitor ]]; then
            # logind stops seeing the KTC as a dock once idle powers it off; tail ends the lock with this script
            systemd-inhibit --what=handle-lid-switch --who=scroll --why='KTC connected' tail --pid=$$ -f /dev/null &
            lid_inhibitor=$!
        fi
        [[ $panel_active == false ]] || scrollmsg -q "output $panel disable"
    else
        [[ $panel_active == true ]] || scrollmsg -q "output $panel enable"
        if [[ -n $lid_inhibitor ]]; then
            kill "$lid_inhibitor"
            lid_inhibitor=
        fi
    fi
}

sync_dock
while read -r _; do sync_dock; done < <(scrollmsg -t subscribe -m '["output"]')
