#!/bin/bash

set +x
base_path=/srv
# Test if we've already run today
rclone_complete_file="/var/tmp/rclone_completed.$(date +%F)"
if [ -f $rclone_complete_file ]; then
  echo "Exiting: offsite backup already happened today"
  exit 0;
fi

export RESTIC_PASSWORD_COMMAND="/usr/local/bin/fetch_restic_pass.sh"
restic_local_backup="${base_path}/backups"
local_rclone_target="/mnt/rclone_local"
remote_rclone_target="s3:bifrost-minecraft-backups/Valhelsia2"

# Test to make sure that restic isn't in the middle of a backup
# If it is, wait for that to complete indefinitely
# if it isn't, or when it's done, lock it so that a new backup
# doesn't start while we're syncing to Backblaze
exec 100>/var/tmp/minecraft_backup.lock || exit 1
flock 100 || exit 1
trap 'rm -f /var/tmp/minecraft_backup.lock' EXIT

# Create a new volume for storing the temporary copy
input_dir="/usr/local/share/minecraft"
output=$(aws ec2 create-volume --cli-input-yaml file://${input_dir}/create_rclone_volume.yaml)

if [ $? -ne 0 ]; then
	echo "Failed to create volume!"
	exit 1;
fi
volumeid=$(echo $output | jq -r '.VolumeId')
aws_token=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
instanceid=$(curl -H "X-aws-ec2-metadata-token: $aws_token" -s http://169.254.169.254/latest/meta-data/instance-id)
# Alternately:
# instanceid=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=Minecraft" "Name=tag:Environment,Values=live" --query "Reservations[].Instances[].InstanceId" --output text)

function cleanup {
	umount $local_rclone_target
	echo "Detach temporary volume:"
	aws ec2 detach-volume --volume-id $1
	echo -n "Waiting on volume to be detached..."
	volstatus='in-use'
	while [ "$volstatus" != "available" ]; do
	  sleep 1
	  volstatus=$(aws ec2 describe-volumes --volume-id $volumeid --no-cli-pager --output=json | jq -r '.Volumes[0].State')
	done
	echo -e "done\nDeleting temporary volume:"
	aws ec2 delete-volume --volume-id $1
}

# Wait for the volume to be ready
echo "Waiting on volume to become available..."
volstatus=''
while [ "$volstatus" != "available" ]; do
  sleep 1
  volstatus=$(aws ec2 describe-volumes --volume-id $volumeid --no-cli-pager --output=json | jq -r '.Volumes[0].State')
done

# First, attach the volume to the instance
aws ec2 attach-volume --device /dev/sdi --instance-id ${instanceid} --volume-id ${volumeid}

if [ $? -ne 0 ]; then
	echo "Failed to attach volume, attempting to delete it..."
	aws ec2 delete-volume --volume-id ${volumeid}
	exit 1;
fi

echo "Waiting on volume to be attached..."
volstatus='available'
while [ "$volstatus" != "in-use" ]; do
  sleep 1
  volstatus=$(aws ec2 describe-volumes --volume-id $volumeid --no-cli-pager --output=json | jq -r '.Volumes[0].State')
done

sleep 2

echo "Creating filesystem on temporary volume..."
test -z "$(sudo blkid /dev/nvme2n1)" && sudo mkfs -t xfs -L rclone_tmp /dev/nvme2n1

if [ $? -ne 0 ]; then
	echo "Failed to create filesystem for volume, attempting to delete it..."
	cleanup ${volumeid}
	exit 1;
fi

mount $local_rclone_target

if [ $? -ne 0 ]; then
	echo "Failed to mount filesystem for volume, attempting to delete it..."
	cleanup ${volumeid}
	exit 1;
fi

sudo chown mcuser:minecraft $local_rclone_target

# Next, cleanup our local restic repository
# Keep:
#  - 5 most recent backups
#  - last 24 hourly backups
#  - last 7 daily backups
#  - last 4 weekly backups
#  - last 3 monthly backups
# Because the most recent snapshot counts as a daily, weekly and monthly, we +1
# what we actually want to make sure we keep enough history
echo "Cleaning up restic snapshot history:"
restic -r "$restic_local_backup" forget -l5 -H24 -d7 -w4 -m3 --prune

if [ $? -ne 0 ]; then
	echo "Failed to clean up local backup, aborting and attempting to clean up volume..."
	cleanup ${volumeid}
	exit 1
fi

# Next, rclone to a local path so we can clean it up before syncing
echo "Sync restic snapshots to temporary filesystem with rclone:"
rclone sync $restic_local_backup $local_rclone_target

if [ $? -ne 0 ]; then
	echo "Failed to sync to ${local_rclone_target}, aborting and attempting to clean up volume..."
	cleanup ${volumeid}
	exit 1
fi

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
echo "Prune the rclone repository to prepare for s3 sync:"
restic -r "$local_rclone_target" forget -l2 -H2 -d7 -w3 -m2 --prune

if [ $? -ne 0 ]; then
	echo "Failed to clean up ${local_rclone_target}, aborting and attempting to clean up volume..."
	cleanup
	exit 1
fi

sync
sleep 1

# Last, rclone to the offsite bucket
echo "Sync rclone copy to S3:"
rclone sync $local_rclone_target $remote_rclone_target --update --use-server-modtime --fast-list

# cleanup temporary volume
cleanup ${volumeid}

# Clean up old completion files and create a current one
rm -f /var/tmp/rclone_completed.*
touch $rclone_complete_file
