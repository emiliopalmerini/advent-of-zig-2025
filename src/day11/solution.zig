const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

const CacheKey = struct {
    current: u32,
    target: u32,
};

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !u.graph.StringGraph {
    var graph = u.graph.StringGraph.init(allocator);
    errdefer graph.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, "\r ");
        if (trimmed.len == 0) continue;

        if (std.mem.indexOf(u8, trimmed, ":")) |colon_idx| {
            const device = std.mem.trim(u8, trimmed[0..colon_idx], " ");
            const outputs_str = trimmed[colon_idx + 1 ..];
            
            var outputs = std.mem.tokenizeScalar(u8, outputs_str, ' ');
            while (outputs.next()) |output| {
                const output_trimmed = std.mem.trim(u8, output, " ");
                try graph.addEdge(device, output_trimmed);
            }
        }
    }

    return graph;
}

fn countPathsMemoized(
    current: u32,
    target: u32,
    graph: *const u.graph.StringGraph,
    cache: *std.AutoHashMap(CacheKey, u64),
) !u64 {
    if (current == target) return 1;

    const key = CacheKey{ .current = current, .target = target };
    if (cache.get(key)) |cached| {
        return cached;
    }

    var total: u64 = 0;
    const neighbors = graph.getNeighbors(current);
    
    for (neighbors) |next_id| {
        total += try countPathsMemoized(next_id, target, graph, cache);
    }

    try cache.put(key, total);
    return total;
}

fn solvePart1Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
    var graph = try parseInput(allocator, data);
    defer graph.deinit();

    var cache = std.AutoHashMap(CacheKey, u64).init(allocator);
    defer cache.deinit();

    const start_id = graph.name_to_id.get("you") orelse return error.StartNodeNotFound;
    const end_id = graph.name_to_id.get("out") orelse return error.EndNodeNotFound;

    return countPathsMemoized(start_id, end_id, &graph, &cache);
}

fn pathProduct(
    nodes: []const []const u8,
    graph: *const u.graph.StringGraph,
    cache: *std.AutoHashMap(CacheKey, u64),
) !u64 {
    var product: u64 = 1;
    for (0..nodes.len - 1) |i| {
        const from_id = graph.getIdReadonly(nodes[i]) orelse return error.NodeNotFound;
        const to_id = graph.getIdReadonly(nodes[i + 1]) orelse return error.NodeNotFound;
        product *= try countPathsMemoized(from_id, to_id, graph, cache);
    }
    return product;
}

fn solvePart2Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
    var graph = try parseInput(allocator, data);
    defer graph.deinit();

    var cache = std.AutoHashMap(CacheKey, u64).init(allocator);
    defer cache.deinit();

    // Path A: svr -> dac -> fft -> out
    const path_a = try pathProduct(&.{ "svr", "dac", "fft", "out" }, &graph, &cache);

    // Path B: svr -> fft -> dac -> out
    const path_b = try pathProduct(&.{ "svr", "fft", "dac", "out" }, &graph, &cache);

    return path_a + path_b;
}

pub const Day11Solution = struct {
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
