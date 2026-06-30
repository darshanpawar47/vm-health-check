# vm-health-check

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
