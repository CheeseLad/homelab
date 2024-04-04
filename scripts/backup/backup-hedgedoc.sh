#!/bin/bash

file=/home/jake/backups/hedgedoc/postgres-$(date +%Y-%m-%d_%H-%M-%S).sql

mkdir -p /home/jake/backups/hedgedoc

docker exec hedgedoc-database pg_dump hedgedoc -U hedgedoc > $file

find /home/jake/backups/hedgedoc -type f -mtime +14 -exec rm {} \;

if [ -s "$file" ]; then
  echo "Backup successful"
  exit 0
else
  rm $file
fi