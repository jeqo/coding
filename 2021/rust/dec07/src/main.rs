use std::collections::HashMap;

use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;

fn main() -> std::io::Result<()> {
    println!("dec07");

    // input: set of positions
    // goal: find the position that requires less moves for all to align

    // min ( sum ( x - s ) )
    // x is unknown

    // h1:
    // floor ( s1 + s2 / 2 )
    // 1 + 16 = 17 / 2 = 8
    // 8 + 2 = 10 / 2 = 5 
    // 5 + 0 = 5 / 2 = 2
    // 2 + 4 = 6 / 2 = 3
    // 3 + 2 = 5 / 2 = 2
    // 2 + 7 = 9 / 2 = 4
    // 4 + 1 = 5 / 2 = 2
    // 2 + 2 = 4 / 2 = 2
    // 2 + 14 = 16 / 2 = 8
    // No

    // h2:
    // 16 1 2
    //  15 1 14 // get distances between 2
    //    2 => 15 // choose the number that represents less moves
    // other opts:
    //  1 => 16
    //  3 => 13 + 1 + 2 = 16
    
    // h2.1:
    // 16,1,2,0,4
    // 16:0,15,14,16,12 = ...
    // 1:15,0,1,1,3 = 20
    // 2:14,1,0,2,2 = 19 (*)
    // 0:16,1,2,0,4 = 23
    // 4:12,3,2,4,0 = 21
    // sum and get min

    // steps:
    // [x] from a list
    // [x] get a set of combinations of 2
    // [x] calculate diff
    // [x] group by position
    // [x] each position sums all diffs
    // [ ] min diff wins

    // 5
    // 00000 = 0 x
    // 00001 = 1 x
    // 00010 = 2 x
    // 00011 = 3 v
    // 00100 = 4 x
    // 00101 = 5 v
    // 00110 = 6 v
    // 00111 = 7 x
    // 01000 = 8 x
    // 01001 = 9 v
    // 01010 = 10 v
    // 01011 = 11 x

    // 00011
    // 00110
    // 00101
    // 01001
    // 01010
    // 01100
    // 10001

    // for i in 1..5
    //   n = 2.pow(1)
    //   for j in 1..5
    //     m = n + 2.pow(1)


    //let input: Vec<u64> = vec![16,1,2,0,4,2,7,1,2,14];
    //let path = "./../../dec07/test.txt";
    let path = "./../../dec07/input.txt";
    let f = File::open(path)?;
    let mut reader = BufReader::new(f);

    let mut l = String::new();
    let _len = reader.read_line(&mut l)?;
    let mut input: Vec<u64> = l
        .trim()
        .split(',')
        .map(|x| x.parse::<u64>().unwrap())
        .collect();
    println!("Line {:?} with len {}", input, input.len());
    
    let mut map = HashMap::new(); 

    // find combinations of 2
    //const POW: u64 = 2u64.pow(1000);
    let size: usize = input.len().try_into().unwrap();
    // let pow: u32 = 20;
    // for i in 3..=2u64.pow(pow) { // too brute force xD
        // if i.count_ones() == 2 {
    
    for i in 1..=size-1 {
        // let a = 2u64.pow(i); // again brute force and not needed
        for j in 0..=i-1 {
            // let b = a + 2u64.pow(j); // same
            // let bin = format!("{b:010b}"); // actually dont need these
            // let l = bin.find('1').unwrap();
            // let r = bin.rfind('1').unwrap();
            //println!("{i} => {bin} 1s at {l} and {r}");
            
            let diff = input[i].abs_diff(input[j]);
            //println!("{i} => {bin} 1s at {l} and {r}, diff {diff}");
            
            match map.get_mut(&i) {
                Some(x) => { *x += diff; },
                None => { map.insert(i, diff); }
            }
            match map.get_mut(&j) {
                Some(x) => { *x += diff; },
                None => { map.insert(j, diff); }
            }
        }
    }
        //}
    //}
    
    let mut min = u64::MAX;
    let mut min_pos: usize = 11;

    for (pos, diff) in &map {
        if diff < &min { min = *diff; min_pos = *pos }
        println!("{} => {diff}", input[*pos]);
    }
        
    println!("Result {} => {}", input[min_pos], min);

    return Ok(())
}
