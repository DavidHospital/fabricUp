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
	echo AWS_ACCOUNT_ID must be set 1>&2
	exit 1
fi

NEXT_WEEK_FILE=$SCRIPT_DIR/nextweek
NEXT_MONTH_FILE=$SCRIPT_DIR/nextmonth

WORLD_FILE=world6
LOCAL_BACKUPS=backups

if ! [[ -d "$LOCAL_BACKUPS" ]]; then
	mkdir $LOCAL_BACKUPS
fi

re='^[0-9]+$'

# Get current time and check for next backup
CURRENT_TIME=$(date +%s)

NEXT_WEEK=$(cat ${NEXT_WEEK_FILE})
if ! [[ $NEXT_WEEK =~ $re ]]; then
	NEXT_WEEK=0
fi

# Handle weekly backups
if [ $CURRENT_TIME -gt $(date --date="@$NEXT_WEEK" +%s) ]; then
	echo "Time for a weekly backup"

	# backup
	RECENT_BACKUP=$(find $LOCAL_BACKUPS -iname *.zip | tail -n 1)
	echo $RECENT_BACKUP
	if [[ -e "$RECENT_BACKUP" ]]; then
		aws glacier upload-archive --vault-name $GLACIER_VAULT \
					   --account-id $AWS_ACCOUNT_ID \
					   --body $RECENT_BACKUP
	fi

	echo $(date -d "$(date -d "@$CURRENT_TIME" +%F) + 7 days" +%s) > $NEXT_WEEK_FILE
fi
