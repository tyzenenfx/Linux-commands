#!/bin/bash
# ==============================================================
# Linux Server Verification Script
# Author: Pranav
# Version: 1.0
# ==============================================================

OUTPUT_DIR="/root/server-audit"
mkdir -p $OUTPUT_DIR

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_FILE="$OUTPUT_DIR/server_verification_$DATE.log"

header() {
    echo -e "\n======================================================================" >> $OUTPUT_FILE
    echo -e "🔹 $1" >> $OUTPUT_FILE
    echo -e "======================================================================\n" >> $OUTPUT_FILE
}

echo "Starting server verification..."
echo "Output file: $OUTPUT_FILE"
sleep 1

header "1. Basic System Information"
{
    hostnamectl
    cat /etc/os-release
    uname -r
    uptime
} >> $OUTPUT_FILE 2>&1

header "2. Hardware and Resource Details"
{
    lscpu
    free -h
    df -hT
    lsblk
} >> $OUTPUT_FILE 2>&1

header "3. Network Configuration"
{
    ip a
    ip r
    cat /etc/resolv.conf
    ss -tulnp
    ping -c 3 8.8.8.8
} >> $OUTPUT_FILE 2>&1

header "4. Security and Access Control"
{
    echo "SSH Configuration:"
    grep -E "Port|PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config
    echo -e "\nSudo Users:"
    grep 'sudo' /etc/group
    echo -e "\nShell Users:"
    grep bash /etc/passwd
} >> $OUTPUT_FILE 2>&1

header "5. Firewall and SELinux"
{
    echo "Firewall (firewalld):"
    systemctl is-active firewalld 2>/dev/null || echo "firewalld not found"
    firewall-cmd --list-all 2>/dev/null
    echo -e "\nUFW status:"
    ufw status 2>/dev/null
    echo -e "\nSELinux status:"
    getenforce 2>/dev/null || echo "SELinux not installed"
} >> $OUTPUT_FILE 2>&1

header "6. Package and Update Status"
{
    if command -v yum &>/dev/null; then
        yum check-update
    elif command -v apt &>/dev/null; then
        apt list --upgradable
    fi
    echo -e "\nTotal Packages:"
    rpm -qa | wc -l 2>/dev/null || dpkg -l | wc -l
} >> $OUTPUT_FILE 2>&1

header "7. Disk Usage and Inodes"
{
    df -hT
    df -i
} >> $OUTPUT_FILE 2>&1

header "8. Services and Daemons"
{
    systemctl list-units --type=service --state=running
    echo -e "\nEnabled at Boot:"
    systemctl list-unit-files --type=service | grep enabled
} >> $OUTPUT_FILE 2>&1

header "9. Logs and Recent Errors"
{
    journalctl -p 3 -xb | tail -n 50
    dmesg | grep -i error | tail -n 30
    tail -n 50 /var/log/messages 2>/dev/null
    tail -n 50 /var/log/secure 2>/dev/null
} >> $OUTPUT_FILE 2>&1

header "10. Cron Jobs and Timers"
{
    echo "Root Cron:"
    crontab -l 2>/dev/null
    echo -e "\nSystem-wide Cron:"
    ls /etc/cron.*
    echo -e "\nSystemd Timers:"
    systemctl list-timers
} >> $OUTPUT_FILE 2>&1

header "11. Performance Metrics Snapshot"
{
    echo -e "\nCPU/Load Info:"
    uptime
    echo -e "\nTop 5 Memory Consumers:"
    ps aux --sort=-%mem | head -n 6
    echo -e "\nI/O Stats (2s sample):"
    iostat -x 2 2 2>/dev/null
} >> $OUTPUT_FILE 2>&1

header "✅ Verification Completed"
echo "Server verification completed on $(date)" >> $OUTPUT_FILE

echo "Verification complete!"
echo "Report saved at: $OUTPUT_FILE"
