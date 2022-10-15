use std::collections::HashMap;

fn main() {
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

    let input: Vec<u32> = vec![16,1,2,0,4,2,7,1,2,14];
    let mut map = HashMap::new(); 

    // find combinations of 2
    const POW: u32 = 2u32.pow(10);
    for i in 3..=POW {
        if i.count_ones() == 2 {
            let bin = format!("{i:010b}");
            let l = bin.find('1').unwrap();
            let r = bin.rfind('1').unwrap();
            println!("{i} => {bin} 1s at {l} and {r}");
            let diff = input[l].abs_diff(input[r]);
            println!("{i} => {bin} 1s at {l} and {r}, diff {diff}");
            match map.get_mut(&l) {
                Some(x) => { *x += diff; },
                None => { map.insert(l, diff); }
            }
            match map.get_mut(&r) {
                Some(x) => { *x += diff; },
                None => { map.insert(r, diff); }
            }
        }
    }
    
    let mut min = u32::MAX;
    let mut min_pos: usize = 11;

    for (pos, diff) in &map {
        if diff < &min { min = *diff; min_pos = *pos }
        println!("{} => {diff}", input[*pos]);
    }
        
    println!("Result {} => {}", input[min_pos], min);

}
