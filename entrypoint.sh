#!/bin/bash

echo "Waiting for PostgreSQL to be ready..."
until PGPASSWORD=${DB_PASSWORD} psql -h ${DB_HOST} -U ${DB_USER} -d postgres -c '\q' 2>/dev/null; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done

echo "PostgreSQL is ready, checking database..."
PGPASSWORD=${DB_PASSWORD} psql -h ${DB_HOST} -U ${DB_USER} -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '${DB_NAME}'" | grep -q 1 || \
  PGPASSWORD=${DB_PASSWORD} psql -h ${DB_HOST} -U ${DB_USER} -d postgres -c "CREATE DATABASE ${DB_NAME};"

echo "Database ${DB_NAME} is ready"

cat > /etc/lapdev.conf <<EOF
db_host = "${DB_HOST:-postgres-server}"
db_port = ${DB_PORT:-5432}
db_name = "${DB_NAME:-lapdev}"
db_user = "${DB_USER:-subaga}"
db_password = "${DB_PASSWORD:-subaga2025}"
bind = "0.0.0.0:80"
root_dir = "/var/lib/lapdev"
EOF

mkdir -p /var/log/supervisor
mkdir -p /var/log
mkdir -p /var/lib/lapdev

echo "Checking for lapdev binaries..."
ls -la /usr/bin/lapdev* || echo "No lapdev binaries found"

echo "Config file contents:"
cat /etc/lapdev.conf

echo "Testing lapdev with config..."
/usr/bin/lapdev --config-file /etc/lapdev.conf &
sleep 2
ps aux | grep lapdev

killall lapdev 2>/dev/null || true

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf