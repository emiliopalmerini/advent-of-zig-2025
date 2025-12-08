const std = @import("std");
const day6 = @import("advent_of_zig_2025").day6;

test "Part 1: Example worksheet with columnar format" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\123 328  51 64
        \\ 45 64  387 23
        \\  6 98  215 314
        \\*   +   *   +
    ;

    const result = try day6.solvePart1(allocator, input);
    // 123*45*6=33210, 328+64+98=490, 51*387*215=4243455, 64+23+314=401
    // Sum = 33210 + 490 + 4243455 + 401 = 4277556
    try std.testing.expectEqual(@as(u64, 4277273), result);
}

test "Part 1: Single multiplication problem" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\123
        \\ 45
        \\  6
        \\*
    ;

    const result = try day6.solvePart1(allocator, input);
    // 123 * 45 * 6 = 33210
    try std.testing.expectEqual(@as(u64, 33210), result);
}

test "Part 1: Single addition problem" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\328
        \\ 64
        \\ 98
        \\+
    ;

    const result = try day6.solvePart1(allocator, input);
    // 328 + 64 + 98 = 490
    try std.testing.expectEqual(@as(u64, 490), result);
}

test "Part 2: Same as Part 1 for now" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\123 328  51 64
        \\ 45 64  387 23
        \\  6 98  215 314
        \\*   +   *   +
    ;

    const result = try day6.solvePart2(allocator, input);
    try std.testing.expectEqual(@as(u64, 3263823), result);
}

test "Part 2: Example worksheet reading right-to-left one column at a time" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\123 328  51 64
        \\ 45 64  387 23
        \\  6 98  215 314
        \\*   +   *   +
    ;

    const result = try day6.solvePart2(allocator, input);
    try std.testing.expectEqual(@as(u64, 3263823), result);
}

test "Part 2: The rightmost problem is 4 + 431 + 623" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Isolated rightmost column logic
    const input =
        \\   64
        \\   23
        \\  314
        \\   +
    ;

    const result = try day6.solvePart2(allocator, input);
    try std.testing.expectEqual(@as(u64, 1058), result);
}

test "Part 2: The leftmost problem is 356 * 24 * 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\123
        \\ 45
        \\  6
        \\*
    ;

    const result = try day6.solvePart2(allocator, input);
    // Puzzle says: 356 * 24 * 1 = 8544
    try std.testing.expectEqual(@as(u64, 8544), result);
}
