# Observance Development

## Setup the Development repo

## Initial Setup

```bash
bench init --frappe-branch version-13 inkers-bench
cd inkers-bench
```

NOTE: If this is not being setup inside docker, specify localhost instead of redis-cache, redis-queue, redis-socketio
NOTE: The below commands only need to be run if Redis was not setup in `bench init`

For Localhost Run:

```bash
bench set-redis-cache-host 127.0.0.1:13000
bench set-redis-socketio-host 127.0.0.1:12000
bench set-redis-queue-host 127.0.0.1:11000
bench setup redis
```

For Docker Run:

```bash
bench set-redis-cache-host redis-cache:13000
bench set-redis-socketio-host redis-socketio:12000
bench set-redis-queue-host redis-queue:11000
bench setup redis
```

add this on top of `Procfile`

```Procfile
redis_cache: redis-server config/redis_cache.conf
redis_socketio: redis-server config/redis_socketio.conf
redis_queue: redis-server config/redis_queue.conf
```

NOTE: for non-docker specify db-host as localhost

```bash
bench new-site inkers.localhost --admin-password admin --db-type postgres --db-host postgresql
```

the default super user and password for postgres is `postgres:123`, BUT if you used setup-db.sh then specify that username and password

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

Setup redis

```bash
bench setup redis
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

replace `satyajit-ink` with your github username or your token

```bash
bench get-app --branch master observance_app https://satyajit-ink@github.com/inkers-ai/observance_app.git
bench --site inkers.localhost install-app observance_app
```

```bash
bench set-config -g developer_mode true
```

Make sure to install `install-deps.sh`

Core dependencies: `imagemagick potrace`

## Exporting fixtures

more about it here: <https://frappeframework.com/docs/user/en/python-api/hooks#fixtures>

```bash
bench --site inkers.localhost export-fixtures
```

## Development

Get an interactive python console

```bash
bench console
```

## NGINX Extra settting

Make sure to add these in every location of the nginx proxy

```
proxy_set_header Authorization $http_x_frappe_authorization;
add_header Access-Control-Allow-Headers "Authorization,DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,X-Frappe-Authorization";
```

### Migrating the app

This might be particularly useful if theres some issue deleting or creating a DocType

```bash
bench --site inkers.localhost migrate
```

## Increase Max Attachment Size

edit `site_config.json` and change `max_file_size` to `104857600`

```json
{
    "max_file_size": "314572800"
}
```

here the max file size is set to 300mb, its specified in bytes

## Allow CORS

edit `site_config.json`

```json
{
 ...
 "allow_cors": "*"
 ...
}
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
bench --site inkers.localhost --force reinstall
```

To uninstall and reinstall custom app

```bash
bench --site inkers.localhost uninstall-app observance_app
bench --site inkers.localhost install-app observance_app
```

## Wipe DB and Reinstall

```bash
bench reinstall
```

## Production Steps

Dont forget to fix CORS for `/files` in nginx, also set max file to 500M in nginx and also in `inkers.localhost/site_config.json`

Add frontend_baseurl to site_config

also mention the http_port and host_name, this will be used for assets that are attached in the email (this should be of the backend only)

`site_config.json`

```json
{
    ...
    "frontend_baseurl": "https://observance.inkers.ai:3444",
    "host_name": "observance.ddns.net",
    "http_port": "3443"
    ...
}
```

Also add `s3_root_prefix` in `site_config.json`, this will be used as `{bucket_name}/{s3_root_prefix}` when the files are uploaded to s3

`common_site_config.json`

```json
{
    ...
    "restart_supervisor_on_update": false,
    "restart_systemd_on_update": false,
    ...
}
```

### Backup & Restore SQL Backup

```bash
bench --site inkers.localhost backup --with-files --compress
```

Copy the SQL file to server

```bash
bench --site inkers.localhost restore {sql_backup_file} --with-public-files {public_archive} --with-private-files {private_archive}
```

NOTE: Sometimes there might be bugs with the tables like UNIQUE constraint not being removed, in that case simply modify the .sql file from the backup and fix the issue in the table creation, then simply restore the modified .sql file (also make gunzip)

If you want to see more of how db is setup see `frappe/frappe/database/postgres/setup_db.py`

### Deploy

```bash
cd inkers-bench
bench setup redis
bench setup supervisor
sudo ln -s `pwd`/config/supervisor.conf /etc/supervisor/conf.d/frappe-bench.conf
sudo bench setup sudoers $(whoami)
bench setup nginx
bench set-nginx-port inkers.localhost 5000
sudo ln -s `pwd`/config/nginx.conf /etc/nginx/conf.d/frappe-bench.conf
```

You might need to edit `config/nginx.conf` and set port to `5000`

Start nginx and supervisor

```bash
sudo service supervisor start
sudo service nginx start
```

You might face some problem with nginx, unknown log format main

edit `/etc/nginx/nginx.conf`

Add this inside the http directive

```txt
log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

```

Maybe reload supervisor

```bash
sudo supervisorctl reload
```

## Updating in Production

```bash
git pull
bench --site inkers.localhost migrate
```

Now you can restore the database, see `Updating and Restoring the Database` above

Also after updating you can run

```
sudo supervisorctl restart all
```

All in One

```bash
git pull
bench --site inkers.localhost migrate
sudo supervisorctl restart all
```

## Troubleshooting

If for some reason you can login to frappe ui, but it says access denied, its probably because of the cookies not being set, i am not sure how to fix this, it's definitely due to HTTPS not being set, but sometimes it still works. For now waiting for sometime and trying again later works.

Also from the frontend if you can't access then use the IP instead of DNS, that fixes it sometimes.

## Setup HTTPS

Make sure nothing is running in port 80, We'll use NGINX and Certbot for this

```bash
sudo apt install certbot python3-certbot-nginx
```

```bash
sudo certbot --nginx -d observance.ddns.net
```

```txt
server {
    server_name observance.ddns.net;

        # managed by Certbot
    listen [::]:5443 ssl ipv6only=on; # managed by Certbot
    listen 5443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/observance.ddns.net/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/observance.ddns.net/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

        location / {
                #proxy_set_header Host inkers.localhost;
                proxy_set_header X-Frappe-Site-Name inkers.localhost;
                #add_header Access-Control-Allow-Origin *;
                #add_header              'Access-Control-Allow-Origin' '$http_origin' always;
                proxy_pass http://127.0.0.1:8000;
        }

        location /files {
                #proxy_set_header Host inkers.localhost;
                proxy_set_header X-Frappe-Site-Name inkers.localhost;
                #add_header Access-Control-Allow-Origin *;
                add_header              'Access-Control-Allow-Origin' '$http_origin' always;
                proxy_pass http://127.0.0.1:8000;
        }

        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;

        add_header X-Frame-Options "SAMEORIGIN";
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Referrer-Policy "same-origin, strict-origin-when-cross-origin";
        #add_header Access-Control-Allow-Origin *;

        # optimizations
        sendfile on;
        keepalive_timeout 15;
        client_max_body_size 500m;
        client_body_buffer_size 16K;
        client_header_buffer_size 1k;

        # enable gzip compresion
        # based on https://mattstauffer.co/blog/enabling-gzip-on-nginx-servers-including-laravel-forge
        gzip on;
        gzip_http_version 1.1;
        gzip_comp_level 5;
        gzip_min_length 256;
        gzip_proxied any;
        gzip_vary on;
        gzip_types
                application/atom+xml
                application/javascript
                application/json
                application/rss+xml
                application/vnd.ms-fontobject
                application/x-font-ttf
                application/font-woff
                application/x-web-app-manifest+json
                application/xhtml+xml
                application/xml
                font/opentype
                image/svg+xml
                image/x-icon
                text/css
                text/plain
                text/x-component
                ;
                # text/html is always compressed by HttpGzipModule
}

```

To test the config

```bash
sudo nginx -T
```

## Optimization

To optimize nginx, make sure to serve files using nginx, not frappe, enable compression.

`/etc/nginx/nginx.conf`

```txt
events {
        worker_connections 768;
    #
    # Let each process accept multiple connections.
    # Accept as many connections as possible, after nginx gets notification
    # about a new connection.
    # May flood worker_connections, if that option is set too low.
    #
    multi_accept on;

    #
    # Preferred connection method for newer linux versions.
    # Essential for linux, optmized to serve many clients with each thread.
    #
    use epoll;
}
```

## Server Maintenance

### Logout all users

```
bench destroy-all-sessions
sudo supervisorctl restart all
```

## Common Problems

404 not found for assets

this is because of permission issues in ubuntu

```
chmod 755 /home/${USER}
```

should fix it
