const std = @import("std");
const day10 = @import("advent_of_zig_2025").day10;

test "Part 1: Example from problem statement" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = "";

    const result = try day10.Day10Solution.solvePart1Impl(undefined, allocator);
    try std.testing.expectEqual(@as(u64, 0), result);
}
