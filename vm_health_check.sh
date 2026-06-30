#!/usr/bin/env bash

# Threshold percentage for healthy metrics.
THRESHOLD=60

# Read CPU statistics from /proc/stat twice and calculate CPU usage.
get_cpu_usage() {
  read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
  idle1=$((idle + iowait))

  sleep 1

  read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
  idle2=$((idle + iowait))

  cpu_usage=$(awk -v t1="$total1" -v i1="$idle1" -v t2="$total2" -v i2="$idle2" 'BEGIN { if (t2 - t1 > 0) printf "%.0f", ((t2 - t1) - (i2 - i1)) / (t2 - t1) * 100; else print 0 }')
  echo "$cpu_usage"
}

# Read memory statistics from free and calculate used memory percentage.
get_memory_usage() {
  mem_total=$(free -m | awk '/^Mem:/ {print $2}')
  mem_available=$(free -m | awk '/^Mem:/ {print $7}')
  mem_used=$((mem_total - mem_available))

  if [ "$mem_total" -gt 0 ]; then
    mem_usage=$((mem_used * 100 / mem_total))
  else
    mem_usage=0
  fi

  echo "$mem_usage"
}

# Read disk usage for the root filesystem and return the used percentage.
get_disk_usage() {
  df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}'
}

# Convert a numeric value and threshold into a health status.
is_below_threshold() {
  local value="$1"
  local threshold="$2"

  if [ "$value" -lt "$threshold" ]; then
    return 0
  fi

  return 1
}

# Print the final status based on the collected metric values.
print_status() {
  local cpu_value="$1"
  local mem_value="$2"
  local disk_value="$3"

  if is_below_threshold "$cpu_value" "$THRESHOLD" && \
     is_below_threshold "$mem_value" "$THRESHOLD" && \
     is_below_threshold "$disk_value" "$THRESHOLD"; then
    echo "Healthy"
  else
    echo "Not Healthy"
  fi
}

# Print the explain output when the user passes the explain argument.
print_explain() {
  local cpu_value="$1"
  local mem_value="$2"
  local disk_value="$3"
  local status_value="$4"

  echo "CPU Usage: ${cpu_value}%"
  echo "Memory Usage: ${mem_value}%"
  echo "Disk Usage: ${disk_value}%"
  echo "Status: ${status_value}"
  echo ""
  echo "Explanation for each metric:"
  echo "- CPU Usage: Shows how much processor capacity is currently in use."
  echo "- Memory Usage: Shows how much RAM is currently used compared to total RAM."
  echo "- Disk Usage: Shows how much of the root filesystem is occupied."
  echo "- Status: Healthy means all metrics are below ${THRESHOLD}%. Not Healthy means one or more metrics are at or above ${THRESHOLD}%."
}

main() {
  cpu_usage=$(get_cpu_usage)
  memory_usage=$(get_memory_usage)
  disk_usage=$(get_disk_usage)

  status=$(print_status "$cpu_usage" "$memory_usage" "$disk_usage")

  case "$1" in
    "")
      echo "$status"
      ;;
    explain)
      print_explain "$cpu_usage" "$memory_usage" "$disk_usage" "$status"
      ;;
    *)
      echo "Usage:"
      echo "./vm_health_check.sh"
      echo "./vm_health_check.sh explain"
      exit 1
      ;;
  esac
}

main "$1"
