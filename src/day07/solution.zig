const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

/// Parse grid from input and return (grid, height, width)
/// Caller is responsible for freeing the grid array via allocator.free(grid)
fn parseGrid(allocator: std.mem.Allocator, input: []const u8) !struct { grid: [][]const u8, height: usize, width: usize } {
    var lines = try u.input.readLines(allocator, input);
    defer lines.deinit(allocator);

    if (lines.items.len == 0) {
        return .{ .grid = &[_][]const u8{}, .height = 0, .width = 0 };
    }

    //TODO: I'm not shure I understand this. Duplicate the items array so we can safely deinit the ArrayList
    const grid = try allocator.dupe([]const u8, lines.items);
    const height = grid.len;
    const width = if (height > 0) grid[0].len else 0;

    return .{ .grid = grid, .height = height, .width = width };
}

// Direction constants
const DOWN = [2]isize{ 1, 0 };
const LEFT = [2]isize{ 0, -1 };
const RIGHT = [2]isize{ 0, 1 };

// Ok, this is a Depth-first-search, I have to go https://en.wikipedia.org/wiki/Depth-first_search
// and the input is a literal tree. LOL
pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const parsed = try parseGrid(allocator, input);
    defer allocator.free(parsed.grid);
    
    const grid = parsed.grid;
    const height = parsed.height;
    const width = parsed.width;

    if (height == 0) return 0;

    const start = u.grid.findCell(grid, 'S') orelse return 0;
    const start_x = start.x;
    const start_y = start.y;

    var visited = try allocator.alloc([]bool, height);
    defer allocator.free(visited);

    for (visited) |*row| {
        row.* = try allocator.alloc(bool, width);
        @memset(row.*, false);
    }
    defer {
        for (visited) |row| {
            allocator.free(row);
        }
    }

    var queue = try std.ArrayList(u.grid.Point).initCapacity(allocator, 100);
    defer queue.deinit(allocator);

    // Start beam just below 'S'
    if (start_y + 1 < height) {
        try queue.append(allocator, .{ .x = start_x, .y = start_y + 1 });
    }

    var split_count: u64 = 0;

    // Process beams using DFS
    while (queue.items.len > 0) {
        const beam = queue.pop().?; // Nice sintax for orelse null: I we will always had something to pop
        
        // Raycast downward from this beam's starting position until hitting a splitter
        if (u.grid.raycast(grid, beam, DOWN, height, width, '^')) |splitter| {
            // Hit a splitter
            if (!visited[splitter.y][splitter.x]) {
                visited[splitter.y][splitter.x] = true;
                split_count += 1;

                // Emit left beam from splitter
                if (u.grid.movePoint(splitter, LEFT, height, width)) |left_beam| {
                    try queue.append(allocator, left_beam);
                }

                // Emit right beam from splitter
                if (u.grid.movePoint(splitter, RIGHT, height, width)) |right_beam| {
                    try queue.append(allocator, right_beam);
                }
            }
        }
    }

    return split_count;
}

// I have to find some way to memorize the path tanken. 
// This seems a bottom up problem.
//https://en.wikipedia.org/wiki/Topological_sorting: I don't want to wrap my head
//around Parallel algorithms, so... TODO: re-read that
pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    const parsed = try parseGrid(allocator, input);
    defer allocator.free(parsed.grid);
    
    const grid = parsed.grid;
    const height = parsed.height;
    const width = parsed.width;

    if (height == 0) return 0;

    // Each splitter in a different timeline counts separately, so the answer can explode.
    // I'll use a memo grid of ?u64 (nullable). null = not computed yet, a number = computed.
    var memo = try allocator.alloc([]?u64, height);
    defer allocator.free(memo);

    for (memo) |*row| {
        row.* = try allocator.alloc(?u64, width);
        @memset(row.*, null);
    }
    defer {
        for (memo) |row| {
            allocator.free(row);
        }
    }

    var y: isize = @intCast(height - 1);
    while (y >= 0) : (y -= 1) {
        const y_usize = @as(usize, @intCast(y));
        for (0..width) |x| {
            const ch = grid[y_usize][x];

            if (ch == '^') {
                // left beam: The left beam continues downward from (x-1, y)
                // The ray can:
                // 1. hit another splitter -> I use that splitter's already-computed result
                // 2. exit the grid -> That's 1 beam that "completed", count as 1
                var left_count: u64 = 0;
                if (x > 0) {
                    if (u.grid.raycast(grid, .{ .y = y_usize, .x = x - 1 }, DOWN, height, width, '^')) |splitter| {
                        left_count = memo[splitter.y][splitter.x] orelse 0;
                    } else {
                        left_count = 1;
                    }
                }

                // right beam: The right beam continues downward from (x+1, y)
                // Same logic as left branch.
                var right_count: u64 = 0;
                if (x + 1 < width) {
                    if (u.grid.raycast(grid, .{ .y = y_usize, .x = x + 1 }, DOWN, height, width, '^')) |splitter| {
                        right_count = memo[splitter.y][splitter.x] orelse 0;
                    } else {
                        right_count = 1;
                    }
                }

                // Left-branch universes: left_count
                // Right-branch universes: right_count
                // Total: left_count + right_count
                memo[y_usize][x] = left_count + right_count;
            }
        }
    }

    // I need to find the beam path that goes straight down 
    const start = u.grid.findCell(grid, 'S') orelse return 0;

    // When it hits the first splitter, I return that memo value.
    // If it never hits a splitter (exits immediately), return 0.
    if (u.grid.raycast(grid, .{ .y = start.y, .x = start.x }, DOWN, height, width, '^')) |splitter| {
        return memo[splitter.y][splitter.x] orelse 0;
    } else {
        return 0;
    }
}

pub const Day7Solution = struct {
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
        return try solvePart1(allocator, data);
    }

    fn solvePart2Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        return try solvePart2(allocator, data);
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

    const p1 = try Day7Solution.asDaySolution().solvePart1(allocator);
    const p2 = try Day7Solution.asDaySolution().solvePart2(allocator);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}
