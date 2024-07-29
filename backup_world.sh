#!/bin/bash -xe

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SERVER_DIR=$( cd -- "$SCRIPT_DIR"/.. &> /dev/null && pwd )
ENV_DIR=${SCRIPT_DIR}/.env
PIPENV=~/.pyenv/shims/pipenv

while getopts o:z flag
do
	case "${flag}" in
		o) s3_output=${OPTARG};;
		z) zip=true;
	esac
done

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

ls -tp $LOCAL_BACKUPS | grep ".zip$" | tail -n +2 | xargs -I {} rm -- $LOCAL_BACKUPS/{}

if [[ -n "${zip}" ]]; then
	tmux send-keys -t mcserver "save-off" C-m
	tmux send-keys -t mcserver "save-all" C-m
	zip -r "$LOCAL_BACKUPS/$(date +%F).zip" world6/
	tmux send-keys -t mcserver "save-on" C-m
fi

if [[ -n "${s3_output}" ]]; then
	# backup to s3 as "latest"
	export PIPENV_PIPFILE=$SCRIPT_DIR/Pipfile && $PIPENV run python $SCRIPT_DIR/s3_backup.py -b "$S3_BUCKET" -d "$SERVER_DIR/$LOCAL_BACKUPS" -k $s3_output
fi

