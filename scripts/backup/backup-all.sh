#!/bin/bash

FOLDERS_TO_ARCHIVE=(
  "/home/jake/storage/cable-anarchy-minecraft"
  "/home/jake/storage/cloudflared"
  "/home/jake/storage/hedgedoc"
  "/home/jake/storage/homepage"
  "/home/jake/storage/jackett"
  "/home/jake/storage/photoprism"
  "/home/jake/storage/qbittorrent"
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

for FOLDER in "${FOLDERS_TO_ARCHIVE[@]}"; do
  archive_folder "$FOLDER"
done
