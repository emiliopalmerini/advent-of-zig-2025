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

pub fn measureMetrics(
    allocator: std.mem.Allocator,
    solvePart1Fn: *const fn (*anyopaque, std.mem.Allocator) anyerror!u64,
    solvePart2Fn: *const fn (*anyopaque, std.mem.Allocator) anyerror!u64,
) !Metrics {
    var timer = try std.time.Timer.start();

    const part1_result = try solvePart1Fn(undefined, allocator);
    const part1_time = timer.lap();

    const part2_result = try solvePart2Fn(undefined, allocator);
    const part2_time = timer.lap();

    return Metrics{
        .part1_result = part1_result,
        .part1_time_ms = @as(f64, @floatFromInt(part1_time)) / 1_000_000,
        .part2_result = part2_result,
        .part2_time_ms = @as(f64, @floatFromInt(part2_time)) / 1_000_000,
    };
}
