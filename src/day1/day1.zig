const std = @import("std");

const advent_of_zig_2025 = @import("advent_of_zig_2025");
const day1_data = @embedFile("day1.txt");

pub fn turn(start: i32, op: i32) i32 {
    return @rem((@rem((start + op), 100) + 100), 100);
}

pub fn countZeroCrossings(start: i32, op: i32) i32 {
    if (op > 0) {
        return @divFloor(start + op, 100);
    } else {
        const abs_op = -op;
        if (start == 0) {
            return @divFloor(abs_op, 100);
        } else if (abs_op < start) {
            return 0;
        } else {
            return 1 + @divFloor(abs_op - start, 100);
        }
    }
}

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ops = try std.ArrayList(i32).initCapacity(allocator, 100);
    defer ops.deinit(allocator);

    var lines = std.mem.splitSequence(u8, day1_data, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        const direction = line[0];
        const num = try std.fmt.parseInt(i32, line[1..], 10);
        const value: i32 = if (direction == 'L') -num else num;
        try ops.append(allocator, value);
    }

    var start: i32 = 50;
    var res: i32 = 0;
    for (ops.items) |value| {
        res += countZeroCrossings(start, value);
        start = turn(start, value);
    }
    std.debug.print("{}\n", .{res});
}
