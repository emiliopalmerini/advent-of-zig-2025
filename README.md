# Advent of Zig 2025

Solving [Advent of Code 2025](https://adventofcode.com/2025) in Zig.

> **Note:** Input files (`input.txt`) are not included in this repository per [Advent of Code's terms of service](https://adventofcode.com/about#faq_copying). Download your personal inputs from [adventofcode.com](https://adventofcode.com) and place them in the respective day directories (e.g., `src/day01/input.txt`).
> I had to do a complete rewrite of this repo history to remove them :,(

## Build

```bash
zig build
```

## Run

```bash
zig build run -- <day|all>
```

**Examples:**
- `zig build run -- 1` - Run day 1
- `zig build run -- all` - Run all days

## Performance Testing

```bash
zig build perf
```

Save a new baseline:
```bash
zig build perf -- save-baseline
```

## Tests

```bash
zig build test
```

### Regression Tests

```bash
zig build regression
```
