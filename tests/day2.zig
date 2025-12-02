const std = @import("std");
const aoz = @import("advent_of_zig_2025");

test "11-22 has two invalid IDs, 11 and 22" {
    const allocator = std.testing.allocator;

    const start = 11;
    const stop = 22;

    const result = try aoz.invalidIdCount(allocator, start, stop);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 2), result.len);
    try std.testing.expectEqual(@as(u64, 11), result[0]);
    try std.testing.expectEqual(@as(u64, 22), result[1]);
}

test "95-115 has one invalid ID, 99" {
    const allocator = std.testing.allocator;

    const result = try aoz.invalidIdCount(allocator, 95, 115);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqual(@as(u64, 99), result[0]);
}

test "998-1012 has one invalid ID, 1010" {
    const allocator = std.testing.allocator;

    const result = try aoz.invalidIdCount(allocator, 998, 1012);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqual(@as(u64, 1010), result[0]);
}

test "1188511880-1188511890 has one invalid ID, 1188511885" {
    const allocator = std.testing.allocator;

    const result = try aoz.invalidIdCount(allocator, 1188511880, 1188511890);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqual(@as(u64, 1188511885), result[0]);
}

test "222220-222224 has one invalid ID, 222222" {
    const allocator = std.testing.allocator;

    const result = try aoz.invalidIdCount(allocator, 222220, 222224);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqual(@as(u64, 222222), result[0]);
}

test "1698522-1698528 contains no invalid IDs" {
    const allocator = std.testing.allocator;

    const result = try aoz.invalidIdCount(allocator, 1698522, 1698528);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "446443-446449 has one invalid ID, 446446" {
    const allocator = std.testing.allocator;

    const result = try aoz.invalidIdCount(allocator, 446443, 446449);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqual(@as(u64, 446446), result[0]);
}

test "38593856-38593862 has one invalid ID, 38593859" {
    const allocator = std.testing.allocator;

    const result = try aoz.invalidIdCount(allocator, 38593856, 38593862);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 1), result.len);
    try std.testing.expectEqual(@as(u64, 38593859), result[0]);
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
            if (aoz.isInvalidIdPart1(i)) {
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
            if (aoz.isInvalidIdPart2(i)) {
                total += i;
            }
        }
    }

    try std.testing.expectEqual(total, 4174379265);
}
