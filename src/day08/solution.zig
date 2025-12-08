// https://adventofcode.com/2025/day/8

const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

const Point3D = struct {
    x: i64,
    y: i64,
    z: i64,
    id: usize,
}; // Extended from u.grid.Point3D with id field for tracking input order

fn parsePoints(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Point3D) {
    var points = try std.ArrayList(Point3D).initCapacity(allocator, 1001);
    errdefer points.deinit(allocator);

    var lines = std.mem.splitSequence(u8, input, "\n");
    var id: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var it = std.mem.splitSequence(u8, line, ",");
        const x_str = it.next() orelse continue;
        const y_str = it.next() orelse continue;
        const z_str = it.next() orelse continue;

        const x = try std.fmt.parseInt(i64, x_str, 10);
        const y = try std.fmt.parseInt(i64, y_str, 10);
        const z = try std.fmt.parseInt(i64, z_str, 10);

        points.appendAssumeCapacity(.{
            .x = x,
            .y = y,
            .z = z,
            .id = id,
        });
        id += 1;
    }

    return points;
}

fn generateEdges(allocator: std.mem.Allocator, points: std.ArrayList(Point3D)) !std.ArrayList(u.grid.Edge) {
    const pts = points.items;
    const edge_count = (pts.len * (pts.len - 1)) / 2;

    var edges = try std.ArrayList(u.grid.Edge).initCapacity(allocator, edge_count);
    errdefer edges.deinit(allocator);

    for (0..pts.len) |i| {
        const p1 = pts[i];
        for (i + 1..pts.len) |j| {
            const p2 = pts[j];

            // Inline distance calculation to avoid function call overhead
            const dx = p2.x - p1.x;
            const dy = p2.y - p1.y;
            const dz = p2.z - p1.z;
            const dist_sq = dx * dx + dy * dy + dz * dz;

            edges.appendAssumeCapacity(u.grid.Edge{
                .u = i,
                .v = j,
                .weight = dist_sq,
            });
        }
    }

    return edges;
}

fn compareEdges(_: void, a: u.grid.Edge, b: u.grid.Edge) bool {
    return a.weight < b.weight;
}

fn compareSizesDescending(_: void, a: usize, b: usize) bool {
    return a > b;
}

fn setupData(allocator: std.mem.Allocator, input: []const u8) !struct { points: std.ArrayList(Point3D), edges: std.ArrayList(u.grid.Edge) } {
    const points = try parsePoints(allocator, input);
    const edges = try generateEdges(allocator, points);

    // Sort edges by distance ascending (shortest first)
    std.mem.sort(u.grid.Edge, edges.items, {}, compareEdges);

    return .{ .points = points, .edges = edges };
}

pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    var parsed = try setupData(allocator, input);
    defer parsed.points.deinit(allocator);
    defer parsed.edges.deinit(allocator);

    var dsu = try u.dsu.DSU(usize).init(allocator, parsed.points.items.len);
    defer dsu.deinit(allocator);

    for (parsed.edges.items[0..@min(1000, parsed.edges.items.len)]) |edge| {
        _ = dsu.unite(edge.u, edge.v);
    }

    var sizes = try dsu.getRootSizes(allocator);
    defer sizes.deinit(allocator);
    std.mem.sort(usize, sizes.items, {}, compareSizesDescending);

    var result: u64 = 1;
    for (0..@min(3, sizes.items.len)) |i| {
        result *= sizes.items[i];
    }

    return result;
}

pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    var parsed = try setupData(allocator, input);
    defer parsed.points.deinit(allocator);
    defer parsed.edges.deinit(allocator);

    var dsu = try u.dsu.DSU(usize).init(allocator, parsed.points.items.len);
    defer dsu.deinit(allocator);

    var components = parsed.points.items.len;
    for (parsed.edges.items) |edge| {
        if (dsu.unite(edge.u, edge.v)) {
            components -= 1;
            if (components == 1) {
                const p1 = parsed.points.items[edge.u];
                const p2 = parsed.points.items[edge.v];
                return @intCast(p1.x * p2.x);
            }
        }
    }

    return 0;
}

pub const Day8Solution = struct {
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

    fn solvePart1Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        return try solvePart1(allocator, data);
    }

    fn solvePart2Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        return try solvePart2(allocator, data);
    }

    fn getMetricsImpl(_: *anyopaque, allocator: std.mem.Allocator) !u.solution.Metrics {
        return u.solution.measureMetrics(allocator, solvePart1Impl, solvePart2Impl);
    }
};
