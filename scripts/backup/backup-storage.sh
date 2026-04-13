#!/bin/bash

SERVICES_DIR="/home/jake/services"
STORAGE_DIR="/home/jake/storage"
BACKUP_DIR="/home/jake/backups"
#BACKUP_DIR="/mnt/usb1/Jake/Device Automated Backups/CheeseLab/Internal Storage/home/jake/backups"

EXCLUDED_SERVICES=(
  "uptime-kuma"
)

FOLDERS_TO_ARCHIVE=()

for service_path in "$SERVICES_DIR"/*; do
  service_name=$(basename "$service_path")

  # Skip if in exclude list
  skip=false
  for excluded in "${EXCLUDED_SERVICES[@]}"; do
    if [[ "$service_name" == "$excluded" ]]; then
      skip=true
      break
    fi
  done
  $skip && continue

  storage_path="$STORAGE_DIR/$service_name"

  # Only include if storage exists
  if [[ -d "$storage_path" ]]; then
    FOLDERS_TO_ARCHIVE+=("$storage_path")
  fi
done

declare -A EXCLUDE_PATHS
EXCLUDE_PATHS["/home/jake/storage/jellyfin"]="--exclude=data/metadata --exclude=cache --exclude=data/data/introskipper/chromaprints"
EXCLUDE_PATHS["/home/jake/storage/hedgedoc"]="--exclude=uploads"
EXCLUDE_PATHS["/home/jake/storage/lidarr"]="--exclude=config/MediaCover --exclude=config/Backups"
EXCLUDE_PATHS["/home/jake/storage/radarr"]="--exclude=MediaCover"
EXCLUDE_PATHS["/home/jake/storage/sonarr"]="--exclude=MediaCover"
EXCLUDE_PATHS["/home/jake/storage/tdarr"]="--exclude=transcode_cache"
EXCLUDE_PATHS["/home/jake/storage/navidrome"]="--exclude=cache"
EXCLUDE_PATHS["/home/jake/storage/immich"]="--exclude=postgres --exclude=backups --exclude=thumbs"
EXCLUDE_PATHS["/home/jake/storage/speedtest-tracker"]="--exclude=www/node_modules --exclude=www/vendor"
EXCLUDE_PATHS["/home/jake/storage/pi-hole"]="--exclude=etc-pihole/logrotate"

archive_folder() {
  FOLDER_TO_ARCHIVE="$1"
  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  FOLDER_NAME="$(basename "$FOLDER_TO_ARCHIVE")"
  ARCHIVE_NAME="${FOLDER_NAME}_${TIMESTAMP}.tar.gz"
  BACKUP_FOLDER="${BACKUP_DIR}/${FOLDER_NAME}"

  if [ ! -d "$FOLDER_TO_ARCHIVE" ]; then
    echo "Error: Folder '$FOLDER_TO_ARCHIVE' does not exist."
    return 1
  fi

  mkdir -p "$BACKUP_FOLDER" || { echo "Error: Failed to create backup directory '$BACKUP_FOLDER'."; return 1; }

  EXCLUDE_OPTIONS=()
  if [[ -n "${EXCLUDE_PATHS[$FOLDER_TO_ARCHIVE]}" ]]; then
    EXCLUDE_OPTIONS=(${EXCLUDE_PATHS[$FOLDER_TO_ARCHIVE]})
  fi

  tar -czf "${BACKUP_FOLDER}/${ARCHIVE_NAME}" "${EXCLUDE_OPTIONS[@]}" -C "$(dirname "$FOLDER_TO_ARCHIVE")" "$(basename "$FOLDER_TO_ARCHIVE")"

  if [ $? -ne 0 ]; then
    echo "Error: Failed to create archive for '$FOLDER_TO_ARCHIVE'."
    return 1
  fi

  echo "Successfully archived '$FOLDER_TO_ARCHIVE' to '${BACKUP_FOLDER}/${ARCHIVE_NAME}'"
}

cleanup_old_backups() {
  FOLDER_NAME="$(basename "$1")"
  BACKUP_FOLDER="${BACKUP_DIR}/${FOLDER_NAME}"

  find "$BACKUP_FOLDER" -type f -name "*.tar.gz" -mtime +7 -exec rm -f {} \;

  echo "Old backups in '$BACKUP_FOLDER' have been cleaned up."
}

for FOLDER in "${FOLDERS_TO_ARCHIVE[@]}"; do
  archive_folder "$FOLDER"
  cleanup_old_backups "$FOLDER"
done