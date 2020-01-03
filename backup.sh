#!/bin/bash
# This script was created to make Duplicity backups.
# One full backup per week then incremental.

# Backup destination (/var/backups/vps/server on wifi.local)
dest="scp://vps@local.atelier-medias.org:43/server"

## Dump MySQL

mysqldump --max_allowed_packet=256M --single-transaction --routines --events --triggers --add-drop-table --extended-insert --all-databases > /var/backups/sql/mysql_databases.sql

## Duplicity

# doing a monthly full backup (1W)
duplicity --no-encryption --full-if-older-than 1W --include='/etc' --include='/var/lib/xwiki' --include='/var/backups/sql/mysql_databases.sql' --exclude='**' / $dest

# check backup status before deleting old backups
if [ $? -eq 0 ]; then
        # cleaning the remote backup space (deleting backups older than 1 month)
        duplicity remove-older-than 1M --force $dest
else
        echo "Backup failed"
        exit 1
fi

exit 0
