const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const FixedSieve = struct {
    const Self = @This();

    allocator: Allocator,
    arr: []bool,
    fn init(allocator: Allocator, size: u32) !FixedSieve {
        var arr = try allocator.alloc(bool, size);
        var i: u32 = 0;
        while (i < size) : (i += 1) {
            arr[i] = i >= 2;
        }
        i = 2;
        while (i * i < size) : (i += 1) {
            var j: u32 = i * i;
            while (j < size) : (j += i) {
                arr[j] = false;
            }
        }
        return FixedSieve{
            .allocator = allocator,
            .arr = arr,
        };
    }
    fn deinit(self: *Self) void {
        self.allocator.free(self.arr);
    }
    fn is_prime(self: *Self, n: u32) SieveErr!bool {
        if (n >= self.arr.len) return SieveErr.OutOfBounds;
        return self.arr[n];
    }
};
const SieveErr = error{
    OutOfBounds,
};

const DynamicSieve = struct {
    const Self = @This();

    arr: ArrayList(bool),
    fn init(allocator: Allocator) DynamicSieve {
        return DynamicSieve{
            .arr = ArrayList(bool).init(allocator),
        };
    }
    fn deinit(self: *Self) void {
        self.arr.deinit();
    }
    fn is_prime(self: *Self, n: u32) !bool {
        try self.expand(n);
        return self.arr.items[n];
    }
    fn expand(self: *Self, n: u32) !void {
        if (n < self.arr.items.len) return;
        try self.arr.appendNTimes(true, n - self.arr.items.len + 1);
        var i: u32 = 2;
        while (i * i <= n) : (i += 1) {
            if (self.arr.items[i]) {
                var j: u32 = i * i;
                while (j <= n) : (j += i) {
                    self.arr.items[j] = false;
                }
            }
        }
    }
};

test "fixed smoke test" {
    var sieve = try FixedSieve.init(testing.allocator, 20);
    defer sieve.deinit();
    const primes = [_]u32{ 2, 3, 5, 7, 11, 13, 17, 19 };
    const composites = [_]u32{ 4, 6, 8, 9, 10, 12, 14, 15, 16, 18 };
    for (primes) |p| {
        try testing.expect(try sieve.is_prime(p));
    }
    for (composites) |c| {
        try testing.expect(!try sieve.is_prime(c));
    }
}

test "fixed sieve has a limited range" {
    var sieve = try FixedSieve.init(testing.allocator, 20);
    defer sieve.deinit();
    try std.testing.expectEqual(sieve.is_prime(50), SieveErr.OutOfBounds);
}

test "dynamic smoke test" {
    var sieve = DynamicSieve.init(testing.allocator);
    defer sieve.deinit();
    const primes = [_]u32{ 2, 3, 5, 7, 11, 13, 17, 19 };
    const composites = [_]u32{ 4, 6, 8, 9, 10, 12, 14, 15, 16, 18 };
    for (primes) |p| {
        try testing.expect(try sieve.is_prime(p));
    }
    for (composites) |c| {
        try testing.expect(!try sieve.is_prime(c));
    }
}

test "dynamic sieve large numbers" {
    var sieve = DynamicSieve.init(testing.allocator);
    defer sieve.deinit();
    try testing.expect(!try sieve.is_prime(1_000_000));
    try testing.expect(try sieve.is_prime(999_983));
}
