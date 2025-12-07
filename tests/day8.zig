const std = @import("std");
const day8 = @import("advent_of_zig_2025").day8;

test "Part 1: placeholder test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = "";

    const result = try day8.solvePart1(allocator, input);
    try std.testing.expectEqual(@as(u64, 0), result);
}

test "Part 2: placeholder test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = "";

    const result = try day8.solvePart2(allocator, input);
    try std.testing.expectEqual(@as(u64, 0), result);
}
