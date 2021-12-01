#!/bin/bash

sudo apt install python3-dev redis-server

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

echo -e "please export NVM to your .bashrc file"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

nvm install 14
nvm use 14
npm install -g yarn

sudo apt install xvfb libfontconfig wkhtmltopdf python-is-python3 python2

# bench
pip3 install frappe-bench

# postgres
sudo apt install postgresql postgresql-contrib

echo -e "please run setup-db.sh to setup postgres"