/*
chunks: (), [], {}, <>
line contains chunks,
chunks can contain other chunks
lines can be complete, incomplete, or corrupted
*/
#[derive(Debug)]
enum Result {
    Complete(),
    InProgress(Vec<char>),
    Incomplete(char),
    Corrupt(char, char),
}

fn process_chunks(head: char, tail: &[char]) -> Result {
    println!("H: {} T: {:?}", head, tail);
    if tail.is_empty() {
        return Result::Incomplete(head);
    }
    if tail.len() == 1 {
        if is_pair(head, tail[0]) {
            return Result::Complete();
        } else {
            return Result::Corrupt(head, tail[0]);
        }
    } else {
        if is_pair(head, tail[0]) {
            return Result::InProgress(tail[1..].to_vec());
        } else {
            if is_closing(tail[0]) {
                return Result::Corrupt(head, tail[0]);
            }
            match process_chunks(tail[0], &tail[1..]) {
                Result::InProgress(left) => {
                    if left.is_empty() {
                        return Result::Incomplete(head);
                    } else {
                        return process_chunks(head, &left[..]);
                    }
                }
                r => return r,
            }
        }
    }
}

fn is_closing(c: char) -> bool {
    return c == ')' || c == '}' || c == ']' || c == '}';
}

fn is_pair(a: char, b: char) -> bool {
    //println!("Checking: {} and {}", a, b);
    match a {
        '(' => {
            return b == ')';
        }
        '[' => {
            return b == ']';
        }
        '{' => {
            return b == '}';
        }
        '<' => {
            return b == '>';
        }
        _ => {
            return false;
        }
    }
}

fn process_line(line: &str) {
    let chars: Vec<char> = line.trim().chars().collect();
    println!("{:?}", chars);
    process(chars);
}

fn process(chars: Vec<char>) {
    match process_chunks(chars[0], &chars[1..]) {
        Result::InProgress(c) => { 
            println!("InProgress! {:?}", c);
            if !c.is_empty() {
                process(c);
            }
        },
        Result::Complete() => { println!("Complete"); }
        Result::Corrupt(a, b) => { println!("Corrupt! {} {}", a, b); }
        Result::Incomplete(a) => { println!("Incomplete! {}", a); }
    }
}

use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;

fn main() -> std::io::Result<()> {
    println!("Dec10");

    //Completed
    //process_line(&"[]");
    //println!();
    //process_line(&"([])");
    //println!();
    //process_line(&"{()()()}");
    //println!();
    //process_line(&"<([{}])>");
    //println!();
    //process_line(&"[<>({}){}[([])<>]]");
    //println!();

    //Corrupted
    //process_line(&"(]");
    //println!();
    //process_line(&"{()()()>");
    //println!();
    //process_line(&"(((()))}");
    //println!();
    //process_line(&"<([]){()}[{}])");
    //println!();

    //Incomplete
    //process_line(&"[({(<(())[]>[[{[]{<()<>>");
    //println!();

    //process_line(&"[({(<(())[]>[[{[]{<()<>>");
    //println!();
    //process_line(&"[[<[([]))<([[{}[[()]]]");
    //println!();
    
    process_line(&"[(()[<>])]({[<{<<[]>>(");
    println!();


    let path = "./../../dec10/test.txt";
    //let path = "./../../dec10/input.txt";
    let mut reader = BufReader::new(File::open(path)?);

    loop {
        let mut line = String::new();
        let len = reader.read_line(&mut line)?;
    
        if len == 0 { println!("EOF"); break; }

        //process_line(&line);
        //println!();
    }


    Ok(())
}
