#!/bin/bash

# Performance testing suite for Advent of Code 2025 solutions.
# Measures and tracks execution time for each day's solution.
# Usage: ./tests/performance.sh [save-baseline]

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

PERF_LOG="tests/performance.log"
PERF_BASELINE="tests/performance.baseline"
SAVE_BASELINE=0

# Check for save-baseline flag
if [ "$1" = "save-baseline" ]; then
    SAVE_BASELINE=1
    echo "Running in baseline-save mode"
fi

echo "Building project..."
zig build

echo ""
echo "Running performance tests..."
echo ""

# Create header for this run
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "=== Performance Test Run: $TIMESTAMP ===" 
echo ""
echo "=== Performance Test Run: $TIMESTAMP ===" >> "$PERF_LOG"

declare -A current_times
declare -a days_array

# Run each day and collect metrics
for day in {1..10}; do
    echo -n "Day $day: "
    
    output=$(zig build run -- "$day" 2>&1)
    
    # Extract timing metrics from performance section only
    perf_section=$(echo "$output" | awk '/^Performance:/,EOF')
    
    part1_val=$(echo "$perf_section" | grep "Part 1:" | sed -E 's/.*Part 1:[[:space:]]+([0-9.]+).*/\1/')
    part2_val=$(echo "$perf_section" | grep "Part 2:" | sed -E 's/.*Part 2:[[:space:]]+([0-9.]+).*/\1/')
    total_val=$(echo "$perf_section" | grep "Total:" | sed -E 's/.*Total:[[:space:]]+([0-9.]+).*/\1/')
    
    part1_time="$part1_val ms"
    part2_time="$part2_val ms"
    total_time="$total_val ms"
    
    current_times["day$day"]="$part1_val|$part2_val|$total_val"
    days_array+=($day)
    
    printf "Part1: %7s  Part2: %7s  Total: %7s\n" "$part1_time" "$part2_time" "$total_time"
done

# Load baseline if it exists and not saving new one
declare -A baseline_times
if [ $SAVE_BASELINE -eq 0 ] && [ -f "$PERF_BASELINE" ]; then
    while IFS='=' read -r key value; do
        baseline_times["$key"]="$value"
    done < "$PERF_BASELINE"
    HAS_BASELINE=1
else
    HAS_BASELINE=0
fi

# Summary table
echo ""
echo "Summary:"
if [ $HAS_BASELINE -eq 1 ]; then
    echo "Day | Part 1 (ms) | Δ        | Part 2 (ms) | Δ        | Total (ms) | Δ"
    echo "----|-------------|----------|-------------|----------|------------|----------"
else
    echo "Day | Part 1 (ms) | Part 2 (ms) | Total (ms)"
    echo "----|-------------|-------------|----------"
fi

total_all=0
for day in "${days_array[@]}"; do
    times="${current_times["day$day"]}"
    IFS='|' read -r p1 p2 tot <<< "$times"
    total_all=$(awk "BEGIN {print $total_all + $tot}")
    
    if [ $HAS_BASELINE -eq 1 ]; then
        baseline="${baseline_times["day$day"]}"
        if [ -z "$baseline" ]; then
            printf "%02d  | %11.2f | --       | %11.2f | --       | %10.2f | --\n" "$day" "$p1" "$p2" "$tot"
        else
            IFS='|' read -r bp1 bp2 btot <<< "$baseline"
            dp1=$(awk "BEGIN {printf \"%.2f\", $p1 - $bp1}")
            dp2=$(awk "BEGIN {printf \"%.2f\", $p2 - $bp2}")
            dtot=$(awk "BEGIN {printf \"%.2f\", $tot - $btot}")
            
            # Format delta with color-like indicators (+ for slower, - for faster)
            [ $(echo "$dp1 < 0" | bc) -eq 1 ] && sdp1="✓ $dp1" || sdp1="✗ +$dp1"
            [ $(echo "$dp2 < 0" | bc) -eq 1 ] && sdp2="✓ $dp2" || sdp2="✗ +$dp2"
            [ $(echo "$dtot < 0" | bc) -eq 1 ] && sdtot="✓ $dtot" || sdtot="✗ +$dtot"
            
            printf "%02d  | %11.2f | %8s | %11.2f | %8s | %10.2f | %8s\n" "$day" "$p1" "$sdp1" "$p2" "$sdp2" "$tot" "$sdtot"
        fi
    else
        printf "%02d  | %11.2f | %11.2f | %9.2f\n" "$day" "$p1" "$p2" "$tot"
    fi
done
echo "----|-------------|" $([ $HAS_BASELINE -eq 1 ] && echo "----------|" || true) "-------------|" $([ $HAS_BASELINE -eq 1 ] && echo "----------|" || true) "----------"
if [ $HAS_BASELINE -eq 1 ]; then
    printf "    |             |          |             |          | %10.2f |\n" "$total_all"
else
    printf "    |             |             | %9.2f\n" "$total_all"
fi

# Log the results
echo "" >> "$PERF_LOG"
for day in "${days_array[@]}"; do
    times="${current_times["day$day"]}"
    IFS='|' read -r p1 p2 tot <<< "$times"
    printf "Day %02d: Part1=%f Part2=%f Total=%f\n" "$day" "$p1" "$p2" "$tot" >> "$PERF_LOG"
done
echo "" >> "$PERF_LOG"

if [ $SAVE_BASELINE -eq 1 ]; then
    echo ""
    echo "Saving baseline..."
    > "$PERF_BASELINE"  # Clear baseline file
    for day in "${days_array[@]}"; do
        times="${current_times["day$day"]}"
        echo "day$day=$times" >> "$PERF_BASELINE"
    done
    echo "Baseline saved to: $PERF_BASELINE"
fi

echo ""
echo "Results logged to: $PERF_LOG"
