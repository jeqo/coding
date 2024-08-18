//! AoC2023 day 4

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const expectEqualSlices = std.testing.expectEqualSlices;

const heap = std.heap;
const io = std.io;

test "card" {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    var card = Card.init(alloc);

    // assert parsing
    const line = "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53";
    try card.parse(line);
    assert(card.id == 1);
    const expected_winning_nums: []const u16 = &.{ 41, 48, 83, 86, 17 };
    try expectEqualSlices(u16, card.winning_nums.items, expected_winning_nums);
    const expected_card_nums: []const u16 = &.{ 83, 86, 6, 31, 17, 9, 48, 53 };
    try expectEqualSlices(u16, card.card_nums.items, expected_card_nums);

    // assert eval
    const points = try card.eval();
    assert(points == 4);

    // next
    card.deinit();
    try card.parse("Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19");
    assert(try card.eval() == 2);
    card.deinit();
    try card.parse("Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1");
    assert(try card.eval() == 2);
    card.deinit();
    try card.parse("Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83");
    assert(try card.eval() == 1);
    card.deinit();
    try card.parse("Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36");
    assert(try card.eval() == 0);
    card.deinit();
    try card.parse("Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11");
    assert(try card.eval() == 0);
}

const mem = std.mem;
const fmt = std.fmt;
const math = std.math;

const Card = struct {
    id: usize,
    winning_nums: std.ArrayList(u16),
    card_nums: std.ArrayList(u16),

    pub fn init(alloc: mem.Allocator) Card {
        const winning_nums = std.ArrayList(u16).init(alloc);
        const card_nums = std.ArrayList(u16).init(alloc);
        return Card{ .id = 0, .winning_nums = winning_nums, .card_nums = card_nums };
    }

    pub fn deinit(self: *Card) void {
        self.winning_nums.deinit();
        self.card_nums.deinit();
        self.id = 0;
    }

    pub fn parse(self: *Card, line: []const u8) !void {
        var card_it = mem.split(u8, line, ":");

        const card_id_part = card_it.next().?;
        var card_id_it = mem.split(u8, card_id_part, " ");
        _ = card_id_it.next(); // ignore constant
        while (card_id_it.next()) |t| {
            if (t.len > 0) {
                const id = try fmt.parseUnsigned(u16, t, 10);
                self.id = id;
                break;
            }
        }

        const card_nums_part = card_it.next().?;
        var nums_it = mem.split(u8, card_nums_part, "|");

        const winning_nums_text = nums_it.next().?;
        var winning_nums_it = mem.split(u8, winning_nums_text, " ");
        while (winning_nums_it.next()) |n| {
            if (n.len > 0) {
                const num = try fmt.parseUnsigned(u16, n, 10);
                try self.winning_nums.append(num);
            }
        }

        const card_nums_text = nums_it.next().?;
        var card_nums_it = mem.split(u8, card_nums_text, " ");
        while (card_nums_it.next()) |n| {
            if (n.len > 0) {
                const num = try fmt.parseUnsigned(u16, n, 10);
                try self.card_nums.append(num);
            }
        }
    }

    pub fn eval(self: *Card) !usize {
        // sort winning
        const winning_nums: []u16 = try self.winning_nums.toOwnedSlice();
        mem.sort(u16, winning_nums, {}, comptime std.sort.asc(u16));
        // sort card nums
        const card_nums: []u16 = try self.card_nums.toOwnedSlice();
        mem.sort(u16, card_nums, {}, comptime std.sort.asc(u16));

        // after soring both lists,
        // start at the winning
        // then iterate nums
        // if win < num
        // move on nums
        // else
        // move on wins
        // if equal, accumulate
        // if wins over, then close eval
        var points: usize = 0;
        var w: usize = 0;
        var n: usize = 0;
        while (w < winning_nums.len) {
            while (n < card_nums.len) {
                // print("Eval {} and {}\n", .{ winning_nums[w], card_nums[n] });
                if (winning_nums[w] == card_nums[n]) {
                    // print("Points: {}\n", .{winning_nums[w]});
                    points += 1;
                } else {
                    if (winning_nums[w] < card_nums[n]) {
                        break;
                    }
                }
                n += 1;
            }
            w += 1;
        }

        return points;
    }
};

pub fn run() !void {
    const in = std.io.getStdIn();
    var buf = std.io.bufferedReader(in.reader());

    // Get the Reader interface from BufferedReader
    var r = buf.reader();

    // init card
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    var card = Card.init(alloc);

    var items: usize = 0;
    var sum: usize = 0;
    var map = std.AutoHashMap(usize, usize).init(alloc);
    defer map.deinit();

    // Ideally we would want to issue more than one read
    // otherwise there is no point in buffering.
    var msg_buf: [4096]u8 = undefined;
    while (true) {
        const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg) |m| {
            items += 1;
            if (m.len == 0) break;
            card.deinit();
            try card.parse(m);
            const n = try card.eval();

            // part 1
            const points = if (n > 0) math.pow(usize, 2, n - 1) else 0;
            sum += points;

            // part 2
            var card_instances: usize = 1;

            if (map.get(card.id)) |v| {
                card_instances += v;
            }

            try map.put(card.id, card_instances);

            // print("Card {} matches {} points {} instances {}\n", .{ card.id, n, points, card_instances });

            for (1..n + 1) |i| {
                const id = card.id + i;
                if (map.get(id)) |v| {
                    try map.put(id, v + card_instances);
                } else {
                    try map.put(id, card_instances);
                }
            }
        } else break;
    }

    var cards: usize = 0;
    for (1..items + 1) |i| {
        if (map.get(i)) |v| {
            // print("Entry: {} => {}\n", .{ i, v });
            cards += v;
        }
    }

    print("Result part 1: {}\n", .{sum});
    print("Result part 2: {}\n", .{cards});
}

pub fn main() !void {
    print("AoC2023 - Day {s}\n", .{"04"});
    try run();
}
