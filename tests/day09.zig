const std = @import("std");
const day9 = @import("advent_of_zig_2025").day9;

test "Part 1: Example from problem statement" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        "7,1\n" ++
        "11,1\n" ++
        "11,7\n" ++
        "9,7\n" ++
        "9,5\n" ++
        "2,5\n" ++
        "2,3\n" ++
        "7,3\n";

    const result = try day9.Day9Solution.solvePart1Impl(undefined, allocator);
    try std.testing.expectEqual(@as(u64, 50), result);
}
