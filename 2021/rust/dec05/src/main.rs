#[derive(Debug,Hash,Eq,PartialEq)]
struct Position(u32, u32);

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

    //let mut rows = HashMap::new();
    //let mut cols = HashMap::new();
    let mut dots = HashMap::new();

    loop {
        let mut line = String::new();
        let len = reader.read_line(&mut line)?;

        if len == 0 { println!("EOF"); break; }

        let nums: Vec<Vec<u32>> = line.trim().split(" -> ")
            .map(|x| x.split(',').map(|y| y.parse::<u32>().unwrap()).collect())
            .collect();
        assert!(nums.len() == 2);

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
        }


    }

    println!("All dots");
    for (pos, inc) in &dots {
        println!("{} @ {:?}", inc, pos);
    }

    println!();

    let mut sum = 0;
    for (pos, inc) in &dots {
        if *inc > 1 {
            println!("found repeated pos @ {:?}", pos);
            sum += 1;
        }
    }
    println!("Total: {}", sum);
    return Ok(());
}
