#!/bin/bash
# Beszel (Podman script)
# Michi von Ah
# Link: https://beszel.dev/guide/hub-installation

# Make script executable: chmod +x podman.sh

# Pod setup
podman network create beszel --ignore
podman pod create --name beszel --replace

# Create directories & files
mkdir -p data
touch beszel_socket beszel_agent_data

# Beszel Hub
# When not using the beszel socket the line "--volume ./beszel_socket:/beszel_socket \" can be removed
podman run --name beszel-hub \
    --replace \
    --pod beszel \
    -d \
    --restart always \
    --net beszel \
    -p 127.0.0.1:8090:8090 \
    --volume ./data:/beszel_data:z \
    --volume ./beszel_socket:/beszel_socket:z \
    docker.io/henrygd/beszel

# Beszel Agent (localhost)
podman run --name beszel-agent \
    --replace \
    --pod beszel \
    -d \
    --restart always \
    --net host \
    --volume ./beszel_socket:/beszel_socket \
    --volume ./beszel_agent_data:/var/lib/beszel-agent \
    -e KEY="<public_key>" \
    -e LISTEN="/beszel_socket/beszel.sock" \
    -e TOKEN="<token>" \
    -e HUB_URL="http://localhost:8090" \
    docker.io/henrygd/beszel-agent:latest

# Beszel Agent (additonal hosts)
# podman run --name beszel-agent \
#     --replace \
#     --pod beszel \
#     -d \
#     --restart always \
#     --net host \
#     -e KEY="<public_key>" \
#     -e LISTEN=45876 \
#     -e TOKEN="<token>" \
#     -e HUB_URL="<hub_url>" \
#     -u ${UID:-1000}:${GID:-1000} \
#     docker.io/henrygd/beszel-agent:latest