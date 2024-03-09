//! AoC2023 day 2
//! The game is to figure out info about number of cubes
//! There are game rounds (or just games)
//! where Elf shows some of the cubes in the bag
//! This info is recorded (input)
//! Based on this info, a question about what games fit the requirement is given
//! Response for v1 will be the sum of the IDs.

const std = @import("std");
// We need a data struct that holds: set of cubes per color
// There are 3 colors known: red (0), green (1), blue (2)
// so the size of the array is fixed
// each game has a dynamic size of sets

const heap = std.heap;
const mem = std.mem;
const ArrayList = std.ArrayList;

const assert = std.debug.assert;
const expect = std.testing.expect;
const print = std.debug.print;

test "instantiate game" {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const line = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green";

    // build set
    const game = try buildGame(alloc, line);
    defer game.sets.deinit();

    try expect(game.sets.items.len == 3);
    try expect(game.sets.items[0].r == 4);
    try expect(game.sets.items[0].g == 0);
    try expect(game.sets.items[0].b == 3);
    try expect(game.sets.items[1].r == 1);
    try expect(game.sets.items[1].g == 2);
    try expect(game.sets.items[1].b == 6);
    try expect(game.sets.items[2].r == 0);
    try expect(game.sets.items[2].g == 2);
    try expect(game.sets.items[2].b == 0);
}

test "if game is possible" {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const expected = CubeSet{ .r = 12, .g = 13, .b = 14 };

    const game = try buildGame(alloc, "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green");
    defer game.sets.deinit();

    try expect(game.is_possible(expected));

    const game_min = game.min_possible();
    try expect(game_min.r == 4);
    try expect(game_min.g == 2);
    try expect(game_min.b == 6);
    try expect(game_min.power() == 48);

    const another_game = try buildGame(alloc, "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red");
    defer another_game.sets.deinit();

    try expect(!another_game.is_possible(expected));
    const another_game_min = another_game.min_possible();
    try expect(another_game_min.r == 20);
    try expect(another_game_min.g == 13);
    try expect(another_game_min.b == 6);
}

const ascii = std.ascii;
const fmt = std.fmt;

const Color = enum {
    red,
    blue,
    green,
};

const Cube = std.meta.Tuple(&.{ u8, Color });
const CubeSet = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,

    pub fn power(self: CubeSet) usize {
        //print("Power of {} {} {}\n", .{ @as(usize, self.r), @as(usize, self.g), @as(usize, self.b) });
        return @as(usize, self.r) * @as(usize, self.g) * @as(usize, self.b);
    }
};
const Game = struct {
    sets: std.ArrayList(CubeSet),

    pub fn init(alloc: mem.Allocator) Game {
        var sets = ArrayList(CubeSet).init(alloc);
        errdefer sets.deinit();
        return Game{ .sets = sets };
    }

    pub fn is_possible(self: Game, expected: CubeSet) bool {
        for (self.sets.items) |set| {
            if (set.r > expected.r or set.g > expected.g or set.b > expected.b) return false;
        }
        return true;
    }

    pub fn min_possible(self: Game) CubeSet {
        var min_r: u8 = 0;
        var min_g: u8 = 0;
        var min_b: u8 = 0;

        for (self.sets.items) |set| {
            if (set.r > min_r) min_r = set.r;
            if (set.g > min_g) min_g = set.g;
            if (set.b > min_b) min_b = set.b;
        }

        const min = CubeSet{
            .r = min_r,
            .g = min_g,
            .b = min_b,
        };

        return min;
    }
};

fn buildCube(line: []const u8, index: *u8) !Cube {
    // build cube
    const start = index.*;
    while (ascii.isDigit(line[index.*])) {
        index.* = index.* + 1;
    }
    const digits = line[start..index.*];
    // print("Digits from {} to {}: {s}\n", .{ start, index, digits });
    const num = try fmt.parseUnsigned(u8, digits, 10);

    index.* = index.* + 1; // N_.

    // build color
    var color: Color = undefined;
    switch (line[index.*]) {
        'r' => {
            color = Color.red;
            index.* = index.* + 3;
        },
        'g' => {
            color = Color.green;
            index.* = index.* + 5;
        },
        'b' => {
            color = Color.blue;
            index.* = index.* + 4;
        },
        else => unreachable,
    }

    return .{ num, color };
}

fn buildCubeSet(alloc: mem.Allocator, line: []const u8, index: *u8) !CubeSet {
    var cubes = ArrayList(Cube).init(alloc);
    defer cubes.deinit();

    const cube = try buildCube(line, index);
    try cubes.append(cube);

    while (index.* < line.len and line[index.*] == ',') {
        index.* = index.* + 2; //,_
        const next = try buildCube(line, index);
        try cubes.append(next);
    }

    assert(cubes.items.len <= 3);

    var cube_set = CubeSet{};

    for (cubes.items) |c| {
        switch (c[1]) {
            Color.red => cube_set.r = c[0],
            Color.green => cube_set.g = c[0],
            Color.blue => cube_set.b = c[0],
        }
    }

    return cube_set;
}

fn buildGame(alloc: mem.Allocator, line: []const u8) !Game {
    // pattern: Game xyz: A blue, B red; C red; ...; Z green
    // initialize game
    var index: u8 = 0;
    index = index + 5; // Game_
    while (ascii.isDigit(line[index])) {
        index = index + 1;
    }
    index = index + 2; // :_.

    var game = Game.init(alloc);

    const set = try buildCubeSet(alloc, line, &index);
    try game.sets.append(set);

    while (index < line.len and line[index] == ';') {
        index = index + 2; //;_
        const next = try buildCubeSet(alloc, line, &index);
        try game.sets.append(next);
    }

    return game;
}

const fs = std.fs;
const io = std.io;

fn run() !struct { usize, usize } {
    var file = try fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const expected = CubeSet{ .r = 12, .g = 13, .b = 14 };
    var i: u8 = 1;
    var v1: usize = 0;
    var v2: usize = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len > 0) {
            const game = try buildGame(alloc, line);
            if (game.is_possible(expected)) {
                v1 = v1 + i;
            }
            const power = game.min_possible().power();
            v2 = v2 + power;
            i = i + 1;
        }
    }

    return .{ v1, v2 };
}

pub fn main() !void {
    print("AoC2023 - Day {s}\n", .{"02"});
    const results = try run();
    print("[v1] Result: {}\n", .{results[0]});
    print("[v2] Result: {}\n", .{results[1]});
}
