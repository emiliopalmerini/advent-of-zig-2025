const std = @import("std");
const day5 = @import("advent_of_zig_2025").day5;

test "Part 1: In the example, 3 of the available ingredient IDs are fresh" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
    ;

    const result = try day5.solvePart1(allocator, input);
    try std.testing.expectEqual(@as(u64, 3), result);
}

test "Part 1: Ingredient ID 5 is fresh because it falls into range 3-5" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\3-5
        \\
        \\5
    ;

    const result = try day5.solvePart1(allocator, input);
    try std.testing.expectEqual(@as(u64, 1), result);
}

test "Part 1: Ingredient ID 1 is spoiled because it does not fall into any range" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\3-5
        \\
        \\1
    ;

    const result = try day5.solvePart1(allocator, input);
    try std.testing.expectEqual(@as(u64, 0), result);
}

test "Part 2: The fresh ingredient ID ranges consider a total of 14 ingredient IDs to be fresh" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
    ;

    const result = try day5.solvePart2(allocator, input);
    try std.testing.expectEqual(@as(u32, 14), result);
}

test "Part 2: A single range 5-8 makes 4 ingredient IDs fresh" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\5-8
    ;

    const result = try day5.solvePart2(allocator, input);
    try std.testing.expectEqual(@as(u32, 4), result);
}
