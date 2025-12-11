const std = @import("std");
const u = @import("utils");

// Single source of truth: import all day solutions here
pub const day1 = @import("day01/solution.zig");
pub const day2 = @import("day02/solution.zig");
pub const day3 = @import("day03/solution.zig");
pub const day4 = @import("day04/solution.zig");
pub const day5 = @import("day05/solution.zig");
pub const day6 = @import("day06/solution.zig");
pub const day7 = @import("day07/solution.zig");
pub const day8 = @import("day08/solution.zig");
pub const day9 = @import("day09/solution.zig");
pub const day10 = @import("day10/solution.zig");
pub const day11 = @import("day11/solution.zig");

/// A registered day solution with its metadata
pub const DaySolutionEntry = struct {
    day_number: usize,
    solution: ?u.solution.DaySolution,
};

/// Build the registry by using the imported day solutions above
/// This is now the single source of truth - edit ONLY here when adding days
pub const all_solutions = blk: {
    var days: [12]DaySolutionEntry = undefined;

    days[0] = .{ .day_number = 1, .solution = day1.Day1Solution.asDaySolution() };
    days[1] = .{ .day_number = 2, .solution = day2.Day2Solution.asDaySolution() };
    days[2] = .{ .day_number = 3, .solution = day3.Day3Solution.asDaySolution() };
    days[3] = .{ .day_number = 4, .solution = day4.Day4Solution.asDaySolution() };
    days[4] = .{ .day_number = 5, .solution = day5.Day5Solution.asDaySolution() };
    days[5] = .{ .day_number = 6, .solution = day6.Day6Solution.asDaySolution() };
    days[6] = .{ .day_number = 7, .solution = day7.Day7Solution.asDaySolution() };
    days[7] = .{ .day_number = 8, .solution = day8.Day8Solution.asDaySolution() };
    days[8] = .{ .day_number = 9, .solution = day9.Day9Solution.asDaySolution() };
    days[9] = .{ .day_number = 10, .solution = day10.Day10Solution.asDaySolution() };
    days[10] = .{ .day_number = 11, .solution = day11.Day11Solution.asDaySolution() };
    days[11] = .{ .day_number = 12, .solution = null };

    break :blk days;
};

/// Get a solution by day number (1-indexed)
/// Returns null if the day is not implemented
pub fn getSolution(day: usize) ?DaySolutionEntry {
    if (day < 1 or day > all_solutions.len) {
        return null;
    }
    const entry = all_solutions[day - 1];
    if (entry.solution == null) {
        return null;
    }
    return entry;
}

/// Get all registered solutions that are implemented
pub fn getImplementedSolutions() []const DaySolutionEntry {
    return &all_solutions;
}

/// Get the total number of available day slots
pub fn getTotalDayCount() usize {
    return all_solutions.len;
}
