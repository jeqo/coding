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
    // [x] min diff wins
    // this worked for constant fuel consumption but fails on linear growth

    // h3:
    // 

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
    let input: Vec<u32> = l
        .trim()
        .split(',')
        .map(|x| x.parse::<u32>().unwrap())
        .collect();

    let size: usize = input.len().try_into().unwrap();

    let mut db = Database::new(input);
    
    println!("DB: {:?}", db);

    for i in 1..=size-1 {
        for j in 0..=i-1 {
            db.add(i, j);
        }
    }
    
    db.min();

    return Ok(())
}

#[derive(Debug)]
struct Database {
    values: Vec<u32>,
    min: u32,
    max: u32,
    map: HashMap<u32, u64>,
    calc: HashMap<u32, u32>,
}

impl Database {
    fn new(values: Vec<u32>) -> Self {
        let min = *values.iter().min().unwrap();
        let max = *values.iter().max().unwrap();
        
        let len = max - min;
        
        let mut calc = HashMap::with_capacity((len + 1) as usize);

        for i in 0..=len+1 {
            calc.insert(i, (i * (i + 1)) / 2);
        }
        Self {
            values,
            min: min,
            max: max,
            map: HashMap::with_capacity(len as usize),
            calc,
        }

    }

    fn add(&mut self, x1: usize, x2: usize) {
        let i = self.values[x1];
        let j = self.values[x2];
        let min = if i < j { i } else { j };
        let max = if i > j { i } else { j };
        let diff = max - min;

        for p in self.min..self.max {
            let d1 = min.abs_diff(p);
            let c1 = self.calc.get(&d1).unwrap();
            let d2 = max.abs_diff(p);
            let c2 = self.calc.get(&d2).unwrap();
            let calc = c1 + c2;
            match self.map.get_mut(&p) {
                Some(x) => { *x += (calc as u64); },
                None => { self.map.insert(p, (calc as u64)); }
            }
            //println!("<{}, {}> at {}: diff: {} calc: {}", min, max, p, diff, calc);
        }
        
        //match self.map.get_mut(&i) {
        //    Some(x) => { *x += calc; },
        //    None => { self.map.insert(i, calc); }
        //}
        //match self.map.get_mut(&j) {
        //    Some(x) => { *x += calc; },
        //    None => { self.map.insert(j, calc); }
        //}

        // e.g.
        // 1 and 16
        // diff = 15
        // then calc diffs for
        // 2,3,4....15
        //if diff > 1 {
        //    for k in 1..=(diff / 2) {
        //        // act, 2 and 15 will be the same
        //        // 1 from i/j and 14 from j/i
        //        println!("Int: {} {} {}", i, j, k);

        //        if i < j {
        //            let calc1 = (k * (k + 1)) / 2;
        //            let o = diff - k;
        //            let calc2 = (o * (o + 1)) / 2;
        //            self.map.insert(i + k, calc1 + calc2);
        //            self.map.insert(j - k, calc1 + calc2);
        //        } else {
        //            let calc1 = (k * (k + 1)) / 2;
        //            let o = diff - k;
        //            let calc2 = (o * (o + 1)) / 2;
        //            self.map.insert(j + k, calc1 + calc2);
        //            self.map.insert(i - k, calc1 + calc2);
        //        }
        //    }
        //}

        //println!("Atm: {:?}", self.map);
    }

    fn min(&self) {
        let mut min = u64::MAX;
        let mut min_pos: u32 = 0;

        for (pos, diff) in &self.map {
            if diff < &min { min = *diff; min_pos = *pos }
            println!("{} => {diff}", *pos);
        }

        let mut cost = 0;
        for val in &self.values {
            let diff = val.abs_diff(min_pos);
            cost += self.calc.get(&diff).unwrap();
        }
        
        println!("Result {} => {} with cost {}", min_pos, min, cost);
    }
    // ~1023sec to complete, ~17min
}
