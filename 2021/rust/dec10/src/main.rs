/*
chunks: (), [], {}, <>
line contains chunks,
chunks can contain other chunks
lines can be complete, incomplete, or corrupted
*/
#[derive(Debug)]
enum Result {
    Complete(Vec<char>),
    Incomplete(char),
    Corrupt(char, char),
}

fn process_chunks(head: char, tail: &[char]) -> Result {
    println!("Head: {} and Tail: {:?}", head, tail);
    if tail.is_empty() {
        return Result::Incomplete(head);
    }
    if tail.len() == 1 {
        if is_pair(head, tail[0]) {
            return Result::Complete(vec![]);
        } else {
            return Result::Corrupt(head, tail[0]);
        }
    } else {
        if is_pair(head, tail[0]) {
            return Result::Complete(tail[1..].to_vec());
        } else {
            match process_chunks(tail[0], &tail[1..]) {
                Result::Complete(left) => {
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

fn is_pair(a: char, b: char) -> bool {
    println!("Checking: {} and {}", a, b);
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
    let left = process_chunks(chars[0], &chars[1..]);
    println!("All left: {:?}", left);
}

use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;

fn main() -> std::io::Result<()> {
    println!("Dec10");
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
    //process_line(&"(((((((((())))))))))");
    

    let path = "./../../dec10/test.txt";
    //let path = "./../../dec10/input.txt";
    let mut reader = BufReader::new(File::open(path)?);

    let mut line = String::new();
    let len = reader.read_line(&mut line)?;

    println!("{}", line);

    Ok(())
}
