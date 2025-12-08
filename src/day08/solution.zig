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
    var points = try std.ArrayList(Point3D).initCapacity(allocator, 100);
    errdefer points.deinit(allocator);

    var lines = try u.input.readLines(allocator, input);
    defer lines.deinit(allocator);

    for (lines.items, 0..) |line, id| {
        var coords = try u.input.tokenizeToList(allocator, line, ',');
        defer coords.deinit(allocator);

        if (coords.items.len < 3) continue;

        const x = try std.fmt.parseInt(i64, coords.items[0], 10);
        const y = try std.fmt.parseInt(i64, coords.items[1], 10);
        const z = try std.fmt.parseInt(i64, coords.items[2], 10);

        try points.append(allocator, .{
            .x = x,
            .y = y,
            .z = z,
            .id = id,
        });
    }

    return points;
}

fn generateEdges(allocator: std.mem.Allocator, points: std.ArrayList(Point3D)) !std.ArrayList(u.grid.Edge) {
    var edges = try std.ArrayList(u.grid.Edge).initCapacity(allocator, 10000);
    errdefer edges.deinit(allocator);

    const pts = points.items;

    //I have to walk every single point twice to determine Edges.
    //First pt is i, second possible points starts from i+1.
    //For each possible edge I have to calculate Euclidean distance
    for (0..pts.len) |i| {
        for (i + 1..pts.len) |j| {
            const p1 = pts[i];
            const p2 = pts[j];

            const dist_sq = u.grid.euclideanDistance3DSq(Point3D, p1, p2);

            try edges.append(allocator, u.grid.Edge{
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

const ProblemSpace = struct {
    points: std.ArrayList(Point3D),
    edges: std.ArrayList(u.grid.Edge),
};

fn setupAndSortEdges(allocator: std.mem.Allocator, input: []const u8) !ProblemSpace {
    const points = try parsePoints(allocator, input);
    const edges = try generateEdges(allocator, points);
    
    // Sort edges by distance ascending (shortest first)
    std.mem.sort(u.grid.Edge, edges.items, {}, compareEdges);
    
    return ProblemSpace{
        .points = points,
        .edges = edges,
    };
}

//To connect junction boxes I have to find the two closest points (closest points = shortest circuit = edges with minimum dist_sq).
//The shortest circuit could start from the latest circuit edge or from another.
//I think I will have to find a forest of minimum spanning tree.
//With the help of wikipedia I decided to use [Kruskal's algorithm](https://en.wikipedia.org/wiki/Kruskal%27s_algorithm),
//I have to return early (1000 connections) and then multiply the three largest circuits.
//Using Kruskal's means I have to use DSU to store the trees. I implemented it following Wikipedia explanation in utils
pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    var setup = try setupAndSortEdges(allocator, input);
    defer setup.points.deinit(allocator);
    defer setup.edges.deinit(allocator);

    // Initialize DSU for tracking connected circuits
    var dsu = try u.dsu.DSU(usize).init(allocator, setup.points.items.len);
    defer dsu.deinit(allocator);

    // Apply Kruskal's algorithm: process edges in order of increasing distance
    // Stop after processing 1000 edges
    for (setup.edges.items[0..@min(1000, setup.edges.items.len)]) |edge| {
        // Try to unite the two endpoints
        _ = dsu.unite(edge.u, edge.v);
    }

    // Get all unique component sizes
    var sizes = try dsu.getRootSizes(allocator);
    defer sizes.deinit(allocator);

    // Sort sizes in descending order
    std.mem.sort(usize, sizes.items, {}, compareSizesDescending);

    // Multiply the three largest
    var result: u64 = 1;
    for (0..@min(3, sizes.items.len)) |i| {
        result *= sizes.items[i];
    }

    return result;
}

//In comparison, part 2 seems trivial. I have to complete the mst and then calculate
//the required product between the latest junction boxes' X.
pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    var setup = try setupAndSortEdges(allocator, input);
    defer setup.points.deinit(allocator);
    defer setup.edges.deinit(allocator);

    // Initialize DSU for tracking connected components
    var dsu = try u.dsu.DSU(usize).init(allocator, setup.points.items.len);
    defer dsu.deinit(allocator);

    // Apply Kruskal's algorithm: process edges until all components merge into one
    var components = setup.points.items.len;
    for (setup.edges.items) |edge| {
        // Try to unite the two endpoints
        if (dsu.unite(edge.u, edge.v)) {
            components -= 1;
            // When we reach 1 component, this edge completes the circuit
            if (components == 1) {
                const p1 = setup.points.items[edge.u];
                const p2 = setup.points.items[edge.v];
                return @intCast(p1.x * p2.x);
            }
        }
    }

    // Should not reach here if input is valid
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
        var timer = try std.time.Timer.start();

        const part1_result = try solvePart1Impl(undefined, allocator);
        const part1_time = timer.lap();

        const part2_result = try solvePart2Impl(undefined, allocator);
        const total_time = timer.read();
        const part2_time = total_time -| part1_time;

        return u.solution.Metrics{
            .part1_result = part1_result,
            .part1_time_ms = @as(f64, @floatFromInt(part1_time)) / 1_000_000,
            .part2_result = part2_result,
            .part2_time_ms = @as(f64, @floatFromInt(part2_time)) / 1_000_000,
        };
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const p1 = try Day8Solution.asDaySolution().solvePart1(allocator);
    const p2 = try Day8Solution.asDaySolution().solvePart2(allocator);
    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}
