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
    Error(char, Option<char>),
    Incomplete(char),
    Corrupt(char, char),
}

fn process_chunks(head: char, tail: &[char]) -> Result {
    //println!("H: {} T: {:?}", head, tail);
    if tail.is_empty() {
        return Result::Error(head, None);
    }
    if tail.len() == 1 {
        if is_pair(head, tail[0]) {
            return Result::Complete();
        } else {
            return Result::Error(head, Some(tail[0]));
        }
    } else {
        if is_pair(head, tail[0]) {
            return Result::InProgress(tail[1..].to_vec());
        } else {
            if is_closing(tail[0]) {
                return Result::Error(head, Some(tail[0]));
            }
            match process_chunks(tail[0], &tail[1..]) {
                Result::InProgress(left) => {
                    if left.is_empty() {
                        return Result::Error(head, None);
                    } else {
                        return process_chunks(head, &left[..]);
                    }
                }
                r => return r,
            }
        }
    }
}

fn is_opening(c: char) -> bool {
    return c == '(' || c == '{' || c == '[' || c == '<';
}

fn is_closing(c: char) -> bool {
    return c == ')' || c == '}' || c == ']' || c == '>';
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

fn points(a: char) -> u32 {
    match a {
        ')' => {
            return 3;
        }
        ']' => {
            return 57;
        }
        '}' => {
            return 1197;
        }
        '>' => {
            return 25137;
        }
        _ => {
            return 0;
        }
    }
}

fn process_line(line: &str) -> u32 {
    let chars: Vec<char> = line.trim().chars().collect();
    println!("{:?}", chars);
    return process(chars);
}

fn process(chars: Vec<char>) -> u32 {
    match process_chunks(chars[0], &chars[1..]) {
        Result::InProgress(c) => { 
            // println!("InProgress! {:?}", c);
            if !c.is_empty() {
                return process(c);
            }
            return 0;
        },
        Result::Complete() => { println!("Complete"); return 0; }
        Result::Error(a, b) => {
            if b.is_none() { println!("Incomplete! {:?}", a); return 0; } 
            else if is_opening(a) && is_closing(b.unwrap()) { 
                println!("Corrupt! {} {:?}", a, b); 
                return points(b.unwrap()); 
            } 
            else if is_opening(a) && is_opening(b.unwrap()) { 
                println!("Incomplete! {} {:?}", a, b); 
                return points(b.unwrap()); 
            } 
            else { 
                println!("Unknown {} {:?}", a, b);
                return points(b.unwrap()); 
            }
        }
        Result::Corrupt(a, b) => { 
            println!("Corrupt! {} {}", a, b);
            return points(b);  
        }
        Result::Incomplete(a) => { println!("Incomplete! {}", a); return 0; }
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
    
    //process_line(&"[(()[<>])]({[<{<<[]>>(");
    //println!();


    //let path = "./../../dec10/test.txt";
    let path = "./../../dec10/input.txt";
    let mut reader = BufReader::new(File::open(path)?);
    
    let mut sum = 0;

    loop {
        let mut line = String::new();
        let len = reader.read_line(&mut line)?;
    
        if len == 0 { println!("EOF"); break; }

        sum += process_line(&line);
        println!();
    }

    println!("Sum => {}", sum);


    Ok(())
}
