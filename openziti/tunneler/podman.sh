#!/bin/bash
# OpenZiti Tunneler

# Environment variables
set -a
source .env
set +a

# Pod setup
podman pod create --name openziti-tunneler --replace

# Tunneler
podman run --name openziti-tunneler \
 --replace \
 --pod openziti-tunneler \
 -d \
 --net host \
 -v ./data:/ziti-edge-tunnel:z,U \
 --restart always \
 -e ZITI_ENROLL_TOKEN=${ZITI_ENROLL_TOKEN:-} \
 -u ${ZITI_UID:-1000}:${ZITI_GID:-1000} \
 docker.io/openziti/ziti-host
