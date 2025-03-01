#!/bin/bash

FOLDERS_TO_ARCHIVE=(
  "/home/jake/storage/cable-anarchy-minecraft"
  "/home/jake/storage/cloudflared"
  "/home/jake/storage/ddclient"
  "/home/jake/storage/hedgedoc"
  "/home/jake/storage/homepage"
  "/home/jake/storage/immich"
  "/home/jake/storage/jackett"
  "/home/jake/storage/jellyfin"
  "/home/jake/storage/lidarr"
  "/home/jake/storage/overseerr"
  "/home/jake/storage/paperless-ngx"
  "/home/jake/storage/photoprism"
  "/home/jake/storage/pterodactyl"
  "/home/jake/storage/qbittorrent"
  "/home/jake/storage/transmission"
  "/home/jake/storage/vaultwarden"
)

declare -A EXCLUDE_PATHS
EXCLUDE_PATHS["/home/jake/storage/jellyfin"]="--exclude=data/metadata"
EXCLUDE_PATHS["/home/jake/storage/qbittorrent"]="--exclude=downloads"
EXCLUDE_PATHS["/home/jake/storage/hedgedoc"]="--exclude=uploads"
EXCLUDE_PATHS["/home/jake/storage/lidarr"]="--exclude=config/MediaCover"
EXCLUDE_PATHS["/home/jake/storage/immich"]="--exclude=postgres"

BACKUP_DIR="/home/jake/backups"

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