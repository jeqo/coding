use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;

fn main() -> std::io::Result<()> {
    println!("dec06");

    //let path = "./../../dec06/test.txt";
    let path = "./../../dec06/input.txt";
    let f = File::open(path)?;
    let mut reader = BufReader::new(f);

    let mut l = String::new();
    let len = reader.read_line(&mut l)?;
    let mut fishes: Vec<isize> = l
        .trim()
        .split(',')
        .map(|x| x.parse::<isize>().unwrap())
        .collect();
    println!("Line {:?} with len {}", fishes, len);

    //let days = 18;
    let days = 80;
    for day in 1..=days {
        let mut newborns: Vec<isize> = Vec::new();
        for n in fishes.iter_mut() {
            match n {
                0 => { *n = 6; newborns.push(8); },
                _ => { *n -= 1; }
            }
        }
        fishes.append(&mut newborns);
        println!("Day {}: {:?}", day, fishes);
    }

    println!("Array: {:?}", fishes);
    println!("Result: {}", fishes.len());

    return Ok(());
}
