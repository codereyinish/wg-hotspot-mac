# WireGuard Hotspot Mac

Automatically connects your Mac to your own private VPN server the moment
you tether from your iPhone — and disconnects when you switch back to WiFi.
No manual toggling. A menu bar widget shows your live data usage in real time.

---

## Why you'd want this

**You work remotely and tether frequently**
Your Mac traffic goes through your own server — not exposed on the carrier
network. No VPN app subscription needed.

**You want to know exactly how much data you're using**
The menu bar widget tracks usage per session, per day, and all time.
You always know how much you've consumed before hitting your limit.

**You're tired of manually connecting your VPN every time you hotspot**
This does it automatically. iPhone hotspot on → VPN up.
Hotspot off → VPN down. You don't touch anything.

**You travel and use cellular data on your Mac**
Keep all your traffic private through your own server instead of relying
on carrier infrastructure or public WiFi.

---

## What it looks like

```
WG ●  ↓8.33 MB  ↑47.60 MB          ← menu bar (live)
─────────────────────────────
🟢  Live   ↓8.33 MB   ↑47.60 MB  ▶
─────────────────────────────
📅  Today
   Session 9   19:24:46   ↓2.73 MB   ↑2.81 MB
   Session 8   19:04:19   ↓171 KB    ↑258 KB
   ▸ 7 earlier session(s)            ▶
📊  Day total  ↓20 MB    ↑77 MB     ▶
─────────────────────────────
📅  Yesterday (2026-05-27)  ↓181 MB  ↑41 MB  ▶
─────────────────────────────
🌐  All time   ↓201 MB   ↑119 MB    ▶
```

---

## Prerequisites

- Mac (Apple Silicon or Intel)
- [Homebrew](https://brew.sh) — install script handles this automatically
- [SwiftBar](https://swiftbar.app) — free menu bar app runner
- Your own WireGuard server (Oracle Cloud Free Tier — free forever)

---

## Setup

There are two sides to set up — server first, then Mac.

### Step 1 — Server (run once on your Oracle VPS)

Create a free Ubuntu VPS on [Oracle Cloud](https://cloud.oracle.com),
open port **51820 UDP** in the security list, SSH in, then run:

```bash
curl -fsSL https://raw.githubusercontent.com/codereyinish/wg-hotspot-mac/main/server/setup.sh | sudo bash
```

At the end it shows your **server public key** — copy it, you'll need it next.

---

### Step 2 — Mac client

```bash
git clone https://github.com/codereyinish/wg-hotspot-mac
cd wg-hotspot-mac
./install.sh
```

The installer will ask you three things:
1. Your server IP
2. Your server public key (from Step 1)
3. Your SwiftBar plugins folder (press Enter for default)

Everything else is automatic.

---

## How it works

```
iPhone hotspot on
      ↓
Mac detects network change (via launchd)
      ↓
WireGuard tunnel connects to your server
      ↓
All traffic routes through your private server
      ↓
iPhone hotspot off → session stats saved → tunnel disconnects
```

---

## Terminal stats

```bash
wg-stats
```

---

## File reference

| File | Purpose |
|------|---------|
| `/opt/homebrew/etc/wireguard/wg0.conf` | WireGuard client config |
| `/usr/local/bin/wireguard-hotspot.sh` | Auto connect/disconnect script |
| `/usr/local/bin/wg-stats` | Usage stats script |
| `/Library/LaunchDaemons/com.wireguard.hotspot.plist` | launchd daemon |
| `/var/log/wg-usage.log` | Session usage log |
| `/var/log/wireguard-hotspot.log` | Daemon activity log |

---

## For developers

Want to understand, modify, or contribute to the scripts?
See [DEVELOPER.md](DEVELOPER.md) — every step documented manually,
no install script required.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

[Elastic License 2.0](LICENSE) —
free for personal use, source visible, redistribution not permitted.
