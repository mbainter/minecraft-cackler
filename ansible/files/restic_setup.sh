#!/bin/bash

base_path="/srv"
export RESTIC_REPOSITORY="${base_path}/backups"
export RESTIC_PASSWORD_COMMAND="/usr/local/bin/fetch_restic_pass.sh"
export LOCAL_RCLONE="/var/tmp/rclone_local"
export REMOTE_RCLONE="s3:bifrost-minecraft-backups/Valhelsia2"
