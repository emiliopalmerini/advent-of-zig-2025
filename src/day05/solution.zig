// https://adventofcode.com/2025/day/5

const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

const Range = struct {
    start: u64,
    end: u64,
};

fn isFresh(id: u64, ranges: []const Range) bool {
    for (ranges) |range| {
        if (id >= range.start and id <= range.end) {
            return true;
        }
    }
    return false;
}

pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    var ranges = try std.ArrayList(Range).initCapacity(allocator, 100);
    defer ranges.deinit(allocator);

    var splitted = std.mem.splitSequence(u8, input, "\n\n");
    const ranges_section = splitted.next() orelse return error.InvalidInput;
    var line_iter = std.mem.tokenizeScalar(u8, ranges_section, '\n');
    while (line_iter.next()) |line| {
        const parsed = try u.input.parseRange(line);
        try ranges.append(allocator, .{
            .start = parsed.start,
            .end = parsed.stop,
        });
    }

    const ids_section = splitted.next() orelse return error.InvalidInput;
    var ids_lines = try u.input.readLines(allocator, ids_section);
    defer ids_lines.deinit(allocator);

    var fresh_count: u64 = 0;
    for (ids_lines.items) |line| {
        const id = try std.fmt.parseInt(u64, line, 10);
        if (isFresh(id, ranges.items)) {
            fresh_count += 1;
        }
    }

    return fresh_count;
}

fn compareRanges(context: void, a: Range, b: Range) bool {
    _ = context;
    return a.start < b.start;
}

pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    var ranges = try std.ArrayList(Range).initCapacity(allocator, 100);
    defer ranges.deinit(allocator);

    var splitted = std.mem.splitSequence(u8, input, "\n\n");
    const ranges_section = splitted.next() orelse return error.InvalidInput;
    var line_iter = std.mem.tokenizeScalar(u8, ranges_section, '\n');
    while (line_iter.next()) |line| {
        const parsed = try u.input.parseRange(line);
        try ranges.append(allocator, .{
            .start = parsed.start,
            .end = parsed.stop,
        });
    }

    std.mem.sort(Range, ranges.items, {}, compareRanges);

    // Merge overlapping/adjacent ranges
    var merged = try std.ArrayList(Range).initCapacity(allocator, 100);
    defer merged.deinit(allocator);

    if (ranges.items.len > 0) {
        var current = ranges.items[0];

        for (ranges.items[1..]) |range| {
            if (range.start <= current.end + 1) {
                current.end = @max(current.end, range.end);
            } else {
                try merged.append(allocator, current);
                current = range;
            }
        }
        try merged.append(allocator, current);
    }

    var total: u64 = 0;
    for (merged.items) |range| {
        total += (range.end - range.start + 1);
    }

    return total;
}

pub const Day5Solution = struct {
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

    fn solvePart1Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        return try solvePart1(allocator, data);
    }

    fn solvePart2Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        return try solvePart2(allocator, data);
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
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const p1 = try Day5Solution.asDaySolution().solvePart1(allocator);
    const p2 = try Day5Solution.asDaySolution().solvePart2(allocator);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}
