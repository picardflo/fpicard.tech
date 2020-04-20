#!/bin/bash

STORAGE_PATH="/srv/mirror/"
EXCLUDE_PATH="/srv/scripts/exclusion-file"
LOGS_PATH="/srv/scripts/rsync_fr.ubuntu.com.log"

rsync \
--dry-run \
--human-readable \
--exclude-from=$EXCLUDE_PATH \
--log-file=$LOGS_PATH \
--bwlimit=30000 \
--recursive \
--links \
--perms \
--times \
--compress \
--progress \
--delete \
--delete-after \
rsync://fr.archive.ubuntu.com/ubuntu/ \
$STORAGE_PATH


