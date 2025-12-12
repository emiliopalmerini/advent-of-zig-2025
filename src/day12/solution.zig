const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

fn parseShapes(_: std.mem.Allocator, input: []const u8) ![6]usize {
    var cell_counts: [6]usize = .{ 0, 0, 0, 0, 0, 0 };
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var current_shape: ?usize = null;

    while (lines.next()) |line| {
        const trimmed = u.parse.trimLine(line);
        if (trimmed.len == 0) break;

        if (std.mem.indexOfScalar(u8, trimmed, ':')) |idx| {
            current_shape = std.fmt.parseInt(usize, trimmed[0..idx], 10) catch null;
        } else if (current_shape) |shape_idx| {
            if (shape_idx < 6) {
                for (trimmed) |ch| {
                    if (ch == '#') cell_counts[shape_idx] += 1;
                }
            }
        }
    }

    return cell_counts;
}

fn solvePart1Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
    const shape_cells = try parseShapes(allocator, data);

    var blank_pos: usize = 0;
    for (data, 0..) |ch, i| {
        if (ch == '\n') {
            if (i + 1 < data.len and data[i + 1] == '\n') {
                blank_pos = i + 1;
                break;
            }
        }
    }

    var lines = std.mem.tokenizeScalar(u8, data[blank_pos..], '\n');
    var count: u64 = 0;

    while (lines.next()) |line| {
        const trimmed = u.parse.trimLine(line);
        if (trimmed.len == 0) continue;

        if (std.mem.indexOfScalar(u8, trimmed, 'x')) |x_idx| {
            const width = std.fmt.parseInt(usize, trimmed[0..x_idx], 10) catch continue;
            const rest = trimmed[x_idx + 1 ..];

            if (std.mem.indexOfScalar(u8, rest, ':')) |idx| {
                const height = std.fmt.parseInt(usize, rest[0..idx], 10) catch continue;
                const counts_str = u.parse.trimLine(rest[idx + 1 ..]);

                var counts = try u.parse.tokenizeToList(allocator, counts_str, ' ');
                defer counts.deinit(allocator);

                var total_cells: usize = 0;
                var num_pieces: usize = 0;
                for (counts.items, 0..) |count_str, i| {
                    if (i >= 6) break;
                    const shape_count = std.fmt.parseInt(usize, count_str, 10) catch 0;
                    total_cells += shape_count * shape_cells[i];
                    num_pieces += shape_count;
                }

                if (width * height >= total_cells and width * height >= 9 * num_pieces) {
                    count += 1;
                }
            }
        }
    }

    return count;
}

fn solvePart2Impl(_: *anyopaque, _: std.mem.Allocator) !u64 {
    return 0;
}

pub const Day12Solution = struct {
    const vtable = u.solution.DaySolution.VTable{
        .solvePart1 = solvePart1Impl,
        .solvePart2 = solvePart2Impl,
        .getMetrics = getMetricsImpl,
    };

    pub fn asDaySolution() u.solution.DaySolution {
        return u.solution.DaySolution{
            .ptr = undefined,
            .vtable = &vtable,
        };
    }

    fn getMetricsImpl(_: *anyopaque, allocator: std.mem.Allocator) !u.solution.Metrics {
        return u.solution.measureMetrics(allocator, solvePart1Impl, solvePart2Impl);
    }
};
