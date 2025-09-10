#!/bin/bash

# Envault Installation Script
# Usage: curl -sSL https://raw.githubusercontent.com/lmaiacosta/say-goodbye-to-your-local-env/main/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
REPO="lmaiacosta/say-goodbye-to-your-local-env"
BINARY_NAME="envault"
INSTALL_DIR="/usr/local/bin"
LOCAL_INSTALL_DIR="$HOME/.local/bin"

# Detect platform
detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)

    case $os in
        linux)
            os="linux"
            ;;
        darwin)
            os="darwin"
            ;;
        mingw*|msys*|cygwin*)
            os="windows"
            ;;
        *)
            echo -e "${RED}❌ Unsupported operating system: $os${NC}"
            exit 1
            ;;
    esac

    case $arch in
        x86_64|amd64)
            arch="amd64"
            ;;
        arm64|aarch64)
            arch="arm64"
            ;;
        *)
            echo -e "${RED}❌ Unsupported architecture: $arch${NC}"
            exit 1
            ;;
    esac

    echo "${os}-${arch}"
}

# Get latest release version
get_latest_version() {
    curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | cut -d '"' -f 4
}

# Download and install
install_envault() {
    echo -e "${PURPLE}🚀 Envault Installation Script${NC}"
    echo "================================="

    # Detect platform
    local platform=$(detect_platform)
    echo -e "${BLUE}🔍 Detected platform: $platform${NC}"

    # Get latest version
    echo -e "${YELLOW}📡 Fetching latest version...${NC}"
    local version=$(get_latest_version)
    if [ -z "$version" ]; then
        echo -e "${RED}❌ Failed to get latest version${NC}"
        exit 1
    fi
    echo -e "${GREEN}📦 Latest version: $version${NC}"

    # Determine file extension
    local ext="tar.gz"
    if [[ "$platform" == *"windows"* ]]; then
        ext="zip"
    fi

    # Download URL
    local filename="${BINARY_NAME}-${platform}"
    local archive_name="${filename}.${ext}"
    local download_url="https://github.com/$REPO/releases/download/$version/$archive_name"

    echo -e "${YELLOW}⬇️  Downloading $archive_name...${NC}"

    # Create temp directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download
    if ! curl -L -o "$archive_name" "$download_url"; then
        echo -e "${RED}❌ Failed to download $archive_name${NC}"
        echo -e "${YELLOW}💡 Available releases: https://github.com/$REPO/releases${NC}"
        exit 1
    fi

    # Extract
    echo -e "${YELLOW}📦 Extracting archive...${NC}"
    if [[ "$ext" == "tar.gz" ]]; then
        tar -xzf "$archive_name"
    else
        unzip -q "$archive_name"
    fi

    # Find binary
    local binary_path=""
    if [[ "$platform" == *"windows"* ]]; then
        binary_path="${filename}.exe"
    else
        binary_path="$filename"
    fi

    if [ ! -f "$binary_path" ]; then
        echo -e "${RED}❌ Binary not found after extraction${NC}"
        exit 1
    fi

    # Determine install location
    local install_path="$INSTALL_DIR/$BINARY_NAME"
    local use_local=false

    # Check if we can write to /usr/local/bin
    if [ ! -w "$INSTALL_DIR" ] && [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}⚠️  Cannot write to $INSTALL_DIR without sudo${NC}"
        read -p "Install to ~/.local/bin instead? (Y/n): " choice
        case "$choice" in
            n|N)
                echo -e "${BLUE}💡 Rerun with sudo to install system-wide${NC}"
                exit 1
                ;;
            *)
                use_local=true
                install_path="$LOCAL_INSTALL_DIR/$BINARY_NAME"
                ;;
        esac
    fi

    # Create install directory if needed
    if [ "$use_local" = true ]; then
        mkdir -p "$LOCAL_INSTALL_DIR"
    fi

    # Install binary
    echo -e "${YELLOW}📋 Installing to $install_path...${NC}"
    if [ "$use_local" = true ]; then
        cp "$binary_path" "$install_path"
    else
        if [ "$EUID" -eq 0 ]; then
            cp "$binary_path" "$install_path"
        else
            sudo cp "$binary_path" "$install_path"
        fi
    fi

    # Make executable
    chmod +x "$install_path"

    # Cleanup
    cd /
    rm -rf "$temp_dir"

    # Verify installation
    echo -e "${GREEN}✅ Installation completed!${NC}"
    echo

    # Check if binary is in PATH
    if command -v "$BINARY_NAME" >/dev/null 2>&1; then
        echo -e "${GREEN}🎉 $BINARY_NAME is ready to use!${NC}"
        "$BINARY_NAME" --version
    else
        echo -e "${YELLOW}⚠️  $BINARY_NAME is installed but not in PATH${NC}"
        if [ "$use_local" = true ]; then
            echo -e "${BLUE}💡 Add ~/.local/bin to your PATH:${NC}"
            echo "   echo 'export PATH=\$HOME/.local/bin:\$PATH' >> ~/.bashrc"
            echo "   source ~/.bashrc"
        fi
        echo
        echo -e "${BLUE}🔧 Manual verification:${NC}"
        echo "   $install_path --version"
    fi

    echo
    echo -e "${PURPLE}📖 Quick start:${NC}"
    echo "   $BINARY_NAME --help"
    echo "   $BINARY_NAME --env-file .env.production --repo owner/repo --environment production"
    echo
    echo -e "${GREEN}🎯 Happy secret management!${NC}"
}

# Check prerequisites
check_prerequisites() {
    # Check curl
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}❌ curl is required but not installed${NC}"
        exit 1
    fi

    # Check tar (for non-Windows)
    if [[ "$(uname -s)" != "MINGW"* ]] && [[ "$(uname -s)" != "MSYS"* ]]; then
        if ! command -v tar >/dev/null 2>&1; then
            echo -e "${RED}❌ tar is required but not installed${NC}"
            exit 1
        fi
    fi
}

# Main execution
main() {
    check_prerequisites
    install_envault
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
