#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/.env" ]; then
  set -a
  source "$SCRIPT_DIR/.env"
  set +a
fi

if [ -z "$DISCORD_WEBHOOK_URL" ]; then
  echo "ERROR: DISCORD_WEBHOOK_URL is not set"
  exit 1
fi

# Paths and config
LOG_FILE="/home/jake/scripts/rclone/backup-homelab.log"
CONFIG="/home/jake/scripts/rclone/rclone.conf"
FILTER="/home/jake/scripts/rclone/filter.txt"
SOURCE="/home/jake"
DEST="DCU-GCrypt-2024:/CheeseLab/home/jake"

# Remove old log
rm -f "$LOG_FILE"

# Run Rclone backup
rclone copy "$SOURCE" "$DEST" -v --config "$CONFIG" --exclude-from "$FILTER" --log-file "$LOG_FILE" --bwlimit 1.7M

# Extract stats from log
TRANSFERRED=$(grep -oP 'Transferred:\s+\K.*' "$LOG_FILE" | tail -1)
CHECKS=$(grep -oP 'Checks:\s+\K.*' "$LOG_FILE" | tail -1)
ELAPSED=$(grep -oP 'Elapsed time:\s+\K.*' "$LOG_FILE" | tail -1)
ERRORS=$(grep -oP 'Errors:\s+\K\d+' "$LOG_FILE" | tail -1)

# Format message
DATE=$(TZ=Europe/Dublin date)
JSON=$(jq -n --arg content ":white_check_mark: \`Rclone\` backup for **cheeselab** has completed **SUCCESSFULLY**

**Date:** \`$DATE\`
**Transferred:** $TRANSFERRED
**Errors:** $ERRORS
**Checks:** $CHECKS
**Elapsed Time:** $ELAPSED" '{content: $content}')

# Send to Discord
curl -X POST -H "Content-Type: application/json" -d "$JSON" "$DISCORD_WEBHOOK_URL"

exit 0
