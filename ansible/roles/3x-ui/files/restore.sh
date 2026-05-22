#!/bin/sh
set -e

apk add --no-cache aws-cli zstd >/dev/null 2>&1

aws s3 cp "s3://backups/${BACKUP_OBJECT_KEY}" /tmp/backup.archive

cd /restore
zstd -dc /tmp/backup.archive | tar -x --strip-components=2
