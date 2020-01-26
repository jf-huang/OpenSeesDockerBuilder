#!/bin/bash
# hooks/build
# https://docs.docker.com/docker-cloud/builds/advanced/

# $IMAGE_NAME var is injected into the build so the tag is correct.
echo "[***] Build hook running"

docker build \
    --build-arg BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
    -t $IMAGE_NAME .
