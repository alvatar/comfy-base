#!/bin/bash
set -e

IMAGE="alvatar/comfy-base:latest"
BUILD_TAG="alvatar/comfy-base:build"

echo "Building image..."
docker build -t "$BUILD_TAG" .

echo "Flattening layers..."
docker rm -f comfy-base-tmp 2>/dev/null || true
docker create --name comfy-base-tmp "$BUILD_TAG"
docker export comfy-base-tmp | docker import - "$IMAGE"
docker rm comfy-base-tmp
docker rmi "$BUILD_TAG"

echo "Pushing to Docker Hub..."
docker push "$IMAGE"

echo "Done: $IMAGE"
docker images "$IMAGE" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
