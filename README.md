# Colliers Development Environment

## Frappe Setup

Open the devcontainer setup

`Ctrl + Shift + P -> Remote-Containers: Rebuild and reopen in Container`

from here on follow the README.md which is there inside the devcontainer.

## Airflow Setup

For now airflow is NOT used directly in the same docker-compose.yml file. But it's pretty simple to get it to work with the frappe environment by keeping them on the same network. Also make sure the frappe devcontainer is running beforehand, because airflow devcontainer does not create a new network, it uses the network created by frappe compose.

```bash
docker-compose up -f airflow/docker-compose.yml
```
