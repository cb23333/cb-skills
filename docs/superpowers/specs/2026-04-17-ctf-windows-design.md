# CTF Windows Skill Design Spec

## Overview

A skill for AI coding assistants that helps solve CTF (Capture The Flag) competition challenges on Windows. Focuses on Web and Crypto challenge categories. Designed for competition-time speed: quick challenge type identification, actionable solution paths, and ready-to-run commands/scripts.

## Skill Identity

- **Name**: `ctf-windows`
- **Location**: `ctf-windows/` in the cb-skills repository
- **Relationship to kali-security**: Independent skill, but cross-references `kali-security` when Kali-specific tools are needed (e.g., nmap, metasploit, forensics)

### Trigger Description

> Windows CTF competition challenge-solving assistant covering Web security and Cryptography. Trigger when users mention: CTF, capture the flag, CTF, flag, writeup, web challenge, crypto challenge, SQL injection, XSS, SSRF, RSA, AES, cryptography, encoding/decoding, Base64, Burp Suite, CyberChef, or describe scenarios that look like CTF challenges (e.g., "this login page has an injection point", "I have an RSA public key"). Even if users don't explicitly say "CTF", activate this skill when the context clearly matches a CTF competition scenario.

## Design Principles

1. **Speed first**: In competition, fast type identification + solution path > detailed teaching
2. **Windows native**: All tools and commands target Windows (PowerShell, Python for Windows, Windows tool binaries)
3. **Complementary with kali-security**: When Kali Linux exclusive tools are needed, guide users to use the `kali-security` skill; this skill focuses on Windows-native problem solving
4. **Progressive disclosure**: SKILL.md provides the main workflow (under 500 lines); detailed techniques live in reference files loaded on demand

## File Structure

```
ctf-windows/
├── SKILL.md                     # Main skill: workflow + type routing + tool quick-ref
└── references/
    ├── web-challenges.md        # Web challenge techniques (SQLi, XSS, SSRF, file upload, etc.)
    ├── crypto-challenges.md     # Crypto challenge techniques (RSA, AES, classical ciphers, hashing)
    ├── tool-guide.md            # Windows tool quick reference (Burp Suite, CyberChef, Python, etc.)
    ├── script-templates.md      # Ready-to-use Python script templates for common CTF tasks
    └── flag-hunting.md          # Flag format patterns, regex search, encoding identification
```

## SKILL.md Workflow (Main Skill)

### Phase 1: Quick Challenge Type Identification

When user presents a challenge, classify it immediately:

| User description pattern | Challenge type | Reference |
|--------------------------|---------------|-----------|
| Website/URL, login page, form submission, HTTP requests | Web | `references/web-challenges.md` |
| Ciphertext, key, public/private key, encryption algorithm | Crypto | `references/crypto-challenges.md` |
| Strange string, possibly encoded | Encoding/Misc | `references/flag-hunting.md` |
| File capture, disk image, memory dump | Forensics/Misc | Guide to `kali-security` forensics module |

### Phase 2: Information Gathering & Initial Analysis

- **Web**: Probe target URL, view source code, analyze request parameters, check HTTP headers
- **Crypto**: Identify encryption type, analyze ciphertext characteristics, extract key material
- **Universal**: Check `references/flag-hunting.md` encoding identification methods first — many "hard" challenges are just multi-layer encoding

### Phase 3: Execute Solution Strategy

Load the corresponding reference file based on challenge type and follow its solution templates. Provide commands and scripts that run directly on Windows.

### Phase 4: Flag Capture

- Flag format hints: `{flag}`, `flag{...}`, `ctf{...}`, etc.
- Use `references/flag-hunting.md` search techniques to locate flag

### Tool Quick Reference Table

Compact tool table at the end of SKILL.md pointing to `references/tool-guide.md` for details.

## Reference File Details

### references/web-challenges.md (~300-400 lines)

Organized by vulnerability type. Each type includes:

- Quick identification characteristics
- Detection commands (PowerShell/Python)
- Common payloads
- Windows tool recommendations

Vulnerability types covered:

| Type | Content |
|------|---------|
| SQL Injection | Detection, UNION injection, blind injection, WAF bypass |
| XSS | Reflected/Stored/DOM, cookie theft, flag exfiltration |
| SSRF | Internal network probing, protocol abuse (file://, gopher://) |
| File Upload | Extension bypass, Content-Type bypass, content detection bypass, webshell |
| File Inclusion | LFI/RFI, PHP pseudo-protocols |
| Command Injection | Common bypasses, Windows-specific tricks |
| Deserialization | PHP/Python deserialization basics |
| SSTI | Jinja2/Flask template injection |

### references/crypto-challenges.md (~300-400 lines)

Organized by encryption type. Each type includes:

- Characteristic identification method
- Python solution scripts
- Common flag format for this type

Encryption types covered:

| Type | Content |
|------|---------|
| RSA | Small public exponent, common modulus attack, Wiener attack, openssl/pycryptodome operations |
| AES | ECB/CBC mode attacks, Padding Oracle, key extraction |
| Classical Ciphers | Caesar, Vigenere, Rail Fence, Bacon, Morse — identification and cracking |
| Hashing | MD5/SHA collision, rainbow tables, common hash format identification |
| Encoding | Base family, Hex, URL, JWT decoding |

### references/tool-guide.md (~200 lines)

Windows environment tool quick reference:

- **Burp Suite**: Proxy configuration, Intruder brute force, Repeater manual testing
- **CyberChef**: Common Recipes (Magic module, Base64 decode chains)
- **Python**: Library quick reference (requests, pycryptodome, gmpy2, beautifulsoup4)
- **Browser DevTools**: Network request analysis, JS auditing
- **PowerShell**: File operations, regex flag search, network requests

### references/script-templates.md (~200-300 lines)

Ready-to-use solution script templates:

- requests brute force script (username/password/directory)
- RSA solution script (factor n, common modulus attack, etc.)
- AES encrypt/decrypt script
- Base64/Hex multi-layer decode script
- SQL injection automation script
- File upload testing script

### references/flag-hunting.md (~150 lines)

- Complete flag format catalog with regex patterns
- PowerShell commands to search for flags in files
- Encoding identification decision tree (how to judge what encoding a string uses)
- Common steganography tools and detection methods (for simple Misc challenges)

## Success Criteria

1. When a user pastes a CTF challenge description, the skill correctly identifies the challenge type within the first response
2. For common Web challenges (SQLi, XSS), the skill provides actionable next steps with Windows-compatible commands
3. For common Crypto challenges (RSA, AES), the skill provides ready-to-run Python scripts
4. The skill correctly cross-references `kali-security` when Linux-specific tools are needed
5. Script templates run without modification on a standard Windows Python installation with common CTF packages
