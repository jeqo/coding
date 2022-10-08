use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;

// PART 02
fn main() -> std::io::Result<()>{
    println!("Hello, world!");
    // read input.txt
    let f = File::open("./../../dec01/input.txt")?;
    //let f = File::open("./../../dec01/test.txt")?;
    let mut reader = BufReader::new(f);

    let mut inc = 0;

    let max_size = 3;

    let mut window: [u32; 4] = [0; 4];
    let mut w_size: [u32; 4] = [0; 4];

    while true {
      let mut line = String::new();
      let len = reader.read_line(&mut line)?;
      println!("Line is {len} bytes long: {line}");
      if len <= 1 { break; }
      let depth: u32 = line.trim().parse().unwrap();
      
      if w_size[0] == 0 { 
        window[0] += depth;
        w_size[0] += 1;
        if window[2] > 0 {
          window[2] += depth;
          w_size[2] += 1;
        }
        if window[3] > 0 {
          window[3] += depth;
          w_size[3] += 1;
        }
      } else if w_size[1] == 0 {
        window[1] += depth;
        w_size[1] += 1;
        if window[3] > 0 {
          window[3] += depth;
          w_size[3] += 1;
        }
        if (window[0] > 0) {
          window[0] += depth;
          w_size[0] += 1;
        }
      } else if w_size[2] == 0 {
        window[2] += depth;
        w_size[2] += 1;
        if window[0] > 0 {
          window[0] += depth;
          w_size[0] += 1;
        }
        if window[1] > 0 {
          window[1] += depth;
          w_size[1] += 1;
        }
      } else if w_size[3] == 0 {
        window[3] += depth;
        w_size[3] += 1;
        if window[1] > 0 {
          window[1] += depth;
          w_size[1] += 1;
        }
        if window[2] > 0 {
          window[2] += depth;
          w_size[2] += 1;
        }
      }

      println!("{:?}", window);
      if w_size[0] == 3 && w_size[1] == 3 {
        if window[0] < window[1] { inc += 1; }
        w_size[0] = 0;
        window[0] = 0;
      }
      if w_size[1] == 3 && w_size[2] == 3 {
        if window[1] < window[2] { inc += 1; }
        w_size[1] = 0;
        window[1] = 0;
      }
      if w_size[2] == 3 && w_size[3] == 3 {
        if window[2] < window[3] { inc += 1; }
        w_size[2] = 0;
        window[2] = 0;
      }
      if w_size[3] == 3 && w_size[0] == 3 {
        if window[3] < window[0] { inc += 1; }
        w_size[3] = 0;
        window[3] = 0;
      }
    }

    println!("Depth increases: {inc}");

    Ok(())
}

/* PART 01
fn main() -> std::io::Result<()>{
    println!("Hello, world!");
    // read input.txt
    let f = File::open("./../../dec01/input.txt")?;
    //let f = File::open("./../../dec01/test.txt")?;
    let mut reader = BufReader::new(f);

    let mut prev = 0;
    let mut inc = 0;
    while true {
      let mut line = String::new();
      let len = reader.read_line(&mut line)?;
      println!("Line is {len} bytes long: {line}");
      if len <= 1 { break; }
      let depth: u32 = line.trim().parse().unwrap();
      if prev != 0 {
        if prev < depth {
            inc += 1;
            println!("Depth {depth} (increased)");
        } else {
            println!("Depth {depth} (decreased)");
        }
      }
      prev = depth;
    }

    println!("Depth increases: {inc}");

    Ok(())
}
*/
