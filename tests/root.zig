// Re-export test modules
pub const day1_tests = @import("day1.zig");
pub const day2_tests = @import("day2.zig");
pub const day3_tests = @import("day3.zig");
pub const day4_tests = @import("day4.zig");
pub const day5_tests = @import("day5.zig");
pub const day6_tests = @import("day6.zig");
pub const day7_tests = @import("day7.zig");
pub const day8_tests = @import("day8.zig");

// Force compilation by using the modules
comptime {
    _ = day1_tests;
    _ = day2_tests;
    _ = day3_tests;
    _ = day4_tests;
    _ = day5_tests;
    _ = day6_tests;
    _ = day7_tests;
    _ = day8_tests;
}
