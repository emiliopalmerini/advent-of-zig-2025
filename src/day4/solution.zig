const std = @import("std");
const u = @import("utils");

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

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = @embedFile("input.txt");
    const grid = try u.grid.readGrid(allocator, data);

    const p1 = solvePart1(@as([][]const u8, @ptrCast(grid.items)));
    std.debug.print("Part 1: {d}\n", .{p1});

    const p2 = try solvePart2(allocator, grid.items);
    std.debug.print("Part 2: {d}\n", .{p2});
}
