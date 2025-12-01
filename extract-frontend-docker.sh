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
# Temporarily disable credential helpers if they're misconfigured
export DOCKER_CONFIG="${HOME}/.docker"
mkdir -p "$DOCKER_CONFIG"
if [ -f "$DOCKER_CONFIG/config.json" ]; then
    # Backup and remove credStore/credsStore temporarily
    cp "$DOCKER_CONFIG/config.json" "$DOCKER_CONFIG/config.json.backup"
    cat "$DOCKER_CONFIG/config.json" | grep -v '"credsStore"' | grep -v '"credStore"' > "$DOCKER_CONFIG/config.json.tmp"
    mv "$DOCKER_CONFIG/config.json.tmp" "$DOCKER_CONFIG/config.json"
fi
docker pull "$DOCKER_IMAGE"
if [ -f "$DOCKER_CONFIG/config.json.backup" ]; then
    mv "$DOCKER_CONFIG/config.json.backup" "$DOCKER_CONFIG/config.json"
fi

# Create temporary container
echo "Extracting assets from container..."
CONTAINER_ID=$(docker create "$DOCKER_IMAGE")

# Extract the frontend files
echo "Extracting assets from container..."
mkdir -p taiga-front/dist
docker export "$CONTAINER_ID" > /tmp/taiga-container.tar

# Extract the html directory (ignore symlink errors - they're not critical)
cd taiga-front/dist
tar -xf /tmp/taiga-container.tar usr/share/nginx/html --strip-components=4 2>&1 | grep -v "Cannot create symlink" || true

# If extraction partially failed, try extracting specific version directory
if [ ! -f "index.html" ]; then
    cd ..
    rm -rf dist
    mkdir dist
    cd dist
    tar -xf /tmp/taiga-container.tar "usr/share/nginx/html/v-*" --strip-components=5 2>&1 | grep -v "Cannot create symlink" || true
fi

# Clean up
rm /tmp/taiga-container.tar
cd ../..

# Verify extraction worked
if [ ! -f "taiga-front/dist/index.html" ]; then
    echo "ERROR: Extraction failed - index.html not found"
    docker rm "$CONTAINER_ID"
    exit 1
fi

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
