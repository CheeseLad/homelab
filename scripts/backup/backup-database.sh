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

declare -A CONTAINERS
declare -A COMMANDS
declare -A OUTPUTS

#BACKUP_DIR="/mnt/usb1/Jake/Device Automated Backups/CheeseLab/Internal Storage/home/jake/backups"
BACKUP_DIR="/home/jake/backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Service definitions
CONTAINERS["hedgedoc"]="hedgedoc-database"
COMMANDS["hedgedoc"]="pg_dump hedgedoc -U hedgedoc"
OUTPUTS["hedgedoc"]="$BACKUP_DIR/hedgedoc/hedgedoc_postgres_$TIMESTAMP.sql"

CONTAINERS["immich"]="immich_postgres"
COMMANDS["immich"]="pg_dump immich -U postgres"
OUTPUTS["immich"]="$BACKUP_DIR/immich/immich_postgres_$TIMESTAMP.sql"

CONTAINERS["mysql"]="mysql-database"
COMMANDS["mysql"]="mysqldump --all-databases -u root --password='$MYSQL_ROOT_PASSWORD'"
OUTPUTS["mysql"]="$BACKUP_DIR/mysql-database/mysql_$TIMESTAMP.sql"

run_backup() {
  local name="$1"
  local container="${CONTAINERS[$name]}"
  local command="${COMMANDS[$name]}"
  local output_file="${OUTPUTS[$name]}"
  local retention_dir
  retention_dir="$(dirname "$output_file")"

  mkdir -p "$retention_dir"

  # Run docker exec
  docker exec "$container" sh -c "$command" > "$output_file"

  # Cleanup old backups
  find "$retention_dir" -type f -mtime +7 -exec rm -f {} \;

  echo "Old backups in '$retention_dir' have been cleaned up."

  # Check result
  if [ -s "$output_file" ]; then
    size=$(du -h "$output_file" | cut -f1)
    echo "$name Backup successful ($size)"
    send_webhook "$name" "SUCCEEDED" "$output_file" "$size"
  else
    echo "$name Backup failed"
    rm -f "$output_file"
    send_webhook "$name" "FAILED" "$output_file" "0B"
  fi
}

# Function to send Discord notification
send_webhook() {
  local service_name=$1
  local status=$2
  local file=$3
  local size=$4

  local icon=""
  if [ "$status" == "SUCCEEDED" ]; then
    icon=":white_check_mark:"
  else
    icon=":x:"
  fi

  JSON='{
    "content": "'"$icon"' `'"$service_name"'` backup has **'"$status"'**\nFile: `'"$file"'`\nSize: `'"$size"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"
  }'

  curl -X POST \
    -H "Content-Type: application/json" \
    -d "$JSON" \
    "${DISCORD_WEBHOOK_URL}"
}

for service in "${!CONTAINERS[@]}"; do
  run_backup "$service"
done