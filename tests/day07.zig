const std = @import("std");
const day7 = @import("advent_of_zig_2025").day7;

test "Part 1: Tachyon manifold beam splitter - 21 total splits" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        ".......S.......\n" ++
        "...............\n" ++
        ".......^.......\n" ++
        "...............\n" ++
        "......^.^......\n" ++
        "...............\n" ++
        ".....^.^.^.....\n" ++
        "...............\n" ++
        "....^.^...^....\n" ++
        "...............\n" ++
        "...^.^...^.^...\n" ++
        "...............\n" ++
        "..^...^.....^..\n" ++
        "...............\n" ++
        ".^.^.^.^.^...^.\n" ++
        "...............\n";

    const result = try day7.solvePart1(allocator, input);
    // The example shows the beam is split a total of 21 times
    try std.testing.expectEqual(@as(u64, 21), result);
}

test "Part 1: Beam extends downward from S until it reaches the first splitter" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        ".S.\n" ++
        "...\n" ++
        ".^.\n" ++
        "...\n";

    const result = try day7.solvePart1(allocator, input);
    try std.testing.expectEqual(@as(u64, 1), result);
}

test "Part 1: Original beam stops, two new beams are emitted from the splitter" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        ".......S.......\n" ++
        "...............\n" ++
        ".......^.......\n" ++
        "...............\n" ++
        "......^.^......\n" ++
        "...............\n";

    const result = try day7.solvePart1(allocator, input);
    // First splitter creates left and right beams that hit two more splitters
    try std.testing.expectEqual(@as(u64, 3), result);
}

test "Part 1: Two splitters dumping tachyons into the same place between them" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        ".......S.......\n" ++
        "...............\n" ++
        ".......^.......\n" ++
        "...............\n" ++
        "......^.^......\n" ++
        "...............\n" ++
        ".....^.^.^.....\n" ++
        "...............\n";

    const result = try day7.solvePart1(allocator, input);
    // Multiple splits creating converging beams
    try std.testing.expectEqual(@as(u64, 6), result);
}

test "Part 2: Tachyon timeline counting - 40 distinct timelines" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        ".......S.......\n" ++
        "...............\n" ++
        ".......^.......\n" ++
        "...............\n" ++
        "......^.^......\n" ++
        "...............\n" ++
        ".....^.^.^.....\n" ++
        "...............\n" ++
        "....^.^...^....\n" ++
        "...............\n" ++
        "...^.^...^.^...\n" ++
        "...............\n" ++
        "..^...^.....^..\n" ++
        "...............\n" ++
        ".^.^.^.^.^...^.\n" ++
        "...............\n";

    const result = try day7.solvePart2(allocator, input);
    // Multiple distinct timelines based on left/right choices at each splitter
    try std.testing.expectEqual(@as(u64, 40), result);
}

test "Part 2: Single splitter creates multiple timelines" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        ".......S.......\n" ++
        "...............\n" ++
        ".......^.......\n" ++
        "...............\n" ++
        "......^.^......\n" ++
        "...............\n";

    const result = try day7.solvePart2(allocator, input);
    // One splitter with multiple downstream positions creates 4 timelines
    try std.testing.expectEqual(@as(u64, 4), result);
}
