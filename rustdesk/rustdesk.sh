#!/bin/bash
# RustDesk
# Docs: https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/

DATA_DIR=/app/rustdesk/data

podman network create rustdesk --ignore
podman pod create --name rustdesk --replace

podman run \
 --name hbbs \
 --replace \
 --pod rustdesk \
 -d \
 --net rustdesk \
 -v ${DATA_DIR}:/root:z \
 -p 21115:21115 \
 -p 21116:21116/tcp \
 -p 21116:21116/udp \
 -p 21118:21118 \
 --restart always \
 docker.io/rustdesk/rustdesk-server:latest hbbs

podman run \
 --name hbbr \
 --replace \
 --pod rustdesk \
 -d \
 --net rustdesk \
 -v ${DATA_DIR}:/root:z \
 -p 21117:21117 \
 -p 21119:21119 \
 --restart always \
 docker.io/rustdesk/rustdesk-server:latest hbbr