const std = @import("std");
const advent = @import("advent_of_zig_2025");
const u = @import("utils");

fn showPerformanceMetrics(allocator: std.mem.Allocator) !void {
    const solutions: [8]u.solution.DaySolution = .{
        advent.day1.Day1Solution.asDaySolution(),
        advent.day2.Day2Solution.asDaySolution(),
        advent.day3.Day3Solution.asDaySolution(),
        advent.day4.Day4Solution.asDaySolution(),
        advent.day5.Day5Solution.asDaySolution(),
        advent.day6.Day6Solution.asDaySolution(),
        advent.day7.Day7Solution.asDaySolution(),
        advent.day8.Day8Solution.asDaySolution(),
    };

    var total_time: f64 = 0;

    std.debug.print("\nAdvent of Code 2025 - Performance Metrics\n", .{});
    std.debug.print("=========================================\n\n", .{});
    std.debug.print("{s:<5} {s:<18} {s:<18} {s:<18}\n", .{ "Day", "Part 1 (ms)", "Part 2 (ms)", "Total (ms)" });
    std.debug.print("{s:<5} {s:<18} {s:<18} {s:<18}\n", .{ "---", "-----------", "-----------", "----------" });

    for (solutions, 0..) |solution, idx| {
        const day = idx + 1;
        const metrics = try solution.getMetrics(allocator);
        total_time += metrics.total_time_ms();

        std.debug.print("{d:<5} {d:<18.6} {d:<18.6} {d:<18.6}\n", .{
            day,
            metrics.part1_time_ms,
            metrics.part2_time_ms,
            metrics.total_time_ms(),
        });
    }

    std.debug.print("{s:<5} {s:<18} {s:<18} {d:<18.6}\n", .{ "---", "", "", total_time });
    std.debug.print("\nTotal Time: {d:.6} ms\n", .{total_time});
}

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <day|performance> [performance]\n", .{args[0]});
        std.debug.print("Examples:\n", .{});
        std.debug.print("  {s} 1              - Run day 1\n", .{args[0]});
        std.debug.print("  {s} 1 performance  - Run day 1 and show performance\n", .{args[0]});
        std.debug.print("  {s} performance    - Show performance metrics for all days\n", .{args[0]});
        return;
    }

    // Check if performance flag only
    if (std.mem.eql(u8, args[1], "performance")) {
        return try showPerformanceMetrics(allocator);
    }

    const day = std.fmt.parseInt(usize, args[1], 10) catch {
        std.debug.print("Error: Invalid day number\n", .{});
        return;
    };

    const solutions: [8]u.solution.DaySolution = .{
        advent.day1.Day1Solution.asDaySolution(),
        advent.day2.Day2Solution.asDaySolution(),
        advent.day3.Day3Solution.asDaySolution(),
        advent.day4.Day4Solution.asDaySolution(),
        advent.day5.Day5Solution.asDaySolution(),
        advent.day6.Day6Solution.asDaySolution(),
        advent.day7.Day7Solution.asDaySolution(),
        advent.day8.Day8Solution.asDaySolution(),
    };

    if (day < 1 or day > solutions.len) {
        std.debug.print("Day {d} not implemented yet\n", .{day});
        return;
    }

    const solution = solutions[day - 1];
    const metrics = try solution.getMetrics(allocator);
    
    std.debug.print("Part 1: {d}\n", .{metrics.part1_result});
    std.debug.print("Part 2: {d}\n", .{metrics.part2_result});
    
    // Show performance only if second arg is "performance"
    if (args.len > 2 and std.mem.eql(u8, args[2], "performance")) {
        std.debug.print("\nPerformance:\n", .{});
        std.debug.print("  Part 1: {d:.6} ms\n", .{metrics.part1_time_ms});
        std.debug.print("  Part 2: {d:.6} ms\n", .{metrics.part2_time_ms});
        std.debug.print("  Total:  {d:.6} ms\n", .{metrics.total_time_ms()});
    }
}
