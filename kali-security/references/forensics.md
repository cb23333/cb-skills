# Digital Forensics

## Overview

Digital forensics involves analyzing digital artifacts (disk images, memory dumps, network captures, files) to extract evidence, reconstruct events, or solve CTF challenges.

## File Analysis

### Basic File Inspection

```bash
# File type identification (check actual format, not extension)
file suspicious_file
xxd suspicious_file | head -20       # Hex dump of first bytes
strings suspicious_file | less       # Extract readable strings

# Exif data (metadata) from images
exiftool image.jpg
exiftool -all image.jpg             # All metadata fields

# Binwalk - analyze embedded files and firmware
binwalk suspicious_file             # Scan for embedded files
binwalk -e suspicious_file          # Extract found files
binwalk --dd='.*' suspicious_file   # Extract everything

# Foremost - file carving
foremost -i disk_image.dd -o output_dir
foremost -t jpg,png,pdf -i suspicious_file
# -t: file types to recover
```

### Steganography

```bash
# Steghide - extract hidden data from images
steghide extract -sf image.jpg
steghide info image.jpg             # Check for embedded data
# May prompt for passphrase - try empty string first

# Zsteg - PNG/BMP steganography
zsteg image.png
zsteg -a image.png                  # Try all methods

# Stegoveritas - comprehensive image analysis
stegoveritas image.jpg

# Check LSB (Least Significant Bit) encoding
# Use Python scripts or zsteg for LSB analysis

# Audio steganography
stegolsb -h -i audio.wav -o extracted.txt  # LSB extraction
```

### Archive & Compressed File Analysis

```bash
# ZIP files
zipinfo archive.zip                 # List contents without extracting
zipcloak archive.zip                # Check encryption
fcrackzip -u -D -p /usr/share/wordlists/rockyou.txt archive.zip
# -u: unzip test, -D: dictionary mode

# GZIP
gzip -l file.gz                     # List info
gunzip file.gz                      # Decompress

# Tar
tar -tvf archive.tar                # List contents
tar -xvf archive.tar                # Extract
```

## Disk Forensics

### Disk Image Analysis

```bash
# Image info
fdisk -l disk_image.dd
mmls disk_image.dd                  # Show partition layout (sleuthkit)

# Mount disk image (read-only!)
mkdir /mnt/disk
mount -o ro,loop,offset=$((512*2048)) disk_image.dd /mnt/disk
# offset = sector_size * start_sector

# Autopsy (GUI-based forensic analysis)
autopsy                             # Start web-based forensic tool
# Access at http://localhost:9999/autopsy

# The Sleuth Kit (CLI forensic tools)
fls disk_image.dd                   # List files in image
fls -r disk_image.dd                # Recursive listing
icat disk_image.dd 12345            # Extract file by inode
ils disk_image.dd                   # List inode info
mactime -b body_file > timeline.csv # Create timeline
```

### Deleted File Recovery

```bash
# Recover deleted files from ext2/ext3/ext4
extundelete disk_image.dd --restore-all

# Recover from NTFS
ntfsundelete disk_image.dd -s       # Scan for recoverable files
ntfsundelete disk_image.dd -u -i 12345  # Undelete by inode

# Scalpel - file carving
scalpel disk_image.dd -o recovered/
# Configure /etc/scalpel/scalpel.conf for file types
```

## Memory Forensics

### Volatility 3 (Python 3)

```bash
# Identify the OS profile
vol -f memory.dmp windows.info.Info
vol -f memory.dmp linux.banner.Banner

# Process listing
vol -f memory.dmp windows.pslist.PsList        # Active processes
vol -f memory.dmp windows.psscan.PsScan        # Scan for hidden processes
vol -f memory.dmp windows.pstree.PsTree        # Process tree

# Network connections
vol -f memory.dmp windows.netscan.NetScan      # Network connections
vol -f memory.dmp windows.netstat.NetStat

# File extraction
vol -f memory.dmp windows.filescan.FileScan    # List file objects
vol -f memory.dmp windows.dumpfiles.DumpFiles --virtaddr 0x12345678  # Extract file

# Registry analysis
vol -f memory.dmp windows.registry.hivelist.HiveList          # List registry hives
vol -f memory.dmp windows.registry.printkey.PrintKey --key "Software\Microsoft\Windows\CurrentVersion\Run"

# Credential extraction
vol -f memory.dmp windows.hashdump.Hashdump    # Dump password hashes
vol -f memory.dmp windows.cachedump.Cachedump   # Cached domain credentials
vol -f memory.dmp windows.lsadump.Lsadump       # LSA secrets

# DLL listing
vol -f memory.dmp windows.dlllist.DllList       # Loaded DLLs per process

# Timeline
vol -f memory.dmp windows.timeliner.Timeliner   # Create activity timeline
```

### Volatility 2 (Legacy, still useful)

```bash
# Identify profile
volatility -f memory.dmp imageinfo

# Use identified profile
volatility -f memory.dmp --profile=Win7SP1x64 pslist
volatility -f memory.dmp --profile=Win7SP1x64 netscan
volatility -f memory.dmp --profile=Win7SP1x64 hashdump
```

## Network Forensics

### PCAP Analysis

```bash
# Wireshark (GUI)
wireshark capture.pcap

# Tshark (CLI Wireshark)
tshark -r capture.pcap                          # Read capture
tshark -r capture.pcap -Y "http.request"        # Filter HTTP requests
tshark -r capture.pcap -Y "dns"                 # Filter DNS
tshark -r capture.pcap -Y "tcp.port == 4444"    # Filter by port

# Extract files from PCAP
tshark -r capture.pcap --export-objects http,output_dir
tshark -r capture.pcap --export-objects smb,output_dir

# Extract specific fields
tshark -r capture.pcap -Y "http.request" -T fields \
  -e http.host -e http.request.uri -e http.user_agent

# Follow TCP stream
tshark -r capture.pcap -z "follow,tcp,ascii,0"

# Statistics
tshark -r capture.pcap -z conv,tcp              # TCP conversations
tshark -r capture.pcap -z http,tree              # HTTP statistics
```

### USB Forensics (from PCAP)

```bash
# If the capture contains USB traffic
tshark -r usb_capture.pcap -Y "usb.capdata" -T fields -e usb.capdata
# Decode the captured data (keystrokes, mouse movements, etc.)

# USB keyboard data decoder (manual)
# Each 8-byte packet represents a keypress
# Byte 0: modifier keys (shift, ctrl, alt)
# Byte 2: key code (HID usage table)
```

## Common CTF Forensics Patterns

1. **File in a file**: Use `binwalk -e` to find and extract hidden files
2. **Wrong extension**: `file` command reveals true type
3. **Metadata flag**: Check with `exiftool`
4. **Steganography**: Try steghide, zsteg, or LSB analysis
5. **Base64/Hex encoded**: Check file strings, decode as needed
6. **Memory forensics**: Look for interesting processes, network connections, or files
7. **Network forensics**: Follow TCP streams, extract transferred files
8. **Image manipulation**: Check for appended data after image end (`xxd` or `binwalk`)

## Workflow

```
1. Identify the artifact type (file, disk image, memory dump, PCAP)
2. Determine actual format (file command, magic bytes)
3. Apply appropriate analysis tools
4. Extract and examine suspicious data
5. Correlate findings (processes ↔ files ↔ network)
6. Document timeline and evidence chain
```
