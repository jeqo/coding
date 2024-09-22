const std = @import("std");

const Card = enum(u8) {
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
    ten = 10,
    jack = 11,
    queen = 12,
    king = 13,
    ace = 14,

    fn fromChar(c: u8) !Card {
        return switch (c) {
            'A' => .ace,
            '2' => .two,
            '3' => .three,
            '4' => .four,
            '5' => .five,
            '6' => .six,
            '7' => .seven,
            '8' => .eight,
            '9' => .nine,
            'T' => .ten,
            'J' => .jack,
            'Q' => .queen,
            'K' => .king,
            else => error.InvalidCard,
        };
    }

    fn toChar(self: Card) u8 {
        return switch (self) {
            .ace => 'A',
            .two => '2',
            .three => '3',
            .four => '4',
            .five => '5',
            .six => '6',
            .seven => '7',
            .eight => '8',
            .nine => '9',
            .ten => 'T',
            .jack => 'J',
            .queen => 'Q',
            .king => 'K',
        };
    }

    fn print(self: Card) void {
        std.debug.print("{c}", .{self.toChar()});
    }
};

test "camel card" {
    try std.testing.expect(@intFromEnum(Card.two) == 2);
    try std.testing.expect(@intFromEnum(try Card.fromChar('T')) == 10);
}

const Hand = struct {
    cards: [5]Card,
    size: usize,

    fn init() Hand {
        return Hand{
            .cards = undefined,
            .size = 0,
        };
    }

    fn parse(cards: []const u8) !Hand {
        var h = Hand.init();
        for (cards) |c| {
            const card = try Card.fromChar(c);
            try h.add(card);
        }
        return h;
    }

    fn add(self: *Hand, card: Card) !void {
        if (self.size >= 5) return error.HandFull;
        self.cards[self.size] = card;
        self.size += 1;
    }

    fn sort(self: *Hand) void {
        std.mem.sort(Card, self.cards[0..self.size], {}, comptime cardLessThan);
    }

    fn toString(self: Hand) []u8 {
        var result: [5]u8 = undefined;
        for (self.cards[0..self.size], 0..) |c, i| {
            result[i] = c.toChar();
        }
        return result[0..self.size];
    }

    fn print(self: Hand) void {
        for (self.cards[0..self.size]) |card| {
            card.print();
        }
    }
};

fn cardLessThan(_: void, a: Card, b: Card) bool {
    return @intFromEnum(a) > @intFromEnum(b);
}

test "hand" {
    var h = Hand.init();
    try h.add(Card.two);
    try h.add(Card.ten);
    try h.add(Card.four);
    try h.add(Card.queen);
    try h.add(Card.ace);
    try std.testing.expect(std.mem.eql(Card, &h.cards, &[_]Card{ Card.two, Card.ten, Card.four, Card.queen, Card.ace }));
    h.sort();
    try std.testing.expect(std.mem.eql(Card, &h.cards, &[_]Card{ Card.ace, Card.queen, Card.ten, Card.four, Card.two }));
}

test "hand parsing" {
    const testCases = [_]struct { input: []const u8, expected: []const u8 }{
        .{ .input = "23456", .expected = "65432" },
        .{ .input = "AKQJT", .expected = "AKQJT" },
        .{ .input = "A2345", .expected = "A5432" },
        .{ .input = "KKKKK", .expected = "KKKKK" },
        .{ .input = "A23A4", .expected = "AA432" },
    };

    for (testCases) |tc| {
        var hand = try Hand.parse(tc.input);
        hand.print();
        hand.sort();
        const result = hand.toString();
        try std.testing.expect(std.mem.eql(u8, tc.expected, result));
    }
}

const HandRank = enum(u8) {
    highCard = 1,
    onePair = 2,
    twoPairs = 3,
    threeOfAKind = 4,
    fullHouse = 5,
    fourOfAKind = 6,
    fiveOfAKind = 7,
};

const HandStrength = struct {
    rank: HandRank,

    fn eval(hand: Hand) HandStrength {
        var rank_counts: [15]u8 = [_]u8{0} ** 15;

        for (hand.cards[0..hand.size]) |card| {
            rank_counts[@intFromEnum(card)] += 1;
        }

        var pairs: u8 = 0;
        var three_of_a_kind: bool = false;
        var four_of_a_kind: bool = false;
        var five_of_a_kind: bool = false;

        for (rank_counts) |count| {
            if (count == 2) {
                pairs += 1;
            }
            if (count == 3) {
                three_of_a_kind = true;
            }
            if (count == 4) {
                four_of_a_kind = true;
            }
            if (count == 5) {
                five_of_a_kind = true;
            }
        }

        if (five_of_a_kind) return .{ .rank = HandRank.fiveOfAKind };
        if (four_of_a_kind) return .{ .rank = HandRank.fourOfAKind };
        if (three_of_a_kind and pairs == 1) return .{ .rank = HandRank.fullHouse };
        if (three_of_a_kind) return .{ .rank = HandRank.threeOfAKind };
        if (pairs == 2) return .{ .rank = HandRank.twoPairs };
        if (pairs == 1) return .{ .rank = HandRank.onePair };

        return .{ .rank = HandRank.highCard };
    }
};

test "hand strength" {
    const testCases = [_]struct { input: []const u8, expected: HandRank }{
        .{ .input = "22345", .expected = .onePair },
        .{ .input = "A3323", .expected = .threeOfAKind },
        .{ .input = "54KK5", .expected = .twoPairs },
        .{ .input = "44KK4", .expected = .fullHouse },
        .{ .input = "KJJJJ", .expected = .fourOfAKind },
        .{ .input = "AAAAA", .expected = .fiveOfAKind },
        .{ .input = "AKQJ9", .expected = .highCard },
    };

    for (testCases) |tc| {
        std.debug.print("Testing {s}\n", .{tc.input});
        const hand = try Hand.parse(tc.input);
        const strength = HandStrength.eval(hand);
        try std.testing.expectEqual(tc.expected, strength.rank);
    }
}

fn handLessThan(_: void, a: Hand, b: Hand) bool {
    const rank_a = HandStrength.eval(a).rank;
    const rank_b = HandStrength.eval(b).rank;
    // std.debug.print("Compare {} and {}\n", .{ rank_a, rank_b });
    const val_b = @intFromEnum(rank_b);
    const val_a = @intFromEnum(rank_a);
    if (val_a != val_b) {
        return val_b > val_a;
    }
    for (0..5) |i| {
        if (a.cards[i] != b.cards[i]) {
            return @intFromEnum(b.cards[i]) > @intFromEnum(a.cards[i]);
        }
    }
    return false;
}

test "compare strength" {
    {
        const a = try Hand.parse("22345");
        const b = try Hand.parse("22335");
        try std.testing.expect(handLessThan({}, a, b));
    }
    {
        const a = try Hand.parse("22335");
        const b = try Hand.parse("22344");
        try std.testing.expect(handLessThan({}, a, b));
    }
}

const TreeNode = struct {
    hand: Hand,
    left: ?*TreeNode = null,
    right: ?*TreeNode = null,

    fn init(hand: Hand) TreeNode {
        return TreeNode{ .hand = hand };
    }

    fn add(self: *TreeNode, alloc: std.mem.Allocator, hand: Hand) !void {
        const node = try alloc.create(TreeNode);
        errdefer alloc.destroy(node);
        node.* = TreeNode.init(hand);
        self.add_leaf(node);
    }

    fn add_leaf(self: *TreeNode, other: *TreeNode) void {
        if (handLessThan({}, self.hand, other.hand)) {
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

    fn print(self: TreeNode) void {
        std.debug.print("Node: ", .{});
        self.hand.print();
        std.debug.print("\n", .{});
        if (self.left) |left| {
            std.debug.print("Left: \n", .{});
            left.print();
        }
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

    fn add(self: *Tree, hand: Hand) !void {
        if (self.root == null) {
            self.root = try self.alloc.create(TreeNode);
            self.root.?.* = TreeNode.init(hand);
        } else {
            try self.root.?.add(self.alloc, hand);
        }
    }

    fn print(self: Tree) void {
        if (self.root != null) self.root.?.print();
    }
};

const Game = struct {
    alloc: std.mem.Allocator,
    all: std.AutoHashMap(Hand, usize),
    tree: Tree,

    fn init(alloc: std.mem.Allocator) Game {
        const all = std.AutoHashMap(Hand, usize).init(alloc);
        const tree = Tree.init(alloc);
        return .{ .alloc = alloc, .all = all, .tree = tree };
    }

    fn add(self: *Game, hand: []const u8, bid: usize) !void {
        const h = try Hand.parse(hand);
        try self.all.put(h, bid);
        try self.tree.add(h);
    }

    fn eval(self: Game) usize {
        var idx: usize = 0;
        return self.inner_eval(self.tree.root.?, &idx);
    }

    fn inner_eval(self: Game, node: *TreeNode, idx: *usize) usize {
        var result: usize = 0;
        if (node.left) |left| {
            result += self.inner_eval(left, idx);
        }
        idx.* += 1;
        // const hand = node.hand.toString();
        // std.debug.print("Eval: {}=>{s}\n", .{ idx.*, hand });
        const inner = idx.* * self.all.get(node.hand).?;
        result += inner;
        if (node.right) |right| {
            result += self.inner_eval(right, idx);
        }
        return result;
    }
};

test "game" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var game = Game.init(alloc);
    try game.add("32T3K", 765);
    try game.add("T55J5", 684);
    try game.add("KK677", 28);
    try game.add("KTJJT", 220);
    try game.add("QQQJA", 483);

    game.tree.print();

    std.debug.print("Result: {}\n", .{game.eval()});
}

const GameEntry = struct { hand: []const u8, bid: usize };

fn parse_entry(line: []const u8) !GameEntry {
    var line_it = std.mem.split(u8, line, " ");
    const hand = line_it.next().?;
    const bid = try std.fmt.parseUnsigned(usize, line_it.next().?, 10);
    return .{ .hand = hand, .bid = bid };
}

test "parse entry" {
    const e = try parse_entry("7QTK4 105");
    try std.testing.expect(std.mem.eql(u8, e.hand, "7QTK4"));
    try std.testing.expect(e.bid == 105);
}

fn run() !void {
    const in = std.io.getStdIn();
    var buf = std.io.bufferedReader(in.reader());

    // Get the Reader interface from BufferedReader
    var r = buf.reader();

    // init alloc
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var msg_buf: [4096]u8 = undefined;
    var game = Game.init(alloc);
    while (true) {
        const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg) |m| {
            if (m.len > 0) {
                const entry = try parse_entry(m);
                try game.add(entry.hand, entry.bid);
            } else break;
        } else break;
    }

    std.debug.print("Result: {}\n", .{game.eval()});
}

pub fn main() !void {
    std.debug.print("AoC2023-Day{s}\n", .{"07"});

    try run();
}
