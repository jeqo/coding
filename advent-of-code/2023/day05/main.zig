//! AoC2023 day 5

const std = @import("std");
const assert = std.debug.assert;

const Entry = struct {
    pos: usize,
    len: usize,
    ref: usize,
};

const TreeNode = struct {
    entry: Entry,
    // branches
    left: ?*TreeNode = null,
    right: ?*TreeNode = null,

    fn init(entry: Entry) TreeNode {
        return TreeNode{ .entry = entry };
    }

    fn add(self: *TreeNode, alloc: std.mem.Allocator, entry: Entry) !void {
        const node = try alloc.create(TreeNode);
        errdefer alloc.destroy(node);
        node.* = TreeNode.init(entry);
        self.add_leaf(node);
    }

    fn add_leaf(self: *TreeNode, other: *TreeNode) void {
        // std.debug.print("Check: {} vs {}\n", .{ self.entry.pos, other.entry.pos });
        if (other.entry.pos > self.entry.pos) {
            if (self.right) |right| {
                right.add_leaf(other);
            } else {
                self.right = other;
            }
        } else {
            if (self.left) |left| {
                left.add_leaf(other);
            } else {
                self.left = other;
            }
        }
    }

    fn find(self: TreeNode, n: usize) usize {
        // std.debug.print("Test: {} on Node {} {}\n", .{ n, self.entry.pos, self.entry.len });
        if (self.entry.pos <= n and n <= self.entry.pos + self.entry.len - 1) {
            const diff = n - self.entry.pos;
            return self.entry.ref + diff;
        } else {
            if (n < self.entry.pos) {
                if (self.left) |left| {
                    return left.find(n);
                }
            } else {
                if (self.right) |right| {
                    return right.find(n);
                }
            }
            return n;
        }
    }

    fn print(self: TreeNode) void {
        if (self.left) |left| {
            std.debug.print("Left: \n", .{});
            left.print();
        }
        std.debug.print("Node: {} (len: {}) -> {}\n", .{ self.entry.pos, self.entry.len, self.entry.ref });
        if (self.right) |right| {
            std.debug.print("Right: \n", .{});
            right.print();
        }
    }
};

const Tree = struct {
    alloc: std.mem.Allocator,
    root: ?*TreeNode,

    fn init(alloc: std.mem.Allocator) Tree {
        return .{
            .alloc = alloc,
            .root = null,
        };
    }

    fn add(self: *Tree, entry: Entry) !void {
        if (self.root == null) {
            self.root = try self.alloc.create(TreeNode);
            self.root.?.* = TreeNode.init(entry);
        } else {
            try self.root.?.add(self.alloc, entry);
        }
    }
};

test "sim test" {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var seed_to_soil = Tree.init(alloc);
    try seed_to_soil.add(Entry{ .pos = 98, .len = 2, .ref = 50 });
    try seed_to_soil.add(Entry{ .pos = 50, .len = 48, .ref = 52 });

    assert(seed_to_soil.root.?.find(79) == 81);
    assert(seed_to_soil.root.?.find(14) == 14);
    assert(seed_to_soil.root.?.find(55) == 57);
    assert(seed_to_soil.root.?.find(13) == 13);

    var soil_to_fertilizer = Tree.init(alloc);
    try soil_to_fertilizer.add(Entry{ .pos = 15, .len = 37, .ref = 0 });
    try soil_to_fertilizer.add(Entry{ .pos = 52, .len = 2, .ref = 37 });
    try soil_to_fertilizer.add(Entry{ .pos = 0, .len = 15, .ref = 39 });

    assert(soil_to_fertilizer.root.?.find(81) == 81);
    assert(soil_to_fertilizer.root.?.find(14) == 53);
    assert(soil_to_fertilizer.root.?.find(57) == 57);
    assert(soil_to_fertilizer.root.?.find(13) == 52);

    var fertilizer_to_water = Tree.init(alloc);
    try fertilizer_to_water.add(Entry{ .pos = 53, .len = 8, .ref = 49 });
    try fertilizer_to_water.add(Entry{ .pos = 11, .len = 42, .ref = 0 });
    try fertilizer_to_water.add(Entry{ .pos = 0, .len = 7, .ref = 42 });
    try fertilizer_to_water.add(Entry{ .pos = 7, .len = 4, .ref = 57 });

    assert(fertilizer_to_water.root.?.find(81) == 81);
    assert(fertilizer_to_water.root.?.find(53) == 49);
    assert(fertilizer_to_water.root.?.find(57) == 53);
    assert(fertilizer_to_water.root.?.find(52) == 41);

    var water_to_light = Tree.init(alloc);
    try water_to_light.add(Entry{ .pos = 18, .len = 7, .ref = 88 });
    try water_to_light.add(Entry{ .pos = 25, .len = 70, .ref = 18 });

    assert(water_to_light.root.?.find(81) == 74);
    assert(water_to_light.root.?.find(49) == 42);
    assert(water_to_light.root.?.find(53) == 46);
    assert(water_to_light.root.?.find(41) == 34);

    var light_to_temp = Tree.init(alloc);
    try light_to_temp.add(Entry{ .pos = 77, .len = 23, .ref = 45 });
    try light_to_temp.add(Entry{ .pos = 45, .len = 19, .ref = 81 });
    try light_to_temp.add(Entry{ .pos = 64, .len = 13, .ref = 68 });

    assert(light_to_temp.root.?.find(74) == 78);
    assert(light_to_temp.root.?.find(42) == 42);
    assert(light_to_temp.root.?.find(46) == 82);
    assert(light_to_temp.root.?.find(34) == 34);

    var temp_to_humidity = Tree.init(alloc);
    try temp_to_humidity.add(Entry{ .pos = 69, .len = 1, .ref = 0 });
    try temp_to_humidity.add(Entry{ .pos = 0, .len = 69, .ref = 1 });

    assert(temp_to_humidity.root.?.find(78) == 78);
    assert(temp_to_humidity.root.?.find(42) == 43);
    assert(temp_to_humidity.root.?.find(82) == 82);
    assert(temp_to_humidity.root.?.find(34) == 35);

    var humidity_to_loc = Tree.init(alloc);
    try humidity_to_loc.add(Entry{ .pos = 56, .len = 37, .ref = 60 });
    try humidity_to_loc.add(Entry{ .pos = 93, .len = 1, .ref = 0 });

    assert(humidity_to_loc.root.?.find(78) == 82);
    assert(humidity_to_loc.root.?.find(43) == 43);
    assert(humidity_to_loc.root.?.find(82) == 86);
    assert(humidity_to_loc.root.?.find(35) == 35);
}

test "build tree" {
    var n = TreeNode.init(Entry{ .pos = 98, .len = 2, .ref = 50 });
    assert(n.entry.pos == 98);
    assert(n.entry.len == 2);
    assert(n.entry.ref == 50);

    assert(n.find(99) == 51);

    var n1 = TreeNode.init(Entry{ .pos = 50, .len = 48, .ref = 52 });
    n.add_leaf(&n1);

    assert(n.left != null);
    assert(n.left.?.*.entry.pos == 50);
    assert(n.left.?.*.entry.len == 48);
    assert(n.left.?.*.entry.ref == 52);

    assert(n.find(55) == 57);

    var n2 = TreeNode.init(Entry{ .pos = 100, .len = 2, .ref = 10 });
    n.add_leaf(&n2);
    assert(n.right != null);
    assert(n.right.?.*.entry.pos == 100);
    assert(n.right.?.*.entry.len == 2);
    assert(n.right.?.*.entry.ref == 10);

    assert(n.find(100) == 10);

    n.print();
}

const mem = std.mem;
const fmt = std.fmt;

fn parse_seeds(alloc: mem.Allocator, line: []const u8) !std.ArrayList(usize) {
    var line_it = mem.split(u8, line, ":");
    const prefix = line_it.next().?;
    assert(mem.eql(u8, "seeds", prefix));
    const suffix = line_it.next().?;
    var nums_it = mem.split(u8, suffix, " ");

    var seeds = std.ArrayList(usize).init(alloc);

    while (nums_it.next()) |num| {
        if (num.len > 0) {
            const n = try fmt.parseUnsigned(usize, num, 10);
            try seeds.append(n);
        }
    }

    return seeds;
}

fn seeds_from_ranges(alloc: mem.Allocator, seeds: std.ArrayList(usize)) !std.ArrayList(usize) {
    var new_seeds = std.ArrayList(usize).init(alloc);
    for (0..seeds.items.len / 2) |i| {
        const index = i * 2;
        const first = seeds.items[index];
        const second = if (index + 1 < seeds.items.len) seeds.items[index + 1] else null;

        std.debug.print("Pair: {} {?}\n", .{ first, second });
        for (0..second.?) |j| {
            try new_seeds.append(first + j);
        }
    }
    return new_seeds;
}

const heap = std.heap;
const expectEqualSlices = std.testing.expectEqualSlices;

test "parse seeds" {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const line = "seeds: 79 14 55 13";
    const seeds = try parse_seeds(alloc, line);
    defer seeds.deinit();
    assert(seeds.items.len == 4);
    const expected_seeds: []const usize = &.{ 79, 14, 55, 13 };
    try expectEqualSlices(usize, seeds.items, expected_seeds);

    const new_seeds = try seeds_from_ranges(alloc, seeds);
    defer new_seeds.deinit();
    assert(new_seeds.items.len == 27);
}

fn parse_map_entry(alloc: mem.Allocator, line: []const u8) !Entry {
    var nums_it = mem.split(u8, line, " ");

    var nums = std.ArrayList(usize).init(alloc);

    while (nums_it.next()) |num| {
        if (num.len > 0) {
            const n = try fmt.parseUnsigned(usize, num, 10);
            try nums.append(n);
        }
    }

    assert(nums.items.len == 3);
    const e = Entry{ .pos = nums.items[1], .len = nums.items[2], .ref = nums.items[0] };
    nums.deinit();

    return e;
}

test "parse nums" {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const line = "50 98 2";
    const entry = try parse_map_entry(alloc, line);
    assert(entry.pos == 98);
    assert(entry.len == 2);
    assert(entry.ref == 50);
}

fn run() !void {
    const in = std.io.getStdIn();
    var buf = std.io.bufferedReader(in.reader());

    // Get the Reader interface from BufferedReader
    var r = buf.reader();

    // init card
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // Ideally we would want to issue more than one read
    // otherwise there is no point in buffering.
    var msg_buf: [4096]u8 = undefined;
    const header = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
    var seeds: std.ArrayList(usize) = undefined;
    defer seeds.deinit();
    if (header) |h| {
        seeds = try parse_seeds(alloc, h);
    }
    assert(seeds.items.len > 0);
    // ignore next line
    _ = try r.readUntilDelimiterOrEof(&msg_buf, '\n');

    // ignore head
    _ = try r.readUntilDelimiterOrEof(&msg_buf, '\n');

    var seed_to_soil = Tree.init(alloc);
    while (true) {
        const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg) |m| {
            if (m.len > 0) {
                const entry = try parse_map_entry(alloc, m);
                try seed_to_soil.add(entry);
            } else break;
        } else break;
    }

    // ignore head
    _ = try r.readUntilDelimiterOrEof(&msg_buf, '\n');

    var soil_to_fertilizer = Tree.init(alloc);
    while (true) {
        const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg) |m| {
            if (m.len > 0) {
                const entry = try parse_map_entry(alloc, m);
                try soil_to_fertilizer.add(entry);
            } else break;
        } else break;
    }

    // ignore head
    _ = try r.readUntilDelimiterOrEof(&msg_buf, '\n');

    var fertilizer_to_water = Tree.init(alloc);
    while (true) {
        const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg) |m| {
            if (m.len > 0) {
                const entry = try parse_map_entry(alloc, m);
                try fertilizer_to_water.add(entry);
            } else break;
        } else break;
    }

    // ignore head
    _ = try r.readUntilDelimiterOrEof(&msg_buf, '\n');

    var water_to_light = Tree.init(alloc);
    while (true) {
        const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg) |m| {
            if (m.len > 0) {
                const entry = try parse_map_entry(alloc, m);
                try water_to_light.add(entry);
            } else break;
        } else break;
    }

    // ignore head
    _ = try r.readUntilDelimiterOrEof(&msg_buf, '\n');

    var light_to_temperature = Tree.init(alloc);
    while (true) {
        const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg) |m| {
            if (m.len > 0) {
                const entry = try parse_map_entry(alloc, m);
                try light_to_temperature.add(entry);
            } else break;
        } else break;
    }

    // ignore head
    _ = try r.readUntilDelimiterOrEof(&msg_buf, '\n');

    var temperature_to_humidity = Tree.init(alloc);
    while (true) {
        const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg) |m| {
            if (m.len > 0) {
                const entry = try parse_map_entry(alloc, m);
                try temperature_to_humidity.add(entry);
            } else break;
        } else break;
    }

    // ignore head
    _ = try r.readUntilDelimiterOrEof(&msg_buf, '\n');

    var humidity_to_location = Tree.init(alloc);
    while (true) {
        const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg) |m| {
            if (m.len > 0) {
                const entry = try parse_map_entry(alloc, m);
                try humidity_to_location.add(entry);
            } else break;
        } else break;
    }

    var loc: usize = std.math.maxInt(usize);

    for (seeds.items) |s| {
        const v1 = seed_to_soil.root.?.find(s);
        const v2 = soil_to_fertilizer.root.?.find(v1);
        const v3 = fertilizer_to_water.root.?.find(v2);
        const v4 = water_to_light.root.?.find(v3);
        const v5 = light_to_temperature.root.?.find(v4);
        const v6 = temperature_to_humidity.root.?.find(v5);
        const v7 = humidity_to_location.root.?.find(v6);
        if (loc > v7) loc = v7;
    }

    std.debug.print("Result part 1: {}\n", .{loc});

    var new_loc: usize = std.math.maxInt(usize);

    for (0..seeds.items.len / 2) |i| {
        const index = i * 2;
        const first = seeds.items[index];
        const second = if (index + 1 < seeds.items.len) seeds.items[index + 1] else null;

        std.debug.print("Pair: {} {?}\n", .{ first, second });
        for (0..second.?) |j| {
            const s = first + j;
            const v1 = seed_to_soil.root.?.find(s);
            const v2 = soil_to_fertilizer.root.?.find(v1);
            const v3 = fertilizer_to_water.root.?.find(v2);
            const v4 = water_to_light.root.?.find(v3);
            const v5 = light_to_temperature.root.?.find(v4);
            const v6 = temperature_to_humidity.root.?.find(v5);
            const v7 = humidity_to_location.root.?.find(v6);
            if (new_loc > v7) new_loc = v7;
        }
    }

    std.debug.print("Result part 2: {}\n", .{new_loc});
}

pub fn main() !void {
    std.debug.print("AoC2023 - Day {s}\n", .{"05"});
    try run();
}
