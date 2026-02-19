# Docker Tor Proxy

![Docker Pulls](https://img.shields.io/github/v/release/veka-server/docker-tor-proxy?label=GHCR) 
![Build Docker](https://github.com/veka-server/docker-tor-proxy/actions/workflows/build-central.yml/badge.svg)

Un **proxy Tor complet** dans un conteneur Docker, incluant **Tor + Privoxy** avec option de tunnel SSH vers un VPS.  
Idéal pour router votre trafic via Tor ou un VPS sécurisé.

---

## 🔹 Caractéristiques

- **Tor SOCKS5 proxy** sur le port `9050`
- **HTTP/HTTPS proxy via Privoxy** sur le port `8118`
- Optionnel : **tunnel SSH vers un VPS** pour masquer l’utilisation de Tor
- Compatible avec les **variables d’environnement** pour activer/désactiver le tunnel
- Basé sur **Alpine Linux** pour un conteneur léger

---

## 🔹 Téléchargement

```bash
docker pull ghcr.io/veka-server/docker-tor-proxy:latest
```

# Exemple de docker compose
```yaml
  tor:
    image: ghcr.io/veka-server/docker-tor-proxy:latest
    container_name: tor
    environment:
      SSH_TUNNEL: "true"        # true / false
      SSH_USER: "toruser"
      SSH_HOST: "example.com"
    volumes:
      - ./ssh_key_vps_tor:/root/.ssh
    restart: always
```
