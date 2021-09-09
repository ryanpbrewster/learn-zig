const std = @import("std");
const sort = std.sort;
const Allocator = std.mem.Allocator;
const PriorityQueue = std.PriorityQueue;
const testing = std.testing;
const DefaultPrng = std.rand.DefaultPrng;
const ArrayList = std.ArrayList;

fn less_than(a: i32, b: i32) std.math.Order {
    return std.math.order(a, b);
}
fn greater_than(a: i32, b: i32) std.math.Order {
    return std.math.order(a, b).invert();
}
const Median = struct {
    const Self = @This();

    lo: PriorityQueue(i32), // a max-heap of small items
    hi: PriorityQueue(i32), // a min-heap of large items

    fn new(allocator: *Allocator) Self {
        return Median{
            .lo = PriorityQueue(i32).init(allocator, greater_than),
            .hi = PriorityQueue(i32).init(allocator, less_than),
        };
    }
    fn deinit(self: *Self) void {
        self.lo.deinit();
        self.hi.deinit();
    }
    fn get_median(self: *Self) ?i32 {
        return self.lo.peek();
    }

    fn push(self: *Self, value: i32) !void {
        if (self.lo.peek()) |mid| {
            if (value <= mid) {
                try self.lo.add(value);
            } else {
                try self.hi.add(value);
            }
        } else {
            try self.lo.add(value);
        }
        try self.rebalance();
    }

    fn rebalance(self: *Self) !void {
        while (self.hi.count() > self.lo.count()) {
            try self.lo.add(self.hi.remove());
        }
        while (self.lo.count() > self.hi.count() + 1) {
            try self.hi.add(self.lo.remove());
        }
    }
};

test "smoke test" {
    var m = Median.new(testing.allocator);
    defer m.deinit();
    try m.push(3);
    try m.push(1);
    try m.push(4);
    try testing.expectEqual(m.get_median(), 3);
    try m.push(1);
    try m.push(5);
    try m.push(9);
    // [3, 1, 4, 1, 5, 9] --> [1, 1, 3, 4, 5, 9]
    try testing.expectEqual(m.get_median(), 3);
}

test "sorted asc" {
    var m = Median.new(testing.allocator);
    defer m.deinit();

    var i: i32 = 0;
    while (i < 10) : (i += 1) {
        try m.push(i);
        try testing.expectEqual(m.get_median(), @divTrunc(i, 2));
    }
}

test "psuedo-random" {
    var m = Median.new(testing.allocator);
    defer m.deinit();

    var buf = ArrayList(i32).init(testing.allocator);
    defer buf.deinit();

    var prng = DefaultPrng.init(42);
    var i: i32 = 0;
    while (i < 1_000) : (i += 1) {
        const x = prng.random.int(i32);
        try m.push(x);
        try buf.append(x);
        try testing.expectEqual(m.get_median(), brute_force_median(buf.items));
    }
}

fn brute_force_median(xs: []i32) ?i32 {
    sort.sort(i32, xs, {}, comptime sort.asc(i32));
    return xs[@divTrunc(xs.len - 1, 2)];
}
