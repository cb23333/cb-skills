# Security Assessment Reporting

## Overview

A professional report is the most important deliverable of a security assessment. Technical findings are meaningless if the client can't understand and act on them.

## Report Structure

### Executive Summary (1-2 pages)

Written for non-technical stakeholders (C-level, board, management):

```markdown
# Security Assessment - Executive Summary

## Engagement Overview
- **Client:** [Company Name]
- **Assessment Type:** [Penetration Test / Vulnerability Assessment / Red Team]
- **Scope:** [Target systems/applications]
- **Timeline:** [Start date] to [End date]
- **Testing Team:** [Team members]

## Key Findings Summary
- **Critical:** X findings
- **High:** X findings
- **Medium:** X findings
- **Low:** X findings
- **Informational:** X findings

## Overall Risk Assessment
[Brief paragraph on overall security posture]

## Top Recommendations (Prioritized)
1. [Most critical recommendation]
2. [Second priority]
3. [Third priority]

## Positive Findings
[What the client is doing well - this builds trust and provides balance]
```

### Technical Report (Detailed)

```markdown
# Security Assessment - Technical Report

## 1. Introduction
### 1.1 Scope and Objectives
### 1.2 Rules of Engagement
### 1.3 Methodology
### 1.4 Limitations and Constraints

## 2. Findings

### Finding 1: [Vulnerability Title]
- **Severity:** Critical / High / Medium / Low / Informational
- **CVSS Score:** X.X (if applicable)
- **Affected Asset:** [IP/hostname/application]
- **Description:**
  [Clear explanation of the vulnerability]
- **Impact:**
  [What an attacker could achieve by exploiting this]
- **Steps to Reproduce:**
  1. Step one with specific commands
  2. Step two
  3. Expected result
- **Evidence:**
  [Screenshots, command output, captured data]
- **Remediation:**
  [Specific, actionable fix recommendations]
- **References:**
  [CVE numbers, vendor advisories, relevant links]

### Finding 2: [Repeat for each finding]

## 3. Additional Observations
[Non-critical findings, best practice recommendations]

## 4. Tool Inventory
[List of tools used during the assessment]

## 5. Appendices
### 5.1 Scan Results Summary
### 5.2 Exploit Code (if applicable)
### 5.3 Raw Tool Output
```

## Severity Rating Guide

| Rating | Criteria | Example |
|---|---|---|
| **Critical** | Remote code execution without authentication; full system compromise | Unauthenticated RCE on internet-facing server |
| **High** | Significant access with some prerequisites; sensitive data exposure | SQL injection extracting user credentials |
| **Medium** | Limited impact or requires specific conditions; authenticated exploitation | Stored XSS in authenticated area |
| **Low** | Minimal impact; information disclosure | Server version disclosure in headers |
| **Informational** | Best practice recommendations; no direct vulnerability | Missing security headers |

## CVSS Scoring

```bash
# Calculate CVSS score
# Use: https://www.first.org/cvss/calculator/3.1

# Common base metrics:
# Attack Vector (AV): Network (N), Adjacent (A), Local (L), Physical (P)
# Attack Complexity (AC): Low (L), High (H)
# Privileges Required (PR): None (N), Low (L), High (H)
# User Interaction (UI): None (N), Required (R)
# Scope (S): Unchanged (U), Changed (C)
# Confidentiality (C): None (N), Low (L), High (H)
# Integrity (I): None (N), Low (L), High (H)
# Availability (A): None (N), Low (L), High (H)
```

## Evidence Documentation Best Practices

1. **Screenshots** — Include full browser/terminal window showing:
   - Target URL or IP in address bar/command
   - The vulnerability evidence
   - Timestamp if relevant

2. **Command output** — Always include:
   - The command that was run
   - The full output
   - Any error messages

3. **Network captures** — Save PCAP files for:
   - Proof of exploitation
   - Data exfiltration demonstration

4. **Log entries** — Document relevant log entries from:
   - Target system logs
   - Application logs
   - Attacking tool logs

## Remediation Prioritization

When recommending fixes, prioritize by:

1. **Ease of fix + impact** — Quick wins first (security headers, patch versions)
2. **External-facing first** — Internet-facing vulnerabilities before internal
3. **Compensating controls** — If a direct fix isn't possible, suggest mitigations
4. **Long-term improvements** — Architecture changes, security program recommendations

## Tools for Reporting

```bash
# CherryTree - hierarchical note-taking for pentest notes
cherrytree

# Dradis - collaboration and reporting framework
dradis

# Serpico - automated report generation
serpico

# Pipal - password analysis for reports
pipal password_list.txt
```

## Writing Tips

1. **Be specific** — "Update Apache to version 2.4.58" beats "Update your web server"
2. **Be factual** — Don't exaggerate findings; let the evidence speak
3. **Be constructive** — Frame findings as opportunities for improvement, not failures
4. **Be clear** — Write so both technical and non-technical readers can understand
5. **Be complete** — Include enough detail for the client to reproduce and verify the fix
6. **Use consistent formatting** — Same structure for every finding
7. **Include positive findings** — Acknowledge good security practices observed
8. **Provide risk context** — Help the client understand the business impact, not just technical severity
