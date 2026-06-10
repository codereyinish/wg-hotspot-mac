# Decision: the VPN runs on the Mac, not the iPhone

A reasonable question: the iPhone is right there — why not run the tunnel on the
*phone* and protect the Mac's traffic through it? You can't, for three reasons,
and the Mac is the free, correct place anyway.

## 1. iOS can't tunnel a tethered device's traffic
An iOS VPN runs as a **NetworkExtension** (Packet Tunnel Provider), and that only
ever sees the **iPhone's own** traffic. A **tethered Mac's** traffic goes through a
path an app can't intercept — so even a VPN app on the phone wouldn't carry the
Mac's traffic. The phone simply can't reach in and tunnel a tethered client.

## 2. iOS background tunneling costs $99/yr
The NetworkExtension entitlement requires a **paid Apple Developer account
($99/year)**. A free account can't ship a background tunnel on iOS.

## 3. macOS gives you the tunnel for free
On macOS you create a **utun interface** and run WireGuard with **no paid
entitlement** — the App Store app or `wg-quick` both do it for free. And it's the
**Mac's** traffic we're protecting, so the Mac is where the tunnel belongs.

## Decision
The VPN runs on the **Mac**: the iPhone can't tunnel the Mac's tethered traffic,
iOS would charge $99 for background tunneling, and macOS does it for free.
