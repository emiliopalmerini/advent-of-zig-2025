// https://adventofcode.com/2025/day/6

const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

const Operation = enum {
    add,
    multiply,
};

const Problem = struct {
    numbers: std.ArrayList(u64),
    operation: Operation,

    fn solve(self: Problem) u64 {
        var total: u64 = undefined;
        switch (self.operation) {
            .add => {
                total = 0;
                for (self.numbers.items) |number| {
                    total += number;
                }
            },
            .multiply => {
                total = 1;
                for (self.numbers.items) |number| {
                    total *= number;
                }
            },
        }
        return total;
    }

    fn deinit(self: *Problem, allocator: std.mem.Allocator) void {
        self.numbers.deinit(allocator);
    }
};

fn findProblemBounds(
    lines: []const []const u8,
    op_col: usize,
) struct { left: usize, right: usize } {
    var left: usize = 0;
    var right: usize = lines[0].len - 1;

    var col: isize = @intCast(op_col);
    while (col > 0) {
        col -= 1;
        const c: usize = @intCast(col);
        var all_space = true;
        for (lines) |line| {
            if (c < line.len and line[c] != ' ') {
                all_space = false;
                break;
            }
        }
        if (all_space) {
            left = c + 1;
            break;
        }
    }

    col = @intCast(op_col);
    while (col < lines[0].len - 1) {
        col += 1;
        const c: usize = @intCast(col);
        var all_space = true;
        for (lines) |line| {
            if (c < line.len and line[c] != ' ') {
                all_space = false;
                break;
            }
        }
        if (all_space) {
            right = c - 1;
            break;
        }
    }

    return .{ .left = left, .right = right };
}

fn extractNumberInBounds(
    line: []const u8,
    left: usize,
    right: usize,
) !u64 {
    var found: ?usize = null;
    for (left..right + 1) |i| {
        if (i < line.len and line[i] >= '0' and line[i] <= '9') {
            found = i;
            break;
        }
    }

    if (found == null) return error.NoNumberFound;

    const fc = found.?;
    var start = fc;
    while (start > left and line[start - 1] >= '0' and
        line[start - 1] <= '9')
    {
        start -= 1;
    }

    var end = fc;
    while (end < right and end + 1 < line.len and
        line[end + 1] >= '0' and line[end + 1] <= '9')
    {
        end += 1;
    }

    return try std.fmt.parseInt(u64, line[start .. end + 1], 10);
}

fn parseColumn(
    allocator: std.mem.Allocator,
    lines: []const []const u8,
    col: usize,
) !Problem {
    var numbers = std.ArrayList(u64){};

    const bounds = findProblemBounds(lines, col);
    const num_rows = lines.len - 1;

    for (0..num_rows) |row| {
        const num = extractNumberInBounds(
            lines[row],
            bounds.left,
            bounds.right,
        ) catch continue;
        try numbers.append(allocator, num);
    }

    const op_char = lines[num_rows][col];
    const operation = switch (op_char) {
        '*' => Operation.multiply,
        '+' => Operation.add,
        else => return error.InvalidOperation,
    };

    return .{ .numbers = numbers, .operation = operation };
}

fn parseLines(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList([]const u8) {
    var lines = try std.ArrayList([]const u8).initCapacity(allocator, 100);
    errdefer lines.deinit(allocator);
    var line_iter = std.mem.tokenizeScalar(u8, input, '\n');

    while (line_iter.next()) |line| {
        try lines.append(allocator, line);
    }

    return lines;
}

pub fn solvePart1(
    allocator: std.mem.Allocator,
    input: []const u8,
) !u64 {
    var lines = try parseLines(allocator, input);
    defer lines.deinit(allocator);

    var total: u64 = 0;
    const operator_row = lines.items[lines.items.len - 1];

    for (0..operator_row.len) |col_idx| {
        const char = operator_row[col_idx];
        if (char != '*' and char != '+') continue;

        var problem = try parseColumn(allocator, lines.items, col_idx);
        defer problem.deinit(allocator);
        const result = problem.solve();
        total += result;
    }

    return total;
}

fn parseColumnPart2(
    allocator: std.mem.Allocator,
    lines: []const []const u8,
    col: usize,
) !Problem {
    const bounds = findProblemBounds(lines, col);
    var numbers = std.ArrayList(u64){};
    const num_rows = lines.len - 1;

    var c: isize = @intCast(bounds.right);
    while (c >= @as(isize, @intCast(bounds.left))) : (c -= 1) {
        const col_idx: usize = @intCast(c);

        var digits = try std.ArrayList(u8).initCapacity(allocator, 10);
        defer digits.deinit(allocator);

        for (0..num_rows) |row| {
            if (col_idx < lines[row].len and
                lines[row][col_idx] >= '0' and
                lines[row][col_idx] <= '9')
            {
                try digits.append(allocator, lines[row][col_idx]);
            }
        }

        if (digits.items.len > 0) {
            const num = try std.fmt.parseInt(u64, digits.items, 10);
            try numbers.append(allocator, num);
        }
    }

    const op_char = lines[num_rows][col];
    const operation = switch (op_char) {
        '*' => Operation.multiply,
        '+' => Operation.add,
        else => return error.InvalidOperation,
    };

    return .{ .numbers = numbers, .operation = operation };
}

pub fn solvePart2(
    allocator: std.mem.Allocator,
    input: []const u8,
) !u64 {
    var lines = try parseLines(allocator, input);
    defer lines.deinit(allocator);

    var total: u64 = 0;
    const operator_row = lines.items[lines.items.len - 1];

    for (0..operator_row.len) |col_idx| {
        const char = operator_row[col_idx];
        if (char != '*' and char != '+') continue;

        var problem = try parseColumnPart2(allocator, lines.items, col_idx);
        defer problem.deinit(allocator);
        const result = problem.solve();
        total += result;
    }

    return total;
}

pub const Day6Solution = struct {
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
        return u.solution.measureMetrics(allocator, solvePart1Impl, solvePart2Impl);
    }
};
