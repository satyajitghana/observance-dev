#!/bin/bash
USER=
PASSWORD=

# user or password empty throw error
if [ -z "$USER" ] || [ -z "$PASSWORD" ]; then
	echo "User or password empty, please set in $0"
	exit 1
fi

sudo -u postgres createuser -s -i -d -r -l -w $USER
sudo -u postgres psql -c "ALTER ROLE $USER WITH PASSWORD '$PASSWORD';"
sudo -u postgres psql -c "CREATE DATABASE $USER OWNER $USER;"