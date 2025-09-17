#!/bin/bash

if [ ! -f /etc/lapdev.conf ]; then
    cat > /etc/lapdev.conf <<EOF
db_host = ${DB_HOST:-lapdev-postgres}
db_port = ${DB_PORT:-5432}
db_name = ${DB_NAME:-lapdev}
db_user = ${DB_USER:-lapdev}
db_password = ${DB_PASSWORD:-changeme123}
EOF
fi

systemctl enable lapdev
systemctl start lapdev

systemctl enable lapdev-ws
systemctl start lapdev-ws

tail -f /var/log/lapdev/*.log