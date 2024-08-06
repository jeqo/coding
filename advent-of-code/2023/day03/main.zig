//! AoC2023 day 3
//! In this case there are numbers that are compose by digits.
//! A number may be adjacent to a symbol
//! If it's adjacent, then it should be included in the sum.
//! For a number to be adjacent we need some way to keep track of symbols
//! and adjacent ranges
//! To avoid keeping all in memory,
//! a line can be processed if we know the previous and next line
//! My idea is to keep a buffer of 3 lines in memory.
//! Then by keeping number positions, and symbol positions,
//! we can process the buffer and keep only the numbers that we want.
const std = @import("std");
const print = std.debug.print;
const ascii = std.ascii;
const heap = std.heap;

const assert = std.debug.assert;
const expect = std.testing.expect;

test "id number" {
    const line = "...123...";
    var idx: u8 = 0;

    var start: u8 = 0;
    var end: u8 = 0;

    for (line) |byte| {
        if (ascii.isDigit(byte)) {
            print("Found digit: {c} at {}\n", .{ byte, idx });
            if (start == 0) {
                start = idx;
            }
        } else {
            if (start > 0 and end == 0) {
                print("Not found digit at {}\n", .{idx});
                end = idx - 1;
            }
        }
        idx = idx + 1;
    }

    print("Num range: {} {}\n", .{ start, end });
}

test "appen nums and symbols and eval parts" {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var b = Buffer.init(alloc);
    defer {
        for (0..3) |i| {
            b.nums[i].deinit();
            b.symbols[i].deinit();
        }
        b.results.deinit();
    }

    var idx: usize = 0;
    try b.append("5.*..", idx);
    assert(b.nums[idx].get(.{ .pos = 0, .len = 1 }) == 5);
    assert(b.symbols[idx].get(2) == '*');

    assert(b.nums[0].count() == 1);
    assert(b.symbols[0].count() == 1);
    assert(b.nums[1].count() == 0);
    assert(b.symbols[1].count() == 0);
    assert(b.nums[2].count() == 0);
    assert(b.symbols[2].count() == 0);

    idx += 1;
    try b.append(".123.6", idx);
    assert(b.nums[idx].get(.{ .pos = 1, .len = 3 }) == 123);
    assert(b.nums[idx].get(.{ .pos = 5, .len = 1 }) == 6);

    assert(b.nums[0].count() == 1);
    assert(b.symbols[0].count() == 1);
    assert(b.nums[1].count() == 2);
    assert(b.symbols[1].count() == 0);
    assert(b.nums[2].count() == 0);
    assert(b.symbols[2].count() == 0);
    try b.eval_parts(idx - 1);

    idx += 1;
    try b.append("-3.2.1", idx);
    assert(b.symbols[idx].get(0) == '-');
    assert(b.nums[idx].get(.{ .pos = 1, .len = 1 }) == 3);
    assert(b.nums[idx].get(.{ .pos = 3, .len = 1 }) == 2);
    assert(b.nums[idx].get(.{ .pos = 5, .len = 1 }) == 1);

    assert(b.nums[0].count() == 1);
    assert(b.symbols[0].count() == 1);
    assert(b.nums[1].count() == 2);
    assert(b.symbols[1].count() == 0);
    assert(b.nums[2].count() == 3);
    assert(b.symbols[2].count() == 1);
    try b.eval_parts(idx - 1);

    idx += 1;
    try b.append("%4.6..", idx);
    assert(b.nums[0].get(.{ .pos = 1, .len = 1 }) == 4);
    assert(b.nums[0].get(.{ .pos = 3, .len = 1 }) == 6);
    assert(b.symbols[0].get(0) == '%');
    assert(b.nums[0].count() == 2);
    assert(b.symbols[0].count() == 1);
    assert(b.nums[1].count() == 2);
    assert(b.symbols[1].count() == 0);
    assert(b.nums[2].count() == 3);
    assert(b.symbols[2].count() == 1);
    try b.eval_parts(idx - 1);

    idx += 1;
    try b.append("", idx);
    assert(b.symbols[0].get(0) == '%');
    assert(b.nums[0].count() == 2);
    assert(b.symbols[0].count() == 1);
    assert(b.nums[1].count() == 0);
    assert(b.symbols[1].count() == 0);
    assert(b.nums[2].count() == 3);
    assert(b.symbols[2].count() == 1);
    try b.eval_parts(idx - 1);

    print("Sum {}\n", .{b.part_sum});
    assert(b.part_sum == 130);
}

test "eval gears" {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var b = Buffer.init(alloc);
    defer {
        for (0..3) |i| {
            b.nums[i].deinit();
            b.symbols[i].deinit();
        }
        b.results.deinit();
    }
    try b.append("5..1.", 0);
    try b.append("5.*..", 1);
    try b.append("...3.", 2);
    try b.eval_gears(1);
    try b.append("5*1.3", 3);
    try b.append("", 4);
    try b.eval_gears(3);

    assert(b.gear_ratio_sum == 8);
}

const mem = std.mem;
const fmt = std.fmt;

const Range = struct {
    pos: usize,
    len: usize,
};

// A buffer keeps the 3 lines in-mem to be evaluated
// it captures numbers and symbols, and eval results.
const Buffer = struct {
    nums: [3]std.AutoHashMap(Range, usize),
    symbols: [3]std.AutoHashMap(usize, u8),
    results: std.ArrayList(usize),
    part_sum: usize = 0,
    gears: usize = 0,
    gear_ratio_sum: usize = 0,
    alloc: mem.Allocator,

    // allocate maps and results list
    pub fn init(alloc: mem.Allocator) Buffer {
        var nums: [3]std.AutoHashMap(Range, usize) = undefined;
        var symbols: [3]std.AutoHashMap(usize, u8) = undefined;
        for (0..3) |i| {
            nums[i] = std.AutoHashMap(Range, usize).init(alloc);
            symbols[i] = std.AutoHashMap(usize, u8).init(alloc);
        }
        const results = std.ArrayList(usize).init(alloc);
        return Buffer{ .nums = nums, .symbols = symbols, .results = results, .alloc = alloc };
    }

    // append a new line
    pub fn append(self: *Buffer, line: []const u8, idx: usize) !void {
        // rotate position around buffer
        const pos = idx % 3;
        // find maps and clean them
        var nums = &self.nums[pos];
        nums.clearAndFree();
        var symbols = &self.symbols[pos];
        symbols.clearAndFree();

        // track where a number starts
        var num_start: ?usize = null;

        var i: usize = 0;
        for (line) |c| {
            if (ascii.isDigit(c)) {
                if (num_start == null) { // mark the beginning of a number starts and move on
                    num_start = i;
                }
            } else {
                if (num_start != null) { // til a non-number is found, and number can be collected
                    // collect number
                    const j = num_start.?;
                    const digits = line[j..i];
                    const num = try fmt.parseUnsigned(usize, digits, 10);
                    try nums.put(.{ .pos = num_start.?, .len = i - j }, num);
                    // reset number start for other numbers to come
                    num_start = null;
                }

                if (c != '.') { // collect symbols
                    try symbols.put(i, c);
                }
            }
            i += 1;
        }
        if (num_start != null) {
            // collect number
            const j = num_start.?;
            const digits = line[j..i];
            const num = try fmt.parseUnsigned(usize, digits, 10);
            try nums.put(.{ .pos = num_start.?, .len = i - j }, num);
        }
    }

    // gather num positions and build ranges to search for
    // 3 rounds across symbols before, current, and after
    // check on each round: if symbol match range
    pub fn eval_parts(self: *Buffer, pos: usize) !void {
        const curr = pos % 3;
        const next = if (curr < 2) curr + 1 else 0;

        var nums = self.nums[curr];

        var sum: usize = 0;
        var count: usize = 0;

        // first round
        {
            const symbols = self.symbols[curr];

            var num_iter = nums.iterator();
            while (num_iter.next()) |num| {
                const from = num.key_ptr.pos;
                const to = from + num.key_ptr.len;

                const before = from > 0 and symbols.get(from - 1) != null;
                const after = symbols.get(to) != null;
                if (before or after) {
                    const found = nums.fetchRemove(num.key_ptr.*).?;
                    // print("Found 1st: {} nums left {}\n", .{ found.value, nums.count() });
                    sum += found.value;
                    count += 1;
                    try self.results.append(found.value);
                }
            }
        }

        // second round
        if (pos > 0) {
            const prev = if (curr == 0) 2 else curr - 1;
            const prev_symbols = self.symbols[prev];
            var prev_iter = prev_symbols.iterator();
            while (prev_iter.next()) |s| {
                var num_iter = nums.iterator();
                while (num_iter.next()) |num| {
                    const from = num.key_ptr.pos;
                    const _from = if (from > 0) from - 1 else from;
                    const to = from + num.key_ptr.len;
                    const at = s.key_ptr.*;

                    // print("Check 2nd: {}:{} {}:{c}\n", .{ _from, to, at, s.value_ptr.* });
                    if (_from <= at and at <= to) {
                        const found = nums.fetchRemove(num.key_ptr.*).?;
                        // print("Found 2nd: {} nums left {}\n", .{ found.value, nums.count() });
                        sum += found.value;
                        count += 1;
                        try self.results.append(found.value);
                    }
                }
            }
        }

        // third round
        {
            const next_symbols = self.symbols[next];
            var next_iter = next_symbols.iterator();
            while (next_iter.next()) |s| {
                var num_iter = nums.iterator();
                while (num_iter.next()) |num| {
                    const from = num.key_ptr.pos;
                    const _from = if (from > 0) from - 1 else from;
                    const to = from + num.key_ptr.len;
                    const at = s.key_ptr.*;
                    // print("Check 3rd: {}:{} {}:{c}\n", .{ _from, to, at, s.value_ptr.* });
                    if (_from <= at and at <= to) {
                        const found = nums.fetchRemove(num.key_ptr.*).?;
                        // print("Found 3rd: {} nums left {}\n", .{ found.value, nums.count() });
                        sum += found.value;
                        count += 1;
                        try self.results.append(found.value);
                    }
                }
            }
        }

        self.part_sum += sum;
    }

    // gather num positions and build ranges to search for
    // 3 rounds across symbols before, current, and after
    // check on each round: if symbol match range
    pub fn eval_gears(self: *Buffer, pos: usize) !void {
        const curr = pos % 3;
        const next = if (curr < 2) curr + 1 else 0;

        const symbols = self.symbols[curr];

        var sum: usize = 0;
        var count: usize = 0;

        var s_iter = symbols.iterator();
        while (s_iter.next()) |s| {
            if (s.value_ptr.* == '*') {
                const gear = s.key_ptr.*;
                var adjacents = std.ArrayList(usize).init(self.alloc);
                defer adjacents.deinit();
                // print("Potential gear at {}\n", .{gear});
                // same line
                {
                    var nums = self.nums[curr];
                    var num_iter = nums.iterator();
                    while (num_iter.next()) |num| {
                        const from = num.key_ptr.pos;
                        const before = from == gear + 1;

                        const to = from + num.key_ptr.len;
                        const after = to == gear;
                        // print("Check gear same line  {} within {}:{}\n", .{ gear, from, to });
                        if (before or after) {
                            // print("Found {}\n", .{gear});
                            try adjacents.append(num.value_ptr.*);
                        }
                    }
                }

                // prev line
                if (pos > 0) {
                    const prev = if (curr == 0) 2 else curr - 1;
                    const prev_nums = self.nums[prev];
                    var prev_iter = prev_nums.iterator();
                    while (prev_iter.next()) |n| {
                        const from = n.key_ptr.pos;
                        const _from = if (from > 0) from - 1 else from;
                        const to = from + n.key_ptr.len;

                        // print("Check gear prev line {} within {}:{}\n", .{ gear, _from, to });

                        if (_from <= gear and gear <= to) {
                            // print("Found {}\n", .{gear});
                            try adjacents.append(n.value_ptr.*);
                        }
                    }
                }

                // next line
                {
                    const next_nums = self.nums[next];
                    var next_iter = next_nums.iterator();
                    while (next_iter.next()) |n| {
                        const from = n.key_ptr.pos;
                        const _from = if (from > 0) from - 1 else from;
                        const to = from + n.key_ptr.len;

                        // print("Check gear next line {} within {}:{}\n", .{ gear, _from, to });

                        if (_from <= gear and gear <= to) {
                            // print("Found {}\n", .{gear});
                            try adjacents.append(n.value_ptr.*);
                        }
                    }
                }

                // print("Adj found {}\n", .{adjacents.items.len});
                if (adjacents.items.len == 2) {
                    const n1 = adjacents.pop();
                    const n2 = adjacents.pop();
                    const gear_ratio = n1 * n2;
                    // print("Gear found at {}: {} {} with ratio {}\n", .{ gear, n1, n2, gear_ratio });
                    sum += gear_ratio;
                    count += 1;
                }
            }
        }

        // print("Gears {} with ratio sum {}\n", .{ count, sum });

        self.gears += count;
        self.gear_ratio_sum += sum;
    }
};

const fs = std.fs;
const io = std.io;

fn run_v1() !struct { usize } {
    var file = try fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var b = Buffer.init(alloc);
    var i: usize = 0;
    var len: ?usize = null;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len > 0) {
            if (len == null) len = line.len;
            print("L{}: {s}\n", .{ i, line });
            try b.append(line, i);
            if (i > 0) try b.eval_parts(i - 1);
            i += 1;
        }
    }
    print("L{}:\n", .{i});
    try b.append("", i);
    try b.eval_parts(i - 1);

    return .{b.part_sum};
}

fn run_v2() !struct { usize } {
    var file = try fs.cwd().openFile("input", .{});
    defer file.close();

    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var b = Buffer.init(alloc);
    var i: usize = 0;
    var len: ?usize = null;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len > 0) {
            if (len == null) len = line.len;
            print("L{}: {s}\n", .{ i, line });
            try b.append(line, i);
            if (i > 0) try b.eval_gears(i - 1);
            i += 1;
        }
    }
    print("L{}:\n", .{i});
    try b.append("", i);
    try b.eval_gears(i - 1);

    print("Gears found: {}\n", .{b.gears});
    return .{b.gear_ratio_sum};
}

pub fn main() !void {
    print("AoC2023 - Day {s}\n", .{"03"});
    const result_v1 = try run_v1();
    print("[v1] Result: {}\n", result_v1);
    const result_v2 = try run_v2();
    print("[v2] Result: {}\n", result_v2);
}
