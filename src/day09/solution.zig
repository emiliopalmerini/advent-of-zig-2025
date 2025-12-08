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

pub const Day9Solution = struct {
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
        return u.solution.measureMetrics(allocator, solvePart1Impl, solvePart2Impl);
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const p1 = try Day9Solution.asDaySolution().solvePart1(allocator);
    const p2 = try Day9Solution.asDaySolution().solvePart2(allocator);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}
