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
  "/home/jake/storage/listmonk"
  "/home/jake/storage/overseerr"
  "/home/jake/storage/paperless-ngx"
  "/home/jake/storage/photoprism"
  "/home/jake/storage/pi-hole"
  "/home/jake/storage/portainer"
  "/home/jake/storage/pterodactyl"
  "/home/jake/storage/radarr"
  "/home/jake/storage/qbittorrent"
  "/home/jake/storage/transmission"
  "/home/jake/storage/vaultwarden"
  "/home/jake/storage/speedtest-tracker"
  "/home/jake/storage/sonarr"
  "/home/jake/storage/tautulli"
  "/home/jake/storage/uptime-kuma"
  "/home/jake/storage/jellyseerr"
  "/home/jake/storage/fotosoc-wordpress"
  "/home/jake/storage/grav-mps"
  "/home/jake/storage/wordpress-dcumps"
  "/home/jake/storage/wordpress-dcumps-import"
)

#  "/home/jake/storage/plex"

declare -A EXCLUDE_PATHS
EXCLUDE_PATHS["/home/jake/storage/jellyfin"]="--exclude=data/metadata --exclude=cache"
EXCLUDE_PATHS["/home/jake/storage/qbittorrent"]="--exclude=downloads"
EXCLUDE_PATHS["/home/jake/storage/hedgedoc"]="--exclude=uploads"
EXCLUDE_PATHS["/home/jake/storage/lidarr"]="--exclude=config/MediaCover"
EXCLUDE_PATHS["/home/jake/storage/radarr"]="--exclude=MediaCover"
EXCLUDE_PATHS["/home/jake/storage/immich"]="--exclude=postgres --exclude=backups --exclude=thumbs"
EXCLUDE_PATHS["/home/jake/storage/photoprism"]="--exclude=storage --exclude=database"
EXCLUDE_PATHS["/home/jake/storage/speedtest-tracker"]="--exclude=www/node_modules --exclude=www/vendor"
EXCLUDE_PATHS["/home/jake/storage/sonarr"]="--exclude=MediaCover"
EXCLUDE_PATHS["/home/jake/storage/grav-mps"]="--exclude=config/www/backup"
#EXCLUDE_PATHS["/home/jake/storage/plex"]="--exclude='Library/Application Support/Plex Media Server/Metadata' --exclude='Library/Application Support/Plex Media Server/Drivers'"

#BACKUP_DIR="/home/jake/backups"
BACKUP_DIR="/mnt/usb1/Jake/Device Automated Backups/CheeseLab/Internal Storage/home/jake/backups"
#SECONDARY_BACKUP_DIR="/mnt/usb1/CheeseLab/backups"

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