#!/bin/bash
# Caddy Proxy (Podman script)
# Michi von Ah
# Link: https://github.com/michivonah/docker/tree/main/caddy

# Make script executable: chmod +x podman.sh

# Pod setup
podman network create caddy --ignore
podman pod create --name caddy --replace

# Create directories & files
mkdir -p data
touch Caddyfile

# Caddy
podman run --name caddy-proxy -d \
       --replace \
       --pod caddy \
       -p 80:80 \
       -p 443:443 \
       -v ./Caddyfile:/etc/caddy/Caddyfile:z,ro \
       -v ./data:/data:z,U \
       --restart always \
       --network caddy \
       -u ${UID:-1000}:${GID:-1000} \
       docker.io/caddy

# UID & GID should be set by default on most linux distros, so you don't have to change it here.
# Add another container to the caddy network: --network caddy