const std = @import("std");

const Point = struct { y: usize, x: usize };

const DIRS = [_][2]isize{
    .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
    .{  0, -1 },             .{  0, 1 },
    .{  1, -1 }, .{  1, 0 }, .{  1, 1 },
};

fn countNeighbors(grid: [][]const u8, y: usize, x: usize) u8 {
    const h: isize = @intCast(grid.len);
    const w: isize = @intCast(grid[0].len);
    var neighbors: u8 = 0;
    
    for (DIRS) |d| {
        const ny = @as(isize, @intCast(y)) + d[0];
        const nx = @as(isize, @intCast(x)) + d[1];
        
        if (ny >= 0 and ny < h and nx >= 0 and nx < w) {
            if (grid[@intCast(ny)][@intCast(nx)] == '@') {
                neighbors += 1;
            }
        }
    }
    
    return neighbors;
}

pub fn solvePart1(grid: [][]const u8) usize {
    if (grid.len == 0) return 0;
    
    var valid_rolls: usize = 0;

    for (0..grid.len) |y| {
        for (0..grid[0].len) |x| {
            if (grid[y][x] != '@') continue;

            if (countNeighbors(grid, y, x) < 4) {
                valid_rolls += 1;
            }
        }
    }

    return valid_rolls;
}

pub fn solvePart2(allocator: std.mem.Allocator, grid: [][]u8) !usize {
    var candidates = try std.ArrayList(Point).initCapacity(allocator, 100);
    defer candidates.deinit(allocator);

    var total_removed: usize = 0;

    while (true) {
        for (0..grid.len) |y| {
            for (0..grid[0].len) |x| {
                if (grid[y][x] != '@') continue;

                const grid_const = @as([][]const u8, @ptrCast(grid));
                if (countNeighbors(grid_const, y, x) < 4) {
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

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var grid = try std.ArrayList([]u8).initCapacity(allocator, 100);

    const data = @embedFile("input.txt");
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    
    while (lines.next()) |line| {
        const mutable_line = try allocator.dupe(u8, line);
        try grid.append(allocator, mutable_line);
    }

    const p1 = solvePart1(@as([][]const u8, @ptrCast(grid.items)));
    std.debug.print("Part 1: {d}\n", .{p1});

    const p2 = try solvePart2(allocator, grid.items);
    std.debug.print("Part 2: {d}\n", .{p2});
}
