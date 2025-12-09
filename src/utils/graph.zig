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
