#!/bin/bash

base_path=/mnt/gamocosm_bifrost_minecraft
# Test if we've already run today
rclone_complete_file="/var/tmp/rclone_completed.$(date +%F)"
if [ -f $rclone_complete_file ]; then
  echo "Exiting: offsite backup already happened today"
  exit 0;
fi

export RESTIC_PASSWORD_FILE="${base_path}/.restic/password"
restic_local_backup="${base_path}/backups"
local_rclone_target="/var/tmp/rclone_local"
remote_rclone_target="b2:minecraft-bifrost/do"

# Test to make sure that restic isn't in the middle of a backup
# If it is, wait for that to complete indefinitely
# if it isn't, or when it's done, lock it so that a new backup
# doesn't start while we're syncing to Backblaze
exec 100>/var/tmp/minecraft_backup.lock || exit 1
flock 100 || exit 1
trap 'rm -f /var/tmp/minecraft_backup.lock' EXIT

# If any stage of the backup fails, fail the whole thing
set -o pipefile

# First, cleanup our local restic repository
# Keep:
#  - 5 most recent backups
#  - last 24 hourly backups
#  - last 7 daily backups
#  - last 4 weekly backups
#  - last 3 monthly backups
# Because the most recent snapshot counts as a daily, weekly and monthly, we +1
# what we actually want to make sure we keep enough history
restic -r "$restic_local_backup" forget -l5 -H24 -d7 -w4 -m3 --prune


# Next, rclone to a local path so we can clean it up before syncing
rclone sync $restic_local_backup $local_rclone_target
sync
sleep 1

# Now, clean up the local target repo
# Keep:
#  - most recent backup
#  - last 2 hourly backups
#  - last 3 daily backups
#  - last 3 weekly backups
#  - last 2 monthly backups
# Because the most recent snapshot counts as a daily, weekly and monthly, we +1
# what we actually want to make sure we keep enough history
restic -r "$local_rclone_target" forget -l2 -H2 -d7 -w3 -m2 --prune
sync
sleep 1

# Last, rclone to the offsite bucket
rclone sync $local_rclone_target $remote_rclone_target

set +o pipefail

# Clean up old completion files and create a current one
rm -f /var/tmp/rclone_completed.*
touch $rclone_complete_file
