#!/bin/bash

file=/home/jake/backups/photoprism/mariadb-$(date +%Y-%m-%d_%H-%M-%S).sql

mkdir -p /home/jake/backups/photoprism

docker exec photoprism-photoprism-1 photoprism backup -i -f - > $file

find /home/jake/backups/photoprism -type f -mtime +14 -exec rm {} \;

if [ -s "$file" ]; then
  echo "Backup successful"
  JSON='{
    "content": ":white_check_mark: `MariaDB` backup for **'"Photoprism"'** has completed **SUCCESSFULLY**\nFile name: `'"$file"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"
  }'

  curl -X POST \
    -H "Content-Type: application/json" \
    -d "$JSON" \
    "$DISCORD_WEBHOOK_URL"
  exit 0
else
  echo "Backup failed"
  rm "$file"
  JSON='{
    "content": ":x: `MariaDB` backup for **'"Photoprism"'** has just **FAILED**\nFile name: `'"$file"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"
  }'

  curl -X POST \
    -H "Content-Type: application/json" \
    -d "$JSON" \
    "$DISCORD_WEBHOOK_URL"
  exit 1
fi
