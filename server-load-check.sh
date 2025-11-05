#!/bin/bash
# ==============================================
# Server Load Troubleshooting Script
# Author: Pranav
# Description: Collects basic system performance data
# ==============================================

LOG_DIR="/var/log/server-check"
mkdir -p $LOG_DIR

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/server_load_report_$TIMESTAMP.txt"

# Header
echo "==============================================" | tee -a $LOG_FILE
echo "       SERVER LOAD TROUBLESHOOT REPORT         " | tee -a $LOG_FILE
echo "==============================================" | tee -a $LOG_FILE
echo "Date & Time : $(date)" | tee -a $LOG_FILE
echo "Hostname    : $(hostname)" | tee -a $LOG_FILE
echo "----------------------------------------------" | tee -a $LOG_FILE

# 1. Server Uptime & Load
echo -e "\n[1] 🔹 SYSTEM LOAD & UPTIME" | tee -a $LOG_FILE
echo "----------------------------------------------" | tee -a $LOG_FILE
uptime | tee -a $LOG_FILE
echo "CPU Cores: $(nproc)" | tee -a $LOG_FILE

# 2. Top CPU consuming processes
echo -e "\n[2] 🔹 TOP 10 CPU CONSUMING PROCESSES" | tee -a $LOG_FILE
echo "----------------------------------------------" | tee -a $LOG_FILE
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11 | tee -a $LOG_FILE

# 3. Top Memory consuming processes
echo -e "\n[3] 🔹 TOP 10 MEMORY CONSUMING PROCESSES" | tee -a $LOG_FILE
echo "----------------------------------------------" | tee -a $LOG_FILE
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 11 | tee -a $LOG_FILE

# 4. Memory Usage
echo -e "\n[4] 🔹 MEMORY USAGE" | tee -a $LOG_FILE
echo "----------------------------------------------" | tee -a $LOG_FILE
free -h | tee -a $LOG_FILE

# 5. Disk Usage
echo -e "\n[5] 🔹 DISK USAGE" | tee -a $LOG_FILE
echo "----------------------------------------------" | tee -a $LOG_FILE
df -h | tee -a $LOG_FILE

# 6. I/O Statistics
echo -e "\n[6] 🔹 DISK I/O STATISTICS (iostat -x 1 2)" | tee -a $LOG_FILE
echo "----------------------------------------------" | tee -a $LOG_FILE
if command -v iostat &>/dev/null; then
    iostat -xz 1 2 | tee -a $LOG_FILE
else
    echo "iostat command not found. Install sysstat package." | tee -a $LOG_FILE
fi

# 7. High I/O or Zombie Processes
echo -e "\n[7] 🔹 CHECK FOR ZOMBIE PROCESSES" | tee -a $LOG_FILE
echo "----------------------------------------------" | tee -a $LOG_FILE
ps aux | grep 'Z' | grep -v grep | tee -a $LOG_FILE

# 8. Network Usage
echo -e "\n[8] 🔹 NETWORK CONNECTION SUMMARY" | tee -a $LOG_FILE
echo "----------------------------------------------" | tee -a $LOG_FILE
ss -s | tee -a $LOG_FILE
echo -e "\nTop 10 Connections by Count:" | tee -a $LOG_FILE
ss -tan | awk '{print $5}' | cut -d':' -f1 | sort | uniq -c | sort -nr | head | tee -a $LOG_FILE

# 9. System Logs
echo -e "\n[9] 🔹 SYSTEM LOGS (Last 20 Lines)" | tee -a $LOG_FILE
echo "----------------------------------------------" | tee -a $LOG_FILE
tail -n 20 /var/log/syslog 2>/dev/null | tee -a $LOG_FILE || tail -n 20 /var/log/messages | tee -a $LOG_FILE

# 10. Active Services
echo -e "\n[10] 🔹 TOP ACTIVE SERVICES BY CPU USAGE" | tee -a $LOG_FILE
echo "----------------------------------------------" | tee -a $LOG_FILE
systemctl list-units --type=service --state=running | head -n 15 | tee -a $LOG_FILE

# 11. Summary Line
echo -e "\n✅ Report saved to: $LOG_FILE"
echo "==============================================" | tee -a $LOG_FILE
