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



//Solve both parts using the same parsed data and edges
fn solveBoth(allocator: std.mem.Allocator, input: []const u8) ![2]u64 {
    var points = try parsePoints(allocator, input);
    defer points.deinit(allocator);
    
    var edges = try generateEdges(allocator, points);
    defer edges.deinit(allocator);

    // Sort edges by distance ascending (shortest first)
    std.mem.sort(u.grid.Edge, edges.items, {}, compareEdges);

    // Part 1: Process first 1000 edges
    var dsu1 = try u.dsu.DSU(usize).init(allocator, points.items.len);
    defer dsu1.deinit(allocator);

    for (edges.items[0..@min(1000, edges.items.len)]) |edge| {
        _ = dsu1.unite(edge.u, edge.v);
    }

    var sizes = try dsu1.getRootSizes(allocator);
    defer sizes.deinit(allocator);
    std.mem.sort(usize, sizes.items, {}, compareSizesDescending);

    var part1: u64 = 1;
    for (0..@min(3, sizes.items.len)) |i| {
        part1 *= sizes.items[i];
    }

    // Part 2: Complete MST
    var dsu2 = try u.dsu.DSU(usize).init(allocator, points.items.len);
    defer dsu2.deinit(allocator);

    var components = points.items.len;
    var part2: u64 = 0;
    for (edges.items) |edge| {
        if (dsu2.unite(edge.u, edge.v)) {
            components -= 1;
            if (components == 1) {
                const p1 = points.items[edge.u];
                const p2 = points.items[edge.v];
                part2 = @intCast(p1.x * p2.x);
                break;
            }
        }
    }

    return [2]u64{ part1, part2 };
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
        const results = try solveBoth(allocator, data);
        return results[0];
    }

    fn solvePart2Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        const results = try solveBoth(allocator, data);
        return results[1];
    }

    fn getMetricsImpl(_: *anyopaque, allocator: std.mem.Allocator) !u.solution.Metrics {
        return u.solution.measureMetrics(allocator, solvePart1Impl, solvePart2Impl);
    }
};
