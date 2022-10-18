// Numbers: (Segments, Qty)
// - Zero:  ({a,b,c, ,e,f,g},6)
// - One:   ({ , ,c, , ,f, },2)
// - Two:   ({a, ,c,d,e, ,g},5)
// - Three: ({a, ,c,d, ,f,g},5)
// - Four:  ({ ,b,c,d, ,f, },4)
// - Five:  ({a,b, ,d, ,f,g},5)
// - Six:   ({a,b, ,d,e,f,g},6)
// - Seven: ({a, ,c, , ,f, },3)
// - Eight: ({a,b,c,d,e,f,g},7)
// - Nine:  ({a,b,c,d, ,f,g},6)
//
// Qty -> Numbers
// 6 -> 0,6,9
// 2 -> 1
// 5 -> 2,3,5
// 4 -> 4
// 3 -> 7
// 7 -> 8
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
            "abcefg",
            "cf",
            "acdeg",
            "acdfg",
            "bcdf",
            "abdfg",
            "abdefg",
            "acf",
            "abcdefg",
            "abcdfg",
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

        self.count_digits(digits);
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

    // nums.decode("acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf");
    
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
