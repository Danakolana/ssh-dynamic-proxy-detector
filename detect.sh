#!/bin/bash

# ================================================
# SSH Dynamic Forwarding (-D) Monitor Script
# Shows:
#   Remote destination IPs/ranges being proxied via SSH -D tunnels
# ================================================

echo "=== Remote Destinations via Dynamic Proxies (non-local) ==="
echo "User | Session PID | Start Time | Remote Destination | Port | Count | Status"
echo "------------------------------------------------------------------------------------------"

declare -A dest_map
declare -A start_time_map
declare -A status_map

# Find outbound connections made by sshd processes (these are the tunneled destinations)
while read -r line; do
    if [[ -z "$line" ]]; then continue; fi

    pid=$(echo "$line" | grep -o 'pid=[0-9]*' | cut -d= -f2 | head -n1)
    if [ -z "$pid" ]; then continue; fi

    user=$(ps -p "$pid" -o user= 2>/dev/null | tr -d ' ')
    remote=$(echo "$line" | awk '{print $5}')
    state=$(echo "$line" | awk '{print $1}')

    # Skip if not ESTABLISHED or similar
    if [[ "$state" != *"ESTAB"* ]]; then continue; fi

    # Extract remote IP and port
    remote_ip=$(echo "$remote" | cut -d: -f1)
    remote_port=$(echo "$remote" | cut -d: -f2-)

    # Skip local ranges (RFC1918 + loopback + link-local)
    if [[ "$remote_ip" =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.|127\.|::1|fe80:|169\.254\.) ]]; then
        continue
    fi

    # Skip the incoming SSH connection itself (usually port 22)
    if [[ "$remote_port" == "22" || "$remote_port" == "ssh" ]]; then
        continue
    fi

    key="${user}|${pid}|${remote_ip}"
    dest_map["$key"]=$(( ${dest_map["$key"]:-0} + 1 ))

    # Cache start time and status
    if [[ -z "${start_time_map[$pid]}" ]]; then
        start_time_map["$pid"]=$(ps -p "$pid" -o lstart= 2>/dev/null | tr -d '\n')
        status_map["$pid"]="Alive"
    fi

done < <(ss -tnp 2>/dev/null | grep -E 'sshd')

# Display results
if [ ${#dest_map[@]} -eq 0 ]; then
    echo "No active outbound connections through dynamic proxies detected."
else
    for key in "${!dest_map[@]}"; do
        IFS='|' read -r user pid remote_ip <<< "$key"
        count=${dest_map[$key]}
        start_time="${start_time_map[$pid]:-Unknown}"
        status="${status_map[$pid]:-disconnected}"

        # Get one example port
        example_port=$(ss -tnp 2>/dev/null | grep "pid=$pid" | grep "$remote_ip" | head -n1 | awk '{print $5}' | cut -d: -f2)

        printf "%-10s | %-8s | %-25s | %-35s | %-6s | %-5s | %s\n" \
            "$user" "$pid" "${start_time:0:24}" "$remote_ip" "${example_port:-?}" "$count" "$status"
    done | sort
fi

echo -e "\nNote: This script shows outbound connections made by sshd processes (SOCKS -D proxy traffic)."
