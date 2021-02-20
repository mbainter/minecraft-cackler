#!/bin/bash

base_path=/mnt/gamocosm_bifrost_minecraft
export RESTIC_REPOSITORY="${base_path}/backups"
export LOCAL_RCLONE="${base_path}/tmp/rclone_local"
export REMOTE_RCLONE="b2:minecraft-bifrost/do"
export RESTIC_PASSWORD_FILE=${base_path}/.restic/password
