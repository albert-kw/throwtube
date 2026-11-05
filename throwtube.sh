#!/bin/bash
# throwtube.sh
# throw youtube url to target host with firefox

#!/usr/bin/env bash
set -euo pipefail

HOST="yuzu.sixth.dms"          # target machine

url="${1:-$(xclip -selection clipboard -o)}"
[[ $url =~ ^https?:// ]] || url="https://$url"

ssh "$HOST" "DISPLAY=:0 WAYLAND_DISPLAY=wayland-0 \
  nohup firefox --new-tab $(printf '%q' "$url") >/dev/null 2>&1 &"
