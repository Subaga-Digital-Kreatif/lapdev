FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    supervisor \
    ca-certificates \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN curl -sL -o lapdev_0.1.0-1_amd64.deb https://github.com/lapce/lapdev/releases/download/v0.1.0/lapdev_0.1.0-1_amd64.deb && \
    apt-get update && \
    apt-get install -y ./lapdev_0.1.0-1_amd64.deb && \
    rm lapdev_0.1.0-1_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://lap.dev/install-ws.sh -o install-ws.sh && \
    sed -i 's/systemctl.*//g' install-ws.sh && \
    chmod +x install-ws.sh && \
    ./install-ws.sh || true

RUN ls -la /usr/bin/lapdev* || true
RUN /usr/bin/lapdev --help || true

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443 6123

CMD ["/entrypoint.sh"]