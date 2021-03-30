#!/bin/bash

base_path="/srv"
export RESTIC_REPOSITORY="${base_path}/backups"
export RESTIC_PASSWORD_COMMAND="/usr/local/bin/fetch_restic_pass.sh"

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
  /usr/bin/tmux send -t minecraft:0 "$1" C-m
}

notify-players-color () {
  local MESSAGE=$1
  local COLOR=$2
  local raw_msg=$(sed "s/PREFIX/Server: /;s/COLOR/$COLOR/;s/MESSAGE/$MESSAGE/" \
	  /usr/local/share/minecraft/msg_template.json)
  local quoted_message=$(sed "s/PREFIX/Server: /;s/COLOR/$COLOR/;s/MESSAGE/$MESSAGE/" \
	  /usr/local/share/minecraft/msg_template.json | \
	  jq -Mrc '.' /dev/stdin
   )
  execute-command "tellraw @a $quoted_message"
}

notify-players () {
  local MESSAGE=$1
  notify-players-color "$MESSAGE" "blue"
}

notify-players-error () {
  local MESSAGE=$1
  notify-players-color "$MESSAGE" "red"
}

notify-players-success () {
  local MESSAGE=$1
  notify-players-color "$MESSAGE" "green"
}

date_tag=$(date +%F)
specific_tag=$(date +%F_%H-%M-%S)
notify-players "Starting backup... ($specific_tag)"

execute-command "save-all"
execute-command "save-off"

/usr/local/bin/restic backup --verbose --exclude-file=${base_path}/minecraft/restic_excludes.txt --tag aws --tag ${date_tag} --tag ${specific_tag} ${base_path}/minecraft
restic_backup=$?

# TODO - add a restic check and prune to this
execute-command "save-on"
sleep 1
execute-command "save-all"

if [ $restic_backup -eq 0 ]; then
  notify-players "Backup was successful."
  #restic forget -l5 -H24 -d7 -w4 -m3 --prune
else
  notify-players "Backup failed."
fi

exit $restic_backup
