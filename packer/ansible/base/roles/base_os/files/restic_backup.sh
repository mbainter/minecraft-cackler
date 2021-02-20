#!/bin/bash

base_path="/mnt/gamocosm_bifrost_minecraft"
export RESTIC_REPOSITORY="${base_path}/backups"
export RESTIC_PASSWORD_FILE="${base_path}/.restic/password"

MCSW_PASSWORD=$(sed -n '2{p;q}' /opt/gamocosm/mcsw-auth.txt)

# Test to make sure that restic isn't in the middle of a backup
# If it is, wait for that to complete indefinitely
# if it isn't, or when it's done, lock it so that a new backup
# doesn't start while we're syncing to Backblaze
exec 100>/var/tmp/minecraft_backup.lock || exit 1
flock 100 || exit 1
trap 'rm -f /var/tmp/minecraft_backup.lock' EXIT

execute-command () {
  local COMMAND=$1
  #local COMMAND=$(echo -n "$1" | jq -aRs .)
  /opt/gamocosm/bin/mcsw-client exec "{ \"command\": \"${COMMAND}\" }"
}

notify-players-color () {
  local MESSAGE=$1
  local HOVER_MESSAGE=$2
  local COLOR=$3
  local quoted_message=$(jq -Mcn \
           --arg PREFIX "Server: " \
           --arg COLOR "${COLOR}" \
           --arg MESSAGE "${MESSAGE}" \
	   -f /mnt/gamocosm_bifrost_minecraft/bin/mcsw_msg_template.json | \
           python -c 'import json,sys; print(json.dumps(sys.stdin.read()))' | \
	   sed -e 's/^"//;s/"$//'
   )
  execute-command "tellraw @a $quoted_message"
}

notify-players () {
  local MESSAGE=$1
  local HOVER_MESSAGE=$2
  notify-players-color "$MESSAGE" "blue"
}

notify-players-error () {
  local MESSAGE=$1
  local HOVER_MESSAGE=$2
  notify-players-color "$MESSAGE" "red"
}

notify-players-success () {
  local MESSAGE=$1
  local HOVER_MESSAGE=$2
  notify-players-color "$MESSAGE" "green"
}

date_tag=$(date +%F)
specific_tag=$(date +%F_%H-%M-%S)
notify-players "Starting backup... ($specific_tag)"

execute-command "save-off"

/usr/bin/restic backup --verbose --exclude-file=${base_path}/minecraft/restic_excludes.txt --tag gamocosm --tag ${date_tag} --tag ${specific_tag} ${base_path}/minecraft
restic_backup=$?

# TODO - add a restic check and prune to this
execute-command "save-on"
execute-command "save-all"

if [ $restic_backup -eq 0 ]; then
  notify-players "Backup was successful."
  restic forget -l5 -H24 -d7 -w4 -m3 --prune
else
  notify-players "Backup failed."
fi

exit $restic_backup
