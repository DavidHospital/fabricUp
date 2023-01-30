#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SERVER_DIR=$SCRIPT_DIR/..
ENV_DIR=${SCRIPT_DIR}/.env

cd $SCRIPT_DIR/..
pwd

if [ -r "$ENV_DIR" ]; then
	export $(cat $ENV_DIR | xargs)
fi

if [[ -z "$S3_BUCKET" ]]; then
	echo S3_BUCKET must be set 1>&2
	exit 1
fi

WORLD_FILE=world6
LOCAL_BACKUPS=backups

if ! [[ -d "$LOCAL_BACKUPS" ]]; then
	mkdir $LOCAL_BACKUPS
fi

re='^[0-9]+$'

tmux send-keys -t mcserver "save-all" C-m
tmux send-keys -t mcserver "save-off" C-m
zip -r "$LOCAL_BACKUPS/$(date +%F).zip" world6/
tmux send-keys -t mcserver "save-on" C-m

# backup to s3 as "latest"
$(cd $SCRIPT_DIR && pipenv run python $SCRIPT_DIR/s3_backup.py -d $SERVER_DIR/$LOCAL_BACKUPS -b $S3_BUCKET -k latest.zip)

ls -tp $LOCAL_BACKUPS/*.zip | tail -n +8 | xargs -I {} rm -- {}
