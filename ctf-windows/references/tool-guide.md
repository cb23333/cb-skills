# CTF Windows Tool Guide

Quick reference for essential CTF tools on Windows. Action-oriented commands and workflows for Web and Crypto challenges.

## 1. Burp Suite (Community Edition)

### Setup
- **Proxy Configuration**: Set browser proxy to `127.0.0.1:8080`
- **Certificate**: Install CA cert from `http://burp` to intercept HTTPS traffic
- **Disable Intercept**: Uncheck "Intercept" in Proxy tab when not actively testing

### Core Features
- **Proxy Tab**: View all HTTP/HTTPS traffic through the proxy
- **Intercept**: Pause and modify requests before they send to server
- **Repeater**: Manual request testing with full control over headers/body
- **Intruder**: Automated attacks with payload positions
- **Decoder**: Quick encoding/decoding without leaving Burp

### Workflows
- **Capture Login Request for Brute Force**:
  1. Submit login form with credentials
  2. Find POST request in Proxy → HTTP history
  3. Right-click → Send to Intruder
  4. Set positions: wrap username/password fields with `§§`
  5. Choose payload list (wordlist file)
  6. Attack type: Sniper (one position at a time)

- **Modify and Replay Request**:
  1. Capture request in Proxy
  2. Right-click → Send to Repeater (Ctrl+R)
  3. Edit headers, body, or method
  4. Click "Send" to test changes
  5. Compare response to original

- **Intruder Attack Types**:
  - **Sniper**: One payload set used across all positions sequentially
  - **Battering Ram**: Single payload used in all positions at once
  - **Pitchfork**: Multiple payload sets (one per position) used in parallel
  - **Cluster bomb**: All payload combinations across all positions (slow)

- **Quick Encoding**:
  1. Select text in any tab
  2. Right-click → Send to Decoder
  3. Choose: Base64, URL, Hex, HTML, etc.
  4. Chain operations for multiple transformations

---

## 2. CyberChef

**URL**: https://gchq.github.io/CyberChef/ (works offline if downloaded)

### Getting Started
- **Magic Operation**: Drag in your data → "Magic" auto-detects encoding chains
- **First Thing to Try**: When you see encoded data, run Magic first
- **Recipe URL**: Share/save recipes via URL parameters

### Common Recipes
- **Base64 Chain**: "From Base64" → "From Hex" → "From Base64"
- **URL + Base64**: "URL Decode" → "From Base64"
- **Rot/N Flags**: "ROT13" (or try ROT1-47) → Find flag pattern
- **XOR Brute Force**: "XOR Brute Force" → Search for "flag" or "CTF"
- **Multi-Stage**: Chain multiple decode operations automatically

### Operations
- **Encoding**: Base64, Hex, URL, HTML, Atbash, ROT13, Binary
- **Crypto**: AES, DES, RSA (encrypt/decrypt), XOR
- **Compression**: Gunzip, Bzip2, Zlib
- **Analysis**: Entropy, Frequency, Find/Replace, Regular expression

### Tips
- **Large Data**: CyberChef handles files up to several MB
- **Flag Hunting**: Add "Find / Replace" at end of recipe to locate `flag{...}`
- **Download**: Save output directly from the "Output" pane
- **Test Kitchen**: Verify recipes work on sample data before full run

---

## 3. Python for CTF on Windows

### Installation
```powershell
pip install pycryptodome requests gmpy2 beautifulsoup4 pwntools
```

### Quick HTTP
```python
import requests

# GET request
r = requests.get('http://example.com')
print(r.status_code)
print(r.text)

# POST with data
r = requests.post('http://example.com/login', data={'user': 'admin', 'pass': 'password'})

# Session for cookies
s = requests.Session()
s.get('http://example.com/login')
s.post('http://example.com/submit', data={'answer': '42'})  # Cookies preserved

# Headers and cookies
headers = {'User-Agent': 'CTF-Player'}
cookies = {'session': 'abc123'}
r = requests.get('http://example.com', headers=headers, cookies=cookies)
```

### Quick Crypto
```python
from Crypto.Cipher import AES, DES, PKCS1_v1_5
from Crypto.PublicKey import RSA
from Crypto.Util.Padding import unpad, pad

# AES ECB
cipher = AES.new(key, AES.MODE_ECB)
plaintext = cipher.decrypt(ciphertext)

# AES CBC
cipher = AES.new(key, AES.MODE_CBC, iv)
plaintext = unpad(cipher.decrypt(ciphertext), AES.block_size)

# RSA
key = RSA.import_key(open('private.pem').read())
cipher = PKCS1_v1_5.new(key)
plaintext = cipher.decrypt(ciphertext, None)
```

### Quick Math (RSA Attacks)
```python
import gmpy2
from math import isqrt

# GCD
g = gmpy2.gcd(a, b)

# Modular inverse
inv = gmpy2.invert(a, m)  # a^(-1) mod m

# Integer nth root
root, exact = gmpy2.iroot(n, 3)  # Cube root of n

# Prime factorization (small primes only)
p = gmpy2.next_prime(2**512)
```

### Quick Parsing
```python
from bs4 import BeautifulSoup

# Parse HTML
soup = BeautifulSoup(r.text, 'html.parser')

# Extract forms
form = soup.find('form')
inputs = form.find_all('input')
data = {i.get('name'): i.get('value') for i in inputs}

# Extract comments
comments = soup.find_all(string=lambda text: isinstance(text, str) and 'flag' in text)
```

### Quick Encoding
```python
import base64, binascii, hashlib

# Base64
b64 = base64.b64encode(data)
decoded = base64.b64decode(b64)

# Hex
hex_str = binascii.hexlify(data)
decoded = binascii.unhexlify(hex_str)

# Hash
md5 = hashlib.md5(data).hexdigest()
sha256 = hashlib.sha256(data).hexdigest()

# URL encoding
from urllib.parse import quote, unquote
encoded = quote(data)
decoded = unquote(encoded)
```

---

## 4. Browser DevTools (Chrome/Edge)

**Access**: `F12` or `Ctrl+Shift+I`

### Network Tab
- **All Traffic**: View every request/response sent by browser
- **Headers**: Check for custom headers, cookies, auth tokens
- **Filter**: Filter by "XHR", "JS", "Doc" to find API calls
- **Copy as curl**: Right-click request → Copy as curl (for replay)
- **Red rectangles**: Requests with errors (404, 500, etc.)

### Console
```javascript
// XSS testing
alert(document.cookie)
alert(document.domain)

// Decode Base64
atob('ZmxhZ3t0aGlzX2lzX2FfZmxhZ30=')  // "flag{this_is_a_flag}"

// Encode Base64
btoa('flag{test}')  // "ZmxhZ3t0ZXN0fQ=="

// DOM inspection
document.body.innerHTML
document.cookie
localStorage
sessionStorage
```

### Sources Tab
- **JS Files**: Browse all loaded JavaScript files
- **Pretty Print**: Click `{}` to minified code for readability
- **Search**: `Ctrl+Shift+F` to search all JS files for "flag" or "api"
- **Breakpoints**: Set breakpoints to debug challenge logic
- **Watch**: Inspect variables during execution

### Application Tab
- **Cookies**: View all cookies (domain, path, httpOnly, secure)
- **LocalStorage**: Key-value storage that persists across sessions
- **SessionStorage**: Temporary storage (clears on tab close)
- **Service Workers**: Check for background scripts
- **Cache**: View cached assets (might contain hints)

### Elements Tab
- **Hidden Fields**: Find `<input type="hidden">` with important values
- **Disabled Buttons**: Check if form validation is client-side only
- **HTML Comments**: View comments for hints (`<!-- TODO: add auth -->`)
- **Modify**: Edit HTML/attributes on the fly to test bypasses

---

## 5. PowerShell for CTF

### File Operations
```powershell
# Read file
Get-Content file.txt
cat file.txt  # Alias

# Read file as raw bytes (for binaries)
Get-Content -Path file.bin -Encoding Byte -Raw

# Write file
Set-Content -Path output.txt -Value "data"
echo "data" > output.txt

# List files recursively
Get-ChildItem -Recurse
ls -r  # Alias
```

### Regex Search
```powershell
# Search for flag pattern in files
Select-String -Path . -Pattern "flag\{[^}]+\}" -Recurse
sls -r "flag\{[^}]+\}"  # Short alias

# Case-insensitive search
Select-String -Pattern "flag" -CaseSensitive:$false

# Context lines (2 before, 2 after)
Select-String -Pattern "password" -Context 2,2
```

### Network Requests
```powershell
# GET request
$response = Invoke-WebRequest -Uri "http://example.com"
$response.StatusCode
$response.Content

# POST request
$body = @{"username"="admin"; "password"="password"}
Invoke-RestMethod -Uri "http://example.com/login" -Method Post -Body $body

# With headers
$headers = @{"Authorization"="Bearer token123"}
Invoke-WebRequest -Uri "http://example.com/api" -Headers $headers

# Save response to file
Invoke-WebRequest -Uri "http://example.com/file" -OutFile "downloaded.txt"
```

### Encoding/Decoding
```powershell
# Base64 decode
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("ZmxhZ3t0ZXN0fQ=="))

# Base64 encode
[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("flag{test}"))

# Hex conversion
[BitConverter]::ToString([byte[]](0x41, 0x42, 0x43))  # "41-42-43"

# String to hex
[BitConverter]::ToString([System.Text.Encoding]::ASCII.GetBytes("ABC"))  # "41-42-43"

# URL decode
Add-Type -AssemblyName System.Web
[System.Web.HttpUtility]::UrlDecode("hello%20world")
```

### Useful One-Liners
```powershell
# Find all .txt files with "flag" in content
Get-ChildItem -Filter *.txt -Recurse | Select-String "flag"

# Download file from URL
Invoke-WebRequest -Uri "http://example.com/payload.exe" -OutFile "payload.exe"

# Calculate file hash
Get-FileHash file.txt -Algorithm MD5
Get-FileHash file.txt -Algorithm SHA256

# Convert Unix timestamp to datetime
[DateTimeOffset]::FromUnixTimeSeconds(1234567890).DateTime

# Generate random string
-random = [System.Web.Security.Membership]::GeneratePassword(16, 0)
```

### Tips
- **Execution Policy**: If blocked, run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`
- **Error Handling**: Use `-ErrorAction SilentlyContinue` to suppress errors
- **Pipeline**: Chain commands with `|` like `Get-Content | Select-String "flag"`
- **Help**: Get help with `Get-Help Invoke-WebRequest -Examples`

---

## Quick Reference Summary

| Task | Tool | Command/Action |
|------|------|----------------|
| Intercept/modify HTTP | Burp | Proxy → Intercept |
| Brute force login | Burp Intruder | Positions with `§§`, Sniper attack |
| Auto-detect encoding | CyberChef | Drag data → Magic |
| AES decrypt | Python | `Crypto.Cipher.AES` |
| HTTP requests | Python | `requests.get/post()` |
| View hidden cookies | DevTools | Application → Cookies |
| Find flag in files | PowerShell | `Select-String -Pattern "flag" -Recurse` |
| Base64 decode | CyberChef/Python/PS | From Base64 / `base64.b64decode()` / `[Convert]::FromBase64()` |

Happy hacking! 🚩
