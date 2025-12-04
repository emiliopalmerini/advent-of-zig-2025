const std = @import("std");
const advent = @import("advent_of_zig_2025");

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <day> [part]\n", .{args[0]});
        std.debug.print("Example: {s} 1\n", .{args[0]});
        return;
    }

    const day = std.fmt.parseInt(usize, args[1], 10) catch {
        std.debug.print("Error: Invalid day number\n", .{});
        return;
    };

    switch (day) {
        1 => try advent.day1.main(),
        2 => try advent.day2.main(),
        3 => try advent.day3.main(),
        4 => try advent.day4.main(),
        5 => try advent.day5.main(),
        else => std.debug.print("Day {d} not implemented yet\n", .{day}),
    }
}
