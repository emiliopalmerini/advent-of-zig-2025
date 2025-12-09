const std = @import("std");
const u = @import("utils");
const registry = @import("registry");

fn printParts(metrics: u.solution.Metrics, indent: []const u8) void {
    std.debug.print("{s}Part 1: {d}\n", .{ indent, metrics.part1_result });
    std.debug.print("{s}Part 2: {d}\n", .{ indent, metrics.part2_result });
}

fn printTime(label: []const u8, time_ms: f64, indent: []const u8) void {
    std.debug.print("{s}{s}: {d:.6} ms\n", .{ indent, label, time_ms });
}

fn printMetrics(metrics: u.solution.Metrics) void {
    std.debug.print("\nPerformance:\n", .{});
    printTime("Part 1", metrics.part1_time_ms, "  ");
    printTime("Part 2", metrics.part2_time_ms, "  ");
    printTime("Total", metrics.total_time_ms(), "  ");
}

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <day|all>\n", .{args[0]});
        std.debug.print("Examples:\n", .{});
        std.debug.print("  {s} 1   - Run day 1\n", .{args[0]});
        std.debug.print("  {s} all - Run all days\n", .{args[0]});
        return;
    }

    // Check if running all days
    if (std.mem.eql(u8, args[1], "all")) {
        for (registry.all_solutions) |entry| {
            if (entry.solution) |solution| {
                const metrics = try solution.getMetrics(allocator);
                
                std.debug.print("Day {d}:\n", .{entry.day_number});
                printParts(metrics, "  ");
            }
        }
        return;
    }

    const day = std.fmt.parseInt(usize, args[1], 10) catch {
        std.debug.print("Error: Invalid day number\n", .{});
        return;
    };

    if (registry.getSolution(day)) |entry| {
        if (entry.solution) |solution| {
            const metrics = try solution.getMetrics(allocator);
            
            std.debug.print("Day {d}:\n", .{entry.day_number});
            printParts(metrics, "");
            printMetrics(metrics);
        }
    } else {
        std.debug.print("Day {d} not implemented yet\n", .{day});
    }
}
