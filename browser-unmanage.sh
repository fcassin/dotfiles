#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Remove the enterprise-policy directories Omarchy creates for browser theming.
# Any file under a browser's policies/managed/ dir makes the browser report
# "managed by your organization" and locks the related security settings.
# Omarchy uses it only to sync the window frame color to the current theme
# (see omarchy-theme-set-browser), which we forgo here.
#
# Removing the directory — not just its color.json — is what makes this stick:
# omarchy-theme-set-browser guards each write on `[[ -d $policy_dir ]]`, so it
# will not recreate the file on the next theme switch. An `omarchy update`
# migration or reinstalling a browser via Omarchy can recreate it, so re-run
# this script if the "managed" banner returns.

readonly LOG_FILE="/tmp/$(basename "$0").log"
info() { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }

readonly POLICY_DIRS=(
    /etc/chromium/policies/managed
    /etc/opt/chrome/policies/managed
    /etc/opt/edge/policies/managed
    /etc/brave/policies/managed
)

for dir in "${POLICY_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        info "Removing managed browser policy directory: $dir"
        sudo rm -rf "$dir"
        # Tidy the now-empty policies/ parent, but keep it if anything else lives there.
        sudo rmdir "$(dirname "$dir")" 2>/dev/null || true
    fi
done
