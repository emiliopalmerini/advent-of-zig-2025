const std = @import("std");

pub const Metrics = struct {
    part1_result: u64,
    part1_time_ms: f64,
    part2_result: u64,
    part2_time_ms: f64,

    pub fn total_time_ms(self: Metrics) f64 {
        return self.part1_time_ms + self.part2_time_ms;
    }
};

pub const DaySolution = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        solvePart1: *const fn (ctx: *anyopaque, allocator: std.mem.Allocator) anyerror!u64,
        solvePart2: *const fn (ctx: *anyopaque, allocator: std.mem.Allocator) anyerror!u64,
        getMetrics: *const fn (ctx: *anyopaque, allocator: std.mem.Allocator) anyerror!Metrics,
    };

    pub fn solvePart1(self: DaySolution, allocator: std.mem.Allocator) !u64 {
        return self.vtable.solvePart1(self.ptr, allocator);
    }

    pub fn solvePart2(self: DaySolution, allocator: std.mem.Allocator) !u64 {
        return self.vtable.solvePart2(self.ptr, allocator);
    }

    pub fn getMetrics(self: DaySolution, allocator: std.mem.Allocator) !Metrics {
        return self.vtable.getMetrics(self.ptr, allocator);
    }
};

/// Create a child arena allocator from a parent allocator.
/// The arena will have its own memory pool and clean itself up when passed to deinit.
/// Useful for parts that do temporary allocations that should be freed together.
pub fn createArenaAllocator(parent_allocator: std.mem.Allocator) !std.heap.ArenaAllocator {
    return std.heap.ArenaAllocator.init(parent_allocator);
}

/// Measure performance of both solution parts with proper resource cleanup.
/// Each part gets its own arena allocator for isolated memory management.
pub fn measureMetrics(
    parent_allocator: std.mem.Allocator,
    solvePart1Fn: *const fn (*anyopaque, std.mem.Allocator) anyerror!u64,
    solvePart2Fn: *const fn (*anyopaque, std.mem.Allocator) anyerror!u64,
) !Metrics {
    var timer = try std.time.Timer.start();

    // Part 1: Use arena allocator for clean separation
    var arena1 = try createArenaAllocator(parent_allocator);
    defer arena1.deinit();
    const part1_result = try solvePart1Fn(undefined, arena1.allocator());
    const part1_time = timer.lap();

    // Part 2: Use separate arena allocator for clean separation
    var arena2 = try createArenaAllocator(parent_allocator);
    defer arena2.deinit();
    const part2_result = try solvePart2Fn(undefined, arena2.allocator());
    const part2_time = timer.lap();

    return Metrics{
        .part1_result = part1_result,
        .part1_time_ms = @as(f64, @floatFromInt(part1_time)) / 1_000_000,
        .part2_result = part2_result,
        .part2_time_ms = @as(f64, @floatFromInt(part2_time)) / 1_000_000,
    };
}
