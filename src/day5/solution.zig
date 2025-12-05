const std = @import("std");
const u = @import("utils");

const Range = struct {
    start: u64,
    end: u64,
};

fn isFresh(id: u64, ranges: []const Range) bool {
    for (ranges) |range| {
        if (id >= range.start and id <= range.end) {
            return true;
        }
    }
    return false;
}

pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    var ranges = try std.ArrayList(Range).initCapacity(allocator, 100);
    defer ranges.deinit(allocator);

    var splitted = std.mem.splitSequence(u8, input, "\n\n");
    const ranges_section = splitted.next() orelse return error.InvalidInput;
    var line_iter = std.mem.tokenizeScalar(u8, ranges_section, '\n');
    while (line_iter.next()) |line| {
        const parsed = try u.input.parseRange(line);
        try ranges.append(allocator, .{
            .start = parsed.start,
            .end = parsed.stop,
        });
    }

    const ids_section = splitted.next() orelse return error.InvalidInput;
    var ids_lines = try u.input.readLines(allocator, ids_section);
    defer ids_lines.deinit(allocator);

    var fresh_count: u64 = 0;
    for (ids_lines.items) |line| {
        const id = try std.fmt.parseInt(u64, line, 10);
        if (isFresh(id, ranges.items)) {
            fresh_count += 1;
        }
    }

    return fresh_count;
}

fn compareRanges(context: void, a: Range, b: Range) bool {
    _ = context;
    return a.start < b.start;
}

pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    var ranges = try std.ArrayList(Range).initCapacity(allocator, 100);
    defer ranges.deinit(allocator);

    var splitted = std.mem.splitSequence(u8, input, "\n\n");
    const ranges_section = splitted.next() orelse return error.InvalidInput;
    var line_iter = std.mem.tokenizeScalar(u8, ranges_section, '\n');
    while (line_iter.next()) |line| {
        const parsed = try u.input.parseRange(line);
        try ranges.append(allocator, .{
            .start = parsed.start,
            .end = parsed.stop,
        });
    }

    std.mem.sort(Range, ranges.items, {}, compareRanges);

    // Merge overlapping/adjacent ranges
    var merged = try std.ArrayList(Range).initCapacity(allocator, 100);
    defer merged.deinit(allocator);

    if (ranges.items.len > 0) {
        var current = ranges.items[0];

        for (ranges.items[1..]) |range| {
            if (range.start <= current.end + 1) {
                current.end = @max(current.end, range.end);
            } else {
                try merged.append(allocator, current);
                current = range;
            }
        }
        try merged.append(allocator, current);
    }

    var total: u64 = 0;
    for (merged.items) |range| {
        total += (range.end - range.start + 1);
    }

    return total;
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
