# Self-hosted WireGuard VPN

Tunnel your Mac through your own cloud server over an encrypted WireGuard
connection, so traffic is encrypted to a server *you* control — instead of
trusting a third-party VPN provider.

📐 **Architecture & decisions** (why WireGuard, why the Mac, CLI vs app):
[ARCHITECTURE.md](ARCHITECTURE.md)

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

## Two ways to run it

### Easy path (recommended) — the WireGuard app
1. Install **WireGuard** from the **Mac App Store** (open source — same project as the CLI).
2. **Add Tunnel → Import from file** → choose your `wg0.conf`.
3. Enable **On-Demand** so it auto-connects on a network and survives reboot.
4. Toggle on/off from the **menu-bar** icon anytime. Status + ↑/↓ data + last
   handshake show in the app.

No terminal — the app handles the toggle, auto-connect, and stats natively.

### Advanced path — the CLI (scriptable)
For tinkering / custom behaviour: `wg-quick` + a launchd auto-connect script + a
terminal stats script (`wg-stats`). Full step-by-step: [../DEVELOPER.md](../DEVELOPER.md).
```bash
# Server (Ubuntu VPS): install WireGuard + open UDP 51820
curl -fsSL https://raw.githubusercontent.com/codereyinish/wg-hotspot-mac/main/server/setup.sh | sudo bash
# Mac: clone + run the installer
./install.sh
```

## Layout
- `client/` — config, the CLI scripts (advanced path), and `decisions/` (architecture)
- `server/` — VPS / WireGuard server setup

## Note
`wg0.conf.example` disables IPv6 while connected to prevent leaks outside the
tunnel — standard VPN hygiene.
