#!/bin/bash
# =============================================================================
# install.sh — WireGuard VPN Installer
# =============================================================================
# What this script does:
#   Installs everything needed to auto-connect your Mac to a self-hosted
#   WireGuard VPN on a chosen network.
#
# What it installs:
#   - Homebrew (if missing)
#   - wireguard-tools (via Homebrew)
#   - SwiftBar (via Homebrew, for the menu bar widget)
#   - wireguard-hotspot.sh  → /usr/local/bin/
#   - wg-stats              → /usr/local/bin/
#   - com.wireguard.hotspot.plist → /Library/LaunchDaemons/
#   - wg-stats.10s.sh       → your SwiftBar plugins folder
#   - wg0.conf              → /opt/homebrew/etc/wireguard/
#   - sudoers rule          → /etc/sudoers.d/wireguard
#   - usage log             → /var/log/wg-usage.log
#
# What the user needs to provide:
#   - Their server IP
#   - Their server WireGuard public key
#   - SwiftBar plugins folder path (optional, has default)
#
# Requirements:
#   - macOS (Apple Silicon or Intel)
#   - A running WireGuard server (see server/setup.sh)
#
# Usage:
#   ./install.sh
#
# Author: github.com/codereyinish
# =============================================================================

set -e  # exit immediately if any command fails

# =============================================================================
# COLORS — for readable terminal output
# =============================================================================
RED=$'\033[91m'
GRN=$'\033[92m'
YLW=$'\033[93m'
BLU=$'\033[96m'
BLD=$'\033[1m'
RST=$'\033[0m'

# =============================================================================
# HELPERS
# =============================================================================

# Print a section header
header() {
    echo ""
    echo "${BLD}${BLU}── $1 ${RST}"
}

# Print success
ok() {
    echo "  ${GRN}✓${RST} $1"
}

# Print info
info() {
    echo "  ${YLW}→${RST} $1"
}

# Print error and exit
die() {
    echo ""
    echo "  ${RED}✗ Error: $1${RST}"
    echo ""
    exit 1
}

# Ask a question, store answer in variable
# Usage: ask VARNAME "Question" "default value"
ask() {
    local var=$1
    local question=$2
    local default=$3
    echo ""
    if [ -n "$default" ]; then
        printf "  ${BLD}$question${RST} [${default}]: "
    else
        printf "  ${BLD}$question${RST}: "
    fi
    read -r input
    if [ -z "$input" ] && [ -n "$default" ]; then
        eval "$var=\"$default\""
    else
        eval "$var=\"$input\""
    fi
}

# =============================================================================
# STEP 0 — Welcome
# =============================================================================
clear
echo ""
echo "${BLD}  WireGuard VPN — Installer${RST}"
echo "  ────────────────────────────────────────"
echo "  Automatically connect your Mac to your"
echo "  own private VPN on a chosen network."
echo ""
echo "  This installer will ask you 3 things:"
echo "    1. Your WireGuard server IP"
echo "    2. Your server public key"
echo "    3. Your SwiftBar plugins folder"
echo ""
echo "  Everything else is automatic."
echo ""
read -rp "  Press Enter to start..."

# =============================================================================
# STEP 1 — Check this is macOS
# =============================================================================
header "Step 1/14 — Checking system"

if [ "$(uname)" != "Darwin" ]; then
    die "This installer only supports macOS."
fi
ok "macOS detected"

# Detect Apple Silicon vs Intel — sets the correct Homebrew path
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    BREW_PREFIX="/opt/homebrew"
    ok "Apple Silicon (M1/M2/M3) detected"
else
    BREW_PREFIX="/usr/local"
    ok "Intel Mac detected"
fi

WG_BIN="$BREW_PREFIX/bin/wg"
WG_QUICK_BIN="$BREW_PREFIX/bin/wg-quick"
WG_CONF_DIR="$BREW_PREFIX/etc/wireguard"

# =============================================================================
# STEP 2 — Install Homebrew
# =============================================================================
header "Step 2/14 — Homebrew"

if command -v brew &>/dev/null; then
    ok "Homebrew already installed — skipping"
else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ok "Homebrew installed"
fi

# =============================================================================
# STEP 3 — Install wireguard-tools
# =============================================================================
header "Step 3/14 — WireGuard tools"

if command -v wg &>/dev/null; then
    ok "wireguard-tools already installed — skipping"
else
    info "Installing wireguard-tools..."
    brew install wireguard-tools
    ok "wireguard-tools installed"
fi

# =============================================================================
# STEP 4 — Install SwiftBar
# =============================================================================
header "Step 4/14 — SwiftBar"

if [ -d "/Applications/SwiftBar.app" ]; then
    ok "SwiftBar already installed — skipping"
else
    info "Installing SwiftBar..."
    brew install --cask swiftbar
    ok "SwiftBar installed"
    info "Open SwiftBar once and choose a plugins folder before continuing"
    read -rp "  Press Enter once you've opened SwiftBar and set a plugins folder..."
fi

# =============================================================================
# STEP 5 — Generate client WireGuard key pair
# =============================================================================
header "Step 5/14 — Generating your WireGuard keys"

# Keys are generated fresh — private key is never saved to disk permanently
# It goes straight into wg0.conf which is only readable by root
PRIVATE_KEY=$(wg genkey)
PUBLIC_KEY=$(echo "$PRIVATE_KEY" | wg pubkey)

ok "Key pair generated"
echo ""
echo "  ${BLD}Your client public key:${RST}"
echo ""
echo "  ${BLU}${PUBLIC_KEY}${RST}"
echo ""

# =============================================================================
# STEP 6 — PAUSE: Add client key to server
# =============================================================================
header "Step 6/14 — Add your key to the server"

echo "  You need to add the public key above to your server's wg0.conf."
echo ""
echo "  SSH into your server and run:"
echo ""
echo "  ${YLW}sudo nano /etc/wireguard/wg0.conf${RST}"
echo ""
echo "  Add this at the bottom:"
echo ""
echo "  ${YLW}[Peer]"
echo "  PublicKey = ${PUBLIC_KEY}"
echo "  AllowedIPs = 10.0.0.2/32${RST}"
echo ""
echo "  Then restart WireGuard on the server:"
echo "  ${YLW}sudo systemctl restart wg-quick@wg0${RST}"
echo ""
read -rp "  Press Enter once you've done this..."

# =============================================================================
# STEP 7 — Collect server info from user
# =============================================================================
header "Step 7/14 — Your server details"

ask SERVER_IP    "Server IP address (e.g. 123.456.789.0)" ""
ask SERVER_PORT  "Server WireGuard port" "51820"
ask SERVER_PUBKEY "Server public key" ""
ask CLIENT_ADDR  "Your VPN client address" "10.0.0.2"
ask DNS_SERVER   "DNS server to use" "1.1.1.1"

# Validate — none of these can be empty
[ -z "$SERVER_IP" ]     && die "Server IP cannot be empty"
[ -z "$SERVER_PUBKEY" ] && die "Server public key cannot be empty"

ok "Server details collected"

# =============================================================================
# STEP 8 — Create wg0.conf
# =============================================================================
header "Step 8/14 — Creating WireGuard config"

sudo mkdir -p "$WG_CONF_DIR"

# Write wg0.conf with the user's details
# PostUp/PostDown: sets TTL and IPv6 hop limit for correct packet routing
sudo tee "$WG_CONF_DIR/wg0.conf" > /dev/null << EOF
[Interface]
PrivateKey = ${PRIVATE_KEY}
Address = ${CLIENT_ADDR}/24
DNS = ${DNS_SERVER}
PostUp = /usr/sbin/sysctl -w net.inet.ip.ttl=65; /usr/sbin/sysctl -w net.inet6.ip6.hlim=65
PostDown = /usr/sbin/sysctl -w net.inet.ip.ttl=64; /usr/sbin/sysctl -w net.inet6.ip6.hlim=64

[Peer]
PublicKey = ${SERVER_PUBKEY}
Endpoint = ${SERVER_IP}:${SERVER_PORT}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

sudo chmod 600 "$WG_CONF_DIR/wg0.conf"
ok "wg0.conf created at $WG_CONF_DIR/wg0.conf"

# =============================================================================
# STEP 9 — Install scripts to /usr/local/bin
# =============================================================================
header "Step 9/14 — Installing scripts"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)/client"

sudo cp "$SCRIPT_DIR/wireguard-hotspot.sh" /usr/local/bin/wireguard-hotspot.sh
sudo cp "$SCRIPT_DIR/wg-stats"             /usr/local/bin/wg-stats
sudo chmod +x /usr/local/bin/wireguard-hotspot.sh
sudo chmod +x /usr/local/bin/wg-stats

ok "wireguard-hotspot.sh → /usr/local/bin/"
ok "wg-stats → /usr/local/bin/"

# =============================================================================
# STEP 10 — Install LaunchDaemon
# =============================================================================
header "Step 10/14 — Installing LaunchDaemon"

# LaunchDaemon watches for network changes and fires wireguard-hotspot.sh
# Runs as root (required for wg-quick) — lives in /Library/LaunchDaemons
sudo cp "$SCRIPT_DIR/com.wireguard.hotspot.plist" \
    /Library/LaunchDaemons/com.wireguard.hotspot.plist

sudo launchctl load /Library/LaunchDaemons/com.wireguard.hotspot.plist 2>/dev/null || true

ok "LaunchDaemon installed and loaded"
info "Will auto-start on every reboot"

# =============================================================================
# STEP 11 — Create usage log file
# =============================================================================
header "Step 11/14 — Creating log file"

# wg-usage.log stores completed session stats (rx/tx bytes per session)
# wireguard-hotspot.log stores daemon activity (for debugging)
sudo touch /var/log/wg-usage.log
sudo touch /var/log/wireguard-hotspot.log
sudo chmod 644 /var/log/wg-usage.log
sudo chmod 644 /var/log/wireguard-hotspot.log

ok "/var/log/wg-usage.log created"
ok "/var/log/wireguard-hotspot.log created"

# =============================================================================
# STEP 12 — Configure sudoers
# =============================================================================
header "Step 12/14 — Configuring sudoers"

# Allows wg and wg-quick to run without password prompt
# Required for: wg show (live stats), wg-quick up/down (tunnel management)
# Writes to /etc/sudoers.d/ — safer than editing /etc/sudoers directly
SUDOERS_FILE="/etc/sudoers.d/wireguard"
echo "%admin ALL=(ALL) NOPASSWD: $WG_BIN, $WG_QUICK_BIN" | \
    sudo tee "$SUDOERS_FILE" > /dev/null
sudo chmod 440 "$SUDOERS_FILE"

ok "Sudoers rule added — no password needed for wg commands"

# =============================================================================
# STEP 13 — Set up SwiftBar plugin
# =============================================================================
header "Step 13/14 — SwiftBar plugin"

# Default plugins folder — user can override
DEFAULT_PLUGINS="$HOME/swiftbar-plugins"
ask PLUGINS_DIR "SwiftBar plugins folder path" "$DEFAULT_PLUGINS"

mkdir -p "$PLUGINS_DIR"
cp "$SCRIPT_DIR/wg-stats.10s.sh" "$PLUGINS_DIR/wg-stats.10s.sh"
chmod +x "$PLUGINS_DIR/wg-stats.10s.sh"

ok "Plugin installed → $PLUGINS_DIR/wg-stats.10s.sh"
info "Refreshes every 10 seconds automatically"

# =============================================================================
# STEP 14 — Done
# =============================================================================
header "Step 14/14 — All done"

echo ""
echo "${GRN}${BLD}  ✓ Installation complete!${RST}"
echo ""
echo "  What was installed:"
echo "  • WireGuard config    → $WG_CONF_DIR/wg0.conf"
echo "  • Auto-connect script → /usr/local/bin/wireguard-hotspot.sh"
echo "  • Stats script        → /usr/local/bin/wg-stats"
echo "  • LaunchDaemon        → /Library/LaunchDaemons/com.wireguard.hotspot.plist"
echo "  • Usage log           → /var/log/wg-usage.log"
echo "  • SwiftBar plugin     → $PLUGINS_DIR/wg-stats.10s.sh"
echo ""
echo "  To test:"
echo "  ${YLW}  1. Connect your iPhone hotspot${RST}"
echo "  ${YLW}  2. Wait 5–10 seconds${RST}"
echo "  ${YLW}  3. Check the menu bar — should show WG ● live${RST}"
echo ""
echo "  To view stats in terminal:"
echo "  ${YLW}  wg-stats${RST}"
echo ""
