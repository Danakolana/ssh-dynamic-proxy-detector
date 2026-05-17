# SSH Dynamic Forwarding Monitor

A simple and lightweight Bash script to monitor **SSH SOCKS proxy (-D)** usage on a Linux server.

This tool helps system administrators track which users are using SSH dynamic port forwarding and which **external destinations** they are accessing through their tunnels.

---

## Features

- Shows active SSH sessions using dynamic tunneling (`-D`)
- Displays external remote destinations being proxied (non-local traffic only)
- Includes useful details: User, Session PID, Start Time, Remote IP, Port, Count, and Status
- Filters out local/private network traffic (RFC 1918, loopback, etc.)
- Clean, easy-to-read output
- No dependencies outside standard Linux tools (`ss`, `ps`, `awk`, `grep`)

---

## Usage

### 1. Save the script

Save the script as `detect.sh`:

```bash

wget https://raw.githubusercontent.com/Danakolana/ssh-dynamic-proxy-detector/refs/heads/main/detect.sh   # or copy manually

chmod +x detect.sh

sudo ./detect.sh

```

## Example Output Bash


```
=== Remote Destinations via Dynamic Proxies (non-local) ===

User       | Session PID | Start Time                | Remote Destination                  | Port   | Count | Status
----------------------------------------------------------------------------------------------------------
john       | 23456       | Sun May 17 08:12:45 2026  | 185.230.13.107                      | 443    | 12    | Alive
alice      | 19873       | Sun May 17 07:45:22 2026  | 104.21.45.92                        | 80     | 3     | Alive

```



# 🔍 SSH SOCKS Proxy Activity Monitor

## 📖 How It Works

This script analyzes active network connections created by `sshd` processes to help identify SOCKS proxy usage on a Linux server.

### 🧠 What It Detects

- Identifies outbound connections generated through active SSH sessions
- Filters out internal and private/local network traffic
- Groups connections by:
  - 👤 SSH user
  - 🌐 Remote destination host
- Counts active connections per remote destination

### 📊 Result

The output provides a clean and easy-to-read overview of SOCKS proxy activity happening through the server.



---

# ⚙️ Requirements

| Requirement | Description |
|---|---|
| 🐧 Linux Server | Any modern Linux distribution |
| 🛠 Utilities | `ss`, `ps`, `awk`, `grep`, `bash` |
| 🔐 Permissions | Recommended to run with `sudo` for complete visibility |

---

# 📝 Notes & Limitations

> Important operational details and known limitations.

- Only **external/public destinations** are displayed  
  (`192.168.x.x`, `10.x.x.x`, `172.16.x.x`, `127.0.0.1`, etc. are excluded)

- The SSH session must be:
  - active
  - currently generating outbound traffic

- The script displays:
  - one example port per destination  
  instead of the complete port list

- Designed for systems using the modern `ss` utility  
  (available on nearly all current Linux distributions)

---

# 💡 Typical Use Cases

- Detect active SOCKS proxy usage over SSH
- Monitor unusual outbound traffic from SSH users
- Investigate bandwidth usage
- Audit jump hosts / bastion servers
- Troubleshoot SSH dynamic port forwarding (`ssh -D`)

---

# 🔐 Related SSH Feature

SSH SOCKS proxying is commonly created using:

```bash
ssh -D 1080 user@server
