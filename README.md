# vm-health-check

A small Bash utility for checking VM health by evaluating CPU, memory, and disk utilization.

## Project Overview

`vm_health_check.sh` is a lightweight shell script designed to assess the resource health of a Linux VM. It calculates CPU, memory, and root disk utilization, formats a clear health report, and optionally explains each metric.

## Features

- CPU utilization check using `/proc/stat`
- Memory utilization check using `free`
- Disk utilization check for the root filesystem using `df`
- Threshold-based health decision with a fixed `60%` limit
- Human-readable console report with separators and timestamps
- Explain mode for metric details
- Execution logging to `vm_health.log`
- Exit codes for healthy and unhealthy status

## Project Structure

- `vm_health_check.sh` — main Bash health-check script
- `README.md` — project documentation
- `vm_health.log` — runtime log file created by the script

## Requirements

- Linux-based system
- Bash shell
- `awk`, `free`, `df` available in the environment

## Usage

Make the script executable and run it:

```bash
chmod +x vm_health_check.sh
./vm_health_check.sh
```

### Explain mode

Run with the `explain` argument to print the report plus metric explanations:

```bash
./vm_health_check.sh explain
```

## Example Output

```txt
==========================================
          VM HEALTH CHECK REPORT
==========================================

Timestamp : 2026-06-30 12:34:56

CPU Usage      : 10%   [OK]
Memory Usage   : 35%   [OK]
Disk Usage     : 40%   [OK]

------------------------------------------

Overall Status : HEALTHY

==========================================
```

In explain mode, the output includes additional guidance on what each metric means.

## Logging

Each execution appends a line to `vm_health.log` in this format:

```txt
YYYY-MM-DD HH:MM:SS | CPU=10% | MEM=35% | DISK=40% | STATUS=HEALTHY
```

## Exit Codes

- `0` — Healthy
- `1` — Not Healthy or invalid arguments

## Future Enhancements

- Add configurable thresholds via command-line options
- Add support for additional filesystems and mount points
- Add system load and network health checks
- Add optional JSON or CSV output for automation
- Add unit tests for output formatting and functions


This project contains a simple Bash script that checks VM health by measuring CPU, memory, and disk utilization.

## Files

- `vm_health_check.sh` - Bash script that checks the current VM resource usage.

## Usage

Make the script executable and run it:

```bash
chmod +x vm_health_check.sh
./vm_health_check.sh
```

If you want an explanatory output, run:

```bash
./vm_health_check.sh explain
```

## What the script checks

- CPU utilization: how much of the CPU is in use right now.
- Memory utilization: how much RAM is used compared to the total available RAM.
- Disk utilization: how much of the root filesystem is used.

If all three metrics are below `60%`, the script prints `Healthy`.
If any metric is `60%` or above, it prints `Not Healthy`.

## How the script works

### CPU usage
The script reads CPU counters from `/proc/stat` twice with a one-second pause.
It calculates the difference between the idle and total CPU time values to estimate the CPU usage percentage.

### Memory usage
The script uses `free -m` to get total and available memory.
It calculates the used memory percentage as:

```
used = total - available
usage = used * 100 / total
```

### Disk usage
The script uses `df -P /` to get the usage percentage for the root filesystem.
It removes the trailing percent sign from the `Use%` column and prints the numeric value.

### Status check
The script compares each metric to the threshold of `60%`.
If all metrics are below the threshold, the result is `Healthy`.
Otherwise, the result is `Not Healthy`.

## Explain mode
When you run `./vm_health_check.sh explain`, the script prints:

- CPU Usage
- Memory Usage
- Disk Usage
- Status
- Explanation for each metric

This mode is useful for learning why each metric matters.
