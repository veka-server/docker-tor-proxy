# syntax=docker/dockerfile:1
FROM alpine:latest

# Installer Tor, Privoxy, curl et utilitaires
RUN apk add --no-cache curl tor privoxy bash nyx lyrebird \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /etc/tor /var/lib/tor \
    && chown -R tor:tor /etc/tor /var/lib/tor

# Créer un torrc minimal
RUN echo "SocksPort 0.0.0.0:9050" > /etc/tor/torrc \
    && echo "SocksPolicy accept 0.0.0.0/0" >> /etc/tor/torrc

# Créer la config Privoxy pour forwarder vers Tor
RUN echo "listen-address 0.0.0.0:8118" > /etc/privoxy/config \
    && echo "forward-socks5 / 127.0.0.1:9050 ." >> /etc/privoxy/config

# Exposer les ports
EXPOSE 9050 9051 8118

# Healthcheck sur SOCKS5
HEALTHCHECK --interval=300s --timeout=15s --start-period=60s \
    CMD curl -x socks5h://127.0.0.1:9050 'https://check.torproject.org/api/ip' \
        | grep -qm1 -E '"IsTor"\s*:\s*true'

# Volumes pour config et données
VOLUME ["/etc/tor", "/var/lib/tor"]

# Lancer Tor et Privoxy en même temps
CMD ["sh", "-c", "tor & privoxy --no-daemon /etc/privoxy/config"]
