const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Sieve = struct {
    const Self = @This();

    arr: ArrayList(bool),
    fn init(allocator: *Allocator, size: u32) !Sieve {
        var arr = ArrayList(bool).init(allocator);
        try arr.ensureTotalCapacity(size);
        var i: u32 = 0;
        while (i < size) : (i += 1) {
            try arr.append(true);
        }
        i = 2;
        while (i * i < size) : (i += 1) {
            var j: u32 = i * i;
            while (j < size) : (j += i) {
                arr.items[j] = false;
            }
        }
        return Sieve {
            .arr = arr,
        };
    }
    fn deinit(self: *Self) void {
        self.arr.deinit();
    }
    fn is_prime(self: *Self, n: u32) bool {
        return self.arr.items[n];
    }
};

test "smoke test" {
    var sieve = try Sieve.init(testing.allocator, 20);
    defer sieve.deinit();
    const primes = [_]u32{2, 3, 5, 7, 11, 13, 17, 19};
    const composites = [_]u32{4, 6, 8, 9, 10, 12, 14, 15, 16, 18};
    for (primes) |p| {
        try testing.expect(sieve.is_prime(p));
    }
    for (composites) |c| {
        try testing.expect(!sieve.is_prime(c));
    }
}
