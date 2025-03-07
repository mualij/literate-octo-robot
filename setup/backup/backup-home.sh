#!/bin/bash

# Backup script for home directory to ZFS

# Exit on any error
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Get the username to backup (defaults to current user if not specified)
USERNAME="${1:-$SUDO_USER}"
if [ -z "$USERNAME" ]; then
    echo "Could not determine the username to backup"
    exit 1
fi

# Timestamp for the backup
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIR="/datapool/backup/home/$USERNAME"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Perform the backup using rsync
echo "Starting backup of /home/$USERNAME to $BACKUP_DIR..."
rsync -aAXv --delete --exclude={"*.tmp","*.temp","*/node_modules/*","*/.cache/*"} "/home/$USERNAME/" "$BACKUP_DIR/"

# Create a ZFS snapshot
SNAPSHOT_NAME="datapool/backup@home-$USERNAME-$TIMESTAMP"
echo "Creating snapshot: $SNAPSHOT_NAME"
zfs snapshot "$SNAPSHOT_NAME"

echo "Backup completed successfully"
echo "Snapshot created: $SNAPSHOT_NAME"
