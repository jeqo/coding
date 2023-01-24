#[derive(Debug,Hash,Eq,PartialEq)]
struct Position(i32, i32);

use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;

use std::collections::HashMap;

fn main() -> std::io::Result<()> {
    println!("Dec05");

    //let path = "./../../dec05/test.txt";
    let path = "./../../dec05/input.txt";
    let f = File::open(path)?;
    let mut reader = BufReader::new(f);

    let mut dots = HashMap::new();

    let mut xmax : i32 = 0;
    let mut ymax : i32 = 0;

    loop {
        let mut line = String::new();
        let len = reader.read_line(&mut line)?;

        if len == 0 { println!("EOF"); break; }

        let nums: Vec<Vec<i32>> = line.trim().split(" -> ")
            .map(|x| x.split(',').map(|y| y.parse::<i32>().unwrap()).collect())
            .collect();
        assert!(nums.len() == 2);

        if xmax < nums[0][0] { xmax = nums[0][0]; }
        if xmax < nums[1][0] { xmax = nums[1][0]; }
        if ymax < nums[0][1] { ymax = nums[0][1]; }
        if ymax < nums[1][1] { ymax = nums[1][1]; }

        if nums[0][0] == nums[1][0] || nums[0][1] == nums[1][1] {
            if nums[0][0] == nums[1][0] {
                println!("vertical: {:?}", nums);
                let x = nums[0][0];
                if nums[0][1] < nums[1][1] {
                    let mut y = nums[0][1];
                    while y <= nums[1][1] {
                        let pos = Position(x, y);
                        if let Some(inc) = dots.get_mut(&pos) {
                            *inc += 1;
                        } else {
                            dots.insert(pos, 1);
                        }
                        y += 1;
                    }
                } else {
                    let mut y = nums[1][1];
                    while y <= nums[0][1] {
                        let pos = Position(x, y);
                        if let Some(inc) = dots.get_mut(&pos) {
                            *inc += 1;
                        } else {
                            dots.insert(pos, 1);
                        }
                        y += 1;
                    }
                }
            }

            if nums[0][1] == nums[1][1] {
                println!("horizontal: {:?}", nums);
                let y = nums[1][1];
                if nums[0][0] < nums[1][0] {
                    let mut x = nums[0][0];
                    while x <= nums[1][0] {
                        let pos = Position(x, y);
                        if let Some(inc) = dots.get_mut(&pos) {
                            *inc += 1;
                        } else {
                            dots.insert(pos, 1);
                        }
                        x += 1;
                    }
                } else {
                    let mut x = nums[1][0];
                    while x <= nums[0][0] {
                        let pos = Position(x, y);
                        if let Some(inc) = dots.get_mut(&pos) {
                            *inc += 1;
                        } else {
                            dots.insert(pos, 1);
                        }
                        x += 1;
                    }
                }
            }
        } else { // process diagonals
            if (nums[0][0] - nums[1][0]).abs() == (nums[0][1] - nums[1][1]).abs() {
                println!("diagonal: {:?}", nums);
                if nums[0][0] < nums[1][0] {
                    if nums[0][1] < nums[1][1] { // q4
                        let mut x = nums[0][0];
                        let mut y = nums[0][1];
                        while x <= nums[1][0] {
                            let pos = Position(x, y);
                            if let Some(inc) = dots.get_mut(&pos) {
                                *inc += 1;
                            } else {
                                dots.insert(pos, 1);
                            }
                            y += 1;
                            x += 1;
                        }
                    } else { // q1
                        let mut x = nums[0][0];
                        let mut y = nums[0][1];
                        while x <= nums[1][0] {
                            let pos = Position(x, y);
                            if let Some(inc) = dots.get_mut(&pos) {
                                *inc += 1;
                            } else {
                                dots.insert(pos, 1);
                            }
                            y -= 1;
                            x += 1;
                        }
                    }
                } else {
                    if nums[0][1] < nums[1][1] { //q3
                        let mut x = nums[0][0];
                        let mut y = nums[0][1];
                        while x >= nums[1][0] {
                            let pos = Position(x, y);
                            if let Some(inc) = dots.get_mut(&pos) {
                                *inc += 1;
                            } else {
                                dots.insert(pos, 1);
                            }
                            y += 1;
                            x -= 1;
                        }
                    } else { //q2
                        let mut x = nums[0][0];
                        let mut y = nums[0][1];
                        while x >= nums[1][0] {
                            let pos = Position(x, y);
                            if let Some(inc) = dots.get_mut(&pos) {
                                *inc += 1;
                            } else {
                                dots.insert(pos, 1);
                            }
                            y -= 1;
                            x -= 1;
                        }
                    }
                }
            }
        }
    }

    println!("All dots");
    for y in 0..=ymax {
        for x in 0..=xmax {
            match dots.get(&Position(x, y)) {
                Some(inc) => print!("{}", inc),
                None => print!("."),
            }
        }
        print!("\n");
    }


    println!();

    let mut sum = 0;
    for (_pos, inc) in &dots {
        if *inc > 1 {
            //println!("found repeated pos @ {:?}", pos);
            sum += 1;
        }
    }
    println!("Total: {}", sum);
    return Ok(());
}
