bench init --skip-redis-config-generation --frappe-branch version-13 inkers-bench
cd inkers-bench

bench set-redis-cache-host redis-cache:6379
bench set-redis-queue-host redis-queue:6379
bench set-redis-socketio-host redis-socketio:6379

bench new-site inkers.localhost --admin-password admin --db-type postgres --db-host postgresql

bench config set-common-config -c root_login postgres
bench config set-common-config -c root_password '"123"'

bench --site inkers.localhost set-config developer_mode 1
bench --site inkers.localhost clear-cache