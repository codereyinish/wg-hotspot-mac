# Personal Networking Toolkit

Two self-built tools for routing a laptop's traffic securely when you're away from
a trusted network — built as a hands-on deep-dive into how networking actually
works: routing, tunneling, sockets, and encryption.

## Two parts

### 1. Self-hosted WireGuard VPN → [`client/`](client/) + [`server/`](server/)
Your devices tunnel through your *own* cloud server over an encrypted WireGuard
connection, so traffic is encrypted to a server you control — instead of trusting
a third-party VPN provider. Great for privacy on slow, untrusted public WiFi.
→ [client/README.md](client/README.md)

### 2. Transparent system-wide proxy → [`ios-proxy-test/`](ios-proxy-test/)
Capture **all** of a Mac's traffic at the IP layer — even apps that ignore proxy
settings — and route it through a reverse tunnel to a second device. A deep dive
into Layer-3 capture, tun2socks, routing internals, and connection pooling.
→ [ios-proxy-test/README.md](ios-proxy-test/README.md) ·
[ARCHITECTURE.md](ios-proxy-test/ARCHITECTURE.md)

## License
[Elastic License 2.0](LICENSE) — free for personal use, source visible,
redistribution not permitted.
