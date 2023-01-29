#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SERVER_DIR=$SCRIPT_DIR/..
ENV_DIR=${SCRIPT_DIR}/.env

cd $SCRIPT_DIR/..
pwd

if [ -r "$ENV_DIR" ]; then
	export $(cat $ENV_DIR | xargs)
fi

if [[ -z "$GLACIER_VAULT" ]]; then
	echo GLACIER_VAULT must be set 1>&2
	exit 1
fi

if [[ -z "$AWS_ACCOUNT_ID" ]]; then
	AWS_ACCOUNT_ID="-"
fi

NEXT_BACKUP_FILE=$SCRIPT_DIR/nextbackup

WORLD_FILE=world6
LOCAL_BACKUPS=backups

if ! [[ -d "$LOCAL_BACKUPS" ]]; then
	mkdir $LOCAL_BACKUPS
fi

re='^[0-9]+$'

# Get current time and check for next backup
CURRENT_TIME=$(date +%s)

NEXT_BACKUP=$(cat ${NEXT_BACKUP_FILE})
if ! [[ $NEXT_BACKUP =~ $re ]]; then
	NEXT_BACKUP=0
fi

# Handle bi-weekly backups
if [ $CURRENT_TIME -gt $(date --date="@$NEXT_BACKUP" +%s) ]; then
	echo "Time for a weekly backup"

	# backup
	RECENT_BACKUP=$(find $LOCAL_BACKUPS -iname *.zip | tail -n 1)
	DESCRIPTION=$WORLD_FILE-$(date -d "@$CURRENT_TIME" +%F)	

	if [[ -e "$RECENT_BACKUP" ]]; then
		GLACIER_RESPONSE=$(aws glacier upload-archive 
			--vault-name $GLACIER_VAULT \
			--account-id $AWS_ACCOUNT_ID \
			--body $RECENT_BACKUP \
			--archive-description $DESCRIPTION)
		
	fi

	echo $(date -d "$(date -d "@$CURRENT_TIME" +%F) + 14 days" +%s) > $NEXT_BACKUP_FILE
fi
