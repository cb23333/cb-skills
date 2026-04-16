# Reconnaissance & Information Gathering

## Overview

Reconnaissance is the foundation of any security assessment. It has two phases:
- **Passive recon**: Gathering information without directly interacting with the target (OSINT)
- **Active recon**: Direct interaction with the target (scanning, enumeration)

## Passive Reconnaissance (OSINT)

### Domain & DNS Information

```bash
# WHOIS lookup
whois example.com

# DNS enumeration - basic record lookup
dig example.com ANY
dnsrecon -d example.com

# DNS zone transfer attempt (often misconfigured)
dig axfr example.com @ns1.example.com
dnsrecon -d example.com -t axfr

# Subdomain enumeration
subfinder -d example.com          # Passive subdomain discovery
amass enum -passive -d example.com # Comprehensive passive enum
```

### Web & Email Reconnaissance

```bash
# Email harvesting
theHarvester -d example.com -b all -l 500

# Technology fingerprinting (can be passive)
whatweb example.com

# Google dorking examples (manual)
# site:example.com filetype:pdf
# site:example.com inurl:admin
# site:example.com intitle:"index of"
```

### Social Media & People

```bash
# Username search across platforms
sherlock username

# LinkedIn recon (browser-based, use tools like LinkedIn2username)
```

## Active Reconnaissance

### Network Discovery

Before scanning individual hosts, discover what's on the network:

```bash
# ARP scan - discover live hosts on local network
arp-scan -l
arp-scan --interface=eth0 192.168.1.0/24

# ICMP sweep (may be blocked by firewalls)
nmap -sn 192.168.1.0/24

# Fast host discovery using ARP
netdiscover -r 192.168.1.0/24
```

### Port Scanning with Nmap

Nmap is the cornerstone of active reconnaissance. Here's a progressive approach:

#### Stage 1: Quick Service Discovery

```bash
# Fast scan - top 100 ports with service version detection
nmap -sV --top-ports 100 -T4 target

# Common port scan with OS detection
nmap -sC -sV -O target
# -sC: default scripts, -sV: version detection, -O: OS fingerprinting
```

#### Stage 2: Full Port Scan (when you have time)

```bash
# All 65535 ports - run in background during other work
nmap -p- -T4 -A target -oN full_scan.txt
# -p-: all ports, -T4: aggressive timing, -A: all detection, -oN: normal output

# UDP scan (top ports, as full UDP scan is very slow)
nmap -sU --top-ports 100 -T4 target
```

#### Stage 3: Targeted Service Scans

```bash
# Deep SMB scan
nmap -p 445 --script=smb-enum-shares,smb-enum-users,smb-vuln* target

# Deep HTTP scan
nmap -p 80,443,8080 --script=http-enum,http-headers,http-methods target

# Deep MySQL scan
nmap -p 3306 --script=mysql-info,mysql-vuln-cve2012-2122 target

# SNMP scan (community string brute force)
nmap -sU -p 161 --script=snmp-brute target
onesixtyone -c community.txt -i targets.txt
snmpwalk -v2c -c public target
```

#### Nmap Output Options

```bash
# Save results in multiple formats
nmap -sC -sV -oA scan_results target
# -oA: outputs .nmap (normal), .xml (XML), .gnmap (grepable)

# Resume interrupted scan
nmap --resume scan_results.xml
```

### Fast Alternative Scanners

```bash
# Masscan - extremely fast, good for large ranges
masscan -p1-65535 --rate=1000 target -oG masscan_results.txt

# RustScan - fast port discovery, pipes to nmap for service detection
rustscan -a target -- -sC -sV
```

## Service Enumeration

After discovering open ports, enumerate each service deeply.

### SMB Enumeration (Ports 139, 445)

```bash
# Basic enumeration
smbclient -L //target -N                    # List shares
smbclient //target/share -N                 # Connect to share

# Comprehensive SMB enum
enum4linux -a target                        # All-in-one SMB enum
crackmapexec smb target                     # Modern SMB enumeration

# Null session check
rpcclient -U "" target -c "srvinfo"

# SMB vulnerability check
nmap -p 445 --script=smb-vuln-ms17-010 target  # EternalBlue check
```

### FTP Enumeration (Port 21)

```bash
# Banner grab and version
nmap -sV -p 21 target

# Anonymous login check
ftp target
# Try login: anonymous / anonymous@

# Deep FTP enum
nmap -p 21 --script=ftp-anon,ftp-syst,ftp-vsftpd-backdoor target
```

### SSH Enumeration (Port 22)

```bash
# Version and algorithm info
nmap -p 22 --script=ssh-auth-methods,ssh-hostkey target

# SSH key audit
ssh-audit target
```

### DNS Enumeration (Port 53)

```bash
# DNS lookup
dig @target example.com

# Reverse DNS
dig -x target_ip

# DNSSEC check
dig +dnssec example.com

# DNSEnum - automated
dnsenum example.com
```

### SNMP Enumeration (Port 161)

```bash
# SNMP walk with common community strings
snmpwalk -v1 -c public target
snmpwalk -v2c -c public target
snmpwalk -v3 -c public target

# Extract specific OIDs
snmpwalk -v2c -c public target 1.3.6.1.2.1.1.1  # System info
snmpwalk -v2c -c public target 1.3.6.1.4.1.77.1.2.25  # User accounts

# SNMP brute force
onesixtyone -c /usr/share/wordlists/rockyou.txt target
```

### HTTP/HTTPS Enumeration (Ports 80, 443, 8080, 8443)

```bash
# Web technology detection
whatweb http://target
nikto -h http://target

# Directory discovery
gobuster dir -u http://target -w /usr/share/wordlists/dirb/common.txt
dirb http://target /usr/share/wordlists/dirb/common.txt

# Virtual host discovery
gobuster vhost -u http://target -w /usr/share/wordlists/amass/subdomains-top1mil-5000.txt

# See web-testing.md for comprehensive web application testing
```

## Network Traffic Analysis

```bash
# Capture traffic on interface
tcpdump -i eth0 -w capture.pcap

# Filter specific traffic
tcpdump -i eth0 port 80 -w http_capture.pcap
tcpdump -i eth0 host target_ip -w target_capture.pcap

# Analyze with Wireshark (GUI)
wireshark capture.pcap

# Quick analysis with tshark
tshark -r capture.pcap -Y "http.request" -T fields -e http.host -e http.request.uri
```

## Workflow Decision Tree

```
Start
  │
  ├─ Passive recon first (OSINT)
  │   ├─ WHOIS, DNS, subdomains
  │   ├─ Email harvesting
  │   └─ Technology fingerprinting
  │
  ├─ Active scanning
  │   ├─ Host discovery (ARP/ICMP)
  │   ├─ Quick port scan (top 100)
  │   ├─ Full port scan (all 65535)
  │   └─ UDP scan (top ports)
  │
  └─ Service enumeration
      ├─ SMB (enum4linux, smbclient)
      ├─ FTP (anonymous check)
      ├─ HTTP (gobuster, nikto)
      ├─ SNMP (snmpwalk)
      └─ DNS (dnsenum)
```
