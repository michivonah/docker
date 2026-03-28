#!/bin/bash
# Forgejo (Podman script)
# Michi von Ah
# Link: https://github.com/michivonah/docker/tree/main/forgejo

podman network create forgejo --ignore
podman pod create --name forgejo --replace

mkdir -p forgejo conf postgres

podman run -d \
 --replace \
 --name forgejo-app \
 --pod forgejo \
 --network forgejo \
 -e USER_UID=${UID:-1000} \
 -e USER_GID=${GID:-1000} \
 -e FORGEJO__database__DB_TYPE=postgres \
 -e FORGEJO__database__HOST=db:5432 \
 -e FORGEJO__database__NAME=forgejo \
 -e FORGEJO__database__USER=forgejo \
 -e FORGEJO__database__PASSWD=replace-with-secure-string \
 --restart always \
 -v ./forgejo:/var/lib/gitea \
 -v ./conf:/etc/gitea \
 -v /etc/timezone:/etc/timezone:ro \
 -v /etc/localtime:/etc/localtime:ro \
 -p 3000:3000 \
 -p 222:2222 \
 -u ${UID:-1000}:${GID:-1000} \
 codeberg.org/forgejo/forgejo:14-rootless

podman run -d \
 --replace \
 --name forgejo-db \
 --pod forgejo \
 --network forgejo \
 --restart always \
 -e POSTGRES_USER=forgejo \
 -e POSTGRES_PASSWORD=replace-with-secure-string \
 -e POSTGRES_DB=forgejo \
 -v ./postgres:/var/lib/postgresql/data \
 -u ${UID:-1000}:${GID:-1000} \
postgres:14