# syntax=docker/dockerfile:1
FROM alpine:latest

# Packages nécessaires
RUN apk add --no-cache \
    tor \
    privoxy \
    curl \
    bash \
    nyx \
    lyrebird \
    openssh-client \
    autossh \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /etc/tor /var/lib/tor /root/.ssh \
    && chmod 700 /root/.ssh

# torrc de base (proxy local)
RUN echo "SocksPort 0.0.0.0:9050" > /etc/tor/torrc \
 && echo "SocksPolicy accept 0.0.0.0/0" >> /etc/tor/torrc \
 && echo "Log notice stdout" >> /etc/tor/torrc

# Privoxy → Tor
RUN echo "listen-address 0.0.0.0:8118" > /etc/privoxy/config \
 && echo "forward-socks5 / 127.0.0.1:9050 ." >> /etc/privoxy/config

# Script de démarrage
RUN cat << 'EOF' > /entrypoint.sh
#!/bin/sh
set -e

echo "[INFO] SSH_TUNNEL=$SSH_TUNNEL"

if [ "$SSH_TUNNEL" = "true" ]; then
  echo "[INFO] Starting SSH tunnel…"

  # Ajoute proxy SOCKS SSH pour Tor
  echo "Socks5Proxy 127.0.0.1:1080" >> /etc/tor/torrc

  autossh -M 0 -N \
    -D 127.0.0.1:1080 \
    -i /root/.ssh/id_rsa \
    -o StrictHostKeyChecking=no \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    $SSH_USER@$SSH_HOST &

  sleep 5
else
  echo "[INFO] SSH tunnel disabled — Tor direct"
fi

echo "[INFO] Starting Tor…"
tor &

echo "[INFO] Starting Privoxy…"
exec privoxy --no-daemon /etc/privoxy/config
EOF

RUN chmod +x /entrypoint.sh

# Ports exposés
EXPOSE 9050 8118

# Volumes
VOLUME ["/etc/tor", "/var/lib/tor", "/root/.ssh"]

ENTRYPOINT ["/entrypoint.sh"]