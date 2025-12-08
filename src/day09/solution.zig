const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

pub const Day9Solution = struct {
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

    fn parseInput(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(u.grid.Point2D) {
        var points = try std.ArrayList(u.grid.Point2D).initCapacity(allocator, 10);
        errdefer points.deinit(allocator);

        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        while (lines.next()) |line| {
            const trimmed = std.mem.trim(u8, line, " \r\t");
            if (trimmed.len == 0) continue;

            var parts = std.mem.tokenizeScalar(u8, trimmed, ',');
            const x_str = parts.next() orelse return error.InvalidFormat;
            const y_str = parts.next() orelse return error.InvalidFormat;

            const x = try std.fmt.parseInt(i64, x_str, 10);
            const y = try std.fmt.parseInt(i64, y_str, 10);

            try points.append(allocator, u.grid.Point2D{ .x = x, .y = y });
        }
        return points;
    }

    fn solvePart1Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        var points_list = try parseInput(allocator, data);
        defer points_list.deinit(allocator);

        const points = points_list.items;
        var max_area: i64 = 0;

        for (0..points.len) |i| {
            for ((i + 1)..points.len) |j| {
                const p1 = points[i];
                const p2 = points[j];

                const width = @abs(p1.x - p2.x);
                const height = @abs(p1.y - p2.y);

                const area = @as(i64, @intCast(width)) * @as(i64, @intCast(height));

                if (area > max_area) {
                    max_area = area;
                }
            }
        }

        return @intCast(max_area);
    }

    fn solvePart2Impl(_: *anyopaque, _: std.mem.Allocator) !u64 {
        return 0;
    }

    fn getMetricsImpl(_: *anyopaque, allocator: std.mem.Allocator) !u.solution.Metrics {
        return u.solution.measureMetrics(allocator, solvePart1Impl, solvePart2Impl);
    }
};
