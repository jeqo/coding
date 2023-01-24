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
    let mut fishes: Vec<usize> = l
        .trim()
        .split(',')
        .map(|x| x.parse::<usize>().unwrap())
        .collect();
    println!("Line {:?} with len {}", fishes, len);

    //let days = 18;
    //let days = 80; //part 1

    // part 1
    //let days = 256;
    //for day in 1..=days {
    //    let mut newborns: Vec<usize> = Vec::new();
    //    for n in fishes.iter_mut() {
    //        match n {
    //            0 => { *n = 6; newborns.push(8); },
    //            _ => { *n -= 1; }
    //        }
    //    }
    //    fishes.append(&mut newborns);
    //    // println!("Day {}: {:?}", day, fishes);
    //}

    //println!("Array: {:?}", fishes);
    //println!("Result: {}", fishes.len());

    const range: usize = 9;
    let mut pop: [u64; range] = [0; range];

    println!("Population: {:?}", pop);
    for f in fishes {
        pop[f] += 1;
    }
    println!("Day 0: Population: {:?}", pop);

    //let days = 18;
    let days = 256;
    for day in 1..=days {
        println!("Day {}: Start Population: {:?}", day, pop);
        let mut ready = pop[0];
        
        for p in 0..=range - 1 {
            if p > 0 {
                pop[p-1] = pop[p];
                pop[p] = 0;
            }
        }

        pop[6] += ready;
        pop[8] += ready;

        println!("Day {}: End Population: {:?}", day, pop);
    }

    let mut result = 0;
    for r in pop {
        result += r;
    }
    
    println!("Population: {:?}", pop);
    println!("Result: {}", result);

    return Ok(());
}
