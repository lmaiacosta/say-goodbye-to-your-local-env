#!/bin/bash
# Envault Installation Script
# curl -sSL https://raw.githubusercontent.com/lmaiacosta/say-goodbye-to-your-local-env/main/install.sh | bash

set -e

VERSION="2.0.0"
BINARY_NAME="envault"
INSTALL_DIR="/usr/local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Installing Envault v${VERSION}${NC}"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    arm64) ARCH="arm64" ;;
    *) echo -e "${RED}❌ Unsupported architecture: $ARCH${NC}"; exit 1 ;;
esac

case $OS in
    linux) OS="linux" ;;
    darwin) OS="darwin" ;;
    *) echo -e "${RED}❌ Unsupported OS: $OS${NC}"; exit 1 ;;
esac

DOWNLOAD_URL="https://github.com/lmaiacosta/say-goodbye-to-your-local-env/releases/download/v${VERSION}/${BINARY_NAME}-${OS}-${ARCH}"

echo -e "${YELLOW}📦 Downloading ${BINARY_NAME} for ${OS}/${ARCH}...${NC}"

# Create temporary file
TMP_FILE=$(mktemp)
trap "rm -f $TMP_FILE" EXIT

# Download binary
if ! curl -sSL "$DOWNLOAD_URL" -o "$TMP_FILE"; then
    echo -e "${RED}❌ Download failed. Please check your internet connection.${NC}"
    exit 1
fi

# Make executable
chmod +x "$TMP_FILE"

# Install to system
if [ -w "$INSTALL_DIR" ]; then
    mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"
else
    echo -e "${YELLOW}📋 Installing to $INSTALL_DIR (requires sudo)${NC}"
    sudo mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"
fi

echo -e "${GREEN}✅ Envault installed successfully!${NC}"
echo -e "${BLUE}💡 Usage: envault -f .env -r owner/repo -e production${NC}"
echo -e "${BLUE}📖 Run 'envault --help' for more options${NC}"

# Verify installation
if command -v envault >/dev/null 2>&1; then
    echo -e "${GREEN}🎉 Installation verified!${NC}"
else
    echo -e "${YELLOW}⚠️  You may need to add $INSTALL_DIR to your PATH${NC}"
fi
