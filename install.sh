#!/bin/bash
#
# wlan-autoroam installer
# One-line install: curl -fsSL https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/install.sh | sudo bash
#
# This script:
# 1. Detects your system architecture (AMD64, ARM64, ARMv7)
# 2. Downloads the latest release binary for your platform
# 3. Installs to /usr/local/bin/wlan-autoroam (accessible from anywhere)
# 4. Makes it executable and sets permissions
# 5. Shows helpful usage instructions

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub release info
REPO="jwil007/wlan-autoroam-release"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="wlan-autoroam"

# Helper functions
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    error "Please run as root (use sudo)"
fi

info "wlan-autoroam installer"
echo ""

# Detect architecture
info "Detecting system architecture..."
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        PLATFORM="amd64"
        ;;
    aarch64|arm64)
        PLATFORM="arm64"
        ;;
    armv7l|armhf)
        PLATFORM="armv7"
        ;;
    *)
        error "Unsupported architecture: $ARCH"
        ;;
esac
success "Detected: $ARCH → $PLATFORM"

# Get latest release version
info "Checking for latest release..."
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$LATEST_RELEASE" ]; then
    error "Failed to fetch latest release version"
fi
success "Latest version: $LATEST_RELEASE"

# Check if already installed and up-to-date
if [ -f "$INSTALL_DIR/$BINARY_NAME" ]; then
    CURRENT_VERSION=$($INSTALL_DIR/$BINARY_NAME --version 2>/dev/null || echo "unknown")
    if [ "$CURRENT_VERSION" = "$LATEST_RELEASE" ]; then
        success "wlan-autoroam $LATEST_RELEASE is already installed and up-to-date!"
        echo ""
        info "Run: ${GREEN}sudo wlan-autoroam${NC}"
        exit 0
    else
        warn "Upgrading from $CURRENT_VERSION to $LATEST_RELEASE"
    fi
fi

# Download URL
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_RELEASE/wlan-autoroam-$PLATFORM"

# Download binary
info "Downloading wlan-autoroam-$PLATFORM..."
TMP_FILE=$(mktemp)
if ! curl -fsSL "$DOWNLOAD_URL" -o "$TMP_FILE"; then
    rm -f "$TMP_FILE"
    error "Failed to download binary from $DOWNLOAD_URL"
fi
success "Downloaded successfully"

# Verify it's a valid binary (basic check)
if ! file "$TMP_FILE" | grep -q "ELF.*executable"; then
    rm -f "$TMP_FILE"
    error "Downloaded file is not a valid executable"
fi

# Install binary
info "Installing to $INSTALL_DIR/$BINARY_NAME..."
mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"
success "Installed to $INSTALL_DIR/$BINARY_NAME"

# Verify installation
if ! command -v $BINARY_NAME &> /dev/null; then
    warn "$INSTALL_DIR may not be in your PATH"
    echo "   Add it with: export PATH=\"\$PATH:$INSTALL_DIR\""
else
    success "wlan-autoroam is now available system-wide!"
fi

# Success message
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Version: ${BLUE}$LATEST_RELEASE${NC}"
echo -e "  Platform: ${BLUE}$PLATFORM${NC}"
echo -e "  Location: ${BLUE}$INSTALL_DIR/$BINARY_NAME${NC}"
echo ""
echo -e "${YELLOW}Quick Start:${NC}"
echo -e "  ${GREEN}sudo wlan-autoroam${NC}               # Start the UI"
echo -e "  ${GREEN}sudo wlan-autoroam --help${NC}        # Show help options"
echo ""
echo -e "${YELLOW}Access the UI:${NC}"
echo -e "  Open your browser to: ${BLUE}https://localhost:8443${NC}"
echo -e "  Default credentials: ${BLUE}admin / admin${NC} (change after first login)"
echo ""
echo -e "${YELLOW}Update to latest version:${NC}"
echo -e "  Run this installer again: ${GREEN}curl -fsSL https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/install.sh | sudo bash${NC}"
echo ""
echo -e "${YELLOW}Uninstall:${NC}"
echo -e "  ${GREEN}sudo rm $INSTALL_DIR/$BINARY_NAME${NC}"
echo ""
