const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

const MAX_COUNTERS = 16;
const INITIAL_BUTTON_CAPACITY = 10;
const INITIAL_QUEUE_CAPACITY = 10000;
const INF_COST = std.math.maxInt(usize);

const Vec16 = @Vector(16, u8);
const Vec16u16 = @Vector(16, u16);

const MachineP1 = struct {
    target: u64,
    buttons: std.ArrayList(u64),

    fn init(
        _: std.mem.Allocator,
        target: u64,
        buttons: std.ArrayList(u64),
    ) MachineP1 {
        return .{ .target = target, .buttons = buttons };
    }

    fn deinit(self: *MachineP1, allocator: std.mem.Allocator) void {
        self.buttons.deinit(allocator);
    }
};

const MachineP2 = struct {
    target: Vec16u16,
    buttons: std.ArrayList(Vec16u16),
    num_counters: usize,

    fn init(
        allocator: std.mem.Allocator,
        target: Vec16u16,
        buttons: std.ArrayList(Vec16u16),
        num_counters: usize,
    ) MachineP2 {
        _ = allocator;
        return .{
            .target = target,
            .buttons = buttons,
            .num_counters = num_counters,
        };
    }

    fn deinit(self: *MachineP2, allocator: std.mem.Allocator) void {
        self.buttons.deinit(allocator);
    }

    fn isZero(self: MachineP2) bool {
        for (0..self.num_counters) |i| {
            if (self.target[i] != 0) return false;
        }
        return true;
    }
};

const Parser = struct {
    fn extractBracketContent(line: []const u8, open: u8, close: u8) ?[]const u8 {
        var start: usize = 0;
        while (start < line.len and line[start] != open) start += 1;
        if (start >= line.len) return null;

        var end = start + 1;
        while (end < line.len and line[end] != close) end += 1;
        if (end >= line.len) return null;

        return line[start + 1 .. end];
    }

    fn extractButtonsSection(line: []const u8) []const u8 {
        var start: usize = 0;
        while (start < line.len and line[start] != '(') start += 1;

        var end = start;
        while (end < line.len and line[end] != '{') end += 1;

        return line[start..end];
    }

    fn parseButtonGroup(
        _: std.mem.Allocator,
        group: []const u8,
    ) ![]const u8 {
        const trimmed = u.parse.trimLine(group);
        if (trimmed.len == 0) return "";

        return if (std.mem.indexOf(u8, trimmed, ")")) |idx|
            trimmed[0..idx]
        else
            trimmed;
    }
};

fn parseButtonsPart1(
    allocator: std.mem.Allocator,
    s: []const u8,
) !std.ArrayList(u64) {
    var buttons = try std.ArrayList(u64).initCapacity(
        allocator,
        INITIAL_BUTTON_CAPACITY,
    );

    var groups = try u.parse.tokenizeToList(allocator, s, '(');
    defer groups.deinit(allocator);

    for (groups.items) |group| {
        const group_content = try Parser.parseButtonGroup(allocator, group);
        if (group_content.len == 0) continue;

        var button_mask: u64 = 0;
        var nums = try u.parse.tokenizeToList(
            allocator,
            group_content,
            ',',
        );
        defer nums.deinit(allocator);

        for (nums.items) |num_str| {
            const trimmed = u.parse.trimLine(num_str);
            if (trimmed.len > 0) {
                const bit_pos = try std.fmt.parseInt(u6, trimmed, 10);
                button_mask |= (@as(u64, 1) << bit_pos);
            }
        }

        if (button_mask > 0 or nums.items.len > 0) {
            try buttons.append(allocator, button_mask);
        }
    }

    return buttons;
}

fn parseButtonsPart2(
    allocator: std.mem.Allocator,
    s: []const u8,
    num_counters: usize,
) !std.ArrayList(Vec16u16) {
    var buttons = try std.ArrayList(Vec16u16).initCapacity(
        allocator,
        INITIAL_BUTTON_CAPACITY,
    );

    var groups = try u.parse.tokenizeToList(allocator, s, '(');
    defer groups.deinit(allocator);

    for (groups.items) |group| {
        const group_content = try Parser.parseButtonGroup(allocator, group);
        if (group_content.len == 0) continue;

        var button_vec: Vec16u16 = @splat(0);
        var nums = try u.parse.tokenizeToList(
            allocator,
            group_content,
            ',',
        );
        defer nums.deinit(allocator);

        for (nums.items) |num_str| {
            const trimmed = u.parse.trimLine(num_str);
            if (trimmed.len > 0) {
                const idx = try std.fmt.parseInt(usize, trimmed, 10);
                if (idx < num_counters and idx < MAX_COUNTERS) {
                    button_vec[idx] = 1;
                }
            }
        }

        const has_values = @reduce(
            .Or,
            button_vec != @as(Vec16u16, @splat(0)),
        );
        if (has_values or nums.items.len > 0) {
            try buttons.append(allocator, button_vec);
        }
    }

    return buttons;
}

fn parseMachinePart1(
    allocator: std.mem.Allocator,
    line: []const u8,
) !MachineP1 {
    const target_str = Parser.extractBracketContent(line, '[', ']') orelse
        return error.InvalidInput;

    var target: u64 = 0;
    for (target_str, 0..) |ch, idx| {
        if (ch == '#') {
            target |= (@as(u64, 1) << @intCast(idx));
        }
    }

    const buttons_str = Parser.extractButtonsSection(line);
    const buttons = try parseButtonsPart1(allocator, buttons_str);

    return MachineP1.init(allocator, target, buttons);
}

fn parseMachinePart2(
    allocator: std.mem.Allocator,
    line: []const u8,
) !MachineP2 {
    const counters_str = Parser.extractBracketContent(line, '{', '}') orelse
        return error.InvalidInput;

    var target: Vec16u16 = @splat(0);
    var num_counters: usize = 0;

    var joltages = try u.parse.tokenizeToList(
        allocator,
        counters_str,
        ',',
    );
    defer joltages.deinit(allocator);

    for (joltages.items, 0..) |jolt_str, idx| {
        const trimmed = u.parse.trimLine(jolt_str);
        if (trimmed.len > 0) {
            if (idx >= MAX_COUNTERS) {
                std.debug.print(
                    "ERROR: Input has more than {d} counters!\n",
                    .{MAX_COUNTERS},
                );
                break;
            }
            const val = try std.fmt.parseInt(u16, trimmed, 10);
            target[idx] = val;
            num_counters = idx + 1;
        }
    }

    const buttons_str = Parser.extractButtonsSection(line);
    const buttons = try parseButtonsPart2(
        allocator,
        buttons_str,
        num_counters,
    );

    return MachineP2.init(allocator, target, buttons, num_counters);
}

const State = struct {
    mask: u64,
    presses: usize,
};

fn solvePart1(
    allocator: std.mem.Allocator,
    machine: MachineP1,
) !usize {
    var queue = try std.ArrayList(State).initCapacity(
        allocator,
        INITIAL_QUEUE_CAPACITY,
    );
    defer queue.deinit(allocator);

    var visited = std.AutoHashMap(u64, void).init(allocator);
    defer visited.deinit();

    try queue.append(allocator, .{ .mask = 0, .presses = 0 });

    var head: usize = 0;
    while (head < queue.items.len) {
        const current = queue.items[head];
        head += 1;

        if (current.mask == machine.target) {
            return current.presses;
        }

        if (visited.contains(current.mask)) continue;
        try visited.put(current.mask, {});

        for (machine.buttons.items) |button| {
            const new_mask = current.mask ^ button;
            try queue.append(allocator, .{
                .mask = new_mask,
                .presses = current.presses + 1,
            });
        }
    }

    return 0;
}

const ButtonEffect = struct {
    effect: Vec16u16,
    press_count: usize,
};

const ParityMap = std.AutoHashMap(Vec16u16, std.ArrayList(ButtonEffect));

fn countBits(mask: usize) usize {
    var count: usize = 0;
    var temp = mask;
    while (temp > 0) {
        count += temp & 1;
        temp >>= 1;
    }
    return count;
}

fn computeEffect(buttons: []Vec16u16, mask: usize) Vec16u16 {
    var effect: Vec16u16 = @splat(0);
    for (buttons, 0..) |button, idx| {
        if ((mask & (@as(usize, 1) << @intCast(idx))) != 0) {
            effect = effect + button;
        }
    }
    return effect;
}

fn computeParity(effect: Vec16u16, num_counters: usize) Vec16u16 {
    var parity: Vec16u16 = @splat(0);
    for (0..num_counters) |i| {
        parity[i] = effect[i] & 1;
    }
    return parity;
}

fn buildParityMap(
    allocator: std.mem.Allocator,
    buttons: []Vec16u16,
    num_counters: usize,
) !ParityMap {
    var parity_map = ParityMap.init(allocator);
    var seen_effects = std.AutoHashMap(Vec16u16, void).init(allocator);
    defer seen_effects.deinit();

    const num_buttons = buttons.len;
    const max_mask = @as(usize, 1) << @intCast(num_buttons);

    for (0..num_buttons + 1) |target_bits| {
        var mask: usize = 0;
        while (mask < max_mask) : (mask += 1) {
            if (countBits(mask) != target_bits) continue;

            const effect = computeEffect(buttons, mask);
            if (seen_effects.contains(effect)) continue;

            try seen_effects.put(effect, {});

            const parity = computeParity(effect, num_counters);
            const entry = try parity_map.getOrPut(parity);
            if (!entry.found_existing) {
                entry.value_ptr.* = try std.ArrayList(
                    ButtonEffect,
                ).initCapacity(allocator, INITIAL_BUTTON_CAPACITY);
            }

            try entry.value_ptr.append(allocator, .{
                .effect = effect,
                .press_count = target_bits,
            });
        }
    }

    return parity_map;
}

fn canSubtract(target: Vec16u16, effect: Vec16u16, num_counters: usize) bool {
    for (0..num_counters) |i| {
        if (target[i] < effect[i]) return false;
    }
    return true;
}

fn computeResidual(
    target: Vec16u16,
    effect: Vec16u16,
    num_counters: usize,
) Vec16u16 {
    var residual: Vec16u16 = @splat(0);
    for (0..num_counters) |i| {
        residual[i] = (target[i] - effect[i]) / 2;
    }
    return residual;
}

fn solvePart2Recursive(
    allocator: std.mem.Allocator,
    memo: *std.AutoHashMap(Vec16u16, usize),
    parity_map: *ParityMap,
    target: Vec16u16,
    num_counters: usize,
) !usize {
    var all_zero = true;
    for (0..num_counters) |i| {
        if (target[i] != 0) {
            all_zero = false;
            break;
        }
    }
    if (all_zero) return 0;

    if (memo.get(target)) |cached| return cached;

    const target_parity = computeParity(target, num_counters);
    var min_cost: usize = INF_COST;

    if (parity_map.get(target_parity)) |patterns| {
        for (patterns.items) |button_effect| {
            if (!canSubtract(
                target,
                button_effect.effect,
                num_counters,
            )) continue;

            const residual = computeResidual(
                target,
                button_effect.effect,
                num_counters,
            );
            const sub_cost = try solvePart2Recursive(
                allocator,
                memo,
                parity_map,
                residual,
                num_counters,
            );

            if (sub_cost != INF_COST) {
                const total = button_effect.press_count + (2 * sub_cost);
                min_cost = @min(min_cost, total);
            }
        }
    }

    try memo.put(target, min_cost);
    return min_cost;
}

fn solvePart2(
    allocator: std.mem.Allocator,
    machine: MachineP2,
) !usize {
    var parity_map = try buildParityMap(
        allocator,
        machine.buttons.items,
        machine.num_counters,
    );
    defer {
        var it = parity_map.valueIterator();
        while (it.next()) |list| {
            list.deinit(allocator);
        }
        parity_map.deinit();
    }

    var memo = std.AutoHashMap(Vec16u16, usize).init(allocator);
    defer memo.deinit();

    return try solvePart2Recursive(
        allocator,
        &memo,
        &parity_map,
        machine.target,
        machine.num_counters,
    );
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

    fn solvePart1Impl(
        _: *anyopaque,
        allocator: std.mem.Allocator,
    ) !u64 {
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

    fn solvePart2Impl(
        _: *anyopaque,
        allocator: std.mem.Allocator,
    ) !u64 {
        var lines = try u.parse.readLines(allocator, data);
        defer lines.deinit(allocator);

        var total: u64 = 0;
        for (lines.items) |line| {
            var machine = try parseMachinePart2(allocator, line);
            defer machine.deinit(allocator);

            const min_presses = try solvePart2(allocator, machine);
            if (min_presses != INF_COST) {
                total += min_presses;
            }
        }

        return total;
    }

    fn getMetricsImpl(
        _: *anyopaque,
        allocator: std.mem.Allocator,
    ) !u.solution.Metrics {
        return u.solution.measureMetrics(
            allocator,
            solvePart1Impl,
            solvePart2Impl,
        );
    }
};
