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
db_host = ${DB_HOST:-postgres-server}
db_port = ${DB_PORT:-5432}
db_name = ${DB_NAME:-lapdev}
db_user = ${DB_USER:-subaga}
db_password = ${DB_PASSWORD:-subaga2025}
EOF
fi

mkdir -p /var/log/supervisor
mkdir -p /var/log

echo "Checking for lapdev binaries..."
which lapdev || echo "lapdev not found"
which lapdev-ws || echo "lapdev-ws not found"

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf