const std  = @import("std");
const aoz = @import("advent_of_zig_2025");

test "starting from 50 L68 return 82" {
    const start = 50;
    const ops = [_]i32{-68};
    try std.testing.expectEqual(@as(i32, 82), aoz.turn(start, ops[0]));
}

test "starging from 50 {L68, L30} return 52" {
    const ops = [_]i32{ -68, -30 };
    var start: i32 = 50;
    for (ops) |value| {
        start = aoz.turn(start, value);
    }
    try std.testing.expectEqual(@as(i32, 52), start);
}

test "starging from 50 {L68, L30, R48} return 0" {
    const ops = [_]i32{ -68, -30, 48 };
    var start: i32 = 50;
    for (ops) |value| {
        start = aoz.turn(start, value);
    }
    try std.testing.expectEqual(@as(i32, 0), start);
}

test "complete example return 32" {
    const ops = [_]i32{ -68, -30, 48, 55, -55, -1, -99, 14, -82 };
    var start: i32 = 50;
    for (ops) |value| {
        start = aoz.turn(start, value);
    }
    try std.testing.expectEqual(@as(i32, 32), start);
}

test "complete example return 0 3 times" {
    const ops = [_]i32{ -68, -30, 48, 55, -55, -1, -99, 14, -82 };
    var start: i32 = 50;
    var i: i32 = 0;
    for (ops) |value| {
        start = aoz.turn(start, value);
        if (start == 0) {
            i += 1;
        }
    }
}

test "example part 2 L68 from 50 crosses 0 once" {
    const start = 50;
    const op = -68;
    try std.testing.expectEqual(@as(i32, 1), aoz.countZeroCrossings(start, op));
}

test "example part 2 L30 from 82 does not cross 0" {
    const start = 82;
    const op = -30;
    try std.testing.expectEqual(@as(i32, 0), aoz.countZeroCrossings(start, op));
}

test "example part 2 R48 from 52 crosses 0 once" {
    const start = 52;
    const op = 48;
    try std.testing.expectEqual(@as(i32, 1), aoz.countZeroCrossings(start, op));
}

test "example part 2 R60 from 95 crosses 0 once" {
    const start = 95;
    const op = 60;
    try std.testing.expectEqual(@as(i32, 1), aoz.countZeroCrossings(start, op));
}

test "example part 2 L82 from 14 crosses 0 once" {
    const start = 14;
    const op = -82;
    try std.testing.expectEqual(@as(i32, 1), aoz.countZeroCrossings(start, op));
}

test "example part 2 complete returns 5" {
    const ops = [_]i32{ -68, -30, 48, 55, -55, -1, -99, 14, -82 };
    var start: i32 = 50;
    var res: i32 = 0;
    for (ops) |value| {
        res += aoz.countZeroCrossings(start, value);
        start = aoz.turn(start, value);
    }
    try std.testing.expectEqual(@as(i32, 5), res);
}
