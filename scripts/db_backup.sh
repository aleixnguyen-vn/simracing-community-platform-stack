#!/bin/bash
set -o pipefail # get exit code of backup command

export $(grep -v '^#' .env | xargs)

BAK_DIR="/var/backup/db"
BAK_FILE="$BAK_DIR/db_bak_$(date +%Y-%m-%d).sql.gz"

mkdir -p $BAK_DIR

docker exec db_app mariadb-dump -u root -p$DB_ROOT_PASS --databases "$WP_DB_NAME" | gzip > "$BAK_FILE"

BACKUP_STATUS=$?

if [ $BACKUP_STATUS -ne 0 ]; then
        echo "ERROR: DATABASE BACKUP JOB FAILED!"
        exit 1
fi

# AUTO ROTATION BACKUP WEEKLY

find "$BAK_DIR" -type f -name "*.sql.gz" -mtime +7 -delete

echo "DB Backup job completed successfully. File saved at $BAK_FILE"