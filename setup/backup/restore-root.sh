#!/bin/bash

# Restore script for root filesystem from ZFS snapshot

# Exit on any error
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# List available snapshots for root
echo "Available root snapshots:"
zfs list -t snapshot | grep "datapool/backup@root" | awk '{print $1}'

# Ask which snapshot to restore from
read -p "Enter the snapshot name to restore from (or press Enter to cancel): " SNAPSHOT

if [ -z "$SNAPSHOT" ]; then
    echo "Restore cancelled"
    exit 0
fi

# Check if the snapshot exists
if ! zfs list -t snapshot | grep -q "$SNAPSHOT"; then
    echo "Snapshot $SNAPSHOT does not exist"
    exit 1
fi

# Get the mount point of the snapshot
SNAPSHOT_MOUNTPOINT="/mnt/restore-root"

# Mount the snapshot temporarily
echo "Mounting snapshot $SNAPSHOT to $SNAPSHOT_MOUNTPOINT..."
mkdir -p "$SNAPSHOT_MOUNTPOINT"
mount -t zfs "$SNAPSHOT" "$SNAPSHOT_MOUNTPOINT"

# Confirm before proceeding
echo "WARNING: This will overwrite your current root filesystem!"
read -p "Are you sure you want to proceed? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Restore cancelled"
    umount "$SNAPSHOT_MOUNTPOINT"
    rmdir "$SNAPSHOT_MOUNTPOINT"
    exit 0
fi

# Perform the restore using rsync
echo "Starting restore of root filesystem from $SNAPSHOT_MOUNTPOINT/root..."
rsync -aAXv --delete --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/datapool/*"} "$SNAPSHOT_MOUNTPOINT/root/" /

# Cleanup
echo "Unmounting snapshot..."
umount "$SNAPSHOT_MOUNTPOINT"
rmdir "$SNAPSHOT_MOUNTPOINT"

echo "Restore completed successfully"
