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

    fn parseInput(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(u.geometry.Point) {
        var points = try std.ArrayList(u.geometry.Point).initCapacity(allocator, 10);
        errdefer points.deinit(allocator);

        var lines = try u.parse.readLines(allocator, input);
        defer lines.deinit(allocator);

        for (lines.items) |line| {
            var parts = try u.parse.tokenizeToList(allocator, line, ',');
            defer parts.deinit(allocator);

            if (parts.items.len < 2) return error.InvalidFormat;
            const x = try std.fmt.parseInt(i64, parts.items[0], 10);
            const y = try std.fmt.parseInt(i64, parts.items[1], 10);

            try points.append(allocator, u.geometry.Point{ .x = x, .y = y });
        }
        return points;
    }

    fn findMaxAreaWithPairs(
        points: []const u.geometry.Point,
        edges: ?[]const u.geometry.Edge,
        computeArea: *const fn (p1: u.geometry.Point, p2: u.geometry.Point, edges: ?[]const u.geometry.Edge) ?i64,
    ) i64 {
        var max_area: i64 = 0;

        for (0..points.len) |i| {
            for ((i + 1)..points.len) |j| {
                if (computeArea(points[i], points[j], edges)) |area| {
                    max_area = @max(max_area, area);
                }
            }
        }

        return max_area;
    }

    fn computeAreaPart1(p1: u.geometry.Point, p2: u.geometry.Point, _: ?[]const u.geometry.Edge) ?i64 {
        const width = @abs(p1.x - p2.x) + 1;
        const height = @abs(p1.y - p2.y) + 1;
        return @as(i64, @intCast(width)) * @as(i64, @intCast(height));
    }

    fn solvePart1Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        var points_list = try parseInput(allocator, data);
        defer points_list.deinit(allocator);

        const max_area = findMaxAreaWithPairs(points_list.items, null, computeAreaPart1);
        return @intCast(max_area);
    }

    fn pointInsidePolygon(point: u.geometry.Point, edges: []const u.geometry.Edge) bool {
        var crossings: i32 = 0;

        for (edges) |edge| {
            // Only count vertical edges to the right of point
            if (edge.p1.x == edge.p2.x and edge.p1.x > point.x) {
                const minY = @min(edge.p1.y, edge.p2.y);
                const maxY = @max(edge.p1.y, edge.p2.y);
                if (point.y >= minY and point.y < maxY) {
                    crossings += 1;
                }
            }
        }

        return @mod(crossings, 2) == 1;
    }

    fn pointOnPolygonBoundary(point: u.geometry.Point, edges: []const u.geometry.Edge) bool {
        for (edges) |edge| {
            if (edge.p1.x == edge.p2.x) {
                // Vertical edge
                const minY = @min(edge.p1.y, edge.p2.y);
                const maxY = @max(edge.p1.y, edge.p2.y);
                if (point.x == edge.p1.x and point.y >= minY and point.y <= maxY) {
                    return true;
                }
            } else {
                // Horizontal edge
                const minX = @min(edge.p1.x, edge.p2.x);
                const maxX = @max(edge.p1.x, edge.p2.x);
                if (point.y == edge.p1.y and point.x >= minX and point.x <= maxX) {
                    return true;
                }
            }
        }
        return false;
    }

    fn rectangleIsValid(minX: i64, maxX: i64, minY: i64, maxY: i64, edges: []const u.geometry.Edge) bool {
        // Check if any edge intersects the rectangle interior
        for (edges) |edge| {
            if (edge.p1.x == edge.p2.x) {
                // Vertical edge
                const x = edge.p1.x;
                const minEY = @min(edge.p1.y, edge.p2.y);
                const maxEY = @max(edge.p1.y, edge.p2.y);
                if (x > minX and x < maxX and minEY < maxY and maxEY > minY) {
                    return false;
                }
            } else {
                // Horizontal edge
                const y = edge.p1.y;
                const minEX = @min(edge.p1.x, edge.p2.x);
                const maxEX = @max(edge.p1.x, edge.p2.x);
                if (y > minY and y < maxY and minEX < maxX and maxEX > minX) {
                    return false;
                }
            }
        }

        // Check if all corners are inside or on boundary
        const corners = [4]u.geometry.Point{
            .{ .x = minX, .y = minY },
            .{ .x = maxX, .y = minY },
            .{ .x = minX, .y = maxY },
            .{ .x = maxX, .y = maxY },
        };

        for (corners) |corner| {
            if (!pointOnPolygonBoundary(corner, edges) and !pointInsidePolygon(corner, edges)) {
                return false;
            }
        }

        return true;
    }

    fn computeAreaPart2(p1: u.geometry.Point, p2: u.geometry.Point, edges: ?[]const u.geometry.Edge) ?i64 {
        const edgeList = edges orelse return null;

        const minX = @min(p1.x, p2.x);
        const maxX = @max(p1.x, p2.x);
        const minY = @min(p1.y, p2.y);
        const maxY = @max(p1.y, p2.y);

        if (rectangleIsValid(minX, maxX, minY, maxY, edgeList)) {
            return (maxX - minX + 1) * (maxY - minY + 1);
        }
        return null;
    }

    fn solvePart2Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        var points_list = try parseInput(allocator, data);
        defer points_list.deinit(allocator);

        const points = points_list.items;

        var edges = try std.ArrayList(u.geometry.Edge).initCapacity(allocator, points.len);
        defer edges.deinit(allocator);

        for (0..points.len) |i| {
            const p1 = points[i];
            const p2 = points[(i + 1) % points.len];
            try edges.append(allocator, u.geometry.Edge{ .p1 = p1, .p2 = p2 });
        }

        const max_area = findMaxAreaWithPairs(points, edges.items, computeAreaPart2);
        return @intCast(max_area);
    }

    fn getMetricsImpl(_: *anyopaque, allocator: std.mem.Allocator) !u.solution.Metrics {
        return u.solution.measureMetrics(allocator, solvePart1Impl, solvePart2Impl);
    }
};
