const std = @import("std");
const geometry = @import("geometry.zig");

/// Weighted edge for graph algorithms (MST, shortest path, etc.)
/// u, v: vertex indices (typically into an array or graph)
/// weight: edge weight (typically distance, cost, or other metric)
pub const WeightedEdge = struct {
    u: usize,
    v: usize,
    weight: i64,
};

/// Comparator for sorting edges by weight (ascending)
pub fn compareEdgesAscending(_: void, a: WeightedEdge, b: WeightedEdge) bool {
    return a.weight < b.weight;
}

/// String-based directed graph with node name mapping.
/// Automatically assigns numeric IDs to string node names.
/// Uses ArenaAllocator for efficient memory management.
pub const StringGraph = struct {
    arena: std.heap.ArenaAllocator,
    name_to_id: std.StringHashMap(u32),
    adj: std.ArrayList(std.ArrayList(u32)),

    pub fn init(allocator: std.mem.Allocator) StringGraph {
        var graph = StringGraph{
            .arena = std.heap.ArenaAllocator.init(allocator),
            .name_to_id = std.StringHashMap(u32).init(allocator),
            .adj = undefined,
        };
        graph.adj = std.ArrayList(std.ArrayList(u32)).initCapacity(graph.arena.allocator(), 100) catch unreachable;
        return graph;
    }

    pub fn deinit(self: *StringGraph) void {
        self.name_to_id.deinit();
        var arena_allocator = self.arena;
        self.adj.deinit(arena_allocator.allocator());
        arena_allocator.deinit();
    }

    /// Get node ID for a given name (read-only lookup)
    pub fn getIdReadonly(self: *const StringGraph, name: []const u8) ?u32 {
        return self.name_to_id.get(name);
    }

    /// Get or create node ID for a given name (requires mutable access)
    pub fn getId(self: *StringGraph, name: []const u8) !u32 {
        if (self.name_to_id.get(name)) |id| {
            return id;
        }

        const id: u32 = @intCast(self.adj.items.len);

        const name_dupe = try self.arena.allocator().dupe(u8, name);
        try self.name_to_id.put(name_dupe, id);

        try self.adj.append(self.arena.allocator(), std.ArrayList(u32).initCapacity(self.arena.allocator(), 10) catch unreachable);

        return id;
    }

    /// Add a directed edge from one node to another by name
    pub fn addEdge(self: *StringGraph, from: []const u8, to: []const u8) !void {
        const from_id = try self.getId(from);
        const to_id = try self.getId(to);
        try self.adj.items[from_id].append(self.arena.allocator(), to_id);
    }

    /// Get the adjacency list for a node
    pub fn getNeighbors(self: *const StringGraph, node_id: u32) []u32 {
        return self.adj.items[node_id].items;
    }

    /// Get total number of nodes in graph
    pub fn nodeCount(self: *StringGraph) u32 {
        return @intCast(self.adj.items.len);
    }
};

/// Generate complete graph edges between all point pairs
/// Points must have x, y, z fields (i64)
/// Returns edges with weights as squared Euclidean distance
pub fn generateEdgesComplete(
    allocator: std.mem.Allocator,
    comptime PointType: type,
    points: []const PointType,
) !std.ArrayList(WeightedEdge) {
    const edge_count = (points.len * (points.len - 1)) / 2;
    var edges = try std.ArrayList(WeightedEdge).initCapacity(allocator, edge_count);
    errdefer edges.deinit(allocator);

    for (0..points.len) |i| {
        for (i + 1..points.len) |j| {
            const p1 = points[i];
            const p2 = points[j];

            const dx = p2.x - p1.x;
            const dy = p2.y - p1.y;
            const dz = p2.z - p1.z;
            const dist_sq = dx * dx + dy * dy + dz * dz;

            edges.appendAssumeCapacity(WeightedEdge{
                .u = i,
                .v = j,
                .weight = dist_sq,
            });
        }
    }

    return edges;
}
