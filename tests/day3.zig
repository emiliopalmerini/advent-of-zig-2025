const std = @import("std");
const day3 = @import("advent_of_zig_2025").day3;

test "In 987654321111111, you can make the largest joltage possible, 98, by turning on the first two batteries" {
    try std.testing.expectEqual(@as(u32, 98),day3.largestBatteries(987654321111111));
}

test "In 811111111111119, you can make the largest joltage possible by turning on the batteries labeled 8 and 9, producing 89 jolts" {
    try std.testing.expectEqual(@as(u32, 89),day3.largestBatteries(811111111111119));
}

test "In 234234234234278, you can make 78 by turning on the last two batteries (marked 7 and 8)" {
    try std.testing.expectEqual(@as(u32, 78),day3.largestBatteries(234234234234278));
}

test "In 818181911112111, the largest joltage you can produce is 92" {
    try std.testing.expectEqual(@as(u32, 92),day3.largestBatteries(818181911112111));
}
