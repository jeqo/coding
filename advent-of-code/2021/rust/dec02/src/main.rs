use std::fmt;

#[derive(Debug)]
enum Direction {
    Forward(i32),
    Down(i32),
    Up(i32),
}

impl fmt::Display for Direction {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
       write!(f, "{:?}", self)
    }
}

fn parse_direction(txt: String) -> Direction {
    let c: Vec<&str> = txt.trim().split(' ').collect();
    assert!(c.len() == 2);
    let dir = c[0];
    let pos = c[1].parse::<i32>().unwrap();
    match dir {
        "forward" => { return Direction::Forward(pos); }
        "down" => { return Direction::Down(pos); }
        "up" => { return Direction::Up(pos); }
        _ => { panic!("unknown direction"); }
    }
}

use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;

fn main() -> std::io::Result<()> {
    println!("Dec02");
    // starting point (x: hor, y: depth)
    let mut x: i32 = 0;
    let mut y: i32 = 0;
    let mut aim: i32 = 0;

    // read input.txt
    let f = File::open("./../../dec02/input.txt")?;
    //let f = File::open("./../../dec02/test.txt")?;
    let mut reader = BufReader::new(f);

    loop {
        let mut line = String::new();
        let len = reader.read_line(&mut line)?;
        // println!("Line is {len} bytes long: {line}");
        if len <= 1 { break; }

        let dir = parse_direction(line);

        match dir {
            Direction::Forward(p) => { 
                y += aim * p;
                x += p;
            }
            Direction::Up(p) => { aim -= p; }
            Direction::Down(p) => { aim += p; }
        }
        println!("horizontal position {x}");
        println!("depth {y}");
        println!("aim {aim}");
    }

    println!("horizontal position {x}");
    println!("depth {y}");
    println!("multiplication {}", x * y);

    Ok(())
}
