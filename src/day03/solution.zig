// https://adventofcode.com/2025/day/3

const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

fn largestByRemovingK(bank: []const u8, out_len: usize) u64 {
    if (bank.len < out_len) return 0;
    
    const remove_count = bank.len - out_len;
    var result: u64 = 0;
    var skip: usize = 0;
    
    for (0..out_len) |i| {
        var max_digit: u8 = bank[skip];
        var max_pos: usize = skip;
        
        const search_limit = remove_count + i + 1;
        
        for (skip + 1..search_limit) |j| {
            if (bank[j] > max_digit) {
                max_digit = bank[j];
                max_pos = j;
            }
        }
        
        result = result * 10 + (max_digit - '0');
        skip = max_pos + 1;
    }
    
    return result;
}

pub fn largestBatteries(bank: []const u8) u32 {
    return @intCast(largestByRemovingK(bank, 2));
}

pub fn largestBatteries2(bank: []const u8) u64 {
    return largestByRemovingK(bank, 12);
}

pub const Day3Solution = struct {
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

        var lines = std.mem.tokenizeScalar(u8, data, '\n');
        var part1_total: u64 = 0;

        while (lines.next()) |line| {
            const trimmed = u.input.trimLine(line);
            if (trimmed.len == 0) continue;
            part1_total += largestBatteries(trimmed);
        }

        return part1_total;
    }

    fn solvePart2Impl(_: *anyopaque, _: std.mem.Allocator) !u64 {

        var lines = std.mem.tokenizeScalar(u8, data, '\n');
        var part2_total: u64 = 0;

        while (lines.next()) |line| {
            const trimmed = u.input.trimLine(line);
            if (trimmed.len == 0) continue;
            part2_total += largestBatteries2(trimmed);
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

    const p1 = try Day3Solution.asDaySolution().solvePart1(allocator);
    const p2 = try Day3Solution.asDaySolution().solvePart2(allocator);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}
