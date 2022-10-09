fn convert(bits: &[u8]) -> u8 {
    let mut result: u8 = 0;
    bits.iter().for_each(|&bit| {
        result <<= 1;
        result ^= bit;
    });
    result
}

use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;

fn main() -> std::io::Result<()> {
    println!("Dec03");
    //let mut sum: [i32; 5] = [0; 5];
    let mut sum: Vec<i32> = Vec::new();

    // read input.txt
    let f = File::open("./../../dec03/input.txt")?;
    //let f = File::open("./../../dec03/test.txt")?;
    //let f = File::open("./../../dec03/test1.txt")?;
    let mut reader = BufReader::new(f);    

    loop {
        let mut line = String::new();
        let len = reader.read_line(&mut line)?;
        if len <= 1 { break; }
        println!("Line is {len} bytes long: {line}");

        if sum.len() == 0 { sum = vec![0; len - 1]}
        let mut c = line.trim().chars(); 
        let mut n = 0;
        for val in line.trim().chars() {
            println!("{:?}", val);
            match val {
                '0' => { sum[n] -= 1; }
                '1' => { sum[n] += 1; }
                _ => { panic!("unknown bit"); }
            }
            n += 1;
        }
    }

    println!("Sum {:?}", sum);
    println!("Sum {:?}", sum.len());

    let mut gamma = vec![0; sum.len()];
    let mut epsilon = vec![0; sum.len()];

    for n in 1..=sum.len() {
        if sum[n-1] > 0 { gamma[n-1] = 1; epsilon[n-1] = 0; }
        if sum[n-1] <= 0 { epsilon[n-1] = 1; gamma[n-1] = 0; }
    }

    println!("gamma {:?}", gamma);
    println!("epsilon {:?}", epsilon);
    let g: u32 = convert(&gamma).into();
    println!("gamma {:?}", g);
    let e: u32 = convert(&epsilon).into();
    println!("epsilon {:?}", e);
    println!("result {:?}", g * e);
    // println!("Value {}", txt.parse::<i32>().unwrap());
    
    Ok(())
}
