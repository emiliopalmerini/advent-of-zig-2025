const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

const Vec16 = @Vector(16, u8);

const MachineP1 = struct {
    target: u64,
    buttons: std.ArrayList(u64),

    fn deinit(self: *MachineP1, allocator: std.mem.Allocator) void {
        self.buttons.deinit(allocator);
    }
};

const MachineP2 = struct {
    target: Vec16,
    buttons: std.ArrayList(Vec16),
    num_counters: usize,

    fn deinit(self: *MachineP2, allocator: std.mem.Allocator) void {
        self.buttons.deinit(allocator);
    }
};

const StateP1 = struct {
    mask: u64,
    presses: usize,
};

const StateP2 = struct {
    counters: Vec16,
    presses: usize,
};

fn parseButtonsPart1(allocator: std.mem.Allocator, s: []const u8) !std.ArrayList(u64) {
    var buttons = try std.ArrayList(u64).initCapacity(allocator, 10);

    var groups = try u.parse.tokenizeToList(allocator, s, '(');
    defer groups.deinit(allocator);

    for (groups.items) |group| {
        if (group.len == 0) continue;

        const trimmed = u.parse.trimLine(group);
        if (trimmed.len == 0) continue;

        const group_content = if (std.mem.indexOf(u8, trimmed, ")")) |idx|
            trimmed[0..idx]
        else
            trimmed;

        var button_mask: u64 = 0;
        var nums = try u.parse.tokenizeToList(allocator, group_content, ',');
        defer nums.deinit(allocator);

        for (nums.items) |num_str| {
            const trimmed_num = u.parse.trimLine(num_str);
            if (trimmed_num.len > 0) {
                const bit_pos = try std.fmt.parseInt(u6, trimmed_num, 10);
                button_mask |= (@as(u64, 1) << bit_pos);
            }
        }

        if (button_mask > 0 or nums.items.len > 0) {
            try buttons.append(allocator, button_mask);
        }
    }

    return buttons;
}

fn parseButtonsPart2(allocator: std.mem.Allocator, s: []const u8, num_counters: usize) !std.ArrayList(Vec16) {
    var buttons = try std.ArrayList(Vec16).initCapacity(allocator, 10);

    var groups = try u.parse.tokenizeToList(allocator, s, '(');
    defer groups.deinit(allocator);

    for (groups.items) |group| {
        if (group.len == 0) continue;

        const trimmed = u.parse.trimLine(group);
        if (trimmed.len == 0) continue;

        const group_content = if (std.mem.indexOf(u8, trimmed, ")")) |idx|
            trimmed[0..idx]
        else
            trimmed;

        var button_vec: Vec16 = @splat(0);
        var nums = try u.parse.tokenizeToList(allocator, group_content, ',');
        defer nums.deinit(allocator);

        for (nums.items) |num_str| {
            const trimmed_num = u.parse.trimLine(num_str);
            if (trimmed_num.len > 0) {
                const idx = try std.fmt.parseInt(usize, trimmed_num, 10);
                if (idx < num_counters and idx < 16) {
                    button_vec[idx] = 1;
                }
            }
        }

        if (@reduce(.Or, button_vec != @as(Vec16, @splat(0))) or nums.items.len > 0) {
            try buttons.append(allocator, button_vec);
        }
    }

    return buttons;
}

fn parseMachinePart1(allocator: std.mem.Allocator, line: []const u8) !MachineP1 {
    var target: u64 = 0;
    var start: usize = 0;

    while (start < line.len and line[start] != '[') {
        start += 1;
    }

    var end = start + 1;
    while (end < line.len and line[end] != ']') {
        end += 1;
    }

    const target_str = line[start + 1 .. end];
    for (target_str, 0..) |ch, idx| {
        if (ch == '#') {
            target |= (@as(u64, 1) << @intCast(idx));
        }
    }

    var buttons_start: usize = end + 1;
    while (buttons_start < line.len and line[buttons_start] != '(') {
        buttons_start += 1;
    }

    var buttons_end = buttons_start;
    while (buttons_end < line.len and line[buttons_end] != '{') {
        buttons_end += 1;
    }

    const buttons_str = line[buttons_start..buttons_end];
    const buttons = try parseButtonsPart1(allocator, buttons_str);

    return MachineP1{
        .target = target,
        .buttons = buttons,
    };
}

fn parseMachinePart2(allocator: std.mem.Allocator, line: []const u8) !MachineP2 {
    var target: Vec16 = @splat(0);
    var start: usize = 0;

    while (start < line.len and line[start] != '{') {
        start += 1;
    }

    var end = start + 1;
    while (end < line.len and line[end] != '}') {
        end += 1;
    }

    const joltage_str = line[start + 1 .. end];
    var joltages = try u.parse.tokenizeToList(allocator, joltage_str, ',');
    defer joltages.deinit(allocator);

    var num_counters: usize = 0;
    for (joltages.items, 0..) |jolt_str, idx| {
        const trimmed = u.parse.trimLine(jolt_str);
        if (trimmed.len > 0) {
            if (idx >= 16) {
                std.debug.print("ERROR: Input has more than 16 counters!\n", .{});
                break;
            }
            const val = try std.fmt.parseInt(u64, trimmed, 10);
            const clamped: u8 = if (val > 255) 255 else @intCast(val);
            target[idx] = clamped;
            num_counters = idx + 1;
        }
    }

    var buttons_start: usize = 0;
    while (buttons_start < line.len and line[buttons_start] != '(') {
        buttons_start += 1;
    }

    var buttons_end = buttons_start;
    while (buttons_end < line.len and line[buttons_end] != '{') {
        buttons_end += 1;
    }

    const buttons_str = line[buttons_start..buttons_end];
    const buttons = try parseButtonsPart2(allocator, buttons_str, num_counters);

    return MachineP2{
        .target = target,
        .buttons = buttons,
        .num_counters = num_counters,
    };
}

fn solvePart1(allocator: std.mem.Allocator, machine: MachineP1) !usize {
    //BFS of all machine state. Spent time considering Gaussian Elimination
    //but didn't understand how to minimize button presses with it.
    //https://en.wikipedia.org/wiki/Gaussian_elimination
    var queue = try std.ArrayList(StateP1).initCapacity(allocator, 10000);
    defer queue.deinit(allocator);

    var visited = std.AutoHashMap(u64, void).init(allocator);
    defer visited.deinit();

    try queue.append(allocator, StateP1{ .mask = 0, .presses = 0 });

    var head: usize = 0;
    while (head < queue.items.len) {
        const current = queue.items[head];
        head += 1;

        if (current.mask == machine.target) {
            return current.presses;
        }

        if (visited.contains(current.mask)) {
            continue;
        }

        try visited.put(current.mask, {});

        for (machine.buttons.items) |button| {
            const new_mask = current.mask ^ button;
            try queue.append(allocator, StateP1{ .mask = new_mask, .presses = current.presses + 1 });
        }
    }

    return 0;
}

// Dijkstra approach: explores states with fewer presses first using a priority queue
fn solvePart2Dijkstra(allocator: std.mem.Allocator, machine: MachineP2) !usize {
    const StateWithOrder = struct {
        counters: Vec16,
        presses: usize,

        fn lessThan(_: void, a: @This(), b: @This()) std.math.Order {
            return std.math.order(a.presses, b.presses);
        }
    };

    var pq = std.PriorityQueue(StateWithOrder, void, StateWithOrder.lessThan).init(allocator, {});
    defer pq.deinit();

    var visited = std.AutoHashMap(u128, void).init(allocator);
    defer visited.deinit();

    const start_vec: Vec16 = @splat(0);

    if (@reduce(.And, start_vec == machine.target)) return 0;

    try pq.add(StateWithOrder{ .counters = start_vec, .presses = 0 });

    while (pq.removeOrNull()) |current| {
        // Check goal before marking visited (Dijkstra optimization)
        if (@reduce(.And, current.counters == machine.target)) {
            return current.presses;
        }

        const hash = hashVec16(current.counters);
        if (visited.contains(hash)) continue;
        try visited.put(hash, {});

        for (machine.buttons.items) |button_vec| {
            const next_vec = current.counters +| button_vec;

            // Early exit if any counter exceeds target
            if (@reduce(.Or, next_vec > machine.target)) {
                continue;
            }

            const next_hash = hashVec16(next_vec);
            if (visited.contains(next_hash)) {
                continue;
            }

            try pq.add(StateWithOrder{ .counters = next_vec, .presses = current.presses + 1 });
        }
    }

    return 0;
}

// DFS approach with bounded search: explores limited press counts per button
fn solvePart2DFS(allocator: std.mem.Allocator, machine: MachineP2) !usize {
    // Find maximum target value to bound the search space
    var max_target: u8 = 0;
    for (0..machine.num_counters) |i| {
        if (machine.target[i] > max_target) max_target = machine.target[i];
    }

    var best: usize = std.math.maxInt(usize);

    try dfsHelper(allocator, machine, @splat(0), 0, 0, &best, max_target);

    return if (best == std.math.maxInt(usize)) 0 else best;
}

fn dfsHelper(
    allocator: std.mem.Allocator,
    machine: MachineP2,
    current: Vec16,
    btn_idx: usize,
    presses_so_far: usize,
    best: *usize,
    max_target: u8,
) !void {
    // Pruning: if we already found a better solution, stop
    if (presses_so_far >= best.*) return;

    // Base case: tried all buttons
    if (btn_idx == machine.buttons.items.len) {
        if (@reduce(.And, current == machine.target)) {
            best.* = @min(best.*, presses_so_far);
        }
        return;
    }

    const button = machine.buttons.items[btn_idx];

    // Try pressing this button 0 to max_target times
    var times: usize = 0;
    var state = current;

    while (times <= max_target) : (times += 1) {
        // Recursively try the next button
        try dfsHelper(allocator, machine, state, btn_idx + 1, presses_so_far + times, best, max_target);

        // Press this button one more time for the next iteration
        state = state +| button;

        // Prune: if any counter exceeds target, no point trying more presses
        if (@reduce(.Or, state > machine.target)) break;
    }
}

fn solvePart2(allocator: std.mem.Allocator, machine: MachineP2) !usize {
    // Use Dijkstra by default - change to solvePart2DFS to use DFS approach
    return try solvePart2Dijkstra(allocator, machine);
}

fn hashVec16(v: Vec16) u128 {
    var hash: u128 = 0;
    for (0..16) |i| {
        hash = (hash << 8) | @as(u128, v[i]);
    }
    return hash;
}



pub const Day10Solution = struct {
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

    //Every light in the machine has only two states. We can rapresent the complete machine.
    //A light can be 0 (.) or 1 (#). I can use a u64 for the machine's target state.
    //Buttons are the same: just a bit mask to apply.
    //Applying a bit mask is just a bitwise operation (xor): a ^ b in zig.
    fn solvePart1Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        var lines = try u.parse.readLines(allocator, data);
        defer lines.deinit(allocator);

        var total: u64 = 0;

        for (lines.items) |line| {
            var machine = try parseMachinePart1(allocator, line);
            defer machine.deinit(allocator);

            const min_presses = try solvePart1(allocator, machine);
            total += min_presses;
        }

        return total;
    }

    fn solvePart2Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        var lines = try u.parse.readLines(allocator, data);
        defer lines.deinit(allocator);

        var total: u64 = 0;

        for (lines.items) |line| {
            var machine = try parseMachinePart2(allocator, line);
            defer machine.deinit(allocator);

            const min_presses = try solvePart2(allocator, machine);
            total += min_presses;
        }

        return total;
    }

    fn getMetricsImpl(_: *anyopaque, allocator: std.mem.Allocator) !u.solution.Metrics {
        return u.solution.measureMetrics(allocator, solvePart1Impl, solvePart2Impl);
    }
};
