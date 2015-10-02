#!/bin/sh
# This script was created to make Duplicity backups.
# One full backup per week then incremental.

GOOGLE_ID=$1

# Setting the pass phrase to encrypt the backup files.
export PASSPHRASE=$2
# Setting Google Drive account key
export GOOGLE_DRIVE_ACCOUNT_KEY=$(< /root/.adm/pydriveprivatekey.pem)

## Dump MySQL

mysqldump --single-transaction --routines --events --triggers --add-drop-table --extended-insert --all-databases > /var/backups/sql/mysql_databases.sql

## Duplicity

# doing a monthly full backup (1W)
duplicity --full-if-older-than 1W --include="/etc" --include="/var/lib/xwiki" --include="/var/backups/sql/mysql_databases.sql" --exclude="**" / pydrive://${GOOGLE_ID}@developer.gserviceaccount.com/backup/server
# cleaning the remote backup space (deleting backups older than 1 month)
duplicity remove-older-than 1M --force pydrive://${GOOGLE_ID}@developer.gserviceaccount.com/backup/server

# Unsetting the confidential variables
unset GOOGLE_ID
unset PASSPHRASE
unset GOOGLE_DRIVE_ACCOUNT_KEY

exit 0
