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

//          a b c d e f g
//          6 5 4 3 2 1 0
// 8 -> 127 1 1 1 1 1 1 1
// 9 -> 123 1 1 1 1 0 1 1
// 0 -> 118 1 1 1 0 1 1 1
// 6 -> 111 1 1 0 1 1 1 1
// 5 -> 107 1 1 0 1 0 1 1
// 2 -> 093 1 0 1 1 1 0 1
// 3 -> 091 1 0 1 1 0 1 1
// 7 -> 082 1 0 1 0 0 1 0
// 4 -> 058 0 1 1 1 0 1 0
// 1 -> 018 0 0 1 0 0 1 0

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
// 1 -> a,b -> a->c,b->f or a->f,b->c
// 7 -> a,c,f / 1010010
// 7 -> d,a,b -> d->a
// 4 -> b,c,d,f / 0111010
// 4 -> e,a,f,b -> e->b,f->d or e->d,f->b
// 8 -> a,b,c,d,e,f,g / 1111111
// 8 -> a,c,e,d,g,f,b -> g->e,c->g or g->g,c->e
// ? -> c,e,f,a,b,d -> missing: g, then only matching pattern: g->e, 9
// ? -> c,d,f,g,e,b -> missing: a, then only matching pattern: a->c, 6
// ? -> c,a,g,e,d,b -> missing: f, then only matching pattern: f->d, 0
// then map 5 char numbers
// and build output

use std::collections::HashMap;

#[derive(Debug)]
struct Numbers {
    patterns: HashMap<String, u8>,
    by_qty: HashMap<u8, Vec<usize>>,
    count_by_qty: HashMap<u8, u64>,
}
impl Numbers {
    fn new() -> Self {
        let patterns = HashMap::from([
            (String::from("abcefg"), 0),  // 118 // "1110111", // 0
            (String::from("cf"), 1),      // 018 // "0010010", // 1
            (String::from("acdeg"), 2),   // 093 // "1011101", // 2
            (String::from("acdfg"), 3),   // 091 // "1011011", // 3
            (String::from("bcdf"), 4),    // 058 // "0111010", // 4
            (String::from("abdfg"), 5),   // 107 // "1101011", // 5
            (String::from("abdefg"), 6),  // 111 // "1101111", // 6
            (String::from("acf"), 7),     // 082 // "1010010", // 7
            (String::from("abcdefg"), 8), // 127 // "1111111", // 8
            (String::from("abcdfg"), 9),  // 123 // "1111011", // 9
        ]);
        let by_qty = HashMap::from([
            (6, vec![0, 6, 9]),
            (2, vec![1]),
            (5, vec![2, 3, 5]),
            (4, vec![4]),
            (3, vec![7]),
            (7, vec![8]),
        ]);
        let count_by_qty = HashMap::from([(6, 0), (2, 0), (5, 0), (4, 0), (3, 0), (7, 0)]);
        Self {
            patterns,
            by_qty,
            count_by_qty,
        }
    }

    fn decode(&mut self, code: &str) -> u64 {
        let parts: Vec<&str> = code.trim().split(" | ").collect();
        assert!(parts.len() == 2);

        let mut signals: Vec<&str> = parts[0].split(' ').collect();
        signals.sort_by(|a,b| a.len().partial_cmp(&b.len()).unwrap());
        // println!("Signal: {:?}", signals);

        let digits: Vec<&str> = parts[1].split(' ').collect();
        // println!("Digits: {:?}", digits);

        // self.count_digits(digits);
        let mapping = self.find_map(signals);

        let value = self.decipher(mapping, digits);

        return value;
    }

    fn decipher(&self, mapping: HashMap<char, Vec<char>>, digits: Vec<&str>) -> u64 {
        //println!("Dec: Map: {:?} Dig: {:?}", mapping, digits);
        let mut nums = String::new();
        for dig in digits {
            let mut res = Vec::new();
            for c in dig.chars() {
                let m = mapping.get(&c).unwrap();
                res.push(m[0]);
            }
            res.sort();
            let txt: String = res.into_iter().collect();
            let num = self.patterns.get(&txt).unwrap();
            //println!("Sorted: {:?}", num);
            nums.push_str(&*num.to_string());
        }
        let num = nums.parse::<u64>().unwrap();
        //println!("Num: {:?}", num);
        return num
    }

    // alg: 1 -> 7 -> 4 -> 8 -> [ 9 -> 0 -> 6 ] -> [ 5 -> 2 -> 3 ]
    //                            unknown             unknown
    // a b c d e f g
    // 6 5 4 3 2 1 0
    //
    // 0 0 1 0 0 1 0 -> pos: 4, 1 ?
    // 1 0 1 0 0 1 0 -> pos: 6    x
    // 1 1 1 1 0 1 0 -> pos: 5, 3 ?
    // 1 1 1 1 1 1 1 -> pos: 2, 0 ?
    //               -> pos: 2    x then 0
    //               -> pos: 3    x then 5
    //               -> pos: 4    x then 1

    fn find_map(&self, signals: Vec<&str>) -> HashMap<char, Vec<char>>
    {
        
        let mut map = HashMap::new();
        map.insert('a', Vec::<char>::new());
        map.insert('b', Vec::<char>::new());
        map.insert('c', Vec::<char>::new());
        map.insert('d', Vec::<char>::new());
        map.insert('e', Vec::<char>::new());
        map.insert('f', Vec::<char>::new());
        map.insert('g', Vec::<char>::new());

        let mut six = Vec::new();
        let mut five = Vec::new();

        for s in signals {
            if (s.len() == 2) {
                for x in s.chars() {
                    let y = map.get_mut(&x).unwrap();
                    if y.len() < 1 {
                        y.push('c');
                        y.push('f');
                    }
                }
            }
            if (s.len() == 3) {
                for x in s.chars() {
                    let y = map.get_mut(&x).unwrap();
                    if y.len() < 2 {
                        y.push('a');
                    }
                }
            }
            if (s.len() == 4) {
                for x in s.chars() {
                    let y = map.get_mut(&x).unwrap();
                    if y.len() < 1 {
                        y.push('d');
                        y.push('b');
                    }
                }
            }
            if (s.len() == 7) {
                for x in s.chars() {
                    let y = map.get_mut(&x).unwrap();
                    //println!("7char: {}=>{:?}", x, y.len());
                    if y.len() < 1 {
                        y.push('e');
                        y.push('g');
                        //println!("Found: {:?}", y);
                    }
                }
            }

            if (s.len() == 6) {
                six.push(s);
            }
            if (s.len() == 5) {
                five.push(s);
            }
        }

        let mut a: Vec<char> = map.get_mut(&'a').unwrap().to_vec();
        let mut b: Vec<char> = map.get_mut(&'b').unwrap().to_vec();
        let mut c: Vec<char> = map.get_mut(&'c').unwrap().to_vec();
        let mut d: Vec<char> = map.get_mut(&'d').unwrap().to_vec();
        let mut e: Vec<char> = map.get_mut(&'e').unwrap().to_vec();
        let mut f: Vec<char> = map.get_mut(&'f').unwrap().to_vec();
        let mut g: Vec<char> = map.get_mut(&'g').unwrap().to_vec();

        //println!("map: {:?}", map);

        let keys: Vec<&String> = self.patterns.keys().collect();

        for s in six {
            let y: Vec<char> = s.chars().collect();
            let mut all = vec!['a', 'b', 'c', 'd', 'e', 'f', 'g'];
            all.retain(|&x| !y.contains(&x));
            let v = all.pop().unwrap();
            map.get_mut(&v).unwrap().retain(|x| {
                let pat = "abcdefg".replace(*x, "");
                let r = keys.contains(&&pat);
                //println!("Pat: {:?} {} for {}", pat, r, v);
                return r;
            });
            {
                let z = map.get(&v).unwrap();
                //println!("z:{:?}", z);
                if z.len() == 1 && (z[0] == 'e' || z[0] == 'g') {
                    let tt = z[0];
                    for (key, value) in map.iter_mut() {
                        if value.len() == 2 && value.contains(&tt) {
                            //println!("map kv: {:?}=>{:?} rm {}", key, value, tt);
                            value.retain(|x| *x != tt);
                        }
                    }
                }
            }
            {
                let z = map.get(&v).unwrap();
                //println!("z:{:?}", z);
                if z.len() == 1 && (z[0] == 'b' || z[0] == 'd') {
                    let tt = z[0];
                    for (key, value) in map.iter_mut() {
                        if value.len() == 2 && value.contains(&tt) {
                            //println!("map kv: {:?}=>{:?} rm {}", key, value, tt);
                            value.retain(|x| *x != tt);
                        }
                    }
                }
            }
            {
                let z = map.get(&v).unwrap();
                //println!("z:{:?}", z);
                if z.len() == 1 && (z[0] == 'c' || z[0] == 'f') {
                    let tt = z[0];
                    for (key, value) in map.iter_mut() {
                        if value.len() == 2 && value.contains(&tt) {
                            //println!("map kv: {:?}=>{:?} rm {}", key, value, tt);
                            value.retain(|x| *x != tt);
                        }
                    }
                }
            }
        }

        
        //println!("map: {:?}", map);
        return map;

    }

    fn count_digits(&mut self, digits: Vec<&str>) {
        for d in digits {
            match self.count_by_qty.get_mut(&(d.len() as u8)) {
                Some(x) => {
                    *x += 1;
                }
                None => {
                    panic!("unknown size!");
                }
            }
        }
    }
}

use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;

fn main() -> std::io::Result<()> {
    println!("Dec08");

    let mut nums = Numbers::new();

    // nums.decode(
    //    "fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb",
    //);

    //let path = "./../../dec08/test.txt";
    let path = "./../../dec08/input.txt";
    let f = File::open(path)?;
    let mut reader = BufReader::new(f);

    let mut sum = 0u64;

    loop {
        let mut line = String::new();
        let len = reader.read_line(&mut line)?;
    
        if len == 0 { println!("EOF"); break; }
        let num = nums.decode(line.as_str());
        println!("Num: {}", num);
        sum += num;
    }

    println!("Sum {:?}", sum);

    Ok(())
}
