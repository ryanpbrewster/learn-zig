const std = @import("std");

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();
    const arg1 = args.next() orelse {
        std.debug.print("Usage: ./farey.exe <max_denominator>\n", .{});
        return;
    };
    const d_max = std.fmt.parseUnsigned(u32, arg1, 10) catch {
        std.debug.print("invalid value for max_denominator: {s}\n", .{arg1});
        return;
    };
    explore(Frac{ .n = 0, .d = 1 }, Frac{ .n = 1, .d = 1 }, d_max);
}

const Frac = struct {
    n: u32,
    d: u32,
};

fn explore(lo: Frac, hi: Frac, d_max: u32) void {
    const mid = find_midpoint(lo, hi);
    if (mid.d > d_max) return;

    explore(lo, mid, d_max);
    std.debug.print("{d:.4} --- {}/{}\n", .{ @as(f64, @floatFromInt(mid.n)) / @as(f64, @floatFromInt(mid.d)), mid.n, mid.d });
    explore(mid, hi, d_max);
}

fn find_midpoint(lo: Frac, hi: Frac) Frac {
    return Frac{ .n = lo.n + hi.n, .d = lo.d + hi.d };
}
