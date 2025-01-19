#!/bin/bash

FOLDERS_TO_ARCHIVE=(
  "/home/jake/storage/cable-anarchy-minecraft"
  "/home/jake/storage/cloudflared"
  "/home/jake/storage/hedgedoc"
  "/home/jake/storage/homepage"
  "/home/jake/storage/jackett"
  "/home/jake/storage/lidarr"
  "/home/jake/storage/jellyfin"
  "/home/jake/storage/overseerr"
  "/home/jake/storage/photoprism"
  "/home/jake/storage/pterodactyl"
  "/home/jake/storage/qbittorrent/config"
  "/home/jake/storage/vaultwarden"
)

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

  mkdir -p "$BACKUP_FOLDER"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create backup directory '$BACKUP_FOLDER'."
    return 1
  fi

  tar -czf "${BACKUP_FOLDER}/${ARCHIVE_NAME}" -C "$(dirname "$FOLDER_TO_ARCHIVE")" "$(basename "$FOLDER_TO_ARCHIVE")"
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
  if [ $? -ne 0 ]; then
    echo "Error: Failed to clean up old backups in '$BACKUP_FOLDER'."
    return 1
  fi

  echo "Old backups in '$BACKUP_FOLDER' have been cleaned up."
}

for FOLDER in "${FOLDERS_TO_ARCHIVE[@]}"; do
  archive_folder "$FOLDER"
  cleanup_old_backups "$FOLDER"
done