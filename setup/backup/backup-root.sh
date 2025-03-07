#!/bin/bash

# Backup script for root filesystem to ZFS

# Exit on any error
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Timestamp for the backup
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIR="/datapool/backup/root"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Perform the backup using rsync
echo "Starting backup of root filesystem to $BACKUP_DIR..."
rsync -aAXv --delete --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/datapool/*"} / "$BACKUP_DIR/"

# Create a ZFS snapshot
SNAPSHOT_NAME="datapool/backup@root-$TIMESTAMP"
echo "Creating snapshot: $SNAPSHOT_NAME"
zfs snapshot "$SNAPSHOT_NAME"

echo "Backup completed successfully"
echo "Snapshot created: $SNAPSHOT_NAME"
