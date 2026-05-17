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

Save the script as `ssh-d-monitor.sh`:

```bash
wget https://.../ssh-d-monitor.sh   # or copy manually
chmod +x ssh-d-monitor.sh




**## Example Output Bash**

=== Remote Destinations via Dynamic Proxies (non-local) ===

User       | Session PID | Start Time                | Remote Destination                  | Port   | Count | Status
----------------------------------------------------------------------------------------------------------
john       | 23456       | Sun May 17 08:12:45 2026  | 185.230.13.107                      | 443    | 12    | Alive
alice      | 19873       | Sun May 17 07:45:22 2026  | 104.21.45.92                        | 80     | 3     | Alive
