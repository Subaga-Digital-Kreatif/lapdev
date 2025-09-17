#!/bin/bash

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