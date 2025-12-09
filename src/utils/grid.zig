const std = @import("std");
const geometry = @import("geometry.zig");

/// All 8 cardinal and diagonal directions
pub const DIRS = [_][2]isize{
    .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
    .{  0, -1 },             .{  0, 1 },
    .{  1, -1 }, .{  1, 0 }, .{  1, 1 },
};

/// Check if a coordinate is within grid bounds
pub fn inBounds(y: isize, x: isize, height: usize, width: usize) bool {
    const h: isize = @intCast(height);
    const w: isize = @intCast(width);
    return y >= 0 and y < h and x >= 0 and x < w;
}

/// Read grid from input data (splits by newlines)
pub fn readGrid(allocator: std.mem.Allocator, data: []const u8) !std.ArrayList([]u8) {
    var grid_list = try std.ArrayList([]u8).initCapacity(allocator, 100);
    var lines = std.mem.tokenizeScalar(u8, data, '\n');

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;
        const mutable_line = try allocator.dupe(u8, trimmed);
        try grid_list.append(allocator, mutable_line);
    }

    return grid_list;
}

/// Count neighbors matching a condition
pub fn countNeighborsWhere(
    grid_data: [][]const u8,
    y: usize,
    x: usize,
    target: u8,
) u8 {
    const h: isize = @intCast(grid_data.len);
    const w: isize = @intCast(grid_data[0].len);
    const yc: isize = @intCast(y);
    const xc: isize = @intCast(x);
    var neighbors: u8 = 0;

    for (DIRS) |d| {
        const ny = yc + d[0];
        const nx = xc + d[1];

        if (ny >= 0 and ny < h and nx >= 0 and nx < w) {
            if (grid_data[@intCast(ny)][@intCast(nx)] == target) {
                neighbors += 1;
            }
        }
    }

    return neighbors;
}

/// Find the first cell matching a target character
pub fn findCell(grid_data: [][]const u8, target: u8) ?geometry.Point {
    for (grid_data, 0..) |row, y| {
        for (row, 0..) |ch, x| {
            if (ch == target) {
                return .{ .y = @intCast(y), .x = @intCast(x) };  // usize → i64 cast needed for loop indices
            }
        }
    }
    return null;
}

/// Apply a direction to a point
/// Returns the new point or null if it would be out of bounds
pub fn movePoint(point: geometry.Point, direction: [2]isize, height: usize, width: usize) ?geometry.Point {
    const y = point.y + @as(i64, @intCast(direction[0]));
    const x = point.x + @as(i64, @intCast(direction[1]));

    if (!inBounds(@intCast(y), @intCast(x), height, width)) {
        return null;
    }

    return .{ .y = y, .x = x };
}

/// Raycast from a starting position in a given direction until hitting a target or exiting grid
/// Returns the position of the first target hit, or null if exiting the grid
pub fn raycast(grid_data: [][]const u8, start: geometry.Point, direction: [2]isize, height: usize, width: usize, target: u8) ?geometry.Point {
    var y = start.y;
    var x = start.x;

    while (true) {
        y += @as(i64, @intCast(direction[0]));
        x += @as(i64, @intCast(direction[1]));

        if (!inBounds(@intCast(y), @intCast(x), height, width)) {
            return null;
        }

        const uy: usize = @intCast(y);
        const ux: usize = @intCast(x);

        if (grid_data[uy][ux] == target) {
            return .{ .y = y, .x = x };
        }
    }
}
