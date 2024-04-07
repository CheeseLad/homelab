#!/bin/bash

file=/home/jake/backups/hedgedoc/postgres-$(date +%Y-%m-%d_%H-%M-%S).sql

mkdir -p /home/jake/backups/hedgedoc

docker exec hedgedoc-database pg_dump hedgedoc -U hedgedoc > $file

find /home/jake/backups/hedgedoc -type f -mtime +14 -exec rm {} \;

if [ -s "$file" ]; then
  echo "Backup successful"
  JSON='{
    "content": ":white_check_mark: `PostgreSQL` backup for **'"Hedgedoc"'** has completed **SUCCESSFULLY**\nFile name: `'"$file"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"
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
    "content": ":x: `PostgreSQL` backup for **'"Hedgedoc"'** has just **FAILED**\nFile name: `'"$file"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"
  }'

  curl -X POST \
    -H "Content-Type: application/json" \
    -d "$JSON" \
    "$DISCORD_WEBHOOK_URL"
  exit 1
fi