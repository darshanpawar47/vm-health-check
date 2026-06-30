#!/usr/bin/env bash
set -euo pipefail

# Constants
THRESHOLD=60
LOG_FILE="vm_health.log"

# Utility Functions
usage() {
  cat <<EOF
Usage:
  ./vm_health_check.sh
  ./vm_health_check.sh explain
EOF
  exit 1
}

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

to_status_label() {
  local value="$1"

  if is_below_threshold "$value" "$THRESHOLD"; then
    echo "OK"
  else
    echo "ALERT"
  fi
}

# Metric Functions
get_cpu_usage() {
  read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
  idle1=$((idle + iowait))

  sleep 1

  read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
  idle2=$((idle + iowait))

  cpu_usage=$(awk -v t1="$total1" -v i1="$idle1" -v t2="$total2" -v i2="$idle2" \
    'BEGIN { if (t2 - t1 > 0) printf "%.0f", ((t2 - t1) - (i2 - i1)) / (t2 - t1) * 100; else print 0 }')
  echo "$cpu_usage"
}

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

get_disk_usage() {
  df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}'
}

is_below_threshold() {
  local value="$1"
  local threshold="$2"

  if [ "$value" -lt "$threshold" ]; then
    return 0
  fi

  return 1
}

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

# Output Functions
print_header() {
  echo "=========================================="
  echo "          VM HEALTH CHECK REPORT"
  echo "=========================================="
  echo
  echo "Timestamp : $(timestamp)"
  echo
}

print_metrics() {
  local cpu_value="$1"
  local mem_value="$2"
  local disk_value="$3"

  printf "CPU Usage      : %s%%   [%s]\n" "$cpu_value" "$(to_status_label "$cpu_value")"
  printf "Memory Usage   : %s%%   [%s]\n" "$mem_value" "$(to_status_label "$mem_value")"
  printf "Disk Usage     : %s%%   [%s]\n" "$disk_value" "$(to_status_label "$disk_value")"
  echo
}

print_overall_status() {
  local status="$1"
  echo "------------------------------------------"
  echo
  printf "Overall Status : %s\n" "$status"
  echo
  echo "=========================================="
}

print_summary() {
  local cpu_value="$1"
  local mem_value="$2"
  local disk_value="$3"
  local overall_status="$4"

  print_header
  print_metrics "$cpu_value" "$mem_value" "$disk_value"
  print_overall_status "$overall_status"
}

print_explain() {
  local cpu_value="$1"
  local mem_value="$2"
  local disk_value="$3"
  local overall_status="$4"

  print_summary "$cpu_value" "$mem_value" "$disk_value" "$overall_status"
  echo "Explanation:"
  echo "- CPU Usage: Shows how much processor capacity is currently in use."
  echo "- Memory Usage: Shows how much RAM is currently used compared to total RAM."
  echo "- Disk Usage: Shows how much of the root filesystem is occupied."
  echo "- Overall Status: HEALTHY means all metrics are below ${THRESHOLD}%. NOT HEALTHY means one or more metrics are at or above ${THRESHOLD}%."
}

# Logging
log_result() {
  local current_time
  current_time=$(timestamp)
  printf '%s | CPU=%s%% | MEM=%s%% | DISK=%s%% | STATUS=%s\n' \
    "$current_time" "$1" "$2" "$3" "$4" >> "$LOG_FILE"
}

# Main
main() {
  case "${1:-}" in
    "" | explain)
      ;;
    *)
      usage
      ;;
  esac

  local cpu_usage
  local memory_usage
  local disk_usage
  local status
  local status_label

  cpu_usage=$(get_cpu_usage)
  memory_usage=$(get_memory_usage)
  disk_usage=$(get_disk_usage)
  status=$(print_status "$cpu_usage" "$memory_usage" "$disk_usage")
  status_label=$(printf '%s' "$status" | awk '{print toupper($0)}')

  if [ "${1:-}" = "explain" ]; then
    print_explain "$cpu_usage" "$memory_usage" "$disk_usage" "$status_label"
  else
    print_summary "$cpu_usage" "$memory_usage" "$disk_usage" "$status_label"
  fi

  log_result "$cpu_usage" "$memory_usage" "$disk_usage" "$status_label"

  if [ "$status" = "Healthy" ]; then
    exit 0
  fi

  exit 1
}

main "${1:-}"
