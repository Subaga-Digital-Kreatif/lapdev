FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    sudo \
    supervisor \
    systemd \
    init \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/lapdev

RUN curl -L https://lap.dev/install.sh -o install.sh && \
    chmod +x install.sh && \
    ./install.sh || true

RUN curl -L https://lap.dev/install-ws.sh -o install-ws.sh && \
    chmod +x install-ws.sh && \
    ./install-ws.sh || true

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443 6123

CMD ["/entrypoint.sh"]