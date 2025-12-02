const std = @import("std");

/// Reads embedded file data as a string
pub fn readEmbedded(comptime file_path: []const u8) []const u8 {
    return @embedFile(file_path);
}

/// Reads file into memory using provided allocator
pub fn readFile(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    _ = try file.readAll(buffer);

    return buffer;
}
