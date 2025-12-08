const std = @import("std");

pub const Point = struct { y: usize, x: usize };

pub const Point2D = struct {
    x: i64,
    y: i64,
};

pub const Point3D = struct {
    x: i64,
    y: i64,
    z: i64,
};

/// Protocol: Any type with x, y, z fields (i64) can be used as Point3DLike
/// This allows working with Point3D and any extension of it (e.g., with additional fields like id)
pub const Point3DLike = struct {
    pub fn isValid(comptime T: type) void {
        _ = T;
        // Compile-time verification happens at call site
        // This serves as documentation of the required interface
    }
};

/// Weighted edge for graph algorithms (MST, shortest path, etc.)
/// u, v: vertex indices (typically into an array or graph)
/// weight: edge weight (typically distance, cost, or other metric)
pub const Edge = struct {
    u: usize,
    v: usize,
    weight: i64,
};

/// Calculate squared 3D Euclidean distance between two points
/// Reference: https://en.wikipedia.org/wiki/Euclidean_distance#Higher_dimensions
/// 
/// Type constraint: T must have x: i64, y: i64, z: i64 fields (Point3DLike)
/// Examples: Point3D, or any struct with those fields like Point3D + id
pub fn euclideanDistance3DSq(comptime T: type, p1: T, p2: T) i64 {
    // Verify that T has the required fields at compile-time
    comptime {
        _ = @as(i64, p1.x);
        _ = @as(i64, p1.y);
        _ = @as(i64, p1.z);
    }
    
    const dx = p2.x - p1.x;
    const dy = p2.y - p1.y;
    const dz = p2.z - p1.z;
    return dx * dx + dy * dy + dz * dz;
}

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

/// Check if a coordinate is within grid bounds
pub fn inBounds(y: isize, x: isize, height: usize, width: usize) bool {
    const h: isize = @intCast(height);
    const w: isize = @intCast(width);
    return y >= 0 and y < h and x >= 0 and x < w;
}

/// Find the first cell matching a target character
pub fn findCell(grid: [][]const u8, target: u8) ?Point {
    for (grid, 0..) |row, y| {
        for (row, 0..) |ch, x| {
            if (ch == target) {
                return .{ .y = y, .x = x };
            }
        }
    }
    return null;
}

/// Apply a direction to a point
/// Returns the new point or null if it would be out of bounds
pub fn movePoint(point: Point, direction: [2]isize, height: usize, width: usize) ?Point {
    const new_y: isize = @intCast(point.y);
    const new_x: isize = @intCast(point.x);
    const y = new_y + direction[0];
    const x = new_x + direction[1];
    
    if (!inBounds(y, x, height, width)) {
        return null;
    }
    
    return .{ .y = @intCast(y), .x = @intCast(x) };
}

/// Raycast from a starting position in a given direction until hitting a target or exiting grid
/// Returns the position of the first target hit, or null if exiting the grid
pub fn raycast(grid: [][]const u8, start: Point, direction: [2]isize, height: usize, width: usize, target: u8) ?Point {
    var pos: [2]isize = .{ @intCast(start.y), @intCast(start.x) };
    
    while (true) {
        pos[0] += direction[0];
        pos[1] += direction[1];
        
        if (!inBounds(pos[0], pos[1], height, width)) {
            return null;
        }
        
        const y: usize = @intCast(pos[0]);
        const x: usize = @intCast(pos[1]);
        
        if (grid[y][x] == target) {
            return .{ .y = y, .x = x };
        }
    }
}
