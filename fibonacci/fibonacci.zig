const std = @import("std");

pub fn main() void {
    var a: u64 = 0;
    var b: u64 = 1;

    var i: u32 = 0;
    while (i < 50) : (i += 1) {
        std.debug.print("{}\n", .{b});
        const t = b;
        b += a;
        a = t;
    }
}
