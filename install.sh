#!/bin/bash
#
# wlan-autoroam installer
#
# PUBLIC REPO INSTALL:
#   curl -fsSL https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/scripts/install.sh | sudo bash
#   wget -qO- https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/scripts/install.sh | sudo bash
#
# PRIVATE REPO INSTALL (requires GitHub Personal Access Token):
#   GITHUB_TOKEN=ghp_xxxx curl -fsSL https://raw.githubusercontent.com/jwil007/wlan-autoroam-release/main/scripts/install.sh | sudo -E bash
#
# This script:
# 1. Detects your system architecture (AMD64, ARM64, ARMv7)
# 2. Downloads the latest release binary for your platform
# 3. Installs to /usr/local/bin/wlan-autoroam (accessible from anywhere)
# 4. Makes it executable and sets permissions (755 = world-readable)
# 5. Shows helpful usage instructions
# 6. Supports both public and private GitHub repositories

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub release info
REPO="${GITHUB_REPO:-jwil007/wlan-autoroam-release}"
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

# Authentication header (for private repos)
AUTH_HEADER=""
if [ -n "$GITHUB_TOKEN" ]; then
    AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
    info "Using GitHub authentication token"
fi

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
if command -v curl &> /dev/null; then
    if [ -n "$AUTH_HEADER" ]; then
        LATEST_RELEASE=$(curl -s -H "$AUTH_HEADER" "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    else
        LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    fi
elif command -v wget &> /dev/null; then
    if [ -n "$AUTH_HEADER" ]; then
        LATEST_RELEASE=$(wget --header="$AUTH_HEADER" -qO- "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    else
        LATEST_RELEASE=$(wget -qO- "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    fi
else
    error "Neither curl nor wget found. Please install one of them and try again."
fi

if [ -z "$LATEST_RELEASE" ]; then
    echo ""
    error "Failed to fetch latest release version"
    echo ""
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${YELLOW}💡 This might be a private repository.${NC}"
        echo -e "   If so, you need to set GITHUB_TOKEN environment variable."
        echo ""
        echo -e "   See: ${BLUE}https://github.com/$REPO/blob/main/INTERNAL_INSTALL.md${NC}"
        echo ""
    else
        echo -e "${YELLOW}💡 Possible issues:${NC}"
        echo -e "   1. Invalid GitHub token"
        echo -e "   2. Token doesn't have 'repo' scope"
        echo -e "   3. You don't have access to this repository"
        echo ""
    fi
    exit 1
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

# Download binary (try curl first, fallback to wget)
info "Downloading wlan-autoroam-$PLATFORM..."
TMP_FILE=$(mktemp)
DOWNLOAD_SUCCESS=0

if command -v curl &> /dev/null; then
    if [ -n "$AUTH_HEADER" ]; then
        if curl -fsSL -H "$AUTH_HEADER" "$DOWNLOAD_URL" -o "$TMP_FILE"; then
            DOWNLOAD_SUCCESS=1
        fi
    else
        if curl -fsSL "$DOWNLOAD_URL" -o "$TMP_FILE"; then
            DOWNLOAD_SUCCESS=1
        fi
    fi
elif command -v wget &> /dev/null; then
    if [ -n "$AUTH_HEADER" ]; then
        if wget --header="$AUTH_HEADER" -qO "$TMP_FILE" "$DOWNLOAD_URL"; then
            DOWNLOAD_SUCCESS=1
        fi
    else
        if wget -qO "$TMP_FILE" "$DOWNLOAD_URL"; then
            DOWNLOAD_SUCCESS=1
        fi
    fi
else
    rm -f "$TMP_FILE"
    error "Neither curl nor wget found. Please install one of them and try again."
fi

if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
    rm -f "$TMP_FILE"
    echo ""
    error "Failed to download binary from $DOWNLOAD_URL"
    echo ""
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${YELLOW}💡 This might be a private repository requiring authentication.${NC}"
        echo -e "   See: ${BLUE}https://github.com/$REPO/blob/main/INTERNAL_INSTALL.md${NC}"
        echo ""
    fi
    exit 1
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
chmod 755 "$INSTALL_DIR/$BINARY_NAME"  # Make readable/executable by all users
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
if [ -n "$GITHUB_TOKEN" ]; then
    echo -e "  ${GREEN}GITHUB_TOKEN=\$GITHUB_TOKEN curl -fsSL https://raw.githubusercontent.com/$REPO/main/scripts/install.sh | sudo -E bash${NC}"
else
    echo -e "  ${GREEN}curl -fsSL https://raw.githubusercontent.com/$REPO/main/scripts/install.sh | sudo bash${NC}"
fi
echo ""
echo -e "${YELLOW}Uninstall:${NC}"
echo -e "  ${GREEN}sudo rm $INSTALL_DIR/$BINARY_NAME${NC}"
echo ""
