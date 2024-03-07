//! AoC2023 day 1
//! The input, as usual, requires reading an input text, line by line.
//! In this case, each line has text with 2 or more numbers
//! The first and last digit need to be combined to form a single 2-digit number
//! The result is the sum of all callibration values
//! For the second round, digits can be spelled, and should be included in the calculation
const std = @import("std");
const ascii = std.ascii;
const fmt = std.fmt;
const mem = std.mem;
const print = std.debug.print;
const expect = std.testing.expect;

test "[v1] extract first and last digit from string" {
    try expect(try find_number_v1("1abc2") == 12);
    try expect(try find_number_v1("pqr3stu8vwx") == 38);
    try expect(try find_number_v1("a1b2c3d4e5f") == 15);
    try expect(try find_number_v1("treb7uchet") == 77);
}

fn find_number_v1(line: []const u8) error{InvalidCharacter}!u8 {
    const undef_int = 10;
    // some issues with using undefined for comparison: https://github.com/ziglang/zig/issues/10703
    var first: u8 = undef_int;
    var last: u8 = undef_int;

    for (line) |char| {
        if (ascii.isDigit(char)) {
            const digit = try fmt.charToDigit(char, 10);
            if (first == undef_int) {
                first = digit;
                last = digit;
            } else {
                last = digit;
            }
        }
    }
    return first * 10 + last;
}

test "[v2] extract first and last digit from string" {
    try expect(try find_number_v2("1one1zero") == 10);
    try expect(try find_number_v2("2two2") == 22);
    try expect(try find_number_v2("3three3") == 33);
    try expect(try find_number_v2("4four4") == 44);
    try expect(try find_number_v2("5five5") == 55);
    try expect(try find_number_v2("6six6") == 66);
    try expect(try find_number_v2("7seven7") == 77);
    try expect(try find_number_v2("8eight8") == 88);
    try expect(try find_number_v2("9nine9") == 99);
    try expect(try find_number_v2("two1nine") == 29);
    try expect(try find_number_v2("eightwothree") == 83);
    try expect(try find_number_v2("abcone2threexyz") == 13);
    try expect(try find_number_v2("xtwone3four") == 24);
    try expect(try find_number_v2("4nineeightseven2") == 42);
    try expect(try find_number_v2("zoneight234") == 14);
    try expect(try find_number_v2("7pqrstsixteen") == 76);
    try expect(try find_number_v2("eightfourxrzldsqgbsrgnlvshv3pprjpf") == 83);
}

fn find_number_v2(line: []const u8) error{InvalidCharacter}!u8 {
    const undef_int = 10;
    // some issues with using undefined for comparison: https://github.com/ziglang/zig/issues/10703
    var first: u8 = undef_int;
    var last: u8 = undef_int;

    // group spelled numbers
    const spelled_numbers = [10]*const [5:0]u8{ "zero ", "one  ", "two  ", "three", "four ", "five ", "six  ", "seven", "eight", "nine " };
    // and keep known sizes in mem for easier matching
    const spelled_numbers_len = [10]u8{ 4, 3, 3, 5, 4, 4, 3, 5, 5, 4 };

    // index to iterate line chars
    var char_index: u8 = 0;
    while (char_index < line.len) {
        const char: u8 = line[char_index];
        if (ascii.isDigit(char)) {
            const digit = try fmt.charToDigit(char, 10);
            if (first == undef_int) {
                first = digit;
                last = digit;
            } else {
                last = digit;
            }
            char_index = char_index + 1;
        } else {
            var spelled_digit: u8 = undef_int;
            // check there's enough len to check
            if (line.len - char_index >= 3) {
                // main logic
                for (spelled_numbers, 0..) |spelled_number, num_index| {
                    if (char == spelled_number[0]) {
                        const num_len = spelled_numbers_len[num_index];
                        if (line.len - char_index >= num_len) {
                            const found = line[char_index..(char_index + num_len)];
                            const expected = spelled_number[0..num_len];
                            if (mem.eql(u8, found, expected)) {
                                spelled_digit = @truncate(num_index);
                                // note: may make sense to jump to the end of the number
                                // but there are cases where a subsequent letter
                                // may be the beginning of the next number,
                                // leading to miss some last number potentially
                                break;
                            }
                        }
                    }
                }
            }
            if (spelled_digit != undef_int) {
                if (first == undef_int) {
                    first = spelled_digit;
                    last = spelled_digit;
                } else {
                    last = spelled_digit;
                }
            }
            char_index = char_index + 1;
        }
    }

    return first * 10 + last;
}

const fs = std.fs;
const io = std.io;

fn run(find_number: anytype) !u32 {
    var file = try fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var result: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len > 0) {
            const n = try find_number(line);
            result += n;
        }
    }
    return result;
}

pub fn main() !void {
    print("AoC2023 - Day {s}\n", .{"01"});
    const v1: u32 = try run(find_number_v1);
    print("[v1] Result: {}\n", .{v1});
    const v2: u32 = try run(find_number_v2);
    print("[v2] Result: {}\n", .{v2});
}
