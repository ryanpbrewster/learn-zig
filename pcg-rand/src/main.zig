const std = @import("std");

const Pcg = struct {
    state: u64,
    inc: u64,

    pub fn new(initstate: u32, initseq: u32) Pcg {
        var rng = Pcg{ .state = 0, .inc = (initseq << 1) | 1 };
        _ = rng.next();
        rng.state += initstate;
        _ = rng.next();
        return rng;
    }

    // The C reference implementation relies on normal "wrapping" arithemtic.
    // In Zig, the * operator has "panic on overflow" semantics.
    // The C-like "wrapping" behavior requires the *% operator.
    // The same holds for addition (+%) and negation (-%).
    fn next(self: *Pcg) u32 {
        const oldstate = self.state;
        self.state = oldstate *% 6364136223846793005 +% self.inc;
        const xorshifted = @truncate(u32, ((oldstate >> 18) ^ oldstate) >> 27);
        // Zig seems incredibly opinionated about making sure that bit-shifts are valid.
        // Technically, a u64 shifted by 59 can have at most 5 bits.
        // A 5-bit integer can represent [0, 32).
        // Thus, it is safe to right-shift a u64 by a u5, or even a u6, but not a u7.
        const rot = @truncate(u5, oldstate >> 59);
        return @truncate(u32, (xorshifted >> rot) | (xorshifted << ((-%rot) & 31)));
    }
};

test "pcg known seed" {
    var rand = Pcg.new(19, 84);
    try std.testing.expectEqual(rand.next(), 3180937136);
    try std.testing.expectEqual(rand.next(), 658176402);
    try std.testing.expectEqual(rand.next(), 2336700338);
    try std.testing.expectEqual(rand.next(), 4208611657);
    try std.testing.expectEqual(rand.next(), 1614422100);
}
