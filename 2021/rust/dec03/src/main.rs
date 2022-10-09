use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;

fn array_len(f: File) -> usize {
    let mut reader = BufReader::new(f);
    let mut line = String::new();
    let len = reader.read_line(&mut line);
    return len.unwrap();
}

fn main() -> std::io::Result<()> {
    println!("Dec03");
    //let mut sum: [i32; 5] = [0; 5];
    //let mut sum: Vec<i32> = Vec::new();

    // read input.txt
    let path = "./../../dec03/input.txt";
    //let path = "./../../dec03/test.txt";
    let f0 = File::open(path)?;
    let n = array_len(f0) - 1;
    println!("array len: {}", n); 

    let mut prev = String::new();
    let mut last = String::new();
    for i in 0..=n-1 {
        let mut sum: isize = 0;

        let f = File::open(path)?;
        let mut reader = BufReader::new(f);
        loop {
            let mut line = String::new();
            let len = reader.read_line(&mut line)?;
            if len <= 1 { println!("EOF"); break; }

            if !prev.is_empty() {
                // let cp = line.chars().nth(i - 1).unwrap();
                if line.starts_with(prev.as_str()) {
                    println!("{i} Line is {len} bytes long: {line}");
                    let c = line.chars().nth(i).unwrap();
                    //println!("{:?}", c);
                    match c {
                        '0' => { sum -= 1; }
                        '1' => { sum += 1; }
                        _ => { panic!("unknown bit"); }
                    }
                    last = line;
                }
            } else {
                println!("{i} Line is {len} bytes long: {line}");
                let c = line.chars().nth(i).unwrap();
                //println!("{:?}", c);
                match c {
                    '0' => { sum -= 1; }
                    '1' => { sum += 1; }
                    _ => { panic!("unknown bit"); }
                }
            }
        }

        //if sum >= 0 { prev.push('1'); } // for oxig
        if sum < 0 { prev.push('1'); } // for co2
        else { prev.push('0'); }

        println!("sum[{}]={}", i, sum);
    }
    
    Ok(())
}

// --part1--
/*
fn main() -> std::io::Result<()> {
    println!("Dec03");
    //let mut sum: [i32; 5] = [0; 5];
    let mut sum: Vec<i32> = Vec::new();

    // read input.txt
    let f = File::open("./../../dec03/input.txt")?;
    //let f = File::open("./../../dec03/test.txt")?;
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
    
    Ok(())
}
*/
