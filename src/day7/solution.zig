const std = @import("std");
const u = @import("utils");

pub fn solvePart1( allocator: std.mem.Allocator, input: []const u8,) !u128 {
    _ = allocator;
    _ = input;
    return 0;
}

pub fn solvePart2( allocator: std.mem.Allocator, input: []const u8,) !u128 {
    _ = allocator;
    _ = input;
    return 0;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = @embedFile("input.txt");

    const p1 = try solvePart1(allocator, data);
    std.debug.print("Part 1: {d}\n", .{p1});
    const p2 = try solvePart2(allocator, data);
    std.debug.print("Part 2: {d}\n", .{p2});
}
