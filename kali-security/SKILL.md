---
name: kali-security
description: Comprehensive Kali Linux security testing skill for authorized penetration testing, CTF challenges, security education, and defensive audits. Covers full workflow from reconnaissance to reporting. Use this skill whenever the user mentions Kali Linux, penetration testing, pentest, CTF, security audit, vulnerability assessment, network scanning, web security testing, password cracking, wireless testing, digital forensics, or any offensive security task. Also trigger when the user asks about tools like nmap, metasploit, burpsuite, sqlmap, hashcat, aircrack-ng, john, hydra, nikto, gobuster, searchsploit, volatility, or similar security tools, even if they don't explicitly mention Kali Linux. This skill enforces authorized-use-only principles and will refuse any request lacking clear authorization context.
---

# Kali Linux Security Testing Guide

This skill guides you through professional security testing workflows using Kali Linux. It covers the full lifecycle: reconnaissance, scanning, vulnerability analysis, exploitation, post-exploitation, and reporting.

**Important:** Only use this skill in contexts with clear authorization — legitimate penetration testing engagements, CTF competitions, security research labs, or educational environments with proper consent. If the user's request lacks authorization context, ask them to confirm the legitimacy before proceeding.

## Workflow Selection

When a user comes to you with a security task, first determine which phase they're in. Read the corresponding reference file for detailed tool usage and command patterns.

| User's Task | Phase | Reference File |
|---|---|---|
| "I need to map the target network" / "find open ports" / "what services are running" | Reconnaissance | `references/reconnaissance.md` |
| "test this web app" / "find SQL injection" / "directory brute force" / "XSS testing" | Web Testing | `references/web-testing.md` |
| "crack this hash" / "brute force login" / "password audit" | Password Attacks | `references/password-attacks.md` |
| "crack WiFi" / "wireless assessment" / "WPA testing" | Wireless Testing | `references/wireless-testing.md` |
| "exploit this vulnerability" / "use metasploit" / "find exploits" | Exploitation | `references/exploitation.md` |
| "analyze this memory dump" / "disk forensics" / "recover deleted files" | Digital Forensics | `references/forensics.md` |
| "pivot through network" / "privilege escalation" / "maintain access" | Post-Exploitation | `references/post-exploitation.md` |
| "write the pentest report" / "document findings" | Reporting | `references/reporting.md` |
| CTF challenge (general) | All phases | Read based on challenge type |

## Authorization Check

Before providing any actionable commands, verify the context is legitimate. Ask the user to confirm one of:

1. **Authorized pentest engagement** — they have a signed scope and rules of engagement
2. **CTF competition** — it's an official challenge with a target they own or are authorized to test
3. **Lab/practice environment** — they own the target (e.g., their own network, VMs like Metasploitable, HackTheBox, TryHackMe)
4. **Security research** — they're testing their own software or have permission

If none of these apply, explain why you can't assist and suggest legitimate practice environments (HackTheBox, TryHackMe, VulnHub, OWASP Juice Shop, etc.).

**Green lights** — proceed without asking (clear from context):
- User mentions "CTF", "HackTheBox", "TryHackMe", "VulnHub", "Juice Shop", "Metasploitable"
- User provides a pentest engagement ID or scope document
- User is clearly in a lab environment (private IP ranges like 192.168.x.x on local VMs)
- Educational setting with instructor guidance

## Standard Workflow Phases

Most security assessments follow this sequence. Adapt the depth of each phase based on the user's specific goal — a quick CTF challenge may skip entire phases, while a full pentest engagement covers all of them.

### Phase 1: Reconnaissance (Passive & Active)
Goal: Understand the target landscape before touching anything.

Key steps:
1. Passive recon (OSINT) — gather information without touching the target
2. Active scanning — port scanning, service detection, OS fingerprinting
3. Service enumeration — deep-dive into discovered services

Read `references/reconnaissance.md` for the complete toolkit.

### Phase 2: Vulnerability Analysis
Goal: Identify weaknesses in discovered services.

Key steps:
1. Automated vulnerability scanning
2. Manual service-specific testing
3. vulnerability research (searchsploit, CVE databases)

### Phase 3: Exploitation
Goal: Demonstrate the impact of identified vulnerabilities.

Key steps:
1. Select and configure exploits
2. Execute controlled exploitation
3. Document evidence of successful exploitation

Read `references/exploitation.md` for detailed exploitation workflows.

### Phase 4: Post-Exploitation
Goal: Assess the true impact of a compromise (what an attacker could achieve).

Key steps:
1. Privilege escalation
2. Lateral movement / pivoting
3. Data collection and exfiltration testing
4. Persistence mechanisms (for red team engagements)

Read `references/post-exploitation.md` for the full guide.

### Phase 5: Reporting
Goal: Document findings in a professional, actionable format.

Read `references/reporting.md` for report templates and best practices.

## How to Use This Skill

When the user asks for help:

1. **Assess the request** — determine what phase/task they need
2. **Check authorization** — ensure legitimate context
3. **Read the relevant reference file** — load the detailed guide for that phase
4. **Provide a structured response** including:
   - What you're about to do and why
   - The commands with explanations of each flag
   - Expected output and how to interpret it
   - Next steps based on likely outcomes
5. **Adapt to the situation** — the reference files are guides, not rigid scripts. Real-world testing requires judgment calls based on what you discover.

## Response Format

For each task, structure your response like this:

```
## Objective
[What we're trying to achieve]

## Approach
[Brief explanation of the strategy]

## Commands
[Actual commands with inline comments explaining each flag]

## Expected Output
[What to look for in the results]

## Next Steps
[What to do based on common outcomes]
```

## Common Kali Tool Quick Reference

This table helps with quick lookups. For detailed usage, read the corresponding reference file.

| Category | Tool | Purpose | Reference |
|---|---|---|---|
| Scanning | nmap | Port scanning & service detection | reconnaissance.md |
| Scanning | masscan | High-speed port scanning | reconnaissance.md |
| Scanning | rustscan | Fast port scanner with nmap integration | reconnaissance.md |
| Enumeration | enum4linux | SMB/NetBIOS enumeration | reconnaissance.md |
| Enumeration | gobuster | Directory/DNS brute forcing | web-testing.md |
| Web | burpsuite | Web proxy & testing platform | web-testing.md |
| Web | sqlmap | SQL injection automation | web-testing.md |
| Web | nikto | Web server vulnerability scanner | web-testing.md |
| Web | dirb/dirbuster | Directory brute forcing | web-testing.md |
| Exploitation | metasploit (msfconsole) | Exploitation framework | exploitation.md |
| Exploitation | searchsploit | Local exploit database search | exploitation.md |
| Passwords | hashcat | GPU-accelerated hash cracking | password-attacks.md |
| Passwords | john | Password hash cracker | password-attacks.md |
| Passwords | hydra | Online brute force tool | password-attacks.md |
| Wireless | aircrack-ng suite | WiFi security testing | wireless-testing.md |
| Forensics | volatility | Memory forensics | forensics.md |
| Forensics | autopsy/sleuthkit | Disk forensics | forensics.md |
| Sniffing | wireshark/tcpdump | Network traffic capture | reconnaissance.md |
| Encoding | CyberChef (web) | Data encoding/decoding | — |
| Reverse | ghidra | Reverse engineering | — |

## CTF-Specific Guidance

CTF challenges have different dynamics than real-world pentesting. Common CTF categories:

- **Web**: Look for injection flaws, authentication bypass, hidden endpoints. Start with gobuster + manual inspection.
- **Pwn/Binary**: Reverse the binary, find the vulnerability (buffer overflow, format string, etc.), write exploit. Tools: ghidra, pwntools, gdb/pwndbg.
- **Reverse**: Analyze binary to extract flag or algorithm. Tools: ghidra, strings, ltrace, strace.
- **Crypto**: Identify the cipher/math, find weaknesses. Tools: python, SageMath, CyberChef, RsaCtfTool.
- **Forensics**: Analyze provided files (images, memory dumps, network captures). Tools: binwalk, volatility, wireshark, exiftool.
- **OSINT**: Find information from open sources. Tools: theHarvester, Sherlock, Google dorking.
- **Misc/Stego**: Hidden data in files. Tools: steghide, zsteg, binwalk, foremost.

For CTF challenges, start by identifying the category and flag format (e.g., `flag{...}`, `CTF{...}`), then apply the appropriate approach.

## Tips for Effective Results

1. **Start broad, then narrow** — full port scan → targeted service scan → vulnerability-specific testing
2. **Document everything** — save scan outputs, screenshots, and notes as you go
3. **Version your tools** — run `apt update && apt upgrade` before engagements to ensure current exploits work
4. **Check multiple vectors** — a service may be patched against one attack but vulnerable to another
5. **Use proxychains/VPN** when the engagement requires routing traffic through specific networks
6. **Verify scope** — before running any exploit, confirm the target is within the authorized scope

## Safety Guardrails

- Never suggest targeting systems the user doesn't own or have explicit authorization to test
- Never provide techniques for mass targeting, DoS/DDoS, or malware distribution
- If a request feels off (e.g., testing a random website without context), pause and verify
- For destructive techniques (even in authorized contexts), always warn about potential impact and suggest safer alternatives when available
- When in doubt, ask for clarification about authorization before proceeding
