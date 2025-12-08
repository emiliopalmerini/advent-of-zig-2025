// https://adventofcode.com/2025/day/2

const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

pub fn isInvalidIdPart1(n: u64) bool {
    // Ok so we have a million numbers to check. Converting each one to a string
    // and comparing halves would be super slow. Instead, I use pure arithmetic:
    // division and modulo to extract the left and right halves mathematically.
    
    // Count how many digits this number has
    var temp = n;
    var digit_count: u32 = 0;
    while (temp > 0) : (temp /= 10) {
        digit_count += 1;
    }
    
    // Odd digit count means the halves can never match, so bail early
    if (digit_count % 2 != 0) return false;
    
    // Now extract left and right halves using powers of 10.
    // Example: n=123123, digit_count=6, half=3, divisor=10^3=1000
    //   left = 123123 / 1000 = 123
    //   right = 123123 % 1000 = 123
    //   left == right -> true (this is a valid ID)
    const half = digit_count / 2;
    const divisor = std.math.pow(u64, 10, half);
    
    const left = n / divisor;
    const right = n % divisor;
    
    return left == right;
}

pub fn isInvalidIdPart2(n: u64) bool {
    // Part 2 is all about repeating patterns. We check if the digit string
    // has any repeating subsequence that tiles the whole number.
    var buffer: [20]u8 = undefined;
    const digits = u.input.extractDigits(n, &buffer);

    if (digits.len < 2) return false;

    // Try each possible pattern length from 1 to len/2
    var pattern_len: usize = 1;
    outer: while (pattern_len <= digits.len / 2) : (pattern_len += 1) {
        // The pattern must evenly divide the total length
        if (digits.len % pattern_len != 0) continue;

        // Check if this pattern repeats throughout the entire string
        for (digits, 0..) |digit, i| {
            if (digit != digits[i % pattern_len]) continue :outer;
        }
        // We found a valid repeating pattern!
        return true;
    }
    return false;
}

pub const Day2Solution = struct {
    const vtable = u.solution.DaySolution.VTable{
        .solvePart1 = solvePart1Impl,
        .solvePart2 = solvePart2Impl,
        .getMetrics = getMetricsImpl,
    };

    pub fn asDaySolution() u.solution.DaySolution {
        return u.solution.DaySolution{
            .ptr = undefined,
            .vtable = &vtable,
        };
    }

    fn solvePart1Impl(_: *anyopaque, _: std.mem.Allocator) !u64 {
        // Parse the input and iterate through all ID ranges.
        // For each ID in each range, check if it matches Part 1 criteria.
        var lines = std.mem.tokenizeScalar(u8, data, '\n');
        var part1_total: u64 = 0;

        while (lines.next()) |line| {
            var items = std.mem.tokenizeScalar(u8, line, ',');

            while (items.next()) |entry| {
                const range = u.input.parseRange(entry) catch continue;
                const start = range.start;
                const stop = range.stop;

                // Check every ID in this range
                var i = start;
                while (i <= stop) : (i += 1) {
                    if (isInvalidIdPart1(i)) {
                        part1_total += i;
                    }
                }
            }
        }

        return part1_total;
    }

    fn solvePart2Impl(_: *anyopaque, _: std.mem.Allocator) !u64 {
        // Same as Part 1, but with the stricter Part 2 criteria (repeating patterns).
        var lines = std.mem.tokenizeScalar(u8, data, '\n');
        var part2_total: u64 = 0;

        while (lines.next()) |line| {
            var items = std.mem.tokenizeScalar(u8, line, ',');

            while (items.next()) |entry| {
                const range = u.input.parseRange(entry) catch continue;
                const start = range.start;
                const stop = range.stop;

                // Check every ID in this range for Part 2 pattern matching
                var i = start;
                while (i <= stop) : (i += 1) {
                    if (isInvalidIdPart2(i)) {
                        part2_total += i;
                    }
                }
            }
        }

        return part2_total;
    }

    fn getMetricsImpl(_: *anyopaque, allocator: std.mem.Allocator) !u.solution.Metrics {

        var timer = try std.time.Timer.start();

        const part1_result = try solvePart1Impl(undefined, allocator);
        const part1_time = timer.lap();

        const part2_result = try solvePart2Impl(undefined, allocator);
        const total_time = timer.read();
        const part2_time = total_time -| part1_time;

        return u.solution.Metrics{
            .part1_result = part1_result,
            .part1_time_ms = @as(f64, @floatFromInt(part1_time)) / 1_000_000,
            .part2_result = part2_result,
            .part2_time_ms = @as(f64, @floatFromInt(part2_time)) / 1_000_000,
        };
    }
};

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const p1 = try Day2Solution.asDaySolution().solvePart1(allocator);
    const p2 = try Day2Solution.asDaySolution().solvePart2(allocator);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}
