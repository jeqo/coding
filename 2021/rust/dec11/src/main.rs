#[derive(Copy, Clone, Debug, Eq, Hash, PartialEq)]
struct Pos(u8,u8);

#[derive(Debug)]
struct Octopus {
    pos: Pos,
    energy: u8,
    has_flashed: bool,
    last_step: u8
}

impl Octopus {
    pub fn new(pos: Pos, energy: u8) -> Self {
        assert!(energy <= 9);
        Self {
            pos,
            energy,
            has_flashed: false,
            last_step: 0,
        }
    }

    fn increase(&mut self, step: u8) -> bool {
        if self.has_flashed && self.last_step == step {
            return false;
        }
        self.energy += 1;
        self.last_step = step;
        return self.ready_to_flash();
    }

    fn ready_to_flash(&self) -> bool {
        return self.energy > 9;
    }

    fn flash(&mut self) {
        if self.ready_to_flash() {
            self.has_flashed = true;
            self.energy = 0;
        }
    }
}

use std::collections::HashMap;

#[derive(Debug)]
struct Grid {
    g: HashMap<Pos, Octopus>,
}

impl Grid {
    pub fn new() -> Self {
        Self {
            g: HashMap::new(),
        }
    }

    fn add(&mut self, pos: Pos, energy: u8) {
        let oct = Octopus::new(pos, energy);
        self.g.insert(pos, oct);
    }
}

fn main() {
    println!("Dec11");
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_octopus_initial_state() {
        let oct = Octopus::new(Pos(0,0), 1);
        assert_eq!(oct.last_step, 0);
        assert_eq!(oct.has_flashed, false);
    }
    
    #[test]
    fn test_octopus_increase_normal() {
        let mut oct = Octopus::new(Pos(0,0), 1);
        oct.increase(1);
        assert_eq!(oct.last_step, 1);
        assert_eq!(oct.energy, 2);
        oct.increase(1);
        assert_eq!(oct.last_step, 1);
        assert_eq!(oct.energy, 3);
    }
    
    #[test]
    fn test_octopus_increase_til_ready() {
        let mut oct = Octopus::new(Pos(0,0), 9);
        assert_eq!(oct.ready_to_flash(), false);
        let ready = oct.increase(2);
        assert_eq!(oct.last_step, 2);
        assert_eq!(oct.energy, 10);
        assert_eq!(ready, true);
    }

    #[test]
    fn test_octopus_flash() {
        let mut oct = Octopus::new(Pos(0,0), 9);
        assert_eq!(oct.ready_to_flash(), false);
        let ready = oct.increase(2);
        assert_eq!(oct.last_step, 2);
        assert_eq!(oct.energy, 10);
        assert_eq!(ready, true);
        assert_eq!(oct.has_flashed, false);
        oct.flash();
        assert_eq!(oct.energy, 0);
        assert_eq!(oct.has_flashed, true);
    }

    #[test]
    fn test_grid_insert_octopus() {
        let mut g = Grid::new();
        g.add(Pos(0,0), 5);
        assert_eq!(g.g.len(), 1);
    }
}
