#!/usr/bin/env bash
set -euo pipefail

# Blocks a fixed list of sites in /etc/hosts on weekdays, 09:00-12:00 and
# 14:00-18:00. Outside those windows the sites stay reachable. Idempotent:
# safe to run at any time from a timer, at boot, or by hand.
readonly HOSTS_FILE="/etc/hosts"
readonly MARK_BEGIN="# site-blocker BEGIN"
readonly MARK_END="# site-blocker END"
readonly SITES=(
    "www.lemonde.fr"
    "www.ouest-france.fr"
    "www.youtube.com"
)

is_blocked_now() {
    local day hour_min
    day="$(date +%u)"   # 1=Mon .. 7=Sun
    # 10# forces base 10: bash reads a leading zero as octal, and "0930" is not
    # a valid octal number.
    hour_min="$((10#$(date +%H%M)))"

    [[ "$day" -ge 1 && "$day" -le 5 ]] || return 1
    if [[ "$hour_min" -ge 900 && "$hour_min" -lt 1200 ]]; then
        return 0
    fi
    if [[ "$hour_min" -ge 1400 && "$hour_min" -lt 1800 ]]; then
        return 0
    fi
    return 1
}

remove_block() {
    sed -i "/^${MARK_BEGIN}\$/,/^${MARK_END}\$/d" "$HOSTS_FILE"
}

add_block() {
    remove_block
    {
        echo "$MARK_BEGIN"
        for site in "${SITES[@]}"; do
            echo "127.0.0.1 $site"
        done
        echo "$MARK_END"
    } >> "$HOSTS_FILE"
}

if is_blocked_now; then
    add_block
else
    remove_block
fi
