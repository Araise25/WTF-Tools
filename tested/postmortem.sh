#!/bin/bash

# postmortem: Collect system state after crashes
# Usage: postmortem [output_file]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
OUTPUT_FILE="postmortem_report.txt"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Help message
show_help() {
    cat << EOF
Usage: postmortem [output_file]

Collect system state information after crashes.

Options:
    output_file     Output file to save the report (default: postmortem_report.txt)

Examples:
    postmortem                     # Save to postmortem_report.txt
    postmortem crash_report.txt    # Save to custom file
EOF
}

# Parse arguments
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

if [ -n "$1" ]; then
    OUTPUT_FILE="$1"
fi

# Function to get system information
get_system_info() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -a)"
    echo "Uptime: $(uptime)"
    echo "Load Average: $(cat /proc/loadavg 2>/dev/null || echo "N/A")"
    echo
}

# Function to get memory information
get_memory_info() {
    echo "=== Memory Information ==="
    if [ -f /proc/meminfo ]; then
        echo "Memory Usage:"
        free -h
        echo
        echo "Detailed Memory Info:"
        grep -E '^(MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree)' /proc/meminfo
    else
        echo "Memory Usage:"
        vm_stat 2>/dev/null || echo "N/A"
    fi
    echo
}

# Function to get disk information
get_disk_info() {
    echo "=== Disk Information ==="
    echo "Disk Usage:"
    df -h
    echo
    echo "Inode Usage:"
    df -i
    echo
}

# Function to get process information
get_process_info() {
    echo "=== Process Information ==="
    echo "Top Processes by CPU:"
    ps aux --sort=-%cpu | head -n 10
    echo
    echo "Top Processes by Memory:"
    ps aux --sort=-%mem | head -n 10
    echo
}

# Function to get network information
get_network_info() {
    echo "=== Network Information ==="
    echo "Network Interfaces:"
    ip addr show 2>/dev/null || ifconfig
    echo
    echo "Network Connections:"
    netstat -tuln 2>/dev/null || ss -tuln
    echo
    echo "Routing Table:"
    netstat -rn 2>/dev/null || ip route show
    echo
}

# Function to get logged-in users
get_user_info() {
    echo "=== User Information ==="
    echo "Logged-in Users:"
    who
    echo
    echo "Recent Logins:"
    last | head -n 10
    echo
}

# Function to get system logs
get_system_logs() {
    echo "=== System Logs ==="
    echo "Recent System Messages:"
    journalctl -n 50 2>/dev/null || tail -n 50 /var/log/syslog 2>/dev/null || tail -n 50 /var/log/messages 2>/dev/null
    echo
}

# Function to get Docker information
get_docker_info() {
    if command -v docker >/dev/null 2>&1; then
        echo "=== Docker Information ==="
        echo "Docker Containers:"
        docker ps -a
        echo
        echo "Docker Images:"
        docker images
        echo
        echo "Docker System Info:"
        docker info
        echo
    fi
}

# Function to get Kubernetes information
get_kubernetes_info() {
    if command -v kubectl >/dev/null 2>&1; then
        echo "=== Kubernetes Information ==="
        echo "Kubernetes Nodes:"
        kubectl get nodes
        echo
        echo "Kubernetes Pods:"
        kubectl get pods --all-namespaces
        echo
        echo "Kubernetes Services:"
        kubectl get services --all-namespaces
        echo
    fi
}

# Function to get hardware information
get_hardware_info() {
    echo "=== Hardware Information ==="
    echo "CPU Information:"
    lscpu 2>/dev/null || sysctl -n machdep.cpu 2>/dev/null || echo "N/A"
    echo
    echo "GPU Information:"
    lspci | grep -i vga 2>/dev/null || echo "N/A"
    echo
    echo "USB Devices:"
    lsusb 2>/dev/null || echo "N/A"
    echo
}

# Function to get service status
get_service_status() {
    echo "=== Service Status ==="
    if command -v systemctl >/dev/null 2>&1; then
        echo "System Services:"
        systemctl list-units --state=failed
        echo
    elif command -v service >/dev/null 2>&1; then
        echo "Service Status:"
        service --status-all
        echo
    fi
}

# Function to get package manager information
get_package_info() {
    echo "=== Package Manager Information ==="
    if command -v apt >/dev/null 2>&1; then
        echo "APT Updates Available:"
        apt list --upgradable 2>/dev/null
        echo
    elif command -v yum >/dev/null 2>&1; then
        echo "YUM Updates Available:"
        yum check-update 2>/dev/null
        echo
    elif command -v pacman >/dev/null 2>&1; then
        echo "Pacman Updates Available:"
        pacman -Qu 2>/dev/null
        echo
    fi
}

# Function to get security information
get_security_info() {
    echo "=== Security Information ==="
    echo "Failed Login Attempts:"
    grep "Failed password" /var/log/auth.log 2>/dev/null || grep "Failed password" /var/log/secure 2>/dev/null || echo "N/A"
    echo
    echo "Open Ports:"
    netstat -tuln 2>/dev/null || ss -tuln
    echo
    echo "SELinux Status (if applicable):"
    getenforce 2>/dev/null || echo "N/A"
    echo
}

# Function to get performance metrics
get_performance_metrics() {
    echo "=== Performance Metrics ==="
    echo "CPU Temperature (if available):"
    sensors 2>/dev/null || echo "N/A"
    echo
    echo "IO Statistics:"
    iostat -x 1 1 2>/dev/null || echo "N/A"
    echo
    echo "Network Statistics:"
    netstat -s 2>/dev/null || ss -s
    echo
}

# Main execution
echo -e "${BLUE}Collecting system state information...${NC}"

# Create report
{
    echo "Postmortem Report"
    echo "Generated: $(date)"
    echo "=========================================="
    echo

    get_system_info
    get_memory_info
    get_disk_info
    get_process_info
    get_network_info
    get_user_info
    get_system_logs
    get_docker_info
    get_kubernetes_info
    get_hardware_info
    get_service_status
    get_package_info
    get_security_info
    get_performance_metrics

    echo "=========================================="
    echo "End of Report"
} > "$OUTPUT_FILE"

echo -e "${GREEN}Report saved to: ${YELLOW}$OUTPUT_FILE${NC}"

# Create backup with timestamp
cp "$OUTPUT_FILE" "${OUTPUT_FILE%.*}_${TIMESTAMP}.${OUTPUT_FILE##*.}"
echo -e "${GREEN}Backup saved to: ${YELLOW}${OUTPUT_FILE%.*}_${TIMESTAMP}.${OUTPUT_FILE##*.}${NC}" 