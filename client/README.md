# Self-hosted WireGuard VPN

Tunnel your Mac through your own cloud server over an encrypted WireGuard
connection, so traffic is encrypted to a server *you* control — instead of
trusting a third-party VPN provider. A menu-bar widget shows live data usage.

## Why self-hosted
Public / free WiFi is slow and untrusted: anything between you and a site can
snoop or tamper. A VPN fixes that — but commercial VPNs ask you to trust *their*
servers (logging, leaks, data-selling). Running your own removes that: the only
server in the path is yours.

## How it works
```
your Mac → [WireGuard encrypted tunnel] → your VPS → internet
```
- **WireGuard** — modern, fast VPN protocol (ChaCha20, tiny codebase)
- **Your VPS** (e.g. Oracle Cloud Free Tier) — the always-on exit node you control
- **launchd auto-connect** — watches for network changes and brings the tunnel up
  automatically on a configured network (edit the gateway check in the script)
- **SwiftBar menu-bar widget** — live data usage per session / day / all-time

## What the menu bar looks like
```
WG ●  ↓8.33 MB  ↑47.60 MB
─────────────────────────────
🟢  Live   ↓8.33 MB   ↑47.60 MB
📅  Today      ↓20 MB   ↑77 MB
🌐  All time   ↓201 MB  ↑119 MB
```

## Setup
Server first, then Mac. Full step-by-step (no installer required):
[../DEVELOPER.md](../DEVELOPER.md).

Quick path:
```bash
# 1. Server (Ubuntu VPS): install WireGuard + open UDP 51820
curl -fsSL https://raw.githubusercontent.com/codereyinish/wg-hotspot-mac/main/server/setup.sh | sudo bash
# 2. Mac: clone + run the installer (asks for server IP + public key)
./install.sh
```

## Layout
- `client/` — Mac client config, auto-connect script, launchd job, stats widget
- `server/` — VPS / WireGuard server setup

## Note
`wg0.conf.example` disables IPv6 while connected to prevent leaks outside the
tunnel — standard VPN hygiene.
