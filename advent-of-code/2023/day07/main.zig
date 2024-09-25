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

    fn cardLessThan(_: void, a: Card, b: Card) bool {
        return @intFromEnum(a) > @intFromEnum(b);
    }
};

test "camel card" {
    try std.testing.expect(@intFromEnum(Card.two) == 2);
    try std.testing.expect(@intFromEnum(try Card.fromChar('T')) == 10);
}

const JCard = enum(u8) {
    joker = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
    ten = 10,
    queen = 12,
    king = 13,
    ace = 14,

    fn fromChar(c: u8) !JCard {
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
            'J' => .joker,
            'Q' => .queen,
            'K' => .king,
            else => error.InvalidCard,
        };
    }

    fn toChar(self: JCard) u8 {
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
            .joker => 'J',
            .queen => 'Q',
            .king => 'K',
        };
    }

    fn print(self: JCard) void {
        std.debug.print("{c}", .{self.toChar()});
    }

    fn cardLessThan(_: void, a: JCard, b: JCard) bool {
        return @intFromEnum(a) > @intFromEnum(b);
    }
};

test "camel card with joker" {
    try std.testing.expect(@intFromEnum(JCard.joker) == 1);
    try std.testing.expect(@intFromEnum(JCard.joker) < @intFromEnum(JCard.two));
    try std.testing.expect(@intFromEnum(try JCard.fromChar('J')) == 1);
}

fn Hand(comptime T: type) type {
    return struct {
        cards: [5]T,
        size: usize,

        fn init() Hand(T) {
            return Hand(T){
                .cards = undefined,
                .size = 0,
            };
        }

        fn parse(cards: []const u8) !Hand(T) {
            var h = Hand(T).init();
            for (cards) |c| {
                const card = try T.fromChar(c);
                try h.add(card);
            }
            return h;
        }

        fn add(self: *Hand(T), card: T) !void {
            if (self.size >= 5) return error.HandFull;
            self.cards[self.size] = card;
            self.size += 1;
        }

        fn sort(self: *Hand(T)) void {
            std.mem.sort(T, self.cards[0..self.size], {}, comptime T.cardLessThan);
        }

        fn toString(self: Hand(T)) []u8 {
            var result: [5]u8 = undefined;
            for (self.cards[0..self.size], 0..) |c, i| {
                result[i] = c.toChar();
            }
            return result[0..self.size];
        }

        fn print(self: Hand(T)) void {
            for (self.cards[0..self.size]) |card| {
                card.print();
            }
        }
    };
}

test "hand" {
    var h = Hand(Card).init();
    try h.add(Card.two);
    try h.add(Card.ten);
    try h.add(Card.four);
    try h.add(Card.queen);
    try h.add(Card.ace);
    try std.testing.expect(std.mem.eql(Card, &h.cards, &[_]Card{ Card.two, Card.ten, Card.four, Card.queen, Card.ace }));
    h.sort();
    try std.testing.expect(std.mem.eql(Card, &h.cards, &[_]Card{ Card.ace, Card.queen, Card.ten, Card.four, Card.two }));
}

test "hand with joker" {
    var h = Hand(JCard).init();
    try h.add(JCard.two);
    try h.add(JCard.joker);
    try h.add(JCard.four);
    try h.add(JCard.queen);
    try h.add(JCard.ace);
    try std.testing.expect(std.mem.eql(JCard, &h.cards, &[_]JCard{ JCard.two, JCard.joker, JCard.four, JCard.queen, JCard.ace }));
    h.sort();
    try std.testing.expect(std.mem.eql(JCard, &h.cards, &[_]JCard{ JCard.ace, JCard.queen, JCard.four, JCard.two, JCard.joker }));
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
        var hand = try Hand(Card).parse(tc.input);
        hand.print();
        hand.sort();
        const result = hand.toString();
        try std.testing.expect(std.mem.eql(u8, tc.expected, result));
    }
}

test "hand parsing with joker" {
    const testCases = [_]struct { input: []const u8, expected: []const u8 }{
        .{ .input = "23456", .expected = "65432" },
        .{ .input = "AKQJT", .expected = "AKQTJ" },
        .{ .input = "A2345", .expected = "A5432" },
        .{ .input = "KKKKJ", .expected = "KKKKJ" },
        .{ .input = "A23J4", .expected = "A432J" },
    };

    for (testCases) |tc| {
        var hand = try Hand(JCard).parse(tc.input);
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

    fn eval(hand: Hand(Card)) HandStrength {
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

    fn handLessThan(_: void, a: Hand(Card), b: Hand(Card)) bool {
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
        const hand = try Hand(Card).parse(tc.input);
        const strength = HandStrength.eval(hand);
        try std.testing.expectEqual(tc.expected, strength.rank);
    }
}

test "compare strength" {
    {
        const a = try Hand(Card).parse("22345");
        const b = try Hand(Card).parse("22335");
        try std.testing.expect(HandStrength.handLessThan({}, a, b));
    }
    {
        const a = try Hand(Card).parse("22335");
        const b = try Hand(Card).parse("22344");
        try std.testing.expect(HandStrength.handLessThan({}, a, b));
    }
}

const JHandStrength = struct {
    rank: HandRank,

    fn eval(hand: Hand(JCard)) HandStrength {
        var rank_counts: [15]u8 = [_]u8{0} ** 15;

        var jokers: u8 = 0;
        for (hand.cards[0..hand.size]) |card| {
            if (card == JCard.joker) {
                jokers += 1;
            } else {
                rank_counts[@intFromEnum(card)] += 1;
            }
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

        if (jokers == 5) {
            return .{ .rank = HandRank.fiveOfAKind };
        } else if (jokers == 4) {
            return .{ .rank = HandRank.fiveOfAKind };
        }
        if (five_of_a_kind) return .{ .rank = HandRank.fiveOfAKind };
        if (four_of_a_kind) {
            if (jokers == 1) {
                return .{ .rank = HandRank.fiveOfAKind };
            } else {
                return .{ .rank = HandRank.fourOfAKind };
            }
        }
        if (three_of_a_kind and jokers == 2) {
            return .{ .rank = HandRank.fiveOfAKind };
        }
        if (jokers == 3) {
            if (pairs == 1) {
                return .{ .rank = HandRank.fiveOfAKind };
            } else {
                return .{ .rank = HandRank.fourOfAKind };
            }
        }
        if (three_of_a_kind and pairs == 1) {
            return .{ .rank = HandRank.fullHouse };
        }
        if (three_of_a_kind) {
            if (jokers == 1) {
                return .{ .rank = HandRank.fourOfAKind };
            } else {
                return .{ .rank = HandRank.threeOfAKind };
            }
        }
        if (pairs == 2) {
            if (jokers == 1) {
                return .{ .rank = HandRank.fullHouse };
            } else {
                return .{ .rank = HandRank.twoPairs };
            }
        }
        if (pairs == 1) {
            if (jokers == 3) {
                return .{ .rank = HandRank.fiveOfAKind };
            } else if (jokers == 2) {
                return .{ .rank = HandRank.fourOfAKind };
            } else if (jokers == 1) {
                return .{ .rank = HandRank.threeOfAKind };
            } else {
                return .{ .rank = HandRank.onePair };
            }
        }
        if (jokers == 2) {
            return .{ .rank = HandRank.threeOfAKind };
        } else if (jokers == 1) {
            return .{ .rank = HandRank.onePair };
        } else {
            return .{ .rank = HandRank.highCard };
        }
    }

    fn handLessThan(_: void, a: Hand(JCard), b: Hand(JCard)) bool {
        const rank_a = JHandStrength.eval(a).rank;
        const rank_b = JHandStrength.eval(b).rank;
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
};

test "hand strength with joker" {
    const testCases = [_]struct { input: []const u8, expected: HandRank }{
        .{ .input = "22345", .expected = .onePair },
        .{ .input = "A3323", .expected = .threeOfAKind },
        .{ .input = "54KK5", .expected = .twoPairs },
        .{ .input = "44KK4", .expected = .fullHouse },
        .{ .input = "KJJJJ", .expected = .fiveOfAKind },
        .{ .input = "AAAAA", .expected = .fiveOfAKind },
        .{ .input = "AKQJ9", .expected = .onePair },
        .{ .input = "32T3K", .expected = .onePair },
        .{ .input = "T55J5", .expected = .fourOfAKind },
        .{ .input = "KK677", .expected = .twoPairs },
        .{ .input = "KTJJT", .expected = .fourOfAKind },
        .{ .input = "QQQJA", .expected = .fourOfAKind },
        .{ .input = "3JJ33", .expected = .fiveOfAKind },
        .{ .input = "6J84Q", .expected = .onePair },
        .{ .input = "K4JJJ", .expected = .fourOfAKind },
        .{ .input = "JJJJJ", .expected = .fiveOfAKind },
        .{ .input = "KKKJJ", .expected = .fiveOfAKind },
        .{ .input = "KK34J", .expected = .threeOfAKind },
        .{ .input = "KJ34J", .expected = .threeOfAKind },
        .{ .input = "JJTTJ", .expected = .fiveOfAKind },
    };

    for (testCases) |tc| {
        std.debug.print("Testing {s}\n", .{tc.input});
        const hand = try Hand(JCard).parse(tc.input);
        const strength = JHandStrength.eval(hand);
        try std.testing.expectEqual(tc.expected, strength.rank);
    }
}

test "compare strength with joker" {
    {
        const testCases = [_]struct { a: []const u8, b: []const u8 }{
            .{ .a = "JJJJJ", .b = "22222" },
            .{ .a = "22222", .b = "33333" },
            .{ .a = "22322", .b = "JJ3JJ" },
            .{ .a = "JJ3JJ", .b = "33333" },
            .{ .a = "44342", .b = "JJ3J2" },
            .{ .a = "JJ3J2", .b = "33332" },
        };
        for (testCases) |tc| {
            const a = try Hand(JCard).parse(tc.a);
            const b = try Hand(JCard).parse(tc.b);
            try std.testing.expect(JHandStrength.handLessThan({}, a, b));
        }
    }
}

fn TreeNode(comptime T: type, comptime S: type) type {
    return struct {
        hand: Hand(T),
        left: ?*TreeNode(T, S) = null,
        right: ?*TreeNode(T, S) = null,

        fn init(hand: Hand(T)) TreeNode(T, S) {
            return TreeNode(T, S){ .hand = hand };
        }

        fn add(self: *TreeNode(T, S), alloc: std.mem.Allocator, hand: Hand(T)) !void {
            const node = try alloc.create(TreeNode(T, S));
            errdefer alloc.destroy(node);
            node.* = TreeNode(T, S).init(hand);
            self.add_leaf(node);
        }

        fn add_leaf(self: *TreeNode(T, S), other: *TreeNode(T, S)) void {
            if (S.handLessThan({}, self.hand, other.hand)) {
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

        fn print(self: TreeNode(T, S)) void {
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
}

fn Tree(comptime T: type, comptime S: type) type {
    return struct {
        alloc: std.mem.Allocator,
        root: ?*TreeNode(T, S),

        fn init(alloc: std.mem.Allocator) Tree(T, S) {
            return .{
                .alloc = alloc,
                .root = null,
            };
        }

        fn add(self: *Tree(T, S), hand: Hand(T)) !void {
            if (self.root == null) {
                self.root = try self.alloc.create(TreeNode(T, S));
                self.root.?.* = TreeNode(T, S).init(hand);
            } else {
                try self.root.?.add(self.alloc, hand);
            }
        }

        fn print(self: Tree(T, S)) void {
            if (self.root != null) self.root.?.print();
        }
    };
}

fn Game(comptime T: type, comptime S: type) type {
    return struct {
        alloc: std.mem.Allocator,
        all: std.AutoHashMap(Hand(T), usize),
        tree: Tree(T, S),

        fn init(alloc: std.mem.Allocator) Game(T, S) {
            const all = std.AutoHashMap(Hand(T), usize).init(alloc);
            const tree = Tree(T, S).init(alloc);
            return .{ .alloc = alloc, .all = all, .tree = tree };
        }

        fn add(self: *Game(T, S), hand: []const u8, bid: usize) !void {
            const h = try Hand(T).parse(hand);
            try self.all.put(h, bid);
            try self.tree.add(h);
        }

        fn eval(self: Game(T, S)) usize {
            var idx: usize = 0;
            return self.inner_eval(self.tree.root.?, &idx);
        }

        fn inner_eval(self: Game(T, S), node: *TreeNode(T, S), idx: *usize) usize {
            var result: usize = 0;
            if (node.left) |left| {
                result += self.inner_eval(left, idx);
            }
            idx.* += 1;
            // std.debug.print("Eval: {}=>", .{idx.*});
            // node.hand.print();
            // std.debug.print("\n", .{});
            const inner = idx.* * self.all.get(node.hand).?;
            result += inner;
            if (node.right) |right| {
                result += self.inner_eval(right, idx);
            }
            return result;
        }
    };
}

test "game" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var game = Game(Card, HandStrength).init(alloc);
    try game.add("32T3K", 765);
    try game.add("T55J5", 684);
    try game.add("KK677", 28);
    try game.add("KTJJT", 220);
    try game.add("QQQJA", 483);

    game.tree.print();

    std.debug.print("Result: {}\n", .{game.eval()});
}

test "game with joker" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var game = Game(JCard, JHandStrength).init(alloc);
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
    var game1 = Game(Card, HandStrength).init(alloc);
    var game2 = Game(JCard, JHandStrength).init(alloc);
    while (true) {
        const msg = try r.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (msg) |m| {
            if (m.len > 0) {
                const entry = try parse_entry(m);
                try game1.add(entry.hand, entry.bid);
                try game2.add(entry.hand, entry.bid);
            } else break;
        } else break;
    }

    std.debug.print("Result part 1: {}\n", .{game1.eval()});
    std.debug.print("Result part 2: {}\n", .{game2.eval()});
}

pub fn main() !void {
    std.debug.print("AoC2023-Day{s}\n", .{"07"});

    try run();
}
