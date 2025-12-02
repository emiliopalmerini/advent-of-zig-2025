const std = @import("std");
const day2 = @import("advent_of_zig_2025").day2;

test "11 and 22 are invalid IDs (part 1)" {
    try std.testing.expect(day2.isInvalidIdPart1(11));
    try std.testing.expect(day2.isInvalidIdPart1(22));
}

test "99 is an invalid ID (part 1)" {
    try std.testing.expect(day2.isInvalidIdPart1(99));
}

test "1010 is an invalid ID (part 1)" {
    try std.testing.expect(day2.isInvalidIdPart1(1010));
}

test "1188511885 is an invalid ID (part 1)" {
    try std.testing.expect(day2.isInvalidIdPart1(1188511885));
}

test "222222 is an invalid ID (part 1)" {
    try std.testing.expect(day2.isInvalidIdPart1(222222));
}

test "1698522-1698528 contains no invalid IDs (part 1)" {
    var i: u64 = 1698522;
    while (i <= 1698528) : (i += 1) {
        try std.testing.expect(!day2.isInvalidIdPart1(i));
    }
}

test "446446 is an invalid ID (part 1)" {
    try std.testing.expect(day2.isInvalidIdPart1(446446));
}

test "38593859 is an invalid ID (part 1)" {
    try std.testing.expect(day2.isInvalidIdPart1(38593859));
}

test "part one example data produces 1227775554" {
    var total: u64 = 0;
    const ranges = [_][2]u64{
        .{ 11, 22 },
        .{ 95, 115 },
        .{ 998, 1012 },
        .{ 1188511880, 1188511890 },
        .{ 222220, 222224 },
        .{ 1698522, 1698528 },
        .{ 446443, 446449 },
        .{ 38593856, 38593862 },
        .{ 565653, 565659 },
        .{ 824824821, 824824827 },
        .{ 2121212118, 2121212124 },
    };

    for (ranges) |range| {
        var i = range[0];
        while (i <= range[1]) : (i += 1) {
            if (day2.isInvalidIdPart1(i)) {
                total += i;
            }
        }
    }

    try std.testing.expectEqual(total, 1227775554);
}

test "part two example data produces 4174379265" {
    var total: u64 = 0;
    const ranges = [_][2]u64{
        .{ 11, 22 },
        .{ 95, 115 },
        .{ 998, 1012 },
        .{ 1188511880, 1188511890 },
        .{ 222220, 222224 },
        .{ 1698522, 1698528 },
        .{ 446443, 446449 },
        .{ 38593856, 38593862 },
        .{ 565653, 565659 },
        .{ 824824821, 824824827 },
        .{ 2121212118, 2121212124 },
    };

    for (ranges) |range| {
        var i = range[0];
        while (i <= range[1]) : (i += 1) {
            if (day2.isInvalidIdPart2(i)) {
                total += i;
            }
        }
    }

    try std.testing.expectEqual(total, 4174379265);
}
