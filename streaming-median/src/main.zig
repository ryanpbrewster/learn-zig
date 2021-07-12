const std = @import("std");
const Allocator = std.mem.Allocator;
const PriorityQueue = std.PriorityQueue;
const testing = std.testing;

fn less_than(a: i32, b: i32) bool {
    return a < b;
}
fn greater_than(a: i32, b: i32) bool {
    return a > b;
}
const Median = struct {
  const Self = @This();

  lo: PriorityQueue(i32), // a max-heap of small items
  hi: PriorityQueue(i32), // a min-heap of large items

  fn new(allocator: *Allocator) Self {
    return Median {
      .lo = PriorityQueue(i32).init(allocator, less_than),
      .hi = PriorityQueue(i32).init(allocator, greater_than),
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
  testing.expectEqual(m.get_median(), 3);
}
