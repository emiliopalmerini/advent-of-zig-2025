const std = @import("std");

fn isInvalidIdPart1(n: u64) bool {
    var digits: [20]u8 = undefined;
    var digit_count: usize = 0;

    var x = n;
    while (true) {
        const digit: u8 = @intCast(x % 10);
        digits[digit_count] = digit;
        digit_count += 1;

        if (x < 10) break;
        x /= 10;
    }

    if (digit_count % 2 != 0) {
        return false;
    }

    if (digit_count == 0) {
        return false;
    }

    var i: usize = 0;
    while (i < digit_count / 2) : (i += 1) {
        const temp = digits[i];
        digits[i] = digits[digit_count - 1 - i];
        digits[digit_count - 1 - i] = temp;
    }

    const half = digit_count / 2;
    var j: usize = 0;
    while (j < half) : (j += 1) {
        if (digits[j] != digits[half + j]) {
            return false;
        }
    }

    return true;
}

fn isInvalidIdPart2(n: u64) bool {
    var digits: [20]u8 = undefined;
    var digit_count: usize = 0;

    var x = n;
    while (true) {
        const digit: u8 = @intCast(x % 10);
        digits[digit_count] = digit;
        digit_count += 1;

        if (x < 10) break;
        x /= 10;
    }

    if (digit_count < 2) {
        return false;
    }

    var i: usize = 0;
    while (i < digit_count / 2) : (i += 1) {
        const temp = digits[i];
        digits[i] = digits[digit_count - 1 - i];
        digits[digit_count - 1 - i] = temp;
    }

    var pattern_len: usize = 1;
    while (pattern_len <= digit_count / 2) : (pattern_len += 1) {
        if (digit_count % pattern_len != 0) {
            continue;
        }

        const repetitions = digit_count / pattern_len;
        if (repetitions < 2) {
            continue;
        }

        var matches = true;
        var k: usize = 0;
        while (k < digit_count) : (k += 1) {
            if (digits[k] != digits[k % pattern_len]) {
                matches = false;
                break;
            }
        }

        if (matches) {
            return true;
        }
    }

    return false;
}

pub fn main() !void {
    const data = @embedFile("day2.txt");
    var lines = std.mem.splitSequence(u8, data, "\n");

    var part1_total: u64 = 0;
    var part2_total: u64 = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r\n");
        if (trimmed.len == 0) continue;

        var items = std.mem.splitSequence(u8, trimmed, ",");

        while (items.next()) |entry| {
            const range_trimmed = std.mem.trim(u8, entry, " \t\r\n");
            if (range_trimmed.len == 0) continue;

            var bounds = std.mem.splitSequence(u8, range_trimmed, "-");

            const start_str = std.mem.trim(u8, bounds.next() orelse continue, " \t\r\n");
            const stop_str = std.mem.trim(u8, bounds.next() orelse continue, " \t\r\n");

            const start = try std.fmt.parseInt(u64, start_str, 10);
            const stop = try std.fmt.parseInt(u64, stop_str, 10);

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
