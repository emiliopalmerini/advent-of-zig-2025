const std = @import("std");
const u = @import("utils");

const data = @embedFile("input.txt");

const Vec16 = @Vector(16, u8);

const MachineP1 = struct {
    target: u64,
    buttons: std.ArrayList(u64),
    allocator: std.mem.Allocator,

    fn deinit(self: *MachineP1) void {
        self.buttons.deinit(self.allocator);
    }
};

const MachineP2 = struct {
    target: Vec16,
    buttons: std.ArrayList(Vec16),
    num_counters: usize,
    allocator: std.mem.Allocator,

    fn deinit(self: *MachineP2) void {
        self.buttons.deinit(self.allocator);
    }
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
        .allocator = allocator,
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

    var num_counters: usize = 0;
    var joltages = try u.parse.tokenizeToList(allocator, line[start + 1 .. end], ',');
    defer joltages.deinit(allocator);

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
        .allocator = allocator,
    };
}

fn solvePart1(allocator: std.mem.Allocator, machine: MachineP1) !usize {
    var queue = try std.ArrayList(struct { mask: u64, presses: usize }).initCapacity(allocator, 10000);
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

        if (visited.contains(current.mask)) {
            continue;
        }

        try visited.put(current.mask, {});

        for (machine.buttons.items) |button| {
            const new_mask = current.mask ^ button;
            try queue.append(allocator, .{ .mask = new_mask, .presses = current.presses + 1 });
        }
    }

    return 0;
}

fn hashVec16(v: Vec16) u128 {
    var hash: u128 = 0;
    for (0..16) |i| {
        hash = (hash << 8) | @as(u128, v[i]);
    }
    return hash;
}

fn solvePart2(allocator: std.mem.Allocator, machine: MachineP2) !usize {
    const num_buttons = machine.buttons.items.len;
    const num_counters = machine.num_counters;
    
    // Build augmented matrix [A | b] where A is button effects, b is target.
    // Each row represents one counter equation, each column (except last) is a button.
    // The last column contains the target values we need to reach.
    var matrix = try allocator.alloc([]i64, num_counters);
    defer allocator.free(matrix);
    
    for (0..num_counters) |i| {
        matrix[i] = try allocator.alloc(i64, num_buttons + 1);
        for (0..num_buttons) |j| {
            matrix[i][j] = machine.buttons.items[j][i];
        }
        matrix[i][num_buttons] = machine.target[i];
    }
    defer {
        for (matrix) |row| {
            allocator.free(row);
        }
    }
    
    // Forward elimination: reduce matrix to row echelon form using Gaussian elimination.
    // We iterate through rows and eliminate coefficients below the pivot.
    var pivot_col: usize = 0;
    for (0..num_counters) |row| {
        if (pivot_col >= num_buttons) break;
        
        // Find the row with the largest absolute value in the pivot column (partial pivoting).
        var pivot_row = row;
        for (row + 1..num_counters) |r| {
            if (@abs(matrix[r][pivot_col]) > @abs(matrix[pivot_row][pivot_col])) {
                pivot_row = r;
            }
        }
        
        // If pivot is zero, move to next column.
        if (matrix[pivot_row][pivot_col] == 0) {
            pivot_col += 1;
            continue;
        }
        
        // Swap rows to move pivot to current row.
        std.mem.swap([]i64, &matrix[row], &matrix[pivot_row]);
        
        // Eliminate the pivot column in all rows below current row.
        for (row + 1..num_counters) |r| {
            if (matrix[r][pivot_col] != 0) {
                const factor = matrix[r][pivot_col];
                const divisor = matrix[row][pivot_col];
                for (0..num_buttons + 1) |col| {
                    matrix[r][col] = matrix[r][col] * divisor - matrix[row][col] * factor;
                }
            }
        }
        
        pivot_col += 1;
    }
    
    // Back substitution: solve for each button press count starting from bottom row.
    // Iterate from last row to first, using already-solved variables to solve remaining ones.
    var presses = try allocator.alloc(i64, num_buttons);
    defer allocator.free(presses);
    @memset(presses, 0);
    
    if (num_counters > 0) {
        var row_idx: usize = num_counters - 1;
        while (true) {
            // Find the first non-zero coefficient in this row (the pivot).
            var col_idx: usize = num_buttons;
            for (0..num_buttons) |col| {
                if (matrix[row_idx][col] != 0) {
                    col_idx = col;
                    break;
                }
            }
            
            // If no pivot exists, check if equation is consistent (0 = 0 vs 0 = non-zero).
            if (col_idx == num_buttons) {
                if (matrix[row_idx][num_buttons] != 0) {
                    return 0; // Inconsistent: equation says 0 = non-zero
                }
            } else {
                // Solve for button at col_idx: coefficient * presses[col_idx] + other_terms = target
                var rhs = matrix[row_idx][num_buttons];
                for (0..num_buttons) |col| {
                    if (col != col_idx) {
                        rhs -= matrix[row_idx][col] * presses[col];
                    }
                }
                
                if (matrix[row_idx][col_idx] == 0) {
                    return 0;
                }
                
                // Check if solution is an integer.
                if (@mod(rhs, matrix[row_idx][col_idx]) != 0) {
                    return 0; // Non-integer solution impossible
                }
                
                presses[col_idx] = @divTrunc(rhs, matrix[row_idx][col_idx]);
                
                // Only non-negative press counts are valid.
                if (presses[col_idx] < 0) {
                    return 0;
                }
            }
            
            if (row_idx == 0) break;
            row_idx -= 1;
        }
    }
    
    // Sum all button presses to get total presses.
    var total: i64 = 0;
    for (presses) |p| total += p;
    return @intCast(total);
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

    fn solvePart1Impl(_: *anyopaque, allocator: std.mem.Allocator) !u64 {
        var lines = try u.parse.readLines(allocator, data);
        defer lines.deinit(allocator);

        var total: u64 = 0;

        for (lines.items) |line| {
            var machine = try parseMachinePart1(allocator, line);
            defer machine.deinit();

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
            defer machine.deinit();

            const min_presses = try solvePart2(allocator, machine);
            total += min_presses;
        }

        return total;
    }

    fn getMetricsImpl(_: *anyopaque, allocator: std.mem.Allocator) !u.solution.Metrics {
        return u.solution.measureMetrics(allocator, solvePart1Impl, solvePart2Impl);
    }
};
