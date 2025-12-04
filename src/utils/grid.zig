const std = @import("std");

pub const Point = struct { y: usize, x: usize };

/// All 8 cardinal and diagonal directions
pub const DIRS = [_][2]isize{
    .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
    .{  0, -1 },             .{  0, 1 },
    .{  1, -1 }, .{  1, 0 }, .{  1, 1 },
};

/// Cardinal directions only (up, down, left, right)
pub const CARDINAL_DIRS = [_][2]isize{
    .{ -1, 0 }, // up
    .{  1, 0 }, // down
    .{  0, -1 }, // left
    .{  0, 1 }, // right
};

/// Count neighbors matching a condition
pub fn countNeighborsWhere(
    grid: [][]const u8,
    y: usize,
    x: usize,
    target: u8,
) u8 {
    const h: isize = @intCast(grid.len);
    const w: isize = @intCast(grid[0].len);
    var neighbors: u8 = 0;

    for (DIRS) |d| {
        const ny = @as(isize, @intCast(y)) + d[0];
        const nx = @as(isize, @intCast(x)) + d[1];

        if (ny >= 0 and ny < h and nx >= 0 and nx < w) {
            if (grid[@intCast(ny)][@intCast(nx)] == target) {
                neighbors += 1;
            }
        }
    }

    return neighbors;
}

/// Count neighbors matching a condition using a predicate function
pub fn countNeighborsWhereFn(
    grid: [][]const u8,
    y: usize,
    x: usize,
    predicate: *const fn (u8) bool,
) u8 {
    const h: isize = @intCast(grid.len);
    const w: isize = @intCast(grid[0].len);
    var neighbors: u8 = 0;

    for (DIRS) |d| {
        const ny = @as(isize, @intCast(y)) + d[0];
        const nx = @as(isize, @intCast(x)) + d[1];

        if (ny >= 0 and ny < h and nx >= 0 and nx < w) {
            if (predicate(grid[@intCast(ny)][@intCast(nx)])) {
                neighbors += 1;
            }
        }
    }

    return neighbors;
}

/// Read grid from input data (splits by newlines)
pub fn readGrid(allocator: std.mem.Allocator, data: []const u8) !std.ArrayList([]u8) {
    var grid = try std.ArrayList([]u8).initCapacity(allocator, 100);
    var lines = std.mem.tokenizeScalar(u8, data, '\n');

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;
        const mutable_line = try allocator.dupe(u8, trimmed);
        try grid.append(allocator, mutable_line);
    }

    return grid;
}
