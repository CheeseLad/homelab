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

# --- Configuration ---
STATE_DIR="/var/tmp/smart_monitor_state"
HOSTNAME=$(hostname)
TODAY=$(date '+%Y-%m-%d')

# List drives here, space separated (e.g., /dev/sda /dev/nvme0n1)
DRIVES=("/dev/sda" "/dev/sdb" "/dev/nvme0n1")

mkdir -p "$STATE_DIR"

# Function to get SMART metric depending on drive type
get_smart_metric() {
  local drive=$1
  if [[ "$drive" == /dev/nvme* ]]; then
    # NVMe: Use Media and Data Integrity Errors (ID 0xE7) or similar
    # smartctl -a for NVMe uses slightly different output
    # We'll grab "Media and Data Integrity Errors" if present, else fallback to 0
    smartctl -a "$drive" | awk '
      /Media and Data Integrity Errors/ {print $NF; exit}
      END {if (!found) print 0}
      {found=1}
    '
  else
    # SATA: Use Reallocated_Sector_Ct ID 5 (10th column)
    smartctl -A "$drive" | awk '$1 == 5 {print $10; exit}'
  fi
}

# Initialize message parts
MESSAGE="**$TODAY - $HOSTNAME - SMART Drive Health Report**"
ALERT=0

for DRIVE in "${DRIVES[@]}"; do
  if [ ! -b "$DRIVE" ]; then
    MESSAGE+="
    
Drive $DRIVE not found or not a block device."
    continue
  fi

  CURRENT=$(get_smart_metric "$DRIVE")
  STATE_FILE="$STATE_DIR/$(basename $DRIVE)_metric"

  if [ -f "$STATE_FILE" ]; then
    PREV=$(cat "$STATE_FILE")
  else
    PREV=$CURRENT
  fi

  if (( CURRENT > PREV )); then
    STATUS="⚠️ Increased!"
    ALERT=1
  else
    STATUS="✅ Stable"
  fi

  MESSAGE+="
  
Drive: \`$DRIVE\`
Current SMART metric: $CURRENT (previous: $PREV)
Status: $STATUS"

  echo "$CURRENT" > "$STATE_FILE"
done

if (( ALERT == 1 )); then
  MESSAGE+="
  
@everyone"
fi

# Send Discord message
# Escape special characters for JSON
JSON_MESSAGE=$(jq -Rn --arg msg "$MESSAGE" '{"content": $msg}')

curl -H "Content-Type: application/json" \
     -X POST \
     -d "$JSON_MESSAGE" \
     "$DISCORD_WEBHOOK_URL"

