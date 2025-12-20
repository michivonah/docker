#!/bin/bash
# Umami (Podman script)
# Michi von Ah
# Link: https://github.com/michivonah/docker/tree/main/umami
# Script depends on existing caddy proxy with network caddy

# Make script executable: chmod +x podman.sh

# Environment variables
set -a
source .env
set +a

# Pod setup
podman network create umami --ignore
podman pod create --name umami --replace

# Create directories & files
mkdir -p db

# Containers
podman run --name umami-app \
    --replace \
    --pod umami \
    -d \
    --restart always \
    --net umami \
    --net caddy \
    -e DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@umami-db:5432/${POSTGRES_DB} \
    -e DATABASE_TYPE=postgresql \
    -e APP_SECRET=${APP_SECRET} \
    -u ${UID:-1000}:${GID:-1000} \
    ghcr.io/umami-software/umami:latest

podman run --name umami-db \
    --replace \
    --pod umami \
    -d \
    --restart always \
    --net umami \
    -e POSTGRES_DB=${POSTGRES_DB} \
    -e POSTGRES_USER=${POSTGRES_USER} \
    -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
    -v ./db:/var/lib/postgresql/data:z,U \
    -u ${UID:-1000}:${GID:-1000} \
    docker.io/postgres:15-alpine
