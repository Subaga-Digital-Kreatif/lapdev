FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    systemctl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://lap.dev/install.sh | sh

RUN curl -L https://lap.dev/install-ws.sh | sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443 6123

ENTRYPOINT ["/entrypoint.sh"]