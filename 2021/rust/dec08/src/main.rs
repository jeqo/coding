// Numbers: (Segments, Qty)
// - Zero:  ({a,b,c, ,e,f,g},6)
//            1 1 1 0 1 1 1: 6,5,4,2,1,0: 64+32+16+4+2 = 118
// - One:   ({ , ,c, , ,f, },2)
//            0 0 1 0 0 1 0: 4,1: 16+2 = 18
// - Two:   ({a, ,c,d,e, ,g},5)
//            1 0 1 1 1 0 1: 6,4,3,2,0: 64+16+8+4+1 = 93
// - Three: ({a, ,c,d, ,f,g},5)
//            1 0 1 1 0 1 1: 6,4,3,1,0: 64+16+8+2+1 = 91
// - Four:  ({ ,b,c,d, ,f, },4)
//            0 1 1 1 0 1 0: 5,4,3,1: 32+16+8+2 = 58
// - Five:  ({a,b, ,d, ,f,g},5)
//            1 1 0 1 0 1 1: 6,5,3,1,0: 64+32+8+2+1 = 107
// - Six:   ({a,b, ,d,e,f,g},6)
//            1 1 0 1 1 1 1: 6,5,3,2,1,0: 64+32+8+4+2+1 = 111
// - Seven: ({a, ,c, , ,f, },3)
//            1 0 1 0 0 1 0: 6,4,1: 64+16+2 = 82
// - Eight: ({a,b,c,d,e,f,g},7)
//            1 1 1 1 1 1 1: 6,5,4,3,2,1,0: 127
// - Nine:  ({a,b,c,d, ,f,g},6)
//            1 1 1 1 0 1 1: 6,5,4,3,1,0: 123
//
// Qty -> Numbers
// 6 -> 0,6,9
// 2 -> 1
// 5 -> 2,3,5
// 4 -> 4
// 3 -> 7
// 7 -> 8
// 
// 1 -> c,f / 0010010
// 1 -> a,b -> a->c,b->f
// 7 -> a,c,f / 1010010
// 7 -> d,a,b -> d->a
// 4 -> b,c,d,f / 0111010
// 4 -> e,a,f,b -> e->b,f->d
// 8 -> a,b,c,d,e,f,g / 1111111
// 8 -> a,c,e,d,g,f,b -> g->e,c->g

// 1,7,4,8

// d->a,e->b,a->c,f->d,g->e,b->f,c->g
// 

use std::collections::HashMap;

#[derive(Debug)]
struct Numbers {
    patterns: [&'static str;10],
    by_qty: HashMap<u8, Vec<usize>>,
    count_by_qty: HashMap<u8, u64>,
}
impl Numbers {
    fn new() -> Self {
        let patterns = [
            "1110111",
            "0010010",
            "1011101",
            "1011011",
            "0111010",
            "1101011",
            "1101111", // 6 from 5
            "1010010",
            "1111111",
            "1111011", // 9 from 8
        ];
        let by_qty = HashMap::from([
            (6, vec![0,6,9]),
            (2, vec![1]),
            (5, vec![2,3,5]),
            (4, vec![4]),
            (3, vec![7]),
            (7, vec![8]),
        ]);
        let count_by_qty = HashMap::from([
            (6, 0),
            (2, 0),
            (5, 0),
            (4, 0),
            (3, 0),
            (7, 0),
        ]);
        Self {
            patterns,
            by_qty,
            count_by_qty,
        }
    }

    fn decode(&mut self, code: &str) {
        let parts: Vec<&str> = code.trim().split(" | ").collect();
        assert!(parts.len() == 2);

        let signals: Vec<&str> = parts[0].split(' ').collect();
        // println!("Signal: {:?}", signals);
        
        let digits: Vec<&str> = parts[1].split(' ').collect();
        // println!("Digits: {:?}", digits);

        // self.count_digits(digits);

    }

    fn find_map(&self, signals: Vec<&str>) -> HashMap<char, char> {
        
    }

    fn count_digits(&mut self, digits: Vec<&str>) {
        for d in digits {
            match self.count_by_qty.get_mut(&(d.len() as u8)) {
                Some(x) => { *x += 1; },
                None => { panic!("unknown size!"); }
            }
        }
    }
}

use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;

fn main() -> std::io::Result<()> {
    println!("Dec08");

    let mut nums = Numbers::new();

    // nums.decode("acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | 
    //  cdfeb fcadb cdfeb cdbaf");
    
    //let path = "./../../dec08/test.txt";
    let path = "./../../dec08/input.txt";
    let f = File::open(path)?;
    let mut reader = BufReader::new(f);

    loop {
        let mut line = String::new();
        let len = reader.read_line(&mut line)?;
        
        if len == 0 { println!("EOF"); break; }

        nums.decode(line.as_str());
    }

    println!("{:?}", nums);

    Ok(())
}
