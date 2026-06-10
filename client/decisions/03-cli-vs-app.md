# Decision: WireGuard CLI vs the App Store app (we ship both)

macOS has **two separate WireGuard things**, for different needs:

```
WireGuard GUI app  -> Mac App Store -> menu-bar toggle, On-Demand auto-connect,
                                        built-in stats; NOT scriptable, tunnel is sandboxed
wireguard-tools    -> Homebrew      -> the CLI: wg, wg-quick; scriptable, tunnel is CLI-readable
```

Both are official, **open-source** WireGuard code (`git.zx2c4.com/wireguard-apple`
for the apps, `wireguard-tools` for the CLI). The App Store build is just a signed
build of that source.

## Why we used the CLI (Homebrew) first
The first version had a **custom live-stats widget**. Stats come from
`wg show all dump` — which can **only read a wg-quick-managed tunnel**. The GUI app
runs its tunnel inside a **sandboxed NetworkExtension the CLI can't see**, so the
app's tunnel would have been invisible to the stats script. To get readable stats
we *had* to use `wg-quick` (CLI) — that's why Homebrew was the choice. (It also
needed a passwordless-sudo rule, since `wg`/`wg-quick` need root and you can't
prompt for a password every 10s during a stats poll or a launchd auto-connect.)

## Why the app makes sense now
The GUI app shows its **own** stats, plus the toggle and **On-Demand** auto-connect
— all native. So the entire reason we needed the CLI (custom stats) disappears for
someone who just wants a working VPN.

## Decision: ship both, tiered
- **Easy path (default):** the App Store app — install, import config, toggle from
  the menu bar, On-Demand for auto-connect. Zero terminal. For most people.
- **Advanced path:** the `wg-quick` CLI + launchd scripts — scriptable, customizable,
  CLI-readable stats. For tinkering and future extensions.

```
GUI app -> easiest; built-in stats/toggle/auto-connect; sandboxed (no CLI access)
CLI     -> scriptable; CLI-readable stats; but you build the UI + sudo setup
```

Non-devs take the app; power users (and future-us) keep the CLI. Nothing wasted.
