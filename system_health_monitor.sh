#!/bin/bash

# Thresholds (adjust these according to your requirements)
CPU_THRESHOLD=80   # CPU usage threshold in percentage
MEMORY_THRESHOLD=80  # Memory usage threshold in percentage
DISK_THRESHOLD=80   # Disk usage threshold in percentage

# Log file for alerts
log_file="system_health.log"

# Function to log messages with timestamp
log_message() {
    local log_content="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $log_content" >> "$log_file"
}

# Function to check CPU usage
check_cpu() {
    local cpu_usage=$(mpstat 1 1 | awk '$12 ~ /[0-9.]+/ { print 100 - $12 }' | tail -n 1)
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        log_message "CPU usage is high: $cpu_usage%"
        echo "ALERT: CPU usage is high: $cpu_usage%"
    fi
}

# Function to check memory usage
check_memory() {
    local memory_usage=$(free | awk '/Mem:/ {print $3/$2 * 100.0}')
    if (( $(echo "$memory_usage > $MEMORY_THRESHOLD" | bc -l) )); then
        log_message "Memory usage is high: $memory_usage%"
        echo "ALERT: Memory usage is high: $memory_usage%"
    fi
}

# Function to check disk usage
check_disk() {
    local disk_usage=$(df -h | awk '$NF=="/" {print $5}' | sed 's/%//')
    if (( $disk_usage > $DISK_THRESHOLD )); then
        log_message "Disk usage is high: $disk_usage%"
        echo "ALERT: Disk usage is high: $disk_usage%"
    fi
}

# Function to check running processes
check_processes() {
    local processes=$(ps aux --sort=-%cpu | head -n 10)
    log_message "Top 10 processes by CPU usage:"
    log_message "$processes"
}

# Main function to initiate checks
main() {
    echo "System Health Monitoring Report - $(date)"
    echo "--------------------------------------"

    check_cpu
    check_memory
    check_disk
    check_processes
}

# Execute main function
main
