const std = @import("std");
const day4 = @import("advent_of_zig_2025").day4;

test "day4 example" {
    var rows = [_][]const u8{
        "..@@.@@@@.",
        "@@@.@.@.@@",
        "@@@@@.@.@@",
        "@.@@@@..@.",
        "@@.@@@@.@@",
        ".@@@@@@@.@",
        ".@.@.@.@@@",
        "@.@@@.@@@@",
        ".@@@@@@@@.",
        "@.@.@@@.@.",
    };
    const expected: usize = 13;
    const result = day4.solvePart1(rows[0..]);

    try std.testing.expectEqual(expected, result);
}

