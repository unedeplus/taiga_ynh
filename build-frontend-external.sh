#!/bin/bash
# Build Taiga frontend on a machine with sufficient RAM (8GB+)
# Then package it for deployment on the YunoHost server

set -e

TAIGA_VERSION="6.7.0"
BUILD_DIR="$(pwd)/taiga-build"
DIST_PACKAGE="taiga-front-${TAIGA_VERSION}-dist.tar.gz"

echo "Building Taiga ${TAIGA_VERSION} frontend..."
echo "This requires at least 8GB RAM"
echo ""

# Check available memory
TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_MEM" -lt 8 ]; then
    echo "WARNING: Only ${TOTAL_MEM}GB RAM detected. Build may fail."
    echo "Recommended: 8GB+ RAM"
    echo ""
fi

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Clone Taiga frontend
echo "Cloning Taiga frontend ${TAIGA_VERSION}..."
git clone https://github.com/taigaio/taiga-front --branch "$TAIGA_VERSION" --depth 1 "$BUILD_DIR/taiga-front"

cd "$BUILD_DIR/taiga-front"

# Install Node.js 18 if needed
if ! command -v node &> /dev/null || ! node --version | grep -q "^v18"; then
    echo "Node.js 18 required but not found"
    echo "Please install Node.js 18.x first:"
    echo "  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash -"
    echo "  sudo apt-get install -y nodejs"
    exit 1
fi

echo "Using Node.js $(node --version)"
echo ""

# Install dependencies
echo "Installing dependencies (this takes 15-20 minutes)..."
export NODE_OPTIONS="--max-old-space-size=6144"
npm install --legacy-peer-deps --no-audit --no-fund

# Build
echo "Building frontend..."
npm run build

# Package the results
echo "Packaging built assets..."
cd "$BUILD_DIR"
tar czf "../$DIST_PACKAGE" taiga-front/dist/ taiga-front/node_modules/

cd ..
echo ""
echo "SUCCESS! Built package created:"
echo "  $(pwd)/$DIST_PACKAGE"
echo "  Size: $(du -h "$DIST_PACKAGE" | cut -f1)"
echo ""
echo "Upload this to your YunoHost server and extract:"
echo "  scp $DIST_PACKAGE admin@YOUR_SERVER:/tmp/"
echo "  ssh admin@YOUR_SERVER"
echo "  sudo tar xzf /tmp/$DIST_PACKAGE -C /var/www/taiga/"
echo ""
