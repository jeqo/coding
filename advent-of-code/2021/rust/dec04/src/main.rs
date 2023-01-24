use std::collections::HashMap;
#[derive(Debug)]
struct Position{
    row: usize, 
    col: usize,
}

impl Position {
    pub fn new(row: usize, col: usize) -> Self {
        Self {
            row,
            col,
        }
    }
}
#[derive(Debug)]
struct Player {
    id: usize,
    nums: HashMap<String, Position>,
    rows: [[bool; 5]; 5],
    cols: [[bool; 5]; 5],
    won: bool,
}

impl Player {
    pub fn new(id: usize, num_capacity: usize) -> Self {
        Self {
            id: id,
            nums: HashMap::with_capacity(num_capacity),
            rows: [[false; 5]; 5],
            cols: [[false; 5]; 5],
            won: false,
        }
    }

    fn add(&mut self, line: String, row: usize) {
        let v: Vec<&str> = line.split(" ").collect();
        let mut col = 0;
        for num in v {
            if !num.is_empty() {
                self.nums.insert(num.trim().to_string(), Position::new(row, col));
                col += 1;
            }
        }
    }

    fn printit(&self) {
       for i in 0..5 {
           println!("{:?}", self.rows[i]);
       }
    }

    fn play(&mut self, num: String) -> bool {
        if self.nums.contains_key(&num) && !self.won {
            //println!("{} found in {}", num, self.id);
            match self.nums.get(&num) {
                Some(Position{ row, col }) => { 
                    println!("{} => row:{} col:{}", self.id, row, col);
                    self.rows[*row][*col] = true;
                    self.cols[*col][*row] = true;
                    //let num_val = num.parse::<u32>().unwrap();
                    let mut all = true;
                    for a in self.rows[*row] {
                        if !a { all = false }
                    }
                    if all {
                        println!("{}", num);
                        self.won = true;
                        return true;
                    }
                    all = true;
                    for a in self.cols[*col] {
                        if !a { all = false }
                    }
                    if all {
                        println!("{}", num);
                        self.won = true;
                        return true;
                    }
                    return false;
                }
                None => {}
            }
        }
        return false;
    }
}

struct Game {
    numbers: Vec<String>,
    players: Vec<Player>,
}

impl Game {
    pub fn new(numbers: Vec<String>, players: Vec<Player>) -> Self {
        Self {
            numbers,
            players
        }
    }

    fn play(&mut self) {
        for num in &self.numbers {
            println!("Playing {}", num);
            for i in 0..=self.players.len() - 1 {
                let mut player = &mut self.players[i];
                if player.play(num.to_string()) {
                    println!("Player {} won!", player.id);
                    player.printit();
                    // return;
                }
            }
            println!();
        }
    }
}

use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;

fn main() -> std::io::Result<()> {
    println!("Dec04");

    
    //let path = "./../../dec04/test.txt";
    let path = "./../../dec04/input.txt";
    let f = File::open(path)?;
    let mut reader = BufReader::new(f);

    let mut first = String::new();
    reader.read_line(&mut first)?;

    let nums: Vec<String> = first.split(",").map(|x| x.trim().to_string()).collect();
    println!("{:?}", nums);

    let mut players: Vec<Player> = Vec::new();

    loop {
        let mut line = String::new();
        let len = reader.read_line(&mut line)?;    
        
        if len == 0 { println!("EOF"); break; }

        if len == 1 {
            let mut p = Player::new(players.len(), nums.len());
            let mut row0 = String::new();
            reader.read_line(&mut row0)?;    
            p.add(row0, 0);
            let mut row1 = String::new();
            reader.read_line(&mut row1)?;    
            p.add(row1, 1);
            let mut row2 = String::new();
            reader.read_line(&mut row2)?;    
            p.add(row2, 2);
            let mut row3 = String::new();
            reader.read_line(&mut row3)?;    
            p.add(row3, 3);
            let mut row4 = String::new();
            reader.read_line(&mut row4)?;    
            p.add(row4, 4);
            players.push(p);
        }
    }

    println!("Players {:?}", players.len());

    let mut game = Game::new(nums, players);

    game.play();

    Ok(())
}
