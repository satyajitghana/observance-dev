# Observance Development

## Setup the Development repo

## Initial Setup

```bash
bench init --skip-redis-config-generation --frappe-branch version-13 inkers-bench
cd inkers-bench
```

NOTE: If this is not being setup inside docker, specify localhost instead of redis-cache, redis-queue, redis-socketio

```bash
bench set-redis-cache-host redis-cache:6379
bench set-redis-queue-host redis-queue:6379
bench set-redis-socketio-host redis-socketio:6379
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

### Migrating the app

This might be particularly useful if theres some issue deleting or creating a DocType

```bash
bench --site inkers.localhost migrate
```

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

### Backup & Restore SQL Backup

```bash
bench --site inkers.localhost backup --with-files --compress
```

Copy the SQL file to server

```bash
bench --site inkers.localhost restore {sql_backup_file} --with-public-files {public_archive} --with-private-files {private_archive}
```

### Deploy

```bash
cd inkers-bench
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

Maybe reload supervisor

```bash
sudo supervisorctl reload
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
                proxy_set_header Host inkers.localhost;
                proxy_set_header X-Frappe-Site-Name inkers.localhost;
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

        # optimizations
        sendfile on;
        keepalive_timeout 15;
        client_max_body_size 50m;
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
