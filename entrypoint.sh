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

if [ ! -f /etc/lapdev.conf ]; then
    cat > /etc/lapdev.conf <<EOF
[database]
host = ${DB_HOST:-postgres-server}
port = ${DB_PORT:-5432}
name = ${DB_NAME:-lapdev}
user = ${DB_USER:-subaga}
password = ${DB_PASSWORD:-subaga2025}

[server]
bind = 0.0.0.0:80
EOF
fi

mkdir -p /var/log/supervisor
mkdir -p /var/log
mkdir -p /var/lib/lapdev

echo "Checking for lapdev binaries..."
which lapdev || echo "lapdev not found"
which lapdev-ws || echo "lapdev-ws not found"

echo "Checking lapdev help..."
/usr/bin/lapdev --help || echo "Lapdev help failed"

echo "Config file contents:"
cat /etc/lapdev.conf

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf