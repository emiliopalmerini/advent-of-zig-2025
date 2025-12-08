// https://adventofcode.com/2025/day/1

const std = @import("std");
const u = @import("utils");

const day1_data = @embedFile("input.txt");

const STARTING_POSITION: i32 = 50;
const MODULO: i32 = 100;
const INITIAL_CAPACITY: usize = 100;

pub fn turn(start: i32, op: i32) i32 {
    return @rem((@rem((start + op), MODULO) + MODULO), MODULO);
}

pub fn countZeroCrossings(start: i32, op: i32) i32 {
    if (op > 0) {
        return @divFloor(start + op, MODULO);
    } else {
        const abs_op = -op;
        if (start == 0) {
            return @divFloor(abs_op, MODULO);
        } else if (abs_op < start) {
            return 0;
        } else {
            return 1 + @divFloor(abs_op - start, MODULO);
        }
    }
}

pub const Day1Solution = struct {
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

        var ops = try std.ArrayList(i32).initCapacity(allocator, INITIAL_CAPACITY);
        defer ops.deinit(allocator);

        var lines = std.mem.splitSequence(u8, day1_data, "\n");
        while (lines.next()) |line| {
            if (line.len < 2) continue;

            const direction = line[0];
            const num = try std.fmt.parseInt(i32, line[1..], 10);
            const value: i32 = if (direction == 'L') -num else num;
            try ops.append(allocator, value);
        }

        var start: i32 = STARTING_POSITION;
        var res: i32 = 0;
        for (ops.items) |value| {
            start = turn(start, value);
            if (start == 0) {
                res += 1;
            }
        }
        return @intCast(res);
    }

    fn solvePart2Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {

        var ops = try std.ArrayList(i32).initCapacity(allocator, INITIAL_CAPACITY);
        defer ops.deinit(allocator);

        var lines = std.mem.splitSequence(u8, day1_data, "\n");
        while (lines.next()) |line| {
            if (line.len < 2) continue;

            const direction = line[0];
            const num = try std.fmt.parseInt(i32, line[1..], 10);
            const value: i32 = if (direction == 'L') -num else num;
            try ops.append(allocator, value);
        }

        var start: i32 = STARTING_POSITION;
        var res: i32 = 0;
        for (ops.items) |value| {
            res += countZeroCrossings(start, value);
            start = turn(start, value);
        }
        return @intCast(res);
    }

    fn getMetricsImpl(_: *anyopaque, allocator: std.mem.Allocator) !u.solution.Metrics {
        return u.solution.measureMetrics(allocator, solvePart1Impl, solvePart2Impl);
    }
};

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const p1 = try Day1Solution.asDaySolution().solvePart1(allocator);
    const p2 = try Day1Solution.asDaySolution().solvePart2(allocator);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}
