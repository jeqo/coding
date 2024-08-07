#[derive(Copy, Clone, Debug, Eq, Hash, PartialEq)]
// x: row, y: col
struct Pos(usize,usize);

#[derive(Debug)]
struct Octopus {
    //pos: Pos,
    energy: u32,
    has_flashed: bool,
    last_step: u8
}

impl Octopus {
    //pub fn new(pos: Pos, energy: u32) -> Self {
    pub fn new(energy: u32) -> Self {
        assert!(energy <= 9);
        Self {
            //pos,
            energy,
            has_flashed: false,
            last_step: 0,
        }
    }

    fn increase(&mut self, step: u8) {
        if !self.has_flashed || self.last_step != step {
            self.energy += 1;
            self.last_step = step;
            self.has_flashed = false;
        }
    }

    fn is_ready_to_flash(&self) -> bool {
        return self.energy > 9;
    }
    
    fn is_about_to_be_ready(&self) -> bool {
        return self.energy == 9;
    }

    fn flash(&mut self) {
        if self.is_ready_to_flash() {
            self.has_flashed = true;
            self.energy = 0;
        }
    }
}

use std::collections::HashMap;

#[derive(Debug)]
struct Grid {
    side: usize,
    g: HashMap<Pos, Octopus>,
    index: Vec<Pos>,
}

impl Grid {
    pub fn new(side: usize) -> Self {
        Self {
            side,
            g: HashMap::new(),
            index: Vec::new(),
        }
    }

    fn add(&mut self, pos: Pos, energy: u32) {
        let oct = Octopus::new(energy);
        self.g.insert(pos, oct);
        self.index.push(pos);
    }

    fn step(&mut self, step: u8) -> u32 {
        return self.increase(&self.index.to_vec(), step);
    }

    fn increase(&mut self, pos_set: &Vec<Pos>, step: u8) -> u32 {
        let mut count = 0;
        for pos in pos_set {
            if let Some(oct) = self.g.get_mut(&pos) {
                oct.increase(step);
                if oct.is_ready_to_flash() {
                    oct.flash();
                    count += 1;
                    let adj = self.adjacents(pos);
                    count += self.increase(&adj, step);
                }
            }           
        }
        return count;
    }

    fn adjacents(&self, pos: &Pos) -> Vec<Pos> {
        let Pos(row, col) = *pos;
        let mut adj = Vec::new();

        if row >= 1 {
            if col >= 1 {
                adj.push(Pos(row-1, col-1));
            }
            adj.push(Pos(row-1, col));
            if col + 1 < self.side {
                adj.push(Pos(row-1, col+1));
            }
        }
        {
            if col >= 1 {
                adj.push(Pos(row, col-1));
            }
            if col + 1 < self.side {
                adj.push(Pos(row, col+1));
            }
        }
        if row + 1 < self.side {
            if col >= 1 {
                adj.push(Pos(row+1, col-1));
            }
            adj.push(Pos(row+1, col));
            if col + 1 < self.side {
                adj.push(Pos(row+1, col+1));
            }
        }

        return adj;
    }

    fn is_ready_to_explode(&self) -> bool {
        for pos in self.index.to_vec() {
            if let Some(oct) = self.g.get(&pos) {
                if !oct.is_about_to_be_ready() { return false; }
            }           
        }
        return true;
    }
    
    fn has_already_exploded(&self) -> bool {
        for pos in self.index.to_vec() {
            if let Some(oct) = self.g.get(&pos) {
                if oct.energy != 0 { return false; }
            }           
        }
        return true;
    }

    fn view(&self) -> String {
        let mut s = String::new();
        for i in 0..self.side {
            for j in 0..self.side {
                let oct = self.g.get(&Pos(i, j)).unwrap();
                s.push_str(&format!("{} ", oct.energy));
            }
            s.push_str(&format!("\n"));
        }
        return s;
    }

    fn print(&self) {
        print!("{}", self.view());
    }
}

use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;
fn main() -> std::io::Result<()> {
    println!("Dec11");

    //let path = "./../../dec11/test_0.txt";
    //let path = "./../../dec11/test_1.txt";
    let path = "./../../dec11/input.txt";
    
    let mut reader = BufReader::new(File::open(path)?);
    
    let mut reader_0 = BufReader::new(File::open(path)?);
    let side = reader_0.read_line(&mut String::new())?;

    let mut grid = Grid::new(side - 1);
    let mut i = 0;
    loop {
        let mut line = String::new();
        let len = reader.read_line(&mut line)?;
    
        if len == 0 { println!("EOF"); break; }

        let digits: Vec<u32> = line.trim().chars()
            .map(|x| x.to_digit(10).unwrap())
            .collect();

        for j in 0..digits.len() {
            grid.add(Pos(i, j), digits[j]);
        }
    
        //println!("{:?}", digits);
        i += 1;
    }
    
    println!("Grid @ 0");
    grid.print();
    println!();

    let first = grid.view();

    /*
    Part 1
    // let mut sum = 0;

    //for step in 1..3 { // test_0
    //for step in 1..11 { // test_1
    for step in 1..101 {
        sum += grid.step(step as u8);
        println!("Grid@{}", step);
        grid.print();
        println!();
    }
    println!("Sum: {}", sum);
    */

    /* Part 2*/
    let mut step = 1;
    let mut sum = 0;

    loop {
        sum += grid.step(step as u8);
        println!("Grid@{}", step);
        grid.print();
        println!();
        if grid.has_already_exploded() {
            println!("Ready to explode @ {}", step);
            break;
        }
        if first == grid.view() {
            println!("Infinite loop, not found!!");
            break;
        }
        step+=1;
    }
    
    println!("Sum: {}", sum);

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_octopus_initial_state() {
        //let oct = Octopus::new(Pos(0,0), 1);
        let oct = Octopus::new(1);
        assert_eq!(oct.last_step, 0);
        assert_eq!(oct.has_flashed, false);
    }
    
    #[test]
    fn test_octopus_increase_normal() {
        //let mut oct = Octopus::new(Pos(0,0), 1);
        let mut oct = Octopus::new(1);
        oct.increase(1);
        assert_eq!(oct.last_step, 1);
        assert_eq!(oct.energy, 2);
        oct.increase(1);
        assert_eq!(oct.last_step, 1);
        assert_eq!(oct.energy, 3);
    }
    
    #[test]
    fn test_octopus_increase_til_ready() {
        //let mut oct = Octopus::new(Pos(0,0), 9);
        let mut oct = Octopus::new(9);
        assert_eq!(oct.is_ready_to_flash(), false);
        oct.increase(2);
        assert_eq!(oct.last_step, 2);
        assert_eq!(oct.energy, 10);
        assert_eq!(oct.is_ready_to_flash(), true);
    }

    #[test]
    fn test_octopus_flash() {
        //let mut oct = Octopus::new(Pos(0,0), 9);
        let mut oct = Octopus::new(9);
        assert_eq!(oct.is_ready_to_flash(), false);
        oct.increase(2);
        assert_eq!(oct.last_step, 2);
        assert_eq!(oct.energy, 10);
        assert_eq!(oct.is_ready_to_flash(), true);
        assert_eq!(oct.has_flashed, false);
        
        oct.flash();
        assert_eq!(oct.energy, 0);
        assert_eq!(oct.has_flashed, true);

        oct.increase(2);
        assert_eq!(oct.last_step, 2);
        assert_eq!(oct.energy, 0);
        assert_eq!(oct.is_ready_to_flash(), false);
        assert_eq!(oct.has_flashed, true);
        
        oct.increase(3);
        assert_eq!(oct.last_step, 3);
        assert_eq!(oct.energy, 1);
        assert_eq!(oct.is_ready_to_flash(), false);
        assert_eq!(oct.has_flashed, false);
    }

    #[test]
    fn test_grid_insert_octopus() {
        let mut g = Grid::new(1);
        g.add(Pos(0,0), 5);
        assert_eq!(g.g.len(), 1);
    }
    
    #[test]
    fn test_grid_get_adj() {
        let g = Grid::new(3);
        let adj_0 = g.adjacents(&Pos(1,1));
        println!("Adj0: {:?}", adj_0);
        assert_eq!(adj_0.len(), 8);
        
        let adj_1 = g.adjacents(&Pos(0,0));
        println!("Adj1: {:?}", adj_1);
        assert_eq!(adj_1.len(), 3);

        let adj_2 = g.adjacents(&Pos(0,1));
        println!("Adj2: {:?}", adj_2);
        assert_eq!(adj_2.len(), 5);
    }
}
