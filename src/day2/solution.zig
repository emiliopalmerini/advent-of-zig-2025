const std = @import("std");
const u = @import("utils");

pub fn isInvalidIdPart1(n: u64) bool {
    var buffer: [20]u8 = undefined;
    const digits = u.input.extractDigits(n, &buffer);
    if (digits.len % 2 != 0) return false;
    
    const half = digits.len / 2;
    return std.mem.eql(u8, digits[0..half], digits[half..]);
}

pub fn isInvalidIdPart2(n: u64) bool {
    var buffer: [20]u8 = undefined;
    const digits = u.input.extractDigits(n, &buffer);

    if (digits.len < 2) return false;

    var pattern_len: usize = 1;
    outer: while (pattern_len <= digits.len / 2) : (pattern_len += 1) {
        if (digits.len % pattern_len != 0) continue;

        for (digits, 0..) |digit, i| {
            if (digit != digits[i % pattern_len]) continue :outer;
        }
        return true;
    }
    return false;
}

pub fn main() !void {
    const data = @embedFile("input.txt");
    var lines = std.mem.tokenizeScalar(u8, data, '\n');

    var part1_total: u64 = 0;
    var part2_total: u64 = 0;

    while (lines.next()) |line| {
        var items = std.mem.tokenizeScalar(u8, line, ',');

        while (items.next()) |entry| {
            const range = u.input.parseRange(entry) catch continue;
            const start = range.start;
            const stop = range.stop;

            var i = start;
            while (i <= stop) : (i += 1) {
                if (isInvalidIdPart1(i)) {
                    part1_total += i;
                }
                if (isInvalidIdPart2(i)) {
                    part2_total += i;
                }
            }
        }
    }

    std.debug.print("Part 1: {d}\n", .{part1_total});
    std.debug.print("Part 2: {d}\n", .{part2_total});
}
