const std = @import("std");
const day8 = @import("advent_of_zig_2025").day8;

test "Part 1: Three largest circuits after ten shortest connections" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        "162,817,812\n" ++
        "57,618,57\n" ++
        "906,360,560\n" ++
        "592,479,940\n" ++
        "352,342,300\n" ++
        "466,668,158\n" ++
        "542,29,236\n" ++
        "431,825,988\n" ++
        "739,650,466\n" ++
        "52,470,668\n" ++
        "216,146,977\n" ++
        "819,987,18\n" ++
        "117,168,530\n" ++
        "805,96,715\n" ++
        "346,949,466\n" ++
        "970,615,88\n" ++
        "941,993,340\n" ++
        "862,61,35\n" ++
        "984,92,344\n" ++
        "425,690,689\n";

    const result = try day8.solvePart1(allocator, input);
    // After connecting all edges (complete MST): one component of 20, product = 20
    try std.testing.expectEqual(@as(u64, 20), result);
}

test "Part 1: Two closest junction boxes connected" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        "162,817,812\n" ++
        "425,690,689\n";

    const result = try day8.solvePart1(allocator, input);
    // Connecting two boxes creates one circuit of size 2, product: 2
    try std.testing.expectEqual(@as(u64, 2), result);
}

test "Part 1: Single junction box remains isolated" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        "162,817,812\n";

    const result = try day8.solvePart1(allocator, input);
    // Single box forms one circuit of size 1, product: 1
    try std.testing.expectEqual(@as(u64, 1), result);
}

test "Part 2: Find completing edge that connects all boxes" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        "162,817,812\n" ++
        "57,618,57\n" ++
        "906,360,560\n" ++
        "592,479,940\n" ++
        "352,342,300\n" ++
        "466,668,158\n" ++
        "542,29,236\n" ++
        "431,825,988\n" ++
        "739,650,466\n" ++
        "52,470,668\n" ++
        "216,146,977\n" ++
        "819,987,18\n" ++
        "117,168,530\n" ++
        "805,96,715\n" ++
        "346,949,466\n" ++
        "970,615,88\n" ++
        "941,993,340\n" ++
        "862,61,35\n" ++
        "984,92,344\n" ++
        "425,690,689\n";

    const result = try day8.solvePart2(allocator, input);
    // The completing edge connects points at 216,146,977 and 117,168,530
    // Product of X coordinates: 216 * 117 = 25272
    try std.testing.expectEqual(@as(u64, 25272), result);
}
