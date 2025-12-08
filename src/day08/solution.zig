const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    _ = allocator;
    _ = input;
    return 0;
}

pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    _ = allocator;
    _ = input;
    return 0;
}

pub const Day8Solution = struct {
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

    const p1 = try Day8Solution.asDaySolution().solvePart1(allocator);
    const p2 = try Day8Solution.asDaySolution().solvePart2(allocator);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}
