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
    Incomplete(Vec<char>),
    Corrupt(char, char),
    Unknown(),
}

fn process_chunks(head: char, tail: &[char]) -> Result {
    println!("H: {} T: {:?}", head, tail);
    if tail.is_empty() {
        return Result::Incomplete(vec![head]);
    }
    if tail.len() == 1 {
        if is_pair(head, tail[0]) {
            return Result::Complete();
        } else {
            if is_opening(head) && is_opening(tail[0]) {
                return Result::Incomplete(vec![tail[0], head]);
            } else {
                return Result::Error(head, Some(tail[0]));
            }
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
                },
                Result::Complete() => { return Result::Incomplete(vec![head]); }
                Result::Incomplete(mut a) => {
                    println!("Incomplete! {:?}", a);
                    a.push(head);
                    return Result::Incomplete(a); 
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

fn points(a: char) -> u64 {
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

fn process_line(line: &str) -> (Result, u64) {
    let chars: Vec<char> = line.trim().chars().collect();
    println!("{:?}", chars);
    return process(chars);
}

fn process(chars: Vec<char>) -> (Result, u64) {
    let result = process_chunks(chars[0], &chars[1..]);
    match result {
        Result::InProgress(c) => { 
            // println!("InProgress! {:?}", c);
            return process(c);
        },
        Result::Complete() => { println!("Complete"); return (result, 0); }
        Result::Error(a, b) => {
            if b.is_none() { println!("Incomplete! {:?}", a); return (Result::Incomplete(vec![a]), 0); } 
            else if is_opening(a) && is_closing(b.unwrap()) { 
                println!("Corrupt! {} {:?}", a, b); 
                return (Result::Corrupt(a, b.unwrap()), points(b.unwrap())); 
            } 
            else if is_opening(a) && is_opening(b.unwrap()) { 
                println!("Incomplete! {} {:?}", a, b); 
                return (Result::Incomplete(vec![a]), points(b.unwrap())); 
            } 
            else { 
                println!("Unknown {} {:?}", a, b);
                return (Result::Unknown(), points(b.unwrap())); 
            }
        }
        Result::Corrupt(a, b) => { 
            println!("Corrupt! {} {}", a, b);
            return (result, points(b)); 
        }
        Result::Incomplete(a) => { 
            //println!("Incomplete! {:?}", a);
            let points = incomplete_points(&a);
            return (Result::Incomplete(a), points);
        }
        Result::Unknown() => { return (result, 0);}
    }
}

fn incomplete_points(a: &Vec<char>) -> u64 {
    let mut sum = 0;
    for c in a {
        sum = sum * 5;
        match c {
            '(' => sum += 1,
            '[' => sum += 2,
            '{' => sum += 3,
            '<' => sum += 4,
            _ => panic!("Unknown closing!"),
        }
    }
    return sum;
}

use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;

fn main() -> std::io::Result<()> {
    println!("Dec10");


    //let path = "./../../dec10/test.txt";
    let path = "./../../dec10/input.txt";
    let mut reader = BufReader::new(File::open(path)?);
    
    let mut sum = 0;
    let mut sum_inc = Vec::new();

    loop {
        let mut line = String::new();
        let len = reader.read_line(&mut line)?;
    
        if len == 0 { println!("EOF"); break; }
        let res = process_line(&line);
        match res.0 {
            Result::Corrupt(_, _) => sum += res.1,
            Result::Incomplete(_) => {
                println!("{:?}", res);
                sum_inc.push(res.1);
            },
            _ => {},
        }
        
        println!();
    }

    sum_inc.sort();

    println!("Sum Part 1=> {}", sum);
    for (a, b) in sum_inc.iter().enumerate() {
        println!("Sum inc: {} => {}", a, b);
    }


    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_incomplete() {

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

        let a = process_line(&"[(()[<>])]({[<{<<[]>>(");
        println!("{:?}", a);
    }

}
