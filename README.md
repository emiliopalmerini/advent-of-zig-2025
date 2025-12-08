# Advent of Zig 2025

Solving [Advent of Code 2025](https://adventofcode.com/2025) in Zig.

> **Note:** Input files (`input.txt`) are not included in this repository per [Advent of Code's terms of service](https://adventofcode.com/about#faq_copying). Download your personal inputs from [adventofcode.com](https://adventofcode.com) and place them in the respective day directories (e.g., `src/day01/input.txt`).

## Build

```bash
zig build
```

## Run

```bash
zig build run -- <day|all> [performance]
```

**Examples:**
- `zig build run -- 1` - Run day 1
- `zig build run -- 1 performance` - Run day 1 with performance metrics
- `zig build run -- all` - Run all days
- `zig build run -- all performance` - Run all days with performance metrics

## Tests

```bash
zig build test
```

### Regression Tests

```bash
zig build regression
```
