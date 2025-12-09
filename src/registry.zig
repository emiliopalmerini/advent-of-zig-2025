const std = @import("std");
const u = @import("utils");

/// A registered day solution with its metadata
pub const DaySolutionEntry = struct {
    day_number: usize,
    solution: ?u.solution.DaySolution,
};

/// Build the registry by importing all day solutions
/// Add new days here as you implement them
pub const all_solutions = blk: {
    var days: [12]DaySolutionEntry = undefined;
    
    days[0] = .{ .day_number = 1, .solution = @import("day01/solution.zig").Day1Solution.asDaySolution() };
    days[1] = .{ .day_number = 2, .solution = @import("day02/solution.zig").Day2Solution.asDaySolution() };
    days[2] = .{ .day_number = 3, .solution = @import("day03/solution.zig").Day3Solution.asDaySolution() };
    days[3] = .{ .day_number = 4, .solution = @import("day04/solution.zig").Day4Solution.asDaySolution() };
    days[4] = .{ .day_number = 5, .solution = @import("day05/solution.zig").Day5Solution.asDaySolution() };
    days[5] = .{ .day_number = 6, .solution = @import("day06/solution.zig").Day6Solution.asDaySolution() };
    days[6] = .{ .day_number = 7, .solution = @import("day07/solution.zig").Day7Solution.asDaySolution() };
    days[7] = .{ .day_number = 8, .solution = @import("day08/solution.zig").Day8Solution.asDaySolution() };
    days[8] = .{ .day_number = 9, .solution = @import("day09/solution.zig").Day9Solution.asDaySolution() };
    days[9] = .{ .day_number = 10, .solution = @import("day10/solution.zig").Day10Solution.asDaySolution() };
    days[10] = .{ .day_number = 11, .solution = null }; // TODO: day 11
    days[11] = .{ .day_number = 12, .solution = null }; // TODO: day 12
    
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
