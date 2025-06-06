#!/bin/bash

# WTF-Tools Installation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/wtf-tools"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"

# Print with color
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[x]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Create necessary directories
print_status "Creating installation directories..."
mkdir -p "${INSTALL_DIR}"
mkdir -p "${CONFIG_DIR}"

# Copy scripts to installation directory
print_status "Installing scripts..."
for script in "${SCRIPTS_DIR}"/*; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        cp "$script" "${INSTALL_DIR}/"
        print_status "Installed $(basename "$script")"
    fi
done

# Make scripts executable
print_status "Setting permissions..."
chmod +x "${INSTALL_DIR}"/*

# Add to PATH if not already present
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    print_status "Adding installation directory to PATH..."
    echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "${HOME}/.bashrc"
    echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "${HOME}/.zshrc"
    print_warning "Please restart your shell or run 'source ~/.bashrc' (or 'source ~/.zshrc') to update your PATH"
fi

# Create default configuration
print_status "Creating default configuration..."
cat > "${CONFIG_DIR}/config.sh" << 'EOF'
# WTF-Tools Configuration

# General settings
export WTF_TOOLS_DEBUG=false
export WTF_TOOLS_LOG_LEVEL="info"

# Script-specific settings
export WTF_ENV_SETUP_TEMPLATE=".env.example"
export WTF_WATCH_RUN_DELAY=1
export WTF_ZOMBIE_KILLER_GRACE_PERIOD=300
export WTF_DOCKER_PRUNE_SAFE_KEEP_DAYS=7
export WTF_SECRET_DETECTOR_PATTERNS="aws_key|api_key|secret|token"
EOF

print_status "Installation complete! 🎉"
print_status "Your tools are installed in: ${INSTALL_DIR}"
print_status "Configuration is in: ${CONFIG_DIR}"
print_warning "Please restart your shell or run 'source ~/.bashrc' (or 'source ~/.zshrc') to start using the tools" 