#!/bin/bash
######## EDIT SERVER CONSTANTS HERE ########
mem="8G"
############################################

# navigate to the server folder
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

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
