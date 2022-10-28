use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;

fn main() -> std::io::Result<()> {
    println!("Dec 09");

    //let prev = vec![9; 12];
    //let curr = vec![9, 2,1,9,9,9,4,3,2,1,0, 9];
    //let next = vec![9, 3,9,8,7,8,9,4,9,2,1, 9];

    //let curr_line = String::from("2199943210");
    //let next_line = String::from("3987894921");
    //let size = curr_line.len();
    //let prev = parse_line(String::new(), size);
    //let curr = parse_line(curr_line, size);
    //let next = parse_line(next_line, size);
    // println!("Input: {:?} {:?} {:?}", prev, curr, next);
    //println!("{:?}", find_lowests(prev, curr, next));

    
    //let path = "./../../dec09/test.txt";
    let path = "./../../dec09/input.txt";
    let mut reader1 = BufReader::new(File::open(path)?);
    let mut reader2 = BufReader::new(File::open(path)?);

    let mut sum = 0u64;

    let mut prev = String::new();
    let mut i = 1;

    reader2.read_line(&mut String::new());

    loop {
        let mut first_line = String::new();
        reader1.read_line(&mut first_line)?;
        
        let mut second_line = String::new();
        let len = reader2.read_line(&mut second_line)?;
    
        
        if len == 0 {
            for n in find_lowests(prev.trim(), first_line.trim(), &"") {
                sum += n as u64 + 1;
                println!("line {i}: {:?}", n);
            }
            
            println!("EOF"); 
            break;
        }
        
        for n in find_lowests(prev.trim(), first_line.trim(), second_line.trim()) {
            sum += n as u64 + 1;
            println!("line {i}: {:?}", n);
        }

        prev = first_line.clone();
        
        i += 1;
    }

    println!("Sum {:?}", sum);

    Ok(())
}

//fn find_lowests(prev: Vec<u8>, curr: Vec<u8>, next: Vec<u8>) -> Vec<u8> {
fn find_lowests(prev_line: &str, curr_line: &str, next_line: &str) -> Vec<u8> {
    let size = curr_line.len();
    let prev = parse_line(prev_line, size);
    let curr = parse_line(curr_line, size);
    let next = parse_line(next_line, size);
    
    let mut lowests = Vec::new();
    for i in 1..=curr.len() - 1 {
        if curr[i] < prev[i] 
            && curr[i] < curr [i-1] 
            && curr[i] < curr[i+1] 
            && curr[i] < next[i] {
            //println!("Found {}", curr[i]);
            lowests.push(curr[i]);
        }
    }
    return lowests;
}

fn parse_line(line: &str, size: usize) -> Vec<u8> {
    if line.is_empty() { return vec![9; size + 2];}

    let mut parsed: Vec<u8> = Vec::new();
    parsed.push(9);
    for c in line.chars() {
        parsed.push(c.to_digit(10).unwrap() as u8);
    }
    parsed.push(9);
    return parsed;
}
