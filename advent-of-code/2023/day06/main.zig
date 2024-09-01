const std = @import("std");

const Results = struct {
    t: usize,
    d: usize,

    fn eval(self: Results) usize {
        // std.debug.print("eval: t={} d={} =>\n", .{ self.t, self.d });
        const lower = self.find_lower(self.t / 2, 0);
        const upper = self.find_upper(self.t / 2, self.t);
        // std.debug.print("eval: t={} d={} => {}-{}\n", .{ self.t, self.d, lower, upper });
        return upper - lower + 1;
    }

    fn find_upper(self: Results, upper: usize, prev: usize) usize {
        const di = self.find_distance(upper);
        // std.debug.print("eval upper: {} w/prev: {} (d: {?})\n", .{ upper, prev, di });
        if (di != null) {
            const dj = self.find_distance(upper + 1);
            if (dj == null) {
                return upper;
            } else {
                const next = (self.t - upper) / 2;
                return self.find_upper(upper + next, upper);
            }
        } else {
            if (upper == prev) return self.find_upper(upper - 1, upper - 1);
            const a = if (upper > prev) (upper - prev) / 2 else (prev - upper) / 2;
            return self.find_upper(upper - a, upper);
        }
    }

    fn find_lower(self: Results, lower: usize, prev: usize) usize {
        const di = self.find_distance(lower);
        // std.debug.print("eval lower: {} w/prev: {} (d: {?})\n", .{ lower, prev, di });
        if (di != null) {
            const dj = self.find_distance(lower - 1);
            if (dj == null) {
                return lower;
            } else {
                const next = lower / 2;
                return self.find_lower(lower - next, lower);
            }
        } else {
            if (lower == prev) return self.find_lower(lower + 1, lower + 1);
            const a = if (lower > prev) (lower - prev) / 2 else (prev - lower) / 2;
            return self.find_lower(lower + a, lower);
        }
    }

    fn find_distance(self: Results, ti: usize) ?usize {
        const di = (self.t - ti) * ti;
        if (di > self.d) {
            return di;
        } else {
            return null;
        }
    }
};

test "find bounds" {
    const r: Results = .{ .t = 7, .d = 9 };
    std.debug.assert(r.find_lower(7 / 2, 0) == 2);
    std.debug.assert(r.find_upper(7 / 2, 7) == 5);
}

test "find distance" {
    const r1: Results = .{ .t = 7, .d = 9 };
    std.debug.assert(r1.find_distance(0) == null);
    std.debug.assert(r1.find_distance(1) == null);
    std.debug.assert(r1.find_distance(2) == 10);
    std.debug.assert(r1.find_distance(3) == 12);
    std.debug.assert(r1.find_distance(4) == 12);
    std.debug.assert(r1.find_distance(5) == 10);
    std.debug.assert(r1.find_distance(6) == null);
    std.debug.assert(r1.find_distance(7) == null);

    const r3: Results = .{ .t = 30, .d = 200 };
    std.debug.assert(r3.find_distance(10) == null);
    std.debug.assert(r3.find_distance(11) != null);
    std.debug.assert(r3.find_distance(19) != null);
    std.debug.assert(r3.find_distance(20) == null);
}

test "sim test" {
    const r1: Results = .{ .t = 7, .d = 9 };
    const r1e = r1.eval();
    const r2: Results = .{ .t = 15, .d = 40 };
    const r2e = r2.eval();
    const r3: Results = .{ .t = 30, .d = 200 };
    const r3e = r3.eval();
    std.debug.print("R: {} {} {}\n", .{ r1e, r2e, r3e });
    std.debug.print("Total: {}\n", .{r1e * r2e * r3e});

    const r: Results = .{ .t = 71530, .d = 940200 };
    std.debug.print("R: {}\n", .{r.eval()});
}

fn run() void {
    const r1: Results = .{ .t = 45, .d = 305 };
    const r1e = r1.eval();
    const r2: Results = .{ .t = 97, .d = 1062 };
    const r2e = r2.eval();
    const r3: Results = .{ .t = 72, .d = 1110 };
    const r3e = r3.eval();
    const r4: Results = .{ .t = 95, .d = 1695 };
    const r4e = r4.eval();
    std.debug.print("R: {} {} {} {}\n", .{ r1e, r2e, r3e, r4e });
    std.debug.print("Total: {}\n", .{r1e * r2e * r3e * r4e});
    const r: Results = .{ .t = 45977295, .d = 305106211101695 };
    std.debug.print("Total: {}\n", .{r.eval()});
}

pub fn main() !void {
    std.debug.print("AoC 2023 - Day {s}", .{"06"});
    run();
}
