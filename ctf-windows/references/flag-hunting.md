# Flag Hunting Guide

Quick reference for finding and identifying CTF flags in Windows environments.

## 1. Common Flag Formats

| Format | Pattern | Regex |
|--------|---------|-------|
| Standard | `flag{...}` | `flag\{[^}]+\}` |
| Case-insensitive | `FLAG{...}`, `FlAg{...}` | `[fF][lL][aA][gG]\{[^}]+\}` |
| CTF format | `ctf{...}` | `ctf\{[^}]+\}` |
| HTB format | `HTB{...}` | `HTB\{[^}]+\}` |
| Key format | `key{...}` | `key\{[^}]+\}` |
| Hex-encoded | `666c6167...` | `(666c6167|636c6167|485442)[0-9a-fA-F]*` |
| Catch-all | Any of the above | `([fF][lL][aA][gG]|[cC][tT][fF]|[kK][eE][yY]|HTB)\{[^}]+\}` |

## 2. PowerShell Flag Search Commands

### Search all text files recursively
```powershell
Get-ChildItem -Path . -Recurse -File | Select-String -Pattern '(flag|ctf|key|HTB)\{[^}]+\}' -AllMatches
```

### Search with case variations
```powershell
Get-ChildItem -Path . -Recurse -File | Select-String -Pattern '[fF][lL][aA][gG]\{[^}]+\}' -AllMatches
```

### Search in binary files
```powershell
Get-ChildItem -Path . -Recurse -File -Exclude @('*.exe','*.dll') | ForEach-Object {
    $content = [System.IO.File]::ReadAllBytes($_.FullName)
    $text = [System.Text.Encoding]::ASCII.GetString($content)
    if ($text -match '[fF][lL][aA][gG]\{[^}]+\}') {
        Write-Host "$($_.FullName): $matches[0]"
    }
}
```

### Search for hex-encoded flags
```powershell
Get-ChildItem -Path . -Recurse -File | Select-String -Pattern '(666c6167|636c6167|485442)[0-9a-fA-F]{10,}' -AllMatches
```

### Extract all matches to file
```powershell
Get-ChildItem -Path . -Recurse -File | Select-String -Pattern '[fF][lL][aA][gG]\{[^}]+\}' -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value | Out-File -FilePath flags.txt
```

## 3. Encoding Identification Decision Tree

### Visual Identification
| Encoding | Characteristics | Example |
|----------|-----------------|---------|
| **Base64** | A-Z, a-z, 0-9, +, /, ends with = (padding), length % 4 == 0 | `SGVsbG8gV29ybGQ=` |
| **Hex** | Only 0-9, a-f, even length, pairs represent bytes | `48656c6c6f` |
| **Base32** | A-Z, 2-7, = padding, length % 8 == 0 | `JBSWY3DPEBLW64T` |
| **URL Encoding** | %XX pattern where XX is hex | `Hello%20World%21` |
| **ROT13** | Readable text but words don't make sense | `Uryyb Jbeyq` |
| **Binary** | Only 0 and 1, length % 8 == 0 | `01001000 01100101` |
| **Morse** | dots `.`, dashes `-`, spaces `/` | `.... . .-.. .-.. ---` |
| **Brainfuck** | Only `> < + - . , [ ]` characters | `++++++++++[>+++++++>++++++++++` |
| **ASCII/Decimal** | Numbers 32-126 separated by spaces | `72 101 108 108 111` |
| **Octal** | Numbers 0-7, starts with 0 or prefix `\` | `\150 \145 \154 \154 \157` |

### Quick PowerShell check
```powershell
# Detect Base64
$data -match '^[A-Za-z0-9+/]+={0,2}$' -and ($data.Length % 4 -eq 0)

# Detect Hex
$data -match '^[0-9a-fA-F]+$' -and ($data.Length % 2 -eq 0)

# Detect Base32
$data -match '^[A-Z2-7]+={0,6}$' -and ($data.Length % 8 -eq 0)
```

## 4. Multi-layer Decode Strategy

### Python Auto-decode Script
```python
import base64
import binascii
import re
from urllib.parse import unquote

def try_base64(data):
    """Try Base64 decode."""
    try:
        # Clean whitespace and padding
        data = re.sub(r'\s+', '', data)
        missing_padding = len(data) % 4
        if missing_padding:
            data += '=' * (4 - missing_padding)
        decoded = base64.b64decode(data).decode('utf-8')
        return ('base64', decoded)
    except: return None

def try_hex(data):
    """Try hex decode."""
    try:
        data = re.sub(r'[^0-9a-fA-F]', '', data)
        if len(data) % 2 == 0 and len(data) > 0:
            decoded = bytes.fromhex(data).decode('utf-8')
            return ('hex', decoded)
    except: return None

def try_base32(data):
    """Try Base32 decode."""
    try:
        data = re.sub(r'\s+', '', data).upper()
        missing_padding = len(data) % 8
        if missing_padding:
            data += '=' * (8 - missing_padding)
        decoded = base64.b32decode(data).decode('utf-8')
        return ('base32', decoded)
    except: return None

def try_urldecode(data):
    """Try URL decode."""
    try:
        if '%' in data:
            decoded = unquote(data)
            if decoded != data:
                return ('url', decoded)
    except: return None

def try_rot13(data):
    """Try ROT13 decode."""
    try:
        import codecs
        decoded = codecs.decode(data, 'rot_13')
        if decoded != data:
            return ('rot13', decoded)
    except: return None

def try_decimal_ascii(data):
    """Try decimal ASCII decode."""
    try:
        nums = re.findall(r'\b\d{2,3}\b', data)
        if nums and all(32 <= int(n) <= 126 for n in nums):
            decoded = ''.join(chr(int(n)) for n in nums)
            return ('decimal', decoded)
    except: return None

def try_octal(data):
    """Try octal decode."""
    try:
        nums = re.findall(r'\\?[0-7]{2,3}', data)
        if nums:
            decoded = ''.join(chr(int(n.replace('\\', ''), 8)) for n in nums)
            return ('octal', decoded)
    except: return None

def try_binary(data):
    """Try binary decode."""
    try:
        bits = re.sub(r'[^01]', '', data)
        if len(bits) % 8 == 0 and len(bits) >= 8:
            decoded = ''.join(chr(int(bits[i:i+8], 2)) for i in range(0, len(bits), 8))
            return ('binary', decoded)
    except: return None

# Decode attempts in priority order
DECODERS = [try_base64, try_hex, try_base32, try_urldecode, try_rot13, try_decimal_ascii, try_octal, try_binary]

def auto_decode(data, max_depth=10, visited=None):
    """
    Automatically decode data by trying multiple encoding schemes.
    Returns list of (encoding, result) tuples representing decode chain.
    """
    if visited is None:
        visited = set()

    if max_depth <= 0 or data in visited:
        return []

    visited.add(data)

    for decoder in DECODERS:
        result = decoder(data)
        if result:
            encoding, decoded = result
            chain = [(encoding, decoded)]
            # Recursively try to decode further
            further_chain = auto_decode(decoded, max_depth - 1, visited)
            return chain + further_chain

    return []

# Usage
if __name__ == '__main__':
    sample = 'Uryyb Jbeyq'  # ROT13 of 'Hello World'
    chain = auto_decode(sample)
    for encoding, result in chain:
        print(f'{encoding}: {result}')
```

### PowerShell decode helper
```powershell
function Invoke-Decode {
    param([string]$Data)

    # Try Base64
    try {
        $bytes = [System.Convert]::FromBase64String($Data)
        $decoded = [System.Text.Encoding]::UTF8.GetString($bytes)
        return "Base64: $decoded"
    } catch {}

    # Try Hex
    if ($Data -match '^[0-9a-fA-F]+$' -and $Data.Length % 2 -eq 0) {
        try {
            $bytes = [System.Convert]::FromHexString($Data)
            $decoded = [System.Text.Encoding]::UTF8.GetString($bytes)
            return "Hex: $decoded"
        } catch {}
    }

    # Try URL decode
    if ($Data -match '%[0-9a-fA-F]{2}') {
        try {
            $decoded = [System.Web.HttpUtility]::UrlDecode($Data)
            return "URL: $decoded"
        } catch {}
    }

    return "Unable to decode"
}
```

## 5. Quick Steganography Checks

### File type vs extension mismatch
```powershell
# Check magic bytes of a file
$filePath = "suspicious.jpg"
$bytes = [System.IO.File]::ReadAllBytes($filePath)
$magic = [System.BitConverter]::ToString($bytes[0..3]) -replace '-'
$magicTypes = @{
    'FFD8FF' = 'JPEG'
    '89504E470D0A1A0A' = 'PNG'
    '47494638' = 'GIF'
    '504B0304' = 'ZIP'
    '52617221' = 'RAR'
}
$magicTypes.GetEnumerator() | Where-Object { $magic -like $_.Key }
```

### Extract EXIF data with Python
```python
from PIL import Image
from PIL.PngImagePlugin import PngImageFile

def extract_exif(image_path):
    """Extract EXIF and text metadata from image."""
    try:
        img = Image.open(image_path)

        # EXIF data
        exif = img.getexif()
        if exif:
            print("EXIF Data:")
            for tag, value in exif.items():
                print(f"  {tag}: {value}")

        # PNG text chunks
        if isinstance(img, PngImageFile):
            if hasattr(img, 'text'):
                print("\nPNG Text:")
                for key, value in img.text.items():
                    print(f"  {key}: {value}")

        # Check for appended data
        with open(image_path, 'rb') as f:
            f.seek(-100, 2)  # Last 100 bytes
            tail = f.read()
            if tail and not all(b >= 32 and b < 127 for b in tail):
                print("\nPotential appended data in file tail")
                print(f"  Last bytes: {tail[:50]}")

    except Exception as e:
        print(f"Error: {e}")

# Usage
extract_exif('suspicious.png')
```

### Check for appended data in PowerShell
```powershell
function Test-AppendedData {
    param([string]$FilePath)

    $ext = [System.IO.Path]::GetExtension($FilePath).ToLower()
    $fileInfo = Get-Item $FilePath
    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)

    # Known file sizes
    $sizes = @{
        '.jpg' = 2  # EOI marker
        '.png' = 12  # IEND chunk
        '.gif' = 1   # Trailer
    }

    if ($sizes.ContainsKey($ext)) {
        $tailSize = [Math]::Min(100, $fileBytes.Length)
        $tail = $fileBytes[-$tailSize..-1]
        $tailHex = ($tail | ForEach-Object { '{0:X2}' -f $_ }) -join ''

        Write-Host "Last $tailSize bytes (hex): $tailHex"

        # Look for ZIP signature (PK\x03\x04)
        if ($tailHex -match '504B0304') {
            Write-Host "ALERT: ZIP signature found - possible embedded file!" -ForegroundColor Red
        }

        # Look for other magic bytes
        $magics = @{
            '504B0304' = 'ZIP'
            '52617221' = 'RAR'
            '1F8B08' = 'GZIP'
        }

        foreach ($magic in $magics.Keys) {
            if ($tailHex -match $magic) {
                Write-Host "Found $($magics[$magic]) signature at offset: $($tailHex.IndexOf($magic))" -ForegroundColor Yellow
            }
        }
    }
}
```

### Extract embedded ZIP from image
```powershell
# Find ZIP signature and extract
$fileBytes = [System.IO.File]::ReadAllBytes('image.jpg')
$zipSignature = [byte[]](0x50, 0x4B, 0x03, 0x04)  # "PK\x03\x04"

for ($i = 0; $i -lt $fileBytes.Length - 4; $i++) {
    $match = $true
    for ($j = 0; $j -lt 4; $j++) {
        if ($fileBytes[$i + $j] -ne $zipSignature[$j]) {
            $match = $false
            break
        }
    }
    if ($match) {
        Write-Host "Found ZIP at offset: $i"
        $zipData = $fileBytes[$i..($fileBytes.Length - 1)]
        [System.IO.File]::WriteAllBytes('extracted.zip', $zipData)
        Write-Host "Extracted to extracted.zip"
        break
    }
}
```

### Binwalk alternative for Windows
```powershell
# Simple entropy calculator to find high-entropy regions (potential compression/encryption)
function Get-FileEntropy {
    param([string]$FilePath, [int]$BlockSize = 4096)

    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    $blocks = [Math]::Ceiling($bytes.Length / $BlockSize)

    for ($i = 0; $i -lt $blocks; $i++) {
        $start = $i * $BlockSize
        $end = [Math]::Min($start + $BlockSize, $bytes.Length) - 1
        $block = $bytes[$start..$end]

        # Calculate byte frequencies
        $freq = @{}
        $block | ForEach-Object { $freq[$_] = ($freq[$_] + 1) }

        # Calculate Shannon entropy
        $entropy = 0.0
        $blockLen = $block.Length
        $freq.Values | ForEach-Object {
            $p = $_ / $blockLen
            $entropy -= $p * [Math]::Log($p, 2)
        }

        # High entropy (>7.5) suggests compression or encryption
        if ($entropy -gt 7.5) {
            Write-Host "Block $i (offset $start): High entropy $($entropy.ToString('F2'))"
        }
    }
}
```

## Pro Tips

- Always search recursively - flags hide in subdirectories
- Check file properties, metadata, and alternate data streams
- Look for encoded strings in registry hives
- Don't forget memory dumps and process memory
- Combine multiple tools: find → extract → decode → verify
- When stuck, try the auto_decode script on any suspicious string
