# WireGuard VPN — Architecture & Decisions

A record of the key design decisions, one file each — short "why this, not that"
notes, written as the reasoning, not just the result.

| # | Decision | Why |
|---|----------|-----|
| [01](decisions/01-wireguard-vs-tls-relay.md) | WireGuard, not a TLS relay | a TLS relay is TCP-in-TCP (melts down on lossy links), TCP-only (leaks UDP/QUIC), and a shared token is weaker than asymmetric keys |
| [02](decisions/02-mac-not-iphone.md) | The Mac runs the VPN, not the iPhone | iOS can't tunnel a tethered Mac and needs a $99 entitlement; macOS does it free |
| [03](decisions/03-cli-vs-app.md) | CLI vs the App Store app (ship both) | the app's tunnel is sandboxed (no CLI stats) — so we used the CLI for a custom widget; now the app shows stats natively, so we offer both |

## At a glance
```
your Mac → [WireGuard encrypted tunnel] → your VPS → internet
```
- **UDP, packet-level (L3)** — carries every protocol, no TCP-over-TCP meltdown
- **asymmetric keys** — the private key never leaves the device
- **runs on the Mac** — free utun, protects the Mac's own traffic
- **two ways to run it** — the App Store app (easy) or the CLI (advanced)
