const std = @import("std");
const testing = std.testing;

// Strings in Cpp are null terminated while in zig they are not
// Adding some logic to simulate the same strings on hashing and obtain the same results.
fn NullTerminated(comptime input: []const u8) type {
    return [input.len + 1:0]u8;
}
fn null_terminated_bytes(comptime bytes: []const u8) NullTerminated(bytes) {
    var result: NullTerminated(bytes) = undefined;
    @memcpy(result[0..bytes.len], bytes);
    result[bytes.len] = 0;
    return result;
}

test "null terminated" {
    const input: []const u8 = "Hello";
    const output = null_terminated_bytes(input);
    try testing.expectEqual(6, output.len);
    try testing.expectEqual(0, output[5]);
}

const Hash = u64;
fn hash_bytes(bytes: []const u8) Hash {
    var hash: Hash = bytes.len;
    for (bytes) |b| {
        hash = ((hash << 5) ^ (hash >> 27)) ^ b;
    }
    return hash;
}

test "hash string" {
    const input: []const u8 = "Andy";
    const expected: Hash = 237412128;

    const bytes = null_terminated_bytes(input);
    try std.testing.expectEqual(expected, hash_bytes(&bytes));
}

fn print_bitset_full(bitset: std.bit_set.StaticBitSet(64)) void {
    std.debug.print("Full BitSet: ", .{});
    for (0..64) |i| { // bits ordered in MSB
        std.debug.print("{d}", .{@intFromBool(bitset.isSet(63 - i))});
    }
    std.debug.print("\n", .{});
}

fn compute_binary(hash: Hash) std.bit_set.StaticBitSet(64) {
    var bitset = std.bit_set.StaticBitSet(64).initEmpty();
    for (0..64) |i| {
        const bit_index: u6 = @intCast(i);
        const mask = @as(u64, 1) << bit_index;
        const is_set = (hash & (mask)) != 0;
        if (is_set) { // ordered in MSB
            bitset.set(63 - bit_index);
        }
    }

    // print_bitset_full(bitset);
    return bitset;
}

test "bytes to binary" {
    const hash: u64 = hash_bytes(&null_terminated_bytes("Andy"));
    var bitset = compute_binary(hash);
    // 0000000000000000000000000000000000001110001001101001111100100000
    for (0..36) |i| try testing.expect(!bitset.isSet(i));
    try testing.expect(bitset.isSet(36));
    try testing.expect(bitset.isSet(37));
    try testing.expect(bitset.isSet(38));
    try testing.expect(!bitset.isSet(39));
    try testing.expect(!bitset.isSet(40));
    //...
    for (59..64) |i| try testing.expect(!bitset.isSet(i));
}

fn extract_first_n_bits(comptime n: u6, bitset: std.bit_set.StaticBitSet(64)) u64 {
    if (n > 64 or n == 0) @compileError("Number of bits must be between 1 and 64");

    var result: u64 = 0;
    for (0..n) |i| {
        if (bitset.isSet(i)) { // already ordered, no need to diff with 63
            result |= @as(u64, 1) << @intCast(n - 1 - i);
        }
    }
    return result;
}

test "extract first 6 bits" {
    const hash: u64 = hash_bytes(&null_terminated_bytes("Andy"));
    const bitset = compute_binary(hash);
    // 0000000000000000000000000000000000001110001001101001111100100000
    try testing.expectEqual(0, extract_first_n_bits(1, bitset));
    try testing.expectEqual(0, extract_first_n_bits(6, bitset));
    try testing.expectEqual(0, extract_first_n_bits(9, bitset));
}

fn position_of_leftmost_one(comptime n: u16, bitset: std.bit_set.StaticBitSet(64)) u64 {
    for (n..64) |i| {
        if (bitset.isSet(i)) { // already ordered, no need to diff with 63
            return i - n + 1;
        }
    }
    return 0;
}

test "leftmost one" {
    const hash: u64 = hash_bytes(&null_terminated_bytes("Andy"));
    const bitset = compute_binary(hash);
    // 0000000000000000000000000000000000001110001001101001111100100000
    try testing.expectEqual(36, position_of_leftmost_one(1, bitset));
    try testing.expectEqual(1, position_of_leftmost_one(36, bitset));
}

pub fn HyperLogLog(comptime T: type, comptime initial_bits: u16) type {
    return struct {
        const Self = @This();

        const CONSTANT: f64 = 0.79402;
        const capacity = std.math.pow(usize, 2, initial_bits);

        register: [std.math.pow(usize, 2, initial_bits)]usize,
        cardinality: u64 = 0,

        pub fn init() Self {
            return .{ .register = [_]usize{0} ** capacity };
        }

        pub fn get_cardinality(self: Self) u64 {
            return self.cardinality;
        }

        pub fn add_element(self: *Self, elem: T) void {
            const hash = self.calculate_hash(elem);
            const bin = compute_binary(hash);
            const b = extract_first_n_bits(initial_bits, bin);
            const r = self.register[b];
            const p = position_of_leftmost_one(initial_bits, bin);
            // std.debug.print("Adding: {any}, hash={}, b={}, p={}\n", .{ elem, hash, b, p });
            self.register[b] = @max(r, p);
        }

        pub fn compute_cardinality(self: *Self) void {
            var sum: f64 = 0;
            for (self.register) |r| {
                const exponent = @as(f64, @floatFromInt(r));
                sum += std.math.pow(f64, 2.0, -exponent);
            }
            const m = @as(f64, capacity);
            const h_mean = (1 / sum);
            const c = CONSTANT * m * m * h_mean;
            self.cardinality = @intFromFloat(std.math.floor(c));
        }

        fn calculate_hash(_: Self, elem: T) Hash {
            if (@TypeOf(elem) == []const u8) {
                return hash_bytes(elem);
            } else {
                return hash_bytes(std.mem.asBytes(&elem));
            }
        }
    };
}

test "hll basic string" {
    var hll = HyperLogLog([]const u8, 1).init();
    try testing.expectEqual(0, hll.get_cardinality());

    hll.add_element(&null_terminated_bytes("Welcome to CMU DB (15-445/645)"));
    hll.compute_cardinality();
    try testing.expectEqual(2, hll.get_cardinality());

    for (0..10) |i| {
        hll.add_element(&null_terminated_bytes("Andy"));
        hll.add_element(&null_terminated_bytes("Connor"));
        hll.add_element(&null_terminated_bytes("J-How"));
        hll.add_element(&null_terminated_bytes("Kunle"));
        hll.add_element(&null_terminated_bytes("Lan"));
        hll.add_element(&null_terminated_bytes("Prashanth"));
        hll.add_element(&null_terminated_bytes("William"));
        hll.add_element(&null_terminated_bytes("Yash"));
        hll.add_element(&null_terminated_bytes("Yuanxin"));
        if (i == 0) {
            hll.compute_cardinality();
            try testing.expectEqual(6, hll.get_cardinality());
        }
    }
}

test "hll basic int" {
    var hll = HyperLogLog(i64, 3).init();
    try testing.expectEqual(0, hll.get_cardinality());

    hll.add_element(0);
    hll.compute_cardinality();
    try testing.expectEqual(7, hll.get_cardinality());

    for (0..10) |i| {
        hll.add_element(10);
        hll.add_element(122);
        hll.add_element(200);
        hll.add_element(911);
        hll.add_element(999);
        hll.add_element(1402);
        hll.add_element(15445);
        hll.add_element(15645);
        hll.add_element(123456);
        hll.add_element(312457);
        if (i == 0) {
            hll.compute_cardinality();
            // adjusting the results as cpp char signed bytes cause a different result (10)
            try testing.expectEqual(7, hll.get_cardinality());
        }
    }
}

pub fn HyperLogLogPresto(comptime T: type, comptime _: u16) type { //leading_bits
    return struct {
        const Self = @This();

        const CONSTANT: f64 = 0.79402;
        const DENSE_BUCKET_SIZE: usize = 4;
        const OVERFLOW_BUCKET_SIZE: usize = 3;

        dense_bucket: std.ArrayList(std.bit_set.StaticBitSet(DENSE_BUCKET_SIZE)),

        pub fn add_element(_: *Self, _: T) void {
            // const hash = self.calculate_hash(elem);
            // const bin = compute_binary(hash);
            // const b = extract_first_n_bits(initial_bits, bin);
            // const r = self.register[b];
            // const p = position_of_leftmost_one(initial_bits, bin);
            // // std.debug.print("Adding: {any}, hash={}, b={}, p={}\n", .{ elem, hash, b, p });
            // self.register[b] = @max(r, p);
        }

        pub fn compute_cardinality(_: *Self) void {
            // var sum: f64 = 0;
            // for (self.register) |r| {
            //     const exponent = @as(f64, @floatFromInt(r));
            //     sum += std.math.pow(f64, 2.0, -exponent);
            // }
            // const m = @as(f64, capacity);
            // const h_mean = (1 / sum);
            // const c = CONSTANT * m * m * h_mean;
            // self.cardinality = @intFromFloat(std.math.floor(c));
        }
    };
}
