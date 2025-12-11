const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

const Graph = struct {
    devices: std.StringHashMap(std.ArrayList([]const u8)),
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator) Graph {
        return Graph{
            .devices = std.StringHashMap(std.ArrayList([]const u8)).init(allocator),
            .allocator = allocator,
        };
    }

    fn deinit(self: *Graph) void {
        var it = self.devices.valueIterator();
        while (it.next()) |outputs| {
            outputs.deinit(self.allocator);
        }
        self.devices.deinit();
    }

    fn addEdge(self: *Graph, from: []const u8, to: []const u8) !void {
        if (self.devices.getPtr(from)) |outputs| {
            try outputs.append(self.allocator, to);
        } else {
            var outputs = try std.ArrayList([]const u8).initCapacity(self.allocator, 10);
            try outputs.append(self.allocator, to);
            try self.devices.put(from, outputs);
        }
    }

    fn getOutputs(self: *Graph, device: []const u8) ?std.ArrayList([]const u8) {
        return self.devices.get(device);
    }
};

fn parseInput(allocator: std.mem.Allocator, input: []const u8) !Graph {
    var graph = Graph.init(allocator);
    
    var lines = try u.parse.readLines(allocator, input);
    defer lines.deinit(allocator);

    for (lines.items) |line| {
        const trimmed = u.parse.trimLine(line);
        if (trimmed.len == 0) continue;

        // Parse "device: output1 output2 ..."
        if (std.mem.indexOf(u8, trimmed, ":")) |colon_idx| {
            const device = u.parse.trimLine(trimmed[0..colon_idx]);
            const outputs_str = u.parse.trimLine(trimmed[colon_idx + 1 ..]);

            var outputs = try u.parse.tokenizeToList(allocator, outputs_str, ' ');
            defer outputs.deinit(allocator);

            for (outputs.items) |output| {
                const output_trimmed = u.parse.trimLine(output);
                if (output_trimmed.len > 0) {
                    try graph.addEdge(device, output_trimmed);
                }
            }
        }
    }

    return graph;
}

fn countPaths(allocator: std.mem.Allocator, graph: *Graph, current: []const u8, target: []const u8) !usize {
    if (std.mem.eql(u8, current, target)) {
        return 1;
    }

    if (graph.getOutputs(current)) |outputs| {
        var total: usize = 0;
        for (outputs.items) |next| {
            const paths = try countPaths(allocator, graph, next, target);
            total += paths;
        }
        return total;
    }

    return 0;
}

fn countPathsVisitingBoth(
    allocator: std.mem.Allocator,
    graph: *Graph,
    current: []const u8,
    target: []const u8,
    visited_required: *std.StringHashMap(bool),
) !usize {
    if (std.mem.eql(u8, current, target)) {
        // Check if we've visited both required nodes
        if (visited_required.get("dac") == true and visited_required.get("fft") == true) {
            return 1;
        }
        return 0;
    }

    if (graph.getOutputs(current)) |outputs| {
        var total: usize = 0;
        for (outputs.items) |next| {
            // Update visited status if this is a required node
            const was_visited_dac = visited_required.get("dac") orelse false;
            const was_visited_fft = visited_required.get("fft") orelse false;

            if (std.mem.eql(u8, next, "dac")) {
                try visited_required.put("dac", true);
            } else if (std.mem.eql(u8, next, "fft")) {
                try visited_required.put("fft", true);
            }

            const paths = try countPathsVisitingBoth(allocator, graph, next, target, visited_required);
            total += paths;

            // Restore visited status
            try visited_required.put("dac", was_visited_dac);
            try visited_required.put("fft", was_visited_fft);
        }
        return total;
    }

    return 0;
}

fn solvePart1Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
    var graph = try parseInput(allocator, data);
    defer graph.deinit();

    const paths = try countPaths(allocator, &graph, "you", "out");
    return @intCast(paths);
}

fn solvePart2Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
    _ = allocator;
    // TODO: Implement Part 2
    return 0;
}

// fn solvePart2ImplOld(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
//     var graph = try parseInput(allocator, data);
//     defer graph.deinit();
//
//     var visited_required = std.StringHashMap(bool).init(allocator);
//     defer visited_required.deinit();
//
//     try visited_required.put("dac", false);
//     try visited_required.put("fft", false);
//
//     const paths = try countPathsVisitingBoth(allocator, &graph, "svr", "out", &visited_required);
//     return @intCast(paths);
// }

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
