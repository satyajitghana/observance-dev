# Frappe

## Setup the Development repo


## Initial Setup

```
bench init --skip-redis-config-generation --frappe-branch version-13 inkers-bench
cd inkers-bench
```

```
bench set-mariadb-host mariadb
bench set-redis-cache-host redis-cache:6379
bench set-redis-queue-host redis-queue:6379
bench set-redis-socketio-host redis-socketio:6379

```

```
bench new-site inkers.localhost --mariadb-root-password 123 --admin-password admin --no-mariadb-socket
```

```
bench --site inkers.localhost set-config developer_mode 1
bench --site inkers.localhost clear-cache
```

```
bench start
```

Open http://inkers.localhost:8000

## Install ERPNext

```
bench get-app --branch version-13 erpnext https://github.com/frappe/erpnext.git
```

```
bench --site inkers.localhost install-app erpnext
```

## Install the Ink-Colliers App to Site

replace `satyajit-ink` with your github username

```
bench get-app --branch master colliers_app https://satyajit-ink@github.com/inkers-ai/colliers_app.git
```

```
bench --site inkers.localhost install-app colliers_app
```

```
bench set-config -g developer_mode true
```

## Updating Colliers App to Github


```bash
cd inkers-bench/apps/colliers_app
git add .
git commit -m "<message>"
git push -u origin <branch>
```
