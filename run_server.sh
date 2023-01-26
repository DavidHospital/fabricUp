#!/bin/bash
######## EDIT SERVER CONSTANTS HERE ########
mem="6G"
save_backup="true"
use_git="true"
prune_backups="true"
############################################

# navigate to the server folder
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

# create a backup and prune the folder if necessary
if [ "${save_backup}" == "true" ]
then
    if [ "${use_git}" == "true" ]
    then
        git add *
        git commit -m "Auto Backup of `date`"
    else
        python3 fabricUp/backup.py -w
        if [ "${prune_backups}" == "true" ]
        then
            python3 fabricUp/prune_backups.py
        fi
    fi
fi

# create the eula if necessary
if [ ! -f eula.txt ]
then
    echo "eula=true" > eula.txt
fi

# run the server
java -Xms"${mem}" -Xmx"${mem}" -jar server.jar nogui

# give user chance to quit before restarting

echo "The server is going to restart in 5 seconds!"
echo "--- Press Ctrl + C to cancel. ---"

for i in 5 4 3 2 1
do
	echo "  Restarting in $i..."
	sleep 1
done

echo "--- The Server is Restarting! --- "
exec fabricUp/run_server.sh
