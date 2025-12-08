// https://adventofcode.com/2025/day/4

const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

pub fn solvePart1(grid: [][]const u8) usize {
    if (grid.len == 0) return 0;
    
    var valid_rolls: usize = 0;

    for (0..grid.len) |y| {
        for (0..grid[0].len) |x| {
            if (grid[y][x] != '@') continue;

            if (u.grid.countNeighborsWhere(grid, y, x, '@') < 4) {
                valid_rolls += 1;
            }
        }
    }

    return valid_rolls;
}

pub fn solvePart2(allocator: std.mem.Allocator, grid: [][]u8) !usize {
    var candidates = try std.ArrayList(u.grid.Point).initCapacity(allocator, 100);
    defer candidates.deinit(allocator);

    var total_removed: usize = 0;

    while (true) {
        for (0..grid.len) |y| {
            for (0..grid[0].len) |x| {
                if (grid[y][x] != '@') continue;

                const grid_const = @as([][]const u8, @ptrCast(grid));
                if (u.grid.countNeighborsWhere(grid_const, y, x, '@') < 4) {
                    try candidates.append(allocator, .{ .y = y, .x = x });
                }
            }
        }

        if (candidates.items.len == 0) {
            break;
        }

        for (candidates.items) |p| {
            grid[p.y][p.x] = '.'; 
        }

        total_removed += candidates.items.len;

        candidates.clearRetainingCapacity();
    } 
        
    return total_removed;
}

pub const Day4Solution = struct {
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

        var grid = try u.grid.readGrid(allocator, data);
        defer {
            for (grid.items) |line| {
                allocator.free(line);
            }
            grid.deinit(allocator);
        }
        const result = solvePart1(@as([][]const u8, @ptrCast(grid.items)));
        return @intCast(result);
    }

    fn solvePart2Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {

        var grid = try u.grid.readGrid(allocator, data);
        defer {
            for (grid.items) |line| {
                allocator.free(line);
            }
            grid.deinit(allocator);
        }
        const result = try solvePart2(allocator, grid.items);
        return @intCast(result);
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

    const p1 = try Day4Solution.asDaySolution().solvePart1(allocator);
    const p2 = try Day4Solution.asDaySolution().solvePart2(allocator);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}
