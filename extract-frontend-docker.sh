#!/bin/bash
# Extract pre-built Taiga frontend from official Docker image
# This avoids the memory-intensive build process entirely

set -e

TAIGA_VERSION="6.7.0"
DOCKER_IMAGE="taigaio/taiga-front:${TAIGA_VERSION}"
DIST_PACKAGE="taiga-front-${TAIGA_VERSION}-docker-dist.tar.gz"

echo "Extracting Taiga ${TAIGA_VERSION} frontend from Docker image..."
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed"
    echo "Install Docker first:"
    echo "  curl -fsSL https://get.docker.com | sudo sh"
    exit 1
fi

# Pull the official image
echo "Pulling Docker image: ${DOCKER_IMAGE}"
docker pull "$DOCKER_IMAGE"

# Create temporary container
echo "Extracting assets from container..."
CONTAINER_ID=$(docker create "$DOCKER_IMAGE")

# Extract the frontend files
mkdir -p taiga-front
docker cp "${CONTAINER_ID}:/taiga/dist" taiga-front/
docker cp "${CONTAINER_ID}:/usr/lib/node_modules" taiga-front/ 2>/dev/null || true

# Clean up container
docker rm "$CONTAINER_ID"

# Package the results
echo "Packaging extracted assets..."
tar czf "$DIST_PACKAGE" taiga-front/

# Clean up extracted files
rm -rf taiga-front/

echo ""
echo "SUCCESS! Package created from Docker image:"
echo "  $(pwd)/$DIST_PACKAGE"
echo "  Size: $(du -h "$DIST_PACKAGE" | cut -f1)"
echo ""
echo "Upload this to your YunoHost server:"
echo "  scp $DIST_PACKAGE admin@192.168.1.170:/tmp/"
echo ""
echo "Then modify scripts/install to skip npm install and extract this instead"
echo ""
