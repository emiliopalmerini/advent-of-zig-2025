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

const utils = @import("utils");

pub fn getSolution(day: usize) !utils.solution.DaySolution {
    return switch (day) {
        1 => day1.Day1Solution.asDaySolution(),
        2 => day2.Day2Solution.asDaySolution(),
        3 => day3.Day3Solution.asDaySolution(),
        4 => day4.Day4Solution.asDaySolution(),
        5 => day5.Day5Solution.asDaySolution(),
        6 => day6.Day6Solution.asDaySolution(),
        7 => day7.Day7Solution.asDaySolution(),
        8 => day8.Day8Solution.asDaySolution(),
        9 => day9.Day9Solution.asDaySolution(),
        10 => day10.Day10Solution.asDaySolution(),
        else => error.InvalidDay,
    };
}
