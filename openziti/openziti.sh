#!/bin/bash
# OpenZiti
# Based on https://netfoundry.io/docs/openziti/guides/deployments/docker/controller/ and https://netfoundry.io/docs/openziti/guides/deployments/docker/router

# Environment variables
set -a
source .env
set +a

# Pod setup
podman network create openziti --ignore
podman pod create --name openziti --replace

# Controller
podman run \
 --pod openziti \
 -v ${ZITI_CONTROLLER_DATA_DIR}:/ziti-controller:z \
 docker.io/busybox chown -R ${ZIGGY_UID:-2171} /ziti-controller

podman run --name openziti-controller \
 --replace \
 --pod openziti \
 -d \
 --net openziti \
 -u ${ZIGGY_UID:-2171} \
 -v ${ZITI_CONTROLLER_DATA_DIR}:/ziti-controller:z \
 --network-alias ${ZITI_CTRL_ADVERTISED_ADDRESS:-ziti-controller} \
 -e ZITI_CTRL_ADVERTISED_ADDRESS=${ZITI_CTRL_ADVERTISED_ADDRESS:-ziti-controller} \
 -e ZITI_CTRL_ADVERTISED_PORT=${ZITI_CTRL_ADVERTISED_PORT:-1280} \
 -e ZITI_PWD=${ZITI_PWD:-} \
 -e ZITI_BOOTSTRAP=true \
 -e ZITI_BOOTSTRAP_PKI=true \
 -e ZITI_BOOTSTRAP_CONFIG=true \
 -e ZITI_BOOTSTRAP_DATABASE=true \
 -e ZITI_AUTO_RENEW_CERTS=true \
 -e ZITI_BOOTSTRAP_CONFIG_ARGS \
 -p ${ZITI_INTERFACE:-0.0.0.0}:${ZITI_CTRL_ADVERTISED_PORT:-1280}:${ZITI_CTRL_ADVERTISED_PORT:-1280} \
 --restart unless-stopped \
 --health-cmd CMD,ziti,agent,stats \
 --health-interval 3s \
 --health-retries 5 \
 --health-start-period 15s \
 --health-timeout 3s \
 ${ZITI_CONTROLLER_IMAGE:-docker.io/openziti/ziti-controller} run config.yml

# Router
podman run \
 --pod openziti \
 -v ${ZITI_ROUTER_DATA_DIR}:/ziti-router:z \
 docker.io/busybox chown -R ${ZIGGY_UID:-2171} /ziti-router


podman run --name openziti-router \
 --replace \
 --pod openziti \
 -d \
 --net openziti \
 -u ${ZIGGY_UID:-2171} \
 -v ${ZITI_ROUTER_DATA_DIR}:/ziti-router:z \
 -e ZITI_CTRL_ADVERTISED_ADDRESS=${ZITI_CTRL_ADVERTISED_ADDRESS:-ziti-controller} \
 -e ZITI_CTRL_ADVERTISED_PORT=${ZITI_CTRL_ADVERTISED_PORT:-1280} \
 -e ZITI_ENROLL_TOKEN=${ZITI_ENROLL_TOKEN:-} \
 -e ZITI_ROUTER_ADVERTISED_ADDRESS=${ZITI_ROUTER_ADVERTISED_ADDRESS:-ziti-router} \
 -e ZITI_ROUTER_PORT=${ZITI_ROUTER_PORT:-3022} \
 -e ZITI_ROUTER_MODE=${ZITI_ROUTER_MODE:-host} \
 -e ZITI_BOOTSTRAP=true \
 -e ZITI_BOOTSTRAP_CONFIG=true \
 -e ZITI_BOOTSTRAP_ENROLLMENT=true \
 -e ZITI_AUTO_RENEW_CERTS=true \
 -e ZITI_ROUTER_TYPE=${ZITI_ROUTER_TYPE:-edge} \
 -e ZITI_BOOTSTRAP_CONFIG_ARGS \
 -p ${ZITI_INTERFACE:-0.0.0.0}:${ZITI_ROUTER_PORT:-3022}:${ZITI_ROUTER_PORT:-3022} \
 --restart unless-stopped \
 --health-cmd CMD,ziti,agent,stats \
 --health-interval 3s \
 --health-retries 5 \
 --health-start-period 15s \
 --health-timeout 3s \
 ${ZITI_ROUTER_IMAGE:-docker.io/openziti/ziti-router} run config.yml


