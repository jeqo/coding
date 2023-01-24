use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;
use std::collections::HashMap;

#[derive(Debug,Hash,Eq,PartialEq)]
struct Pos(usize, usize);

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

    let size = reader2.read_line(&mut String::new())?;

    let mut map = HashMap::new();

    let mut lines = Vec::new();
    lines.push(parse_line(&"", size - 1));

    loop {
        let mut first_line = String::new();
        reader1.read_line(&mut first_line)?;
        
        let mut second_line = String::new();
        let len = reader2.read_line(&mut second_line)?;
        
        if len == 0 {
            let mut lowest = find_lowests(i, prev.trim(), first_line.trim(), &"");
            for n in lowest.values() {
                sum += *n as u64 + 1;
                println!("line {i}: {:?}", n);
            }
            for (k, v) in lowest {
                map.insert(k, v);
            }
        
            lines.push(parse_line(first_line.trim(), len));
            
            println!("EOF"); 
            break;
        }
        
        let mut lowest = find_lowests(
            i,
            prev.trim(), 
            first_line.trim(), 
            second_line.trim()
        );
        for n in lowest.values() {
            sum += *n as u64 + 1;
            println!("line {i}: {:?}", n);
        }
        for (k, v) in lowest {
            map.insert(k, v);
        }

        prev = first_line.clone();
        
        i += 1;

        lines.push(parse_line(first_line.trim(), len));
    }
    
    lines.push(parse_line(&"", size - 1));

    println!("Sum {:?}", sum);
    println!("Lowests {:?}", map);
    println!("Lines:");
    for line in &lines {
        println!("{:?}", line);
    }

    let mut basins = find_basins(lines, map);
    basins.sort();
    basins.reverse();
    println!("Total: {:?}", basins);
    println!("Result: {:?}", basins[0] * basins[1] * basins[2]);

    Ok(())
}

fn find_basins(mut lines: Vec<Vec<i8>>, lowest_map: HashMap<Pos, i8>) 
    -> Vec<u64> 
{
    // for each lowest
    let mut total = Vec::new();
    for (pos, low) in lowest_map {
        println!("Low: {low} @ {:?}", pos);
        // find position
        let sum = innundate(&mut lines, &pos, low);
        // get num and inundate
        total.push(sum);
    }
    return total;
}

fn innundate(lines: &mut Vec<Vec<i8>>, pos: &Pos, low: i8) -> u64 {
    println!("Calc cels {low} at {:?}", pos);
    let (_i, basin) = innundate_cell(lines, pos, -1, &Pos(0,0));
    println!("Basin {:?} starting at {:?}", basin, pos);
    println!();
    return basin;
}

fn innundate_cell(lines: &mut Vec<Vec<i8>>, pos: &Pos, prev: i8, p_pos: &Pos) -> (i8, u64) {
    let Pos(row,col) = pos;
    let val = lines[*row][*col];
    if val < 9 && val > prev {
        let mut sum = 1;
        {
            let next = Pos(*row - 1, *col);
            if *p_pos != next {
                println!("Val: {val} @ {:?} prev: {prev} prev_pos: {:?} and next: {:?}",
                    pos, p_pos, next);
                lines[*row][*col] = 9;
                let (p, v) = innundate_cell(lines, &next, val, &pos);
                sum += v;
            }
        }
        {
            let next = Pos(*row, *col - 1);
            if *p_pos != next {
                println!("Val: {val} @ {:?} prev: {prev} prev_pos: {:?} and next: {:?}",
                    pos, p_pos, next);
                lines[*row][*col] = 9;
                let (p, v) = innundate_cell(lines, &next, val, &pos);
                sum += v;
            }
        }
        {
            let next = Pos(*row + 1, *col);
            if *p_pos != next {
                println!("Val: {val} @ {:?} prev: {prev} prev_pos: {:?} and next: {:?}",
                    pos, p_pos, next);
                lines[*row][*col] = 9;
                let (p, v) = innundate_cell(lines, &next, val, &pos);
                sum += v;
            }
        }
        {
            let next = Pos(*row, *col + 1);
            if *p_pos != next {
                println!("Val: {val} @ {:?} prev: {prev} prev_pos: {:?} and next: {:?}",
                    pos, p_pos, next);
                lines[*row][*col] = 9;
                let (p, v) = innundate_cell(lines, &next, val, &pos);
                sum += v;
            }
        }
        return (val, sum);
    } else { return (val, 0); }
}

fn find_lowests(line: usize, prev_line: &str, curr_line: &str, next_line: &str) 
    -> HashMap<Pos, i8> 
{
    let size = curr_line.len();
    let prev = parse_line(prev_line, size);
    let curr = parse_line(curr_line, size);
    let next = parse_line(next_line, size);
    
    let mut lowests = HashMap::new();
    for i in 1..=curr.len() - 1 {
        if curr[i] < prev[i] 
            && curr[i] < curr [i-1] 
            && curr[i] < curr[i+1] 
            && curr[i] < next[i] {
            //println!("Found {}", curr[i]);
            lowests.insert(Pos(line, i), curr[i]);
        }
    }
    return lowests;
}

fn parse_line(line: &str, size: usize) -> Vec<i8> {
    if line.is_empty() { return vec![9; size + 2];}

    let mut parsed: Vec<i8> = Vec::new();
    parsed.push(9);
    for c in line.chars() {
        parsed.push(c.to_digit(10).unwrap() as i8);
    }
    parsed.push(9);
    return parsed;
}
