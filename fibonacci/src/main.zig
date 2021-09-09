const std = @import("std");

pub fn fib(n: u32) u64 {
    var a: u64 = 1;
    var b: u64 = 0;

    var i: u32 = 1;
    while (i < n) : (i += 1) {
        const t = a;
        a += b;
        b = t;
    }
    return a;
}

test "smoke test" {
    try std.testing.expectEqual(fib(1), 1);
    try std.testing.expectEqual(fib(2), 1);
    try std.testing.expectEqual(fib(3), 2);
    try std.testing.expectEqual(fib(4), 3);
    try std.testing.expectEqual(fib(5), 5);
    try std.testing.expectEqual(fib(10), 55);
    try std.testing.expectEqual(fib(20), 6765);
}
