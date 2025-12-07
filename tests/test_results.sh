#!/bin/bash

# Regression test script for Advent of Code 2025 solutions.
# This ensures the outputs of each day remain consistent
# while I move around stuff and try to understand how zig works.

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Building project..."
zig build

echo ""
echo "Running regression tests..."

FAILED=0

test_day() {
    local day=$1
    local expected=$2
    
    echo ""
    echo "Testing Day $day..."
    
    result=$(zig build run -- "$day" 2>&1 || true)
    
    if [ "$result" = "$expected" ]; then
        echo "✓ Day $day: PASS"
        return 0
    else
        echo "✗ Day $day: FAIL"
        echo "  Expected:"
        printf "    %s\n" "$expected"
        echo "  Got:"
        printf "    %s\n" "$result"
        return 1
    fi
}

test_day 1 "Part 1: 1089
Part 2: 6530" || ((FAILED++))

test_day 2 "Part 1: 19128774598
Part 2: 21932258645" || ((FAILED++))

test_day 3 "Part 1: 17766
Part 2: 176582889354075" || ((FAILED++))

test_day 4 "Part 1: 1491
Part 2: 8722" || ((FAILED++))

test_day 5 "Part 1: 773
Part 2: 332067203034711" || ((FAILED++))

test_day 6 "Part 1: 6725216329103
Part 2: 10600728112865" || ((FAILED++))

test_day 7 "Part 1: 1613
Part 2: 48021610271997" || ((FAILED++))

echo ""
if [ $FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Failed tests: $FAILED"
    exit 1
fi
