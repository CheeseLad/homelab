#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source .env file if it exists
if [ -f "$SCRIPT_DIR/.env" ]; then
  set -a
  source "$SCRIPT_DIR/.env"
  set +a
fi

# Default configuration
BACKUP_DIR="${BACKUP_DIR:-/home/jake/backups}"
OUTPUT_DIR="${CCRP_BACKUP_DIR:-$BACKUP_DIR/ccrp}"
SERVICE_NAME="${CCRP_SERVICE_NAME:-Cable Creative Roleplay}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"

# Database parameters (defaults from environment if set)
DB_HOST="${CCRP_DB_HOST:-${DB_HOST:-${CCRP_IP:-$DB_IP}}}"
DB_PORT="${CCRP_DB_PORT:-${DB_PORT:-${PORT:-3306}}}"
DB_USER="${CCRP_DB_USER:-${DB_USER:-${CCRP_USER:-$DB_USERNAME}}}"
DB_PASSWORD="${CCRP_DB_PASSWORD:-${DB_PASSWORD:-${CCRP_PASS:-$DB_PASS}}}"
DB_NAME="${CCRP_DB_NAME:-${DB_NAME:-${CCRP_DATABASE:-$DATABASE_NAME}}}"
DB_SSL="${CCRP_DB_SSL:-${DB_SSL:-false}}"

print_usage() {
  echo "Usage: $(basename "$0") [options] or [ip] [port] [username] [password] [database]"
  echo
  echo "Options:"
  echo "  -h, --host, --ip <ip/host>     Database server hostname or IP"
  echo "  -P, --port <port>              Database server port (default: 3306)"
  echo "  -u, --user, --username <user>  Database username"
  echo "  -p, --password, --pass <pass>  Database password"
  echo "  -d, --database, --db <name>    Database name"
  echo "  -o, --output-dir <dir>         Backup output directory (default: $OUTPUT_DIR)"
  echo "      --ssl                      Enable SSL for connection"
  echo "      --skip-ssl, --no-ssl       Disable SSL for connection (default)"
  echo "      --help                     Show this help message"
  echo
  echo "Environment variables (or in $SCRIPT_DIR/.env):"
  echo "  CCRP_DB_HOST, CCRP_DB_PORT, CCRP_DB_USER, CCRP_DB_PASSWORD, CCRP_DB_NAME"
  echo "  CCRP_DB_SSL (default: false)"
  echo "  DISCORD_WEBHOOK_URL (optional for notifications)"
}

# Parse positional arguments or flags
if [ $# -gt 0 ] && [[ "$1" != -* ]]; then
  if [ $# -ge 5 ]; then
    DB_HOST="$1"
    DB_PORT="$2"
    DB_USER="$3"
    DB_PASSWORD="$4"
    DB_NAME="$5"
  elif [ $# -eq 4 ]; then
    DB_HOST="$1"
    DB_PORT="3306"
    DB_USER="$2"
    DB_PASSWORD="$3"
    DB_NAME="$4"
  else
    echo "ERROR: Invalid number of positional arguments ($# provided)."
    echo "Expected: <ip> <port> <username> <password> <database> (or without port for default 3306)"
    echo
    print_usage
    exit 1
  fi
else
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--host|--ip)
        DB_HOST="$2"
        shift 2
        ;;
      -P|--port)
        DB_PORT="$2"
        shift 2
        ;;
      -u|--user|--username)
        DB_USER="$2"
        shift 2
        ;;
      -p|--password|--pass)
        DB_PASSWORD="$2"
        shift 2
        ;;
      -d|--database|--db|--name)
        DB_NAME="$2"
        shift 2
        ;;
      -o|--output-dir)
        OUTPUT_DIR="$2"
        shift 2
        ;;
      --ssl)
        DB_SSL="true"
        shift
        ;;
      --skip-ssl|--no-ssl)
        DB_SSL="false"
        shift
        ;;
      --help)
        print_usage
        exit 0
        ;;
      *)
        echo "ERROR: Unknown option '$1'"
        echo
        print_usage
        exit 1
        ;;
    esac
  done
fi

# Validate required connection parameters
MISSING_PARAMS=()
[ -z "$DB_HOST" ] && MISSING_PARAMS+=("Host/IP (-h, --ip, or CCRP_DB_HOST)")
[ -z "$DB_PORT" ] && MISSING_PARAMS+=("Port (-P, --port, or CCRP_DB_PORT)")
[ -z "$DB_USER" ] && MISSING_PARAMS+=("Username (-u, --user, or CCRP_DB_USER)")
[ -z "$DB_PASSWORD" ] && MISSING_PARAMS+=("Password (-p, --password, or CCRP_DB_PASSWORD)")
[ -z "$DB_NAME" ] && MISSING_PARAMS+=("Database name (-d, --database, or CCRP_DB_NAME)")

if [ ${#MISSING_PARAMS[@]} -ne 0 ]; then
  echo "ERROR: Missing required database parameters:"
  for param in "${MISSING_PARAMS[@]}"; do
    echo "  - $param"
  done
  echo
  print_usage
  exit 1
fi

# Function to send Discord notification
send_webhook() {
  local service_name="$1"
  local status="$2"
  local file="$3"
  local size="$4"

  if [ -z "$DISCORD_WEBHOOK_URL" ]; then
    echo "Notice: DISCORD_WEBHOOK_URL is not set; skipping Discord notification."
    return 0
  fi

  local icon=""
  if [ "$status" == "SUCCEEDED" ]; then
    icon=":white_check_mark:"
  else
    icon=":x:"
  fi

  JSON='{
    "content": "'"$icon"' `'"$service_name"'` backup has **'"$status"'**\nFile: `'"$file"'`\nSize: `'"$size"'`\nDate: `'"$(TZ=Europe/Dublin date)"'`"
  }'

  curl -s -X POST \
    -H "Content-Type: application/json" \
    -d "$JSON" \
    "${DISCORD_WEBHOOK_URL}" > /dev/null
}

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_FILE="${OUTPUT_DIR}/ccrp_mysql_${TIMESTAMP}.sql"
ERROR_LOG=$(mktemp)

mkdir -p "$OUTPUT_DIR"

echo "Starting backup for $SERVICE_NAME ($DB_NAME) from $DB_HOST:$DB_PORT..."

# Determine SSL options
SSL_OPTS=()
if [ "$DB_SSL" = "true" ] || [ "$DB_SSL" = "1" ]; then
  SSL_OPTS=("--ssl")
else
  # Default to skipping SSL for servers that do not support TLS
  SSL_OPTS=("--skip-ssl")
fi

# Run mysqldump
mysqldump \
  -h "$DB_HOST" \
  -P "$DB_PORT" \
  -u "$DB_USER" \
  --password="$DB_PASSWORD" \
  "${SSL_OPTS[@]}" \
  "$DB_NAME" > "$OUTPUT_FILE" 2> "$ERROR_LOG"
DUMP_EXIT_CODE=$?

# Cleanup old backups
find "$OUTPUT_DIR" -type f -name "*.sql" -mtime +"$RETENTION_DAYS" -exec rm -f {} \;
echo "Old backups in '$OUTPUT_DIR' older than $RETENTION_DAYS days have been cleaned up."

# Check result
if [ $DUMP_EXIT_CODE -eq 0 ] && [ -s "$OUTPUT_FILE" ]; then
  size=$(du -h "$OUTPUT_FILE" | cut -f1)
  echo "$SERVICE_NAME Backup successful ($size)"
  send_webhook "$SERVICE_NAME" "SUCCEEDED" "$OUTPUT_FILE" "$size"
  rm -f "$ERROR_LOG"
  exit 0
else
  echo "$SERVICE_NAME Backup failed"
  if [ -s "$ERROR_LOG" ]; then
    echo "mysqldump error:" >&2
    cat "$ERROR_LOG" >&2
  fi
  rm -f "$OUTPUT_FILE"
  rm -f "$ERROR_LOG"
  send_webhook "$SERVICE_NAME" "FAILED" "$OUTPUT_FILE" "0B"
  exit 1
fi
