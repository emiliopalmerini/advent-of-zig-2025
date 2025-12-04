const std = @import("std");

/// Parse a range string in the format "start-stop" and return both values
pub fn parseRange(s: []const u8) !struct { start: u64, stop: u64 } {
    var parts = std.mem.tokenizeScalar(u8, s, '-');
    const start_str = parts.next() orelse return error.InvalidRange;
    const stop_str = parts.next() orelse return error.InvalidRange;

    const start = try std.fmt.parseInt(u64, start_str, 10);
    const stop = try std.fmt.parseInt(u64, stop_str, 10);

    return .{ .start = start, .stop = stop };
}

/// Parse a range string and return just the start value
pub fn parseRangeStart(s: []const u8) !u64 {
    const range = try parseRange(s);
    return range.start;
}

/// Parse a range string and return just the stop value
pub fn parseRangeStop(s: []const u8) !u64 {
    const range = try parseRange(s);
    return range.stop;
}

/// Extract digits from a number into a buffer and return the digit slice
pub fn extractDigits(n: u64, buffer: *[20]u8) []u8 {
    if (n == 0) {
        buffer[0] = 0;
        return buffer[0..1];
    }

    var num = n;
    var pos: usize = 0;

    while (num > 0) : (pos += 1) {
        buffer[pos] = @intCast(num % 10);
        num /= 10;
    }

    const slice = buffer[0..pos];
    std.mem.reverse(u8, slice);
    return slice;
}

/// Parse integer with optional prefix (e.g., "L10" -> (-10), "R10" -> (+10))
pub fn parseIntWithPrefix(
    s: []const u8,
    positive_prefix: u8,
    negative_prefix: u8,
) !i32 {
    if (s.len < 2) return error.InvalidFormat;

    const prefix = s[0];
    const num = try std.fmt.parseInt(i32, s[1..], 10);

    return if (prefix == positive_prefix) num else if (prefix == negative_prefix) -num else error.InvalidPrefix;
}

/// Tokenize a string by a delimiter and collect results into ArrayList
pub fn tokenizeToList(
    allocator: std.mem.Allocator,
    s: []const u8,
    delimiter: u8,
) !std.ArrayList([]const u8) {
    var result = try std.ArrayList([]const u8).initCapacity(allocator, 10);
    var tokens = std.mem.tokenizeScalar(u8, s, delimiter);

    while (tokens.next()) |token| {
        try result.append(allocator, token);
    }

    return result;
}

/// Trim whitespace from all sides and skip empty lines
pub fn trimLine(line: []const u8) []const u8 {
    return std.mem.trim(u8, line, " \t\r\n");
}

/// Split lines from data and return non-empty trimmed lines
pub fn readLines(allocator: std.mem.Allocator, data: []const u8) !std.ArrayList([]const u8) {
    var lines = try std.ArrayList([]const u8).initCapacity(allocator, 100);
    var line_iter = std.mem.tokenizeScalar(u8, data, '\n');

    while (line_iter.next()) |line| {
        const trimmed = trimLine(line);
        if (trimmed.len > 0) {
            try lines.append(allocator, trimmed);
        }
    }

    return lines;
}
