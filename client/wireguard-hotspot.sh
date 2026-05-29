#!/bin/bash
  export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
  sleep 3

  # ── Detect Homebrew prefix (Apple Silicon vs Intel) ──
  # Apple Silicon: /opt/homebrew | Intel: /usr/local
  if [ "$(uname -m)" = "arm64" ]; then
      BREW_PREFIX="/opt/homebrew"
  else
      BREW_PREFIX="/usr/local"
  fi
  WG_BIN="$BREW_PREFIX/bin/wg"
  WG_QUICK_BIN="$BREW_PREFIX/bin/wg-quick"

  # ── Lock to prevent duplicate runs ──
  LOCKFILE="/tmp/wireguard-hotspot.lock"
  if [ -f "$LOCKFILE" ]; then
      exit 0
  fi
  touch "$LOCKFILE"
  trap "rm -f $LOCKFILE" EXIT

  # ── Config ──
  IPHONE_GATEWAY="172.20.10.1"
  WG_STATE_FILE="/var/run/wireguard/wg0.name"
  WG_USAGE_LOG="/var/log/wg-usage.log"

  # ── Detect current gateway ──
  current_gateway=$(netstat -rn | awk '/default/{print $2}' | head -1)
  echo "Gateway detected: $current_gateway"

  # ── Save session stats before tunnel goes down ──
  save_session_stats() {
      DUMP=$($WG_BIN show all dump 2>/dev/null | awk 'NR==2 {print $7, $8}')
      if [ -n "$DUMP" ]; then
          RX=$(echo "$DUMP" | cut -d' ' -f1)
          TX=$(echo "$DUMP" | cut -d' ' -f2)
          TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
          echo "$TIMESTAMP | rx:$RX | tx:$TX" >> "$WG_USAGE_LOG"
          echo "Session saved → rx:$RX bytes | tx:$TX bytes"
      else
          echo "No WireGuard stats to save"
      fi
  }

  # ── Main logic ──
  if [ "$current_gateway" = "$IPHONE_GATEWAY" ]; then
      if [ ! -f "$WG_STATE_FILE" ]; then
          echo "Hotspot detected - bringing wg0 up"
          $WG_QUICK_BIN up wg0
      else
          echo "Hotspot detected - wg0 already up, skipping"
      fi
  else
      if [ -f "$WG_STATE_FILE" ]; then
          echo "Hotspot disconnected - saving session stats"
          save_session_stats
          echo "Bringing wg0 down"
          $WG_QUICK_BIN down wg0
      else
          echo "Not on hotspot - wg0 already down, skipping"
      fi
  fi
