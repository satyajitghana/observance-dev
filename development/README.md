# Observance Development

## Setup the Development repo

## Initial Setup

```bash
bench init --skip-redis-config-generation --frappe-branch version-13 inkers-bench
cd inkers-bench
```

```bash
bench set-redis-cache-host redis-cache:6379
bench set-redis-queue-host redis-queue:6379
bench set-redis-socketio-host redis-socketio:6379

```

```bash
bench new-site inkers.localhost --admin-password admin --db-type postgres --db-host postgresql
```

the default super user and password for postgres is `postgres:123`

set the postgres login and password

```bash
bench config set-common-config -c root_login postgres
bench config set-common-config -c root_password '"123"'
```

Set bench developer mode on the new site

```bash
bench --site inkers.localhost set-config developer_mode 1
bench --site inkers.localhost clear-cache
```

```bash
bench start
```

Open <http://inkers.localhost:8000>

## Install ERPNext (We don't use this anymore)

```bash
bench get-app --branch version-13 erpnext https://github.com/frappe/erpnext.git
bench --site inkers.localhost install-app erpnext
```

## Install the Observance App to Site

replace `satyajit-ink` with your github username

```bash
bench get-app --branch master observance_app https://satyajit-ink@github.com/inkers-ai/observance_app.git
bench --site inkers.localhost install-app observance_app
```

```bash
bench set-config -g developer_mode true
```

## Updating Observance App to Github

```bash
cd inkers-bench/apps/observance_app
git add .
git commit -m "<verb>: <message>"
git push -u origin <branch>
```

## Updating and reinstalling

Update the branch

```bash
bench switch-to-branch develop frappe --upgrade
```

NOTE: This will clear all the databases and reinstalls the apps

```bash
bench --site inkers.localhost --force reinstal
```
