# Colliers Development Environment

replace satyajit-ink with your github username

```bash
git clone https://satyajit-ink@github.com/inkers-ai/colliers-dev.git
```

## Frappe Setup

Open the devcontainer setup

`Ctrl + Shift + P -> Remote-Containers: Rebuild and reopen in Container`

from here on follow the README.md which is there inside the devcontainer.

## Airflow Setup

For now airflow is NOT used directly in the same docker-compose.yml file. But it's pretty simple to get it to work with the frappe environment by keeping them on the same network. Also make sure the frappe devcontainer is running beforehand, because airflow devcontainer does not create a new network, it uses the network created by frappe compose.

```bash
docker-compose up -f airflow/docker-compose.yml
```

## Windows Specific Setup

Make sure to use Docker for Windows with WSL2 backend.

Move the `colliers-dev` folder to WSL2 instance, like Ubuntu 20.04, and open VSCode in that. using Windows paths slows down the npm install process really slow, so we have to move the project to WSL2, and docker will just pick it up.
