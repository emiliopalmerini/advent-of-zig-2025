const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

const CacheKey = struct {
    current: u32,
    target: u32,
};

const Graph = struct {
    arena: std.heap.ArenaAllocator,
    name_to_id: std.StringHashMap(u32),
    adj: std.ArrayList(std.ArrayList(u32)),

    fn init(allocator: std.mem.Allocator) Graph {
        var graph = Graph{
            .arena = std.heap.ArenaAllocator.init(allocator),
            .name_to_id = std.StringHashMap(u32).init(allocator),
            .adj = undefined,
        };
        graph.adj = std.ArrayList(std.ArrayList(u32)).initCapacity(graph.arena.allocator(), 100) catch unreachable;
        return graph;
    }

    fn deinit(self: *Graph) void {
        self.name_to_id.deinit();
        var arena_allocator = self.arena;
        self.adj.deinit(arena_allocator.allocator());
        arena_allocator.deinit();
    }

    fn getId(self: *Graph, name: []const u8) !u32 {
        if (self.name_to_id.get(name)) |id| {
            return id;
        }
        
        const id: u32 = @intCast(self.adj.items.len);
        
        const name_dupe = try self.arena.allocator().dupe(u8, name);
        try self.name_to_id.put(name_dupe, id);
        
        try self.adj.append(self.arena.allocator(), std.ArrayList(u32).initCapacity(self.arena.allocator(), 10) catch unreachable);
        
        return id;
    }

    fn addEdge(self: *Graph, from: []const u8, to: []const u8) !void {
        const from_id = try self.getId(from);
        const to_id = try self.getId(to);
        try self.adj.items[from_id].append(self.arena.allocator(), to_id);
    }
};

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !Graph {
    var graph = Graph.init(allocator);
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
    graph: *const Graph,
    cache: *std.AutoHashMap(CacheKey, u64),
) !u64 {
    if (current == target) return 1;

    const key = CacheKey{ .current = current, .target = target };
    if (cache.get(key)) |cached| {
        return cached;
    }

    var total: u64 = 0;
    const neighbors = graph.adj.items[current].items;
    
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
    graph: *const Graph,
    cache: *std.AutoHashMap(CacheKey, u64),
) !u64 {
    var product: u64 = 1;
    for (0..nodes.len - 1) |i| {
        const from_id = graph.name_to_id.get(nodes[i]) orelse return error.NodeNotFound;
        const to_id = graph.name_to_id.get(nodes[i + 1]) orelse return error.NodeNotFound;
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
