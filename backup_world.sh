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

zip -r "$LOCAL_BACKUPS/$(date +%F).zip" world6/

